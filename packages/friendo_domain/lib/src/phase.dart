import 'package:equatable/equatable.dart';

import 'cadence.dart';
import 'civil_date.dart';

/// How far a Friend has travelled through their current Cadence.
///
/// It is `0` at the last Meeting and `1` at the start of the Due Date. A value
/// above `1` means the Bead has arrived at the top and waits there.
///
/// The value is never negative. A Meeting cannot be in the future, so a reading
/// below zero means the phone moved zone or its clock changed. Zero is the
/// truthful answer in that case, and holding the rule here keeps every reader
/// free of the check.
final class Phase extends Equatable implements Comparable<Phase> {
  /// Build a Phase from a fraction of a Cadence.
  ///
  /// Throw [ArgumentError] when [value] is negative or not a number.
  factory Phase(double value) {
    if (value.isNaN || value < 0) {
      throw ArgumentError.value(value, 'value', 'must be zero or more');
    }
    return Phase._(value);
  }

  const Phase._(this.value);

  /// A Friend seen at this moment.
  static const Phase fresh = Phase._(0);

  final double value;

  /// True once the Bead has reached the top of its Orbit.
  ///
  /// This is not the same question as Overdue. The Bead reaches the top when
  /// the Due Date starts, and the Friend becomes Overdue only after that date
  /// ends. Overdue compares two Civil Dates. See [isOverdue].
  bool get hasArrived => value >= 1;

  @override
  int compareTo(Phase other) => value.compareTo(other.value);

  @override
  List<Object?> get props => [value];

  @override
  String toString() => 'phase ${value.toStringAsFixed(3)}';
}

/// The Due Date for a Friend last seen on [lastMet].
///
/// Whole calendar days are added, so the answer is the same day of the week no
/// matter which daylight-saving change falls in between.
CivilDate dueDateOf({required CivilDate lastMet, required Cadence cadence}) =>
    lastMet.addDays(cadence.days);

/// True when the Due Date has passed on [today].
///
/// A Friend is not Overdue on their own Due Date. That is the day the Meeting
/// is wanted, so it has not been missed until it ends.
bool isOverdue({required CivilDate today, required CivilDate dueAt}) =>
    today > dueAt;

/// Return how far a Friend has travelled through their current Cadence.
///
/// The travel starts at midnight of [lastMet], read in the zone the phone is in
/// now. Measuring from midnight, and not from a stored instant, gives a Bead
/// that creeps through the day instead of jumping once every 24 hours. A
/// 7-day Cadence would otherwise have seven places to stand.
///
/// A Meeting may carry a time of day. That time is not read here. Two Friends
/// seen on one day must draw at one place, and they would not if the Bead moved
/// according to whether the owner happened to type an hour.
///
/// [now] is a parameter and never a call to `DateTime.now()`. This package
/// holds no clock, so the caller supplies the current time. Every case is
/// therefore testable without waiting for one to arrive.
Phase phaseOf({
  required CivilDate lastMet,
  required Cadence cadence,
  required DateTime now,
}) {
  final travelled = now.difference(lastMet.startOfDayLocal()).inMicroseconds;
  final lap = cadence.duration.inMicroseconds;
  if (travelled <= 0) return Phase.fresh;
  return Phase._(travelled / lap);
}
