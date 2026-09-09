/// The number of wrong PINs that cost nothing.
const restFreeAttempts = 4;

/// The rest the fifth wrong PIN buys.
const firstRest = Duration(seconds: 30);

/// The longest rest, however many wrong PINs came before it.
const longestRest = Duration(minutes: 15);

/// The wrong PIN whose rest is the first to double.
const _firstDoublingAttempt = 6;

/// The wrong PIN whose rest is the first to reach the cap.
const _cappedAttempt = 10;

/// How long the keypad rests after [failedAttempts] wrong PINs.
///
/// The first four cost nothing, so that a mistyped digit is not punished. The
/// rest then doubles, so that guessing gets worse and worse.
Duration restAfter(int failedAttempts) {
  if (failedAttempts <= restFreeAttempts) return Duration.zero;
  if (failedAttempts == restFreeAttempts + 1) return firstRest;
  if (failedAttempts >= _cappedAttempt) return longestRest;

  return Duration(minutes: 1 << (failedAttempts - _firstDoublingAttempt));
}

/// How much of the rest is still to come, [sinceArrival] after the keypad
/// appeared.
///
/// The rest is measured from the arrival and not from a stored deadline,
/// because the phone's clock belongs to whoever holds the phone.
Duration restLeft(int failedAttempts, Duration sinceArrival) {
  final left = restAfter(failedAttempts) - sinceArrival;

  return left.isNegative ? Duration.zero : left;
}
