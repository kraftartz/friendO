import 'package:friendo/core/time/clock.dart';

/// A Clock that starts at a chosen moment and then runs with the machine.
///
/// A fixed Clock cannot test anything that schedules against its own reading:
/// the code reschedules from a now that never moved, so a timer set for the
/// rest of the day fires again at once.
class RunningClock extends Clock {
  RunningClock(this._start) {
    _since.start();
  }

  final DateTime _start;

  final Stopwatch _since = Stopwatch();

  @override
  DateTime now() => _start.add(_since.elapsed);
}
