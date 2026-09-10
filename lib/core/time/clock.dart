/// Where every now in the app comes from.
///
/// One source keeps the wall clock out of the code that reasons about time,
/// so that a test fixes the moment instead of waiting for it.
class Clock {
  const Clock();

  DateTime now() => DateTime.now();
}
