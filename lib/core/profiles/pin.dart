/// The rules a PIN answers to: how long it is, and what a wrong one costs.
///
/// See [ADR-0031](../../../docs/adr/0031-a-forgotten-pin-loses-the-profile.md),
/// which sets the table below and the reason for it.
library;

/// How many digits a PIN has.
///
/// The last digit submits the PIN, so the count is the whole of the rule: no
/// screen needs a confirm key.
const pinLength = 6;

/// The number of wrong PINs that cost nothing.
const pinDelayFreeAttempts = 4;

/// The delay the fifth wrong PIN buys.
const firstPinDelay = Duration(seconds: 30);

/// The longest delay, however many wrong PINs came before it.
const longestPinDelay = Duration(minutes: 15);

/// The wrong PIN whose delay is the first to double.
const _firstDoublingAttempt = 6;

/// The wrong PIN whose delay is the first to reach the cap.
const _cappedAttempt = 10;

/// How long the keypad waits after [failedAttempts] wrong PINs.
///
/// The first four cost nothing, so that a mistyped digit is not punished. The
/// delay then doubles, so that guessing gets worse and worse.
Duration pinDelayAfter(int failedAttempts) {
  if (failedAttempts <= pinDelayFreeAttempts) return Duration.zero;
  if (failedAttempts == pinDelayFreeAttempts + 1) return firstPinDelay;
  if (failedAttempts >= _cappedAttempt) return longestPinDelay;

  return Duration(minutes: 1 << (failedAttempts - _firstDoublingAttempt));
}

/// How much of the delay is still to come, [sinceArrival] after the keypad
/// appeared.
///
/// The delay is measured from the arrival and not from a stored deadline,
/// because the phone's clock belongs to whoever holds the phone.
Duration pinDelayLeft(int failedAttempts, Duration sinceArrival) {
  final left = pinDelayAfter(failedAttempts) - sinceArrival;

  return left.isNegative ? Duration.zero : left;
}
