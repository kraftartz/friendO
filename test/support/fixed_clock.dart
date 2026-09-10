import 'package:friendo/core/time/clock.dart';

/// A Clock that moves only when a test moves it.
class FixedClock extends Clock {
  FixedClock(this._now);

  DateTime _now;

  void advance(Duration step) => _now = _now.add(step);

  @override
  DateTime now() => _now;
}
