import 'package:equatable/equatable.dart';

import 'cadence.dart';
import 'civil_date.dart';
import 'phase.dart';
import 'standing.dart';

/// One Friend, reduced to what the Dial and the Priority Order need.
///
/// Two facts are stored, the Cadence and the last Meeting date. Everything else
/// here is worked out on read, so nothing can fall out of step with the rows.
final class Placing extends Equatable {
  /// Work out one Friend's place from the two stored facts.
  factory Placing({
    required String friendId,
    required CivilDate lastMet,
    required Cadence cadence,
    required DateTime now,
  }) {
    final dueAt = dueDateOf(lastMet: lastMet, cadence: cadence);
    final overdue = isOverdue(today: CivilDate.from(now), dueAt: dueAt);
    final phase = phaseOf(lastMet: lastMet, cadence: cadence, now: now);
    return Placing._(
      friendId: friendId,
      cadence: cadence,
      dueAt: dueAt,
      phase: phase,
      standing: Standing.of(phase: phase, isOverdue: overdue),
    );
  }

  const Placing._({
    required this.friendId,
    required this.cadence,
    required this.dueAt,
    required this.phase,
    required this.standing,
  });

  final String friendId;
  final Cadence cadence;
  final CivilDate dueAt;
  final Phase phase;
  final Standing standing;

  bool get overdue => standing == Standing.overdue;

  @override
  List<Object?> get props => [friendId, cadence, dueAt, phase, standing];
}

/// The single ranking of every Friend, held as its two groups.
///
/// The two groups rank by different keys, so they are kept apart rather than
/// flattened into one comparator with a branch inside it. "Overdue Friends come
/// first" then holds because of the shape of this type, and no test has to
/// guard it.
///
/// See ADR-0009 and ADR-0028.
final class PriorityOrder extends Equatable {
  /// Split [placings] into the two groups and rank each by its own key.
  factory PriorityOrder(Iterable<Placing> placings) {
    final overdue = <Placing>[];
    final onTrack = <Placing>[];
    for (final placing in placings) {
      (placing.overdue ? overdue : onTrack).add(placing);
    }
    overdue.sort((a, b) => a.dueAt.compareTo(b.dueAt));
    onTrack.sort((a, b) => b.phase.compareTo(a.phase));
    return PriorityOrder._(
      overdue: List.unmodifiable(overdue),
      onTrack: List.unmodifiable(onTrack),
    );
  }

  const PriorityOrder._({required this.overdue, required this.onTrack});

  /// Overdue Friends, the oldest Due Date first. This answers "who became
  /// Overdue first".
  final List<Placing> overdue;

  /// The rest, the highest Phase first. This answers "who is closest to due".
  final List<Placing> onTrack;

  /// Every Friend in one ranking, Overdue first.
  List<Placing> get all => List.unmodifiable([...overdue, ...onTrack]);

  /// The Friend to see next, or null when there is no Friend at all.
  Placing? get next => overdue.isNotEmpty
      ? overdue.first
      : (onTrack.isNotEmpty ? onTrack.first : null);

  /// How many Friends stand in each Standing.
  DialCounts get counts =>
      DialCounts.from(all.map((placing) => placing.standing));

  @override
  List<Object?> get props => [overdue, onTrack];
}
