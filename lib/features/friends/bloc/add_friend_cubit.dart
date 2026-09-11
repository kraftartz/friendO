import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart' show Cubit;
import 'package:friendo/core/db/database_session.dart'
    show DatabaseLockedError, DatabaseSession, DatabaseState;
import 'package:friendo/core/friends/friend_repository.dart'
    show FriendRepository;
import 'package:friendo/core/ids/new_id.dart' show newId;
import 'package:friendo/core/text/folded_text.dart' show foldedText;
import 'package:friendo/core/time/clock.dart' show Clock;
import 'package:friendo/features/friends/bloc/add_friend_state.dart'
    show AddFriendDraft;
import 'package:friendo/features/friends/bloc/refusal_words.dart'
    show refusalWords, somethingIsNotFilledIn;
import 'package:friendo/features/friends/cadence/cadence_choice.dart'
    show CadenceChoice, cadenceOfText, cadenceRefusal;
import 'package:friendo_domain/friendo_domain.dart'
    show Affinity, CivilDate, Fact, Friend, Meeting, Milestone, Note, NoteLabel;

/// Add a Friend: one form, held in memory, written in one call.
///
/// The form collects a name, a Civil Date, a Cadence and whatever else was
/// typed, and hands the lot to [FriendRepository] once. ADR-0016 needs a first
/// Meeting for the Friend to be placeable at all, and ADR-0022 puts the two
/// rows in one transaction, so a failure between them leaves nothing behind.
///
/// A lock clears the form and asks nothing. ADR-0011 hides private text from a
/// borrowed phone, and a half-written Friend is exactly that.
class AddFriendCubit extends Cubit<AddFriendDraft> {
  /// Open a fresh form over [friends].
  AddFriendCubit({
    required this.friends,
    required this.databases,
    this.clock = const Clock(),
  }) : super(const AddFriendDraft.locked()) {
    _whileOpen = databases.state.listen(_onDatabaseState);
  }

  /// The one writer of the Friend tables.
  final FriendRepository friends;

  /// The owner of the connection, which says whether a Profile is open.
  final DatabaseSession databases;

  /// Where every `now` comes from.
  final Clock clock;

  StreamSubscription<DatabaseState>? _whileOpen;

  /// Type the Friend's name.
  void typeName(String name) => emit(state.changing(name: name));

  /// Say which day the User last saw this Friend.
  void chooseLastMet(CivilDate day) => emit(state.changing(lastMet: day));

  /// Add a time of day to that first Meeting, or take one away with null.
  void chooseMetAtMinute(int? minute) => emit(
    state.changing(metAtMinute: minute, clearMetAtMinute: minute == null),
  );

  /// Take the Cadence a preset or a typed number names.
  void chooseCadence(CadenceChoice choice) =>
      emit(state.changing(choice: choice));

  /// Take a Cadence from the days field, and report a number it refuses.
  void typeCadence(String text) {
    final cadence = cadenceOfText(text);
    if (cadence == null) {
      emit(state.changing(cadenceRefusal: cadenceRefusal));

      return;
    }

    emit(state.changing(choice: CadenceChoice(cadence)));
  }

  /// Write a Topic, an Update or a Note about a Friend who does not exist yet.
  void writeNote({required NoteLabel label, required String body}) {
    if (body.trim().isEmpty) return;

    emit(
      state.changing(
        notes: [
          ...state.notes,
          Note(
            id: newId(),
            label: label,
            body: body.trim(),
            writtenOn: CivilDate.from(clock.now()),
          ),
        ],
      ),
    );
  }

  /// Take back a note written on this form.
  void dropNote(String noteId) => emit(
    state.changing(
      notes: [
        for (final note in state.notes)
          if (note.id != noteId) note,
      ],
    ),
  );

  /// Write a Fact: the User writes both halves and chooses the label.
  void writeFact({required String label, required String value}) {
    if (label.trim().isEmpty || value.trim().isEmpty) return;

    emit(
      state.changing(
        facts: [
          ...state.facts,
          Fact(id: newId(), label: label.trim(), value: value.trim()),
        ],
      ),
    );
  }

  /// Take back a Fact written on this form.
  void dropFact(String factId) => emit(
    state.changing(
      facts: [
        for (final fact in state.facts)
          if (fact.id != factId) fact,
      ],
    ),
  );

  /// Write a Milestone, yearly or one-off.
  void writeMilestone({
    required String label,
    required CivilDate onDate,
    bool repeatsYearly = false,
  }) {
    if (label.trim().isEmpty) return;

    emit(
      state.changing(
        milestones: [
          ...state.milestones,
          Milestone(
            id: newId(),
            label: label.trim(),
            onDate: onDate,
            repeatsYearly: repeatsYearly,
          ),
        ],
      ),
    );
  }

  /// Take back a Milestone written on this form.
  void dropMilestone(String milestoneId) => emit(
    state.changing(
      milestones: [
        for (final milestone in state.milestones)
          if (milestone.id != milestoneId) milestone,
      ],
    ),
  );

  /// Give this Friend the Affinity [label], or take it back.
  ///
  /// A label the Profile already holds is reused by its id, so two Friends
  /// given one Affinity share one row. A label nobody has written yet takes a
  /// fresh id, and the save writes it once.
  void chooseAffinity(String label) {
    final wanted = label.trim();
    if (wanted.isEmpty) return;

    final folded = foldedText(wanted);
    final held = state.affinities
        .where((affinity) => foldedText(affinity.label) == folded)
        .firstOrNull;
    if (held != null) {
      emit(
        state.changing(
          affinities: [
            for (final affinity in state.affinities)
              if (affinity.id != held.id) affinity,
          ],
        ),
      );

      return;
    }

    final known = state.knownAffinities
        .where((affinity) => foldedText(affinity.label) == folded)
        .firstOrNull;

    emit(
      state.changing(
        affinities: [
          ...state.affinities,
          known ?? Affinity(id: newId(), label: wanted),
        ],
      ),
    );
  }

  /// Write the Friend and their first Meeting, in one call.
  ///
  /// The refusals belong to the aggregate. This reports the one it raises and
  /// writes nothing, so a refused save leaves the form as the User left it.
  Future<void> save() async {
    final draft = state;
    if (draft.isLocked) throw const DatabaseLockedError();

    final friend = _friendOf(draft);
    if (friend == null) return;

    await friends.save(friend);
    if (isClosed) return;

    emit(state.changing(savedFriendId: friend.id));
  }

  @override
  Future<void> close() async {
    await _whileOpen?.cancel();

    return super.close();
  }

  Friend? _friendOf(AddFriendDraft draft) {
    try {
      return Friend.started(
        id: draft.friendId!,
        name: draft.name,
        cadence: draft.choice!.cadence,
        firstMeeting: Meeting(
          id: newId(),
          happenedOn: draft.lastMet!,
          happenedAtMinute: draft.metAtMinute,
        ),
        now: clock.now(),
        notes: draft.notes,
        facts: draft.facts,
        affinities: draft.affinities,
        milestones: draft.milestones,
      );
    } on ArgumentError catch (error) {
      emit(
        state.changing(
          refusal: refusalWords(error, whenUnknown: somethingIsNotFilledIn),
        ),
      );

      return null;
    }
  }

  void _onDatabaseState(DatabaseState open) {
    if (open != DatabaseState.open) {
      emit(const AddFriendDraft.locked());

      return;
    }

    unawaited(_startFresh());
  }

  Future<void> _startFresh() async {
    // The Profile can lock between the announcement and these two reads. A
    // lock is not a failure to report, so the read is dropped and the locked
    // state that the announcement already emitted stands.
    final List<Affinity> known;
    final List<String> labels;
    try {
      known = await friends.affinities();
      labels = await friends.factLabels();
    } on DatabaseLockedError {
      return;
    }
    if (isClosed || databases.stateNow != DatabaseState.open) return;

    emit(
      AddFriendDraft.fresh(
        now: clock.now(),
        friendId: newId(),
        knownAffinities: known,
        knownFactLabels: labels,
      ),
    );
  }
}
