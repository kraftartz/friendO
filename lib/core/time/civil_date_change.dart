import 'dart:async';

import 'package:friendo/core/time/clock.dart' show Clock;
import 'package:friendo_domain/friendo_domain.dart' show CivilDate;

/// How long is left of the local day that [now] falls in.
///
/// The next local midnight, which on a day that shifts the clock is not
/// twenty-four hours on. It is never nothing: at midnight a whole day is left.
Duration untilNextMidnight(DateTime now) =>
    DateTime(now.year, now.month, now.day + 1).difference(now);

/// The shortest wait this ever sets.
///
/// A timer may fire a fraction before the moment it was set for, and a wait
/// worked out from a now that has not reached midnight yet is close to
/// nothing. Without a floor the two together spin.
const _leastWait = Duration(milliseconds: 20);

/// Announces that the local Civil Date has changed.
///
/// One timer to the next local midnight, and not a tick. A reading of a Friend
/// stays true with nothing running, so the only moment a screen has to hear
/// about is the one where a Friend can become Overdue with nothing else having
/// happened.
///
/// The announcement carries no reading. A listener re-reads, which keeps one
/// answer on the screen rather than two that were worked out in two places.
///
/// It announces once per midnight: the day it last waited from is compared
/// against the day it woke in, so a wakeup that arrives early says nothing and
/// waits again.
///
/// The timer runs only while somebody listens, and stops with the last
/// listener. A screen that clears behind a lock cancels its subscription, so
/// no timer is left running behind the PIN screen.
class CivilDateChange {
  CivilDateChange({this.clock = const Clock()});

  final Clock clock;

  Timer? _waiting;

  /// The Civil Date the newest wait was set from.
  CivilDate? _waitingFrom;

  late final StreamController<void> _changes = StreamController<void>.broadcast(
    onListen: _wait,
    onCancel: _stop,
  );

  Stream<void> get changes => _changes.stream;

  /// Whether a timer is running towards the next midnight.
  bool get isWaiting => _waiting != null;

  Future<void> dispose() {
    _stop();

    return _changes.close();
  }

  void _wait() {
    _waiting?.cancel();

    final now = clock.now();
    _waitingFrom = CivilDate.from(now);
    final rest = untilNextMidnight(now);
    _waiting = Timer(rest < _leastWait ? _leastWait : rest, _wake);
  }

  void _wake() {
    _waiting = null;
    final changed = CivilDate.from(clock.now()) != _waitingFrom;

    if (_changes.hasListener) _wait();
    if (changed) _changes.add(null);
  }

  void _stop() {
    _waiting?.cancel();
    _waiting = null;
    _waitingFrom = null;
  }
}
