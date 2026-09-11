import 'package:equatable/equatable.dart';
import 'package:friendo/features/friends/cadence/cadence_choice.dart'
    show CadenceChoice, CadencePreview;
import 'package:friendo_domain/friendo_domain.dart'
    show Affinity, CivilDate, Fact, Milestone, Note, Orbit;

/// What Add a Friend holds while the User fills it in.
///
/// Nothing here reaches the database until the save. There is no draft row and
/// no half-made Friend, so the whole of an abandoned form is this object going
/// out of scope.
///
/// [isLocked] is a state of its own and not an empty form. A locked screen
/// offers no next action, and a form with nothing typed offers several.
final class AddFriendDraft extends Equatable {
  /// A fresh form, dated today and set to the middle preset.
  factory AddFriendDraft.fresh({
    required DateTime now,
    required String friendId,
    List<Affinity> knownAffinities = const [],
    List<String> knownFactLabels = const [],
  }) => AddFriendDraft(
    now: now,
    friendId: friendId,
    lastMet: CivilDate.from(now),
    choice: CadenceChoice.preset(Orbit.middle),
    knownAffinities: knownAffinities,
    knownFactLabels: knownFactLabels,
  );

  /// Hold every field.
  const AddFriendDraft({
    required this.now,
    required this.lastMet,
    required this.choice,
    required this.friendId,
    this.name = '',
    this.metAtMinute,
    this.cadenceRefusal,
    this.notes = const [],
    this.facts = const [],
    this.milestones = const [],
    this.affinities = const [],
    this.knownAffinities = const [],
    this.knownFactLabels = const [],
    this.refusal,
    this.savedFriendId,
    this.isLocked = false,
  });

  /// A screen with nothing on it, because no Profile is open.
  const AddFriendDraft.locked()
    : friendId = null,
      now = null,
      lastMet = null,
      choice = null,
      name = '',
      metAtMinute = null,
      cadenceRefusal = null,
      notes = const [],
      facts = const [],
      milestones = const [],
      affinities = const [],
      knownAffinities = const [],
      knownFactLabels = const [],
      refusal = null,
      savedFriendId = null,
      isLocked = true;

  /// The id the Friend will hold, settled when the form opens.
  ///
  /// The Avatar is drawn from it, so the picture the User sees while they type
  /// is the picture the roster gets. Null while locked.
  final String? friendId;

  /// The moment every reading on this build is worked out at. Null while
  /// locked.
  final DateTime? now;

  /// The name as the User typed it, untrimmed.
  final String name;

  /// The day the User last saw this Friend. It becomes the first Meeting.
  final CivilDate? lastMet;

  /// The optional time of day on that first Meeting, in minutes past
  /// midnight.
  final int? metAtMinute;

  /// The Cadence in force, and the preset it reads as.
  final CadenceChoice? choice;

  /// The sentence to draw when the typed Cadence names none.
  final String? cadenceRefusal;

  /// The Topics, Updates and Notes written before the Friend exists.
  final List<Note> notes;

  /// The Facts written before the Friend exists.
  final List<Fact> facts;

  /// The Milestones written before the Friend exists.
  final List<Milestone> milestones;

  /// The Affinities this Friend is being given.
  final List<Affinity> affinities;

  /// Every Affinity the Profile already holds, to choose from.
  final List<Affinity> knownAffinities;

  /// The Fact labels the Profile has already used.
  final List<String> knownFactLabels;

  /// Why the last save was refused, in a sentence naming the field to fix.
  final String? refusal;

  /// The id of the Friend the save wrote, once it has been written.
  final String? savedFriendId;

  /// Whether no Profile is open.
  final bool isLocked;

  /// What the chosen Cadence gives this Friend, at [now].
  CadencePreview? get preview =>
      choice?.previewFrom(lastMet: lastMet!, now: now!);

  /// Whether the User has written anything that abandoning would lose.
  ///
  /// The date and the Cadence carry a default each, so neither on its own
  /// counts as typing. Asking about them would be asking about nothing.
  bool get hasTyping =>
      name.trim().isNotEmpty ||
      notes.isNotEmpty ||
      facts.isNotEmpty ||
      milestones.isNotEmpty ||
      affinities.isNotEmpty;

  /// Whether the form has been saved and the screen may close.
  bool get isSaved => savedFriendId != null;

  /// Copy the draft, changing the fields given.
  ///
  /// A null argument keeps the held value, so [refusal], [cadenceRefusal] and
  /// [metAtMinute] each take a flag to clear them.
  AddFriendDraft changing({
    String? name,
    CivilDate? lastMet,
    int? metAtMinute,
    bool clearMetAtMinute = false,
    CadenceChoice? choice,
    String? cadenceRefusal,
    List<Note>? notes,
    List<Fact>? facts,
    List<Milestone>? milestones,
    List<Affinity>? affinities,
    List<Affinity>? knownAffinities,
    List<String>? knownFactLabels,
    String? refusal,
    String? savedFriendId,
  }) => AddFriendDraft(
    now: now,
    friendId: friendId,
    name: name ?? this.name,
    lastMet: lastMet ?? this.lastMet,
    metAtMinute: clearMetAtMinute ? null : (metAtMinute ?? this.metAtMinute),
    choice: choice ?? this.choice,
    cadenceRefusal: cadenceRefusal,
    notes: notes ?? this.notes,
    facts: facts ?? this.facts,
    milestones: milestones ?? this.milestones,
    affinities: affinities ?? this.affinities,
    knownAffinities: knownAffinities ?? this.knownAffinities,
    knownFactLabels: knownFactLabels ?? this.knownFactLabels,
    refusal: refusal,
    savedFriendId: savedFriendId ?? this.savedFriendId,
  );

  @override
  List<Object?> get props => [
    friendId,
    now,
    name,
    lastMet,
    metAtMinute,
    choice,
    cadenceRefusal,
    notes,
    facts,
    milestones,
    affinities,
    knownAffinities,
    knownFactLabels,
    refusal,
    savedFriendId,
    isLocked,
  ];
}
