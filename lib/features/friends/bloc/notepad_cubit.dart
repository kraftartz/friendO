import 'dart:async';

import 'package:flutter/widgets.dart'
    show AppLifecycleState, WidgetsBinding, WidgetsBindingObserver;
import 'package:flutter_bloc/flutter_bloc.dart' show Cubit;
import 'package:friendo/core/db/database_session.dart'
    show DatabaseLockedError, DatabaseSession, DatabaseState;
import 'package:friendo/core/friends/friend_repository.dart'
    show FriendRepository;
import 'package:friendo/core/ids/new_id.dart' show newId;
import 'package:friendo/core/time/civil_date_change.dart' show CivilDateChange;
import 'package:friendo/core/time/clock.dart' show Clock;
import 'package:friendo/features/friends/bloc/notepad_state.dart'
    show NotepadReading;
import 'package:friendo/features/friends/cadence/cadence_choice.dart'
    show CadenceChoice, cadenceOfText, cadenceRefusal;
import 'package:friendo_domain/friendo_domain.dart'
    show CivilDate, Fact, Friend, Meeting, Milestone, Note, NoteLabel;

/// The sentence for each refusal the aggregate raises on this screen.
String notepadRefusalWords(ArgumentError error) => switch (error.name) {
  'meeting.happenedOn' =>
    'A Meeting happens on today or an earlier day. Pick a day that has '
        'already come.',
  'body' => 'A Topic, an Update or a Note needs some text.',
  'label' => 'A Fact and a Milestone each need a label.',
  'value' => 'A Fact needs a value.',
  'name' => 'A Friend needs a name.',
  _ => 'That change was refused.',
};

/// The Friend Notepad: one Friend, loaded whole and saved whole.
///
/// The screen writes, so it takes the aggregate rather than a read model
/// (ADR-0022). Every change is a call on the Friend and one save, which keeps
/// the rules that span rows in the domain and leaves one write path for
/// `core/reminders/` to watch.
///
/// This screen calls no scheduler. It writes, and the reminder follows.
class NotepadCubit extends Cubit<NotepadReading> with WidgetsBindingObserver {
  /// Open the Notepad on [friendId].
  NotepadCubit({
    required this.friendId,
    required this.friends,
    required this.databases,
    required this.dayChange,
    this.clock = const Clock(),
  }) : super(const NotepadReading.locked()) {
    WidgetsBinding.instance.addObserver(this);
    _whileOpen = databases.state.listen(_onDatabaseState);
  }

  /// The Friend this screen reads.
  final String friendId;

  /// The one reader and writer of the Friend tables.
  final FriendRepository friends;

  /// The owner of the connection, which says whether a Profile is open.
  final DatabaseSession databases;

  /// The announcement that the local Civil Date has turned.
  final CivilDateChange dayChange;

  /// Where every `now` comes from.
  final Clock clock;

  StreamSubscription<DatabaseState>? _whileOpen;
  StreamSubscription<void>? _untilMidnight;

  /// Read the Friend again, on one fresh `now`.
  Future<void> readAgain() async {
    if (databases.stateNow != DatabaseState.open) return;

    final Friend? friend;
    try {
      friend = await friends.load(friendId);
    } on DatabaseLockedError {
      return;
    }
    if (isClosed || databases.stateNow != DatabaseState.open) return;

    if (friend == null) {
      emit(const NotepadReading.gone());

      return;
    }

    // A read of the same Friend keeps what the User has half typed and half
    // tuned. A read that arrives on a different Friend keeps neither, because
    // neither belongs to them.
    final same = state.friend?.id == friend.id;

    emit(
      NotepadReading.of(
        friend: friend,
        now: clock.now(),
        tuner: same ? state.tuner : null,
        draftNote: same ? state.draftNote : '',
        draftLabel: same ? state.draftLabel : NoteLabel.topic,
      ),
    );
  }

  /// Type the words of a Topic, an Update or a Note. Nothing is written yet.
  void typeNote(String body) => emit(state.changing(draftNote: body));

  /// Choose which of the three the editor is writing.
  void chooseNoteLabel(NoteLabel label) =>
      emit(state.changing(draftLabel: label));

  /// Write what the editor holds, dated today, and empty the editor.
  Future<void> writeNote() async {
    final draft = state;
    if (draft.draftNote.trim().isEmpty) return;

    await _change(
      (friend) => friend.copyWith(
        notes: [
          ...friend.notes,
          Note(
            id: newId(),
            label: draft.draftLabel,
            body: draft.draftNote,
            writtenOn: CivilDate.from(clock.now()),
          ),
        ],
      ),
    );
    if (isClosed) return;

    emit(state.changing(draftNote: ''));
  }

  /// Move a piece of writing to another label.
  ///
  /// One field, and nothing else about the record. ADR-0017 keeps the three as
  /// labels on one kind of record, so there is nothing to convert.
  Future<void> relabelNote(String noteId, NoteLabel label) =>
      _changeNote(noteId, (note) => _noteOf(note, label: label));

  /// Change the words of a piece of writing, and nothing else.
  Future<void> editNote(String noteId, String body) =>
      _changeNote(noteId, (note) => _noteOf(note, body: body));

  /// Take a piece of writing off this Friend.
  Future<void> dropNote(String noteId) => _change(
    (friend) => friend.copyWith(
      notes: [
        for (final note in friend.notes)
          if (note.id != noteId) note,
      ],
    ),
  );

  /// Write a Fact about this Friend.
  Future<void> writeFact({required String label, required String value}) =>
      _change(
        (friend) => friend.copyWith(
          facts: [
            ...friend.facts,
            Fact(id: newId(), label: label, value: value),
          ],
        ),
      );

  /// Take a Fact off this Friend.
  Future<void> dropFact(String factId) => _change(
    (friend) => friend.copyWith(
      facts: [
        for (final fact in friend.facts)
          if (fact.id != factId) fact,
      ],
    ),
  );

  /// Write a Milestone, yearly or one-off.
  Future<void> writeMilestone({
    required String label,
    required CivilDate onDate,
    bool repeatsYearly = false,
  }) => _change(
    (friend) => friend.copyWith(
      milestones: [
        ...friend.milestones,
        Milestone(
          id: newId(),
          label: label,
          onDate: onDate,
          repeatsYearly: repeatsYearly,
        ),
      ],
    ),
  );

  /// Take a Milestone off this Friend.
  Future<void> dropMilestone(String milestoneId) => _change(
    (friend) => friend.copyWith(
      milestones: [
        for (final milestone in friend.milestones)
          if (milestone.id != milestoneId) milestone,
      ],
    ),
  );

  /// Log a Meeting. Everything beyond the day is optional.
  ///
  /// It writes one Meeting and clears nothing. ADR-0017 says the app clears no
  /// Topic by itself, and this is the call a later reader would improve.
  Future<void> logMeeting({
    CivilDate? on,
    int? atMinute,
    String? place,
    int? lengthInMinutes,
    String? feeling,
    String? recap,
  }) {
    final now = clock.now();

    return _change(
      (friend) => friend.logMeeting(
        Meeting(
          id: newId(),
          happenedOn: on ?? CivilDate.from(now),
          happenedAtMinute: atMinute,
          place: place,
          lengthInMinutes: lengthInMinutes,
          feeling: feeling,
          recap: recap,
        ),
        now: now,
      ),
    );
  }

  /// Correct a Meeting already logged.
  Future<void> amendMeeting(Meeting meeting) =>
      _change((friend) => friend.amendMeeting(meeting, now: clock.now()));

  /// Take a Meeting off this Friend.
  ///
  /// The aggregate keeps the last one. The screen reads
  /// [NotepadReading.canDropMeeting] and offers no control rather than
  /// offering one that fails.
  Future<void> dropMeeting(String meetingId) =>
      _change((friend) => friend.dropMeeting(meetingId));

  /// Move the tuner without writing anything.
  void moveTuner(CadenceChoice choice) => emit(state.changing(tuner: choice));

  /// Move the tuner from the days field, and report a number it refuses.
  void typeCadence(String text) {
    final cadence = cadenceOfText(text);
    if (cadence == null) {
      emit(state.changing(refusal: cadenceRefusal));

      return;
    }

    emit(state.changing(tuner: CadenceChoice(cadence)));
  }

  /// Write the tuner's Cadence, and nothing else.
  ///
  /// ADR-0032: the Due Date moves and the last Meeting stays where it is. The
  /// reminder follows through `core/reminders/`, which watches this write.
  Future<void> saveCadence() {
    final choice = state.tuner;
    if (choice == null) return Future<void>.value();

    return _change((friend) => friend.copyWith(cadence: choice.cadence));
  }

  /// Delete this Friend, with their Meetings, Notes, Facts, Milestones and
  /// Affinity links.
  ///
  /// The Affinity labels survive, because they belong to the Profile.
  Future<void> deleteFriend() async {
    await friends.delete(friendId);
    if (isClosed) return;

    emit(const NotepadReading.gone());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(readAgain());
  }

  @override
  Future<void> close() async {
    WidgetsBinding.instance.removeObserver(this);
    await _untilMidnight?.cancel();
    await _whileOpen?.cancel();

    return super.close();
  }

  Note _noteOf(Note note, {NoteLabel? label, String? body}) => Note(
    id: note.id,
    label: label ?? note.label,
    body: body ?? note.body,
    writtenOn: note.writtenOn,
    resolvedOn: note.resolvedOn,
  );

  Future<void> _changeNote(String noteId, Note Function(Note note) change) =>
      _change(
        (friend) => friend.copyWith(
          notes: [
            for (final note in friend.notes)
              if (note.id == noteId) change(note) else note,
          ],
        ),
      );

  /// Load the Friend whole, change them, save them whole, and read again.
  ///
  /// A refusal is the aggregate's. It is reported and nothing is written.
  Future<void> _change(Friend Function(Friend friend) change) async {
    final friend = await friends.load(friendId);
    if (friend == null || isClosed) return;

    final Friend changed;
    try {
      changed = change(friend);
    } on ArgumentError catch (error) {
      emit(state.changing(refusal: notepadRefusalWords(error)));

      return;
    }

    await friends.save(changed);
    if (isClosed) return;

    await readAgain();
  }

  void _onDatabaseState(DatabaseState open) {
    if (open == DatabaseState.open) {
      _untilMidnight ??= dayChange.changes.listen(
        (_) => unawaited(readAgain()),
      );
      unawaited(readAgain());

      return;
    }

    unawaited(_untilMidnight?.cancel());
    _untilMidnight = null;
    emit(const NotepadReading.locked());
  }
}
