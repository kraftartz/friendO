import 'package:equatable/equatable.dart';

/// A span of Cadence days, closed at the start and open at the end when
/// [last] is null.
final class DayRange extends Equatable {
  const DayRange({required this.first, this.last});

  /// The shortest Cadence the range holds, in days.
  final int first;

  /// The longest Cadence the range holds, in days. Null when the range runs
  /// on with no end.
  final int? last;

  bool holds(int days) {
    final last = this.last;

    return days >= first && (last == null || days <= last);
  }

  @override
  List<Object?> get props => [first, last];

  @override
  String toString() =>
      last == null ? '$first days and up' : '$first-$last days';
}

/// One of the three tracks a Bead travels.
///
/// The name is a bucket and not a size. Radii belong to the Dial. See
/// ADR-0008 and ADR-0014.
///
/// Each Orbit owns the range of Cadence days that belongs to it, and the
/// boundaries live here alone. ADR-0008 promises that moving one is a one-line
/// change that touches no stored data, which holds only while no second copy
/// of a boundary exists, in SQL or anywhere else.
enum Orbit {
  inner(DayRange(first: 1, last: 14)),
  middle(DayRange(first: 15, last: 60)),
  outer(DayRange(first: 61));

  const Orbit(this.cadenceDays);

  /// The Cadences, in days, that put a Friend on this Orbit.
  final DayRange cadenceDays;

  /// The Orbit whose range holds [days].
  static Orbit of(int days) =>
      values.firstWhere((orbit) => orbit.cadenceDays.holds(days));
}

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
  Orbit get orbit => Orbit.of(days);

  @override
  int compareTo(Cadence other) => days.compareTo(other.days);

  @override
  List<Object?> get props => [days];

  @override
  String toString() => 'every $days days';
}
