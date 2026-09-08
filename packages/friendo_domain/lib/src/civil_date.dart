import 'package:equatable/equatable.dart';

/// One day on a calendar. It carries no time and no zone.
///
/// A Meeting happens on a Civil Date. "I saw Anna on Tuesday" stays Tuesday
/// when the owner flies to another zone, because there is no instant here to
/// re-read against a different offset.
///
/// The stored form is [epochDay], the count of days from 1970-01-01. It is a
/// small integer, it sorts in the same order as the date, and subtracting two
/// of them gives whole days.
///
/// See ADR-0021.
final class CivilDate extends Equatable implements Comparable<CivilDate> {
  /// Build a Civil Date from its three parts.
  ///
  /// Throw [ArgumentError] when the three parts do not name a real day. The
  /// 30th of February is rejected rather than rolled forward, because a rolled
  /// date is a wrong date that no later code can detect.
  factory CivilDate(int year, int month, int day) {
    final utc = DateTime.utc(year, month, day);
    if (utc.year != year || utc.month != month || utc.day != day) {
      throw ArgumentError('$year-$month-$day is not a real day');
    }
    return CivilDate._(year, month, day);
  }

  const CivilDate._(this.year, this.month, this.day);

  /// Read back a Civil Date from its stored form.
  factory CivilDate.fromEpochDay(int epochDay) {
    final utc = DateTime.fromMillisecondsSinceEpoch(
      epochDay * Duration.millisecondsPerDay,
      isUtc: true,
    );
    return CivilDate._(utc.year, utc.month, utc.day);
  }

  /// Take the calendar day that [moment] falls on.
  ///
  /// The day comes from the parts of [moment] as given. A local `DateTime`
  /// yields the local day and a UTC one yields the UTC day, so the caller
  /// chooses the zone by choosing what it passes.
  factory CivilDate.from(DateTime moment) =>
      CivilDate._(moment.year, moment.month, moment.day);

  final int year;
  final int month;
  final int day;

  /// The count of days from 1970-01-01. Negative before that day.
  int get epochDay =>
      DateTime.utc(year, month, day).millisecondsSinceEpoch ~/
      Duration.millisecondsPerDay;

  /// The Civil Date [days] later. A negative [days] moves back.
  CivilDate addDays(int days) => CivilDate.fromEpochDay(epochDay + days);

  /// Whole days from [earlier] to this Civil Date. Negative when this one is
  /// the earlier of the two.
  int daysFrom(CivilDate earlier) => epochDay - earlier.epochDay;

  /// Midnight at the start of this day, read in the zone of the running phone.
  ///
  /// This is the one place a Civil Date meets an instant. The result depends on
  /// where the phone is, so it belongs at the moment of use and never in
  /// storage.
  DateTime startOfDayLocal() => DateTime(year, month, day);

  bool operator <(CivilDate other) => epochDay < other.epochDay;
  bool operator <=(CivilDate other) => epochDay <= other.epochDay;
  bool operator >(CivilDate other) => epochDay > other.epochDay;
  bool operator >=(CivilDate other) => epochDay >= other.epochDay;

  @override
  int compareTo(CivilDate other) => epochDay.compareTo(other.epochDay);

  @override
  List<Object?> get props => [year, month, day];

  @override
  String toString() =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';
}
