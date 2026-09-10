import 'package:equatable/equatable.dart';
import 'package:friendo_domain/friendo_domain.dart'
    show Cadence, CivilDate, Orbit, Standing;
// Aliased because this file names a Cadence's own reading `isOverdue` too,
// and a member wins over a top-level function of the same name.
import 'package:friendo_domain/friendo_domain.dart'
    as domain
    show dueDateOf, isOverdue, phaseOf;

/// What one Cadence would give a Friend, worked out and never stored.
///
/// ADR-0032 asks the picker to show the consequence before the User commits,
/// so this is the whole of what a preview says: the Due Date that Cadence
/// lands on, and the Standing it reads at [now].
final class CadencePreview extends Equatable {
  /// Work out the reading [cadence] gives a Friend last met on [lastMet].
  factory CadencePreview.of({
    required Cadence cadence,
    required CivilDate lastMet,
    required DateTime now,
  }) {
    final today = CivilDate.from(now);
    final dueAt = domain.dueDateOf(lastMet: lastMet, cadence: cadence);
    final passed = domain.isOverdue(today: today, dueAt: dueAt);

    return CadencePreview._(
      cadence: cadence,
      dueAt: dueAt,
      standing: Standing.of(
        phase: domain.phaseOf(lastMet: lastMet, cadence: cadence, now: now),
        isOverdue: passed,
      ),
      today: today,
    );
  }

  const CadencePreview._({
    required this.cadence,
    required this.dueAt,
    required this.standing,
    required this.today,
  });

  /// The Cadence this preview reads.
  final Cadence cadence;

  /// The Civil Date one Cadence after the last Meeting.
  final CivilDate dueAt;

  /// The Standing the Friend would hold at the `now` the preview was built on.
  final Standing standing;

  /// The Civil Date the preview was built on.
  final CivilDate today;

  /// Whether this Cadence puts the Due Date behind the day of the preview.
  bool get isOverdue => standing == Standing.overdue;

  /// Days from today to the Due Date. Negative once the Due Date has passed.
  int get daysUntilDue => dueAt.daysFrom(today);

  @override
  List<Object?> get props => [cadence, dueAt, standing, today];
}

/// The Cadence the picker holds, and the preset it reads as.
///
/// One value and not two. A preset is a way of setting the Cadence, so a typed
/// number and a tapped preset that mean the same number are one state, which
/// is what makes [CadenceChoice] worth having over a bare [Cadence].
final class CadenceChoice extends Equatable {
  /// Hold [cadence].
  const CadenceChoice(this.cadence);

  /// Hold the Cadence [orbit] puts forward.
  factory CadenceChoice.preset(Orbit orbit) =>
      CadenceChoice(orbit.recommendedCadence);

  /// The Cadence in force.
  final Cadence cadence;

  /// The preset that reads as chosen.
  ///
  /// Every Cadence falls in exactly one Orbit, so a typed number always lights
  /// a preset. There is no fourth, unlit state to draw.
  Orbit get preset => cadence.orbit;

  /// Whether [orbit]'s preset reads as chosen.
  bool holds(Orbit orbit) => preset == orbit;

  /// What this Cadence would give a Friend last met on [lastMet].
  CadencePreview previewFrom({
    required CivilDate lastMet,
    required DateTime now,
  }) => CadencePreview.of(cadence: cadence, lastMet: lastMet, now: now);

  @override
  List<Object?> get props => [cadence];

  @override
  String toString() => 'cadence choice of ${cadence.days} days';
}

/// The presets the picker offers: one per Orbit, in Orbit order.
///
/// The day counts come from the Orbit ranges, so ADR-0008 keeps its promise
/// that moving a boundary is a one-line change in the domain.
List<CadenceChoice> get cadencePresets => [
  for (final orbit in Orbit.values) CadenceChoice.preset(orbit),
];

/// The Cadence [text] names, or null when it names none.
///
/// `Cadence.ofDays` already refuses zero and below (ADR-0027), so this builds
/// one and reports the failure rather than writing a second rule.
Cadence? cadenceOfText(String text) {
  final days = int.tryParse(text.trim());
  if (days == null) return null;

  try {
    return Cadence.ofDays(days);
  } on ArgumentError {
    return null;
  }
}

/// The one sentence to show when [cadenceOfText] refuses.
const cadenceRefusal = 'A Cadence is a whole number of days, one or more.';
