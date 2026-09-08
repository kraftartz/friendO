import 'package:equatable/equatable.dart';

/// One of the three tracks a Bead travels.
///
/// The name is a bucket and not a size. Radii belong to the Dial. See
/// ADR-0008 and ADR-0014.
enum Orbit { inner, middle, outer }

/// How often the owner wants to see a Friend, in whole days.
///
/// Whole days, because the Due Date is a Civil Date and adding a part of a day
/// to a calendar day means nothing. The owner picks "every 30 days", never
/// "every 30 days and 4 hours".
///
/// The value is positive. A zero Cadence would divide by zero in [Phase], and a
/// negative one would reverse the scale so that a fresh Meeting reads as
/// Overdue. Both are rejected here, once, so that no later function needs to
/// guard against them.
///
/// See ADR-0008 and ADR-0027.
final class Cadence extends Equatable implements Comparable<Cadence> {
  /// Build a Cadence of [days].
  ///
  /// Throw [ArgumentError] when [days] is zero or negative.
  factory Cadence.ofDays(int days) {
    if (days <= 0) {
      throw ArgumentError.value(days, 'days', 'must be one or more');
    }
    return Cadence._(days);
  }

  const Cadence._(this.days);

  final int days;

  /// The same length as a [Duration], for arithmetic that needs one.
  Duration get duration => Duration(days: days);

  /// Which Orbit a Friend on this Cadence travels.
  ///
  /// The boundaries are a display choice and they move without a migration,
  /// because no row stores an Orbit.
  Orbit get orbit => switch (days) {
    <= 14 => Orbit.inner,
    <= 60 => Orbit.middle,
    _ => Orbit.outer,
  };

  @override
  int compareTo(Cadence other) => days.compareTo(other.days);

  @override
  List<Object?> get props => [days];

  @override
  String toString() => 'every $days days';
}
