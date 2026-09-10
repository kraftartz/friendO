import 'package:friendo/core/time/clock.dart';

/// A Clock that starts at a chosen moment and then runs with the machine.
///
/// A fixed Clock cannot test anything that schedules against its own reading:
/// the code reschedules from a now that never moved, so a timer set for the
/// rest of the day fires again at once.
///
/// It starts running when it is first read, and not when it is built. A busy
/// machine can leave a gap between the two, and a Clock that spent that gap
/// running would be somewhere else by the time the code under test asked.
class RunningClock extends Clock {
  RunningClock(this._start);

  final DateTime _start;

  final Stopwatch _since = Stopwatch();

  @override
  DateTime now() {
    if (!_since.isRunning) _since.start();

    return _start.add(_since.elapsed);
  }
}
