import 'package:equatable/equatable.dart';
import 'package:friendo/features/friends/cadence/cadence_choice.dart'
    show CadenceChoice, CadencePreview;
import 'package:friendo_domain/friendo_domain.dart'
    show
        Affinity,
        Cadence,
        CivilDate,
        Fact,
        Friend,
        Meeting,
        Milestone,
        Note,
        NoteLabel,
        Orbit,
        Placing,
        Standing;

/// One Friend, read top to bottom, at one moment.
///
/// Every reading on one build takes the same [now]. Two reads could fall on
/// either side of midnight, and the header would then disagree with the
/// history below it.
///
/// A locked Notepad holds no Friend. It is a different state from a Friend
/// with nothing written about them, which is a real and calm page.
final class NotepadReading extends Equatable {
  /// Read [friend] at [now].
  factory NotepadReading.of({
    required Friend friend,
    required DateTime now,
    CadenceChoice? tuner,
    String? refusal,
    String draftNote = '',
    NoteLabel draftLabel = NoteLabel.topic,
  }) => NotepadReading._(
    friend: friend,
    now: now,
    tuner: tuner ?? CadenceChoice(friend.cadence),
    refusal: refusal,
    draftNote: draftNote,
    draftLabel: draftLabel,
  );

  const NotepadReading._({
    required this.friend,
    required this.now,
    required this.tuner,
    required this.refusal,
    this.draftNote = '',
    this.draftLabel = NoteLabel.topic,
  });

  /// A screen with nothing on it, because no Profile is open.
  const NotepadReading.locked()
    : friend = null,
      now = null,
      tuner = null,
      refusal = null,
      draftNote = '',
      draftLabel = NoteLabel.topic;

  /// A Friend the open Profile does not hold.
  const NotepadReading.gone()
    : friend = null,
      now = null,
      tuner = null,
      refusal = 'This Friend is no longer in the roster.',
      draftNote = '',
      draftLabel = NoteLabel.topic;

  /// The whole aggregate, or null while locked.
  final Friend? friend;

  /// The moment every reading on this build is worked out at.
  final DateTime? now;

  /// The Cadence the tuner shows, which is the held one until the User moves
  /// it.
  final CadenceChoice? tuner;

  /// Why the last write was refused.
  final String? refusal;

  /// The words half typed into the editor, held here and written nowhere.
  ///
  /// A lock clears it, because it is the private text ADR-0011 hides from a
  /// borrowed phone.
  final String draftNote;

  /// The label the editor is set to.
  final NoteLabel draftLabel;

  /// Whether no Profile is open.
  bool get isLocked => friend == null && refusal == null;

  /// The Friend's name, or the empty string while there is no Friend.
  String get name => friend?.name ?? '';

  /// The seed the Avatar is drawn from.
  String get avatarSeed => friend?.id ?? '';

  /// Where this Friend stands at [now].
  Placing? get placing => friend?.placing(now: now!);

  /// The Standing the header draws.
  Standing? get standing => placing?.standing;

  /// The Orbit the Friend travels.
  Orbit? get orbit => friend?.cadence.orbit;

  /// The Cadence the Friend is held on, which the tuner may not yet match.
  Cadence? get cadence => friend?.cadence;

  /// The Civil Date this build reads as today.
  CivilDate? get today => now == null ? null : CivilDate.from(now!);

  /// Every Meeting, newest first.
  ///
  /// The aggregate already orders them, so this is the aggregate's own order
  /// and not a second sort with a second answer.
  List<Meeting> get meetings => friend?.meetings ?? const [];

  /// The writing under one label, newest first.
  List<Note> notesLabelled(NoteLabel label) {
    final held = [
      for (final note in friend?.notes ?? const <Note>[])
        if (note.label == label) note,
    ]..sort(_newestNoteFirst);

    return List.unmodifiable(held);
  }

  /// The Topics waiting for this Friend.
  List<Note> get topics => notesLabelled(NoteLabel.topic);

  /// The Updates about this Friend's life.
  List<Note> get updates => notesLabelled(NoteLabel.update);

  /// The plain Notes about this Friend.
  List<Note> get notes => notesLabelled(NoteLabel.note);

  /// The standing facts about this Friend.
  List<Fact> get facts => friend?.facts ?? const [];

  /// The days in this Friend's life worth coming back to.
  List<Milestone> get milestones => friend?.milestones ?? const [];

  /// What this Friend is into.
  List<Affinity> get affinities => friend?.affinities ?? const [];

  /// Whether the delete on a Meeting may be offered.
  bool get canDropMeeting => friend?.canDropMeeting ?? false;

  /// What the tuner's Cadence would give this Friend, at [now].
  CadencePreview? get tunerPreview =>
      tuner?.previewFrom(lastMet: friend!.lastMet, now: now!);

  /// Whether the tuner holds a Cadence the Friend is not on yet.
  bool get tunerHasMoved => tuner?.cadence != friend?.cadence;

  /// Days from today to [day]. Negative once the day has passed.
  int daysUntil(CivilDate day) => day.daysFrom(today!);

  /// Copy the reading, changing the fields given.
  NotepadReading changing({
    CadenceChoice? tuner,
    String? refusal,
    String? draftNote,
    NoteLabel? draftLabel,
  }) => NotepadReading._(
    friend: friend,
    now: now,
    tuner: tuner ?? this.tuner,
    refusal: refusal,
    draftNote: draftNote ?? this.draftNote,
    draftLabel: draftLabel ?? this.draftLabel,
  );

  @override
  List<Object?> get props => [
    friend,
    now,
    tuner,
    refusal,
    draftNote,
    draftLabel,
  ];
}

int _newestNoteFirst(Note a, Note b) {
  final byDate = b.writtenOn.compareTo(a.writtenOn);

  return byDate != 0 ? byDate : b.id.compareTo(a.id);
}
