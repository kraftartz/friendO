/// Return how far a Friend has travelled through their current Cadence.
///
/// The result is `0.0` at [lastMet] and `1.0` at the Due Date, which falls one
/// [cadence] after [lastMet]. A result above `1.0` means the Friend is Overdue.
/// The result is negative when [now] falls before [lastMet].
///
/// [now] is a parameter and never a call to `DateTime.now()`. This package
/// holds no clock, so the caller supplies the current time. Every case is
/// therefore testable without waiting for one to arrive.
///
/// Throw [ArgumentError] when [cadence] is zero or negative. A zero cadence
/// would divide by zero and give infinity. A negative one would reverse the
/// scale, so a fresh Meeting would read as Overdue.
double phaseOf({
  required DateTime lastMet,
  required Duration cadence,
  required DateTime now,
}) {
  if (cadence <= Duration.zero) {
    throw ArgumentError.value(
      cadence,
      'cadence',
      'must be a positive duration',
    );
  }
  return now.difference(lastMet).inMicroseconds / cadence.inMicroseconds;
}
