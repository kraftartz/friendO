import 'dart:async';

import 'package:flutter/widgets.dart';

import '../time/clock.dart';

/// How long the app may stay in the background before it locks.
const defaultLockTimeout = Duration(seconds: 60);

/// Answers whether an absence between [wentAway] and [cameBack] locks the app.
///
/// An absence of exactly [timeout] does not lock. The boundary is decided
/// here, once, rather than guessed at each call.
///
/// A phone that came back before it went away locks. A clock that moved
/// backwards is not a short absence, and the safe answer costs six digits
/// while the other one costs the Profile.
bool shouldLock({
  required DateTime wentAway,
  required DateTime cameBack,
  Duration timeout = defaultLockTimeout,
}) {
  final gap = cameBack.difference(wentAway);

  return gap.isNegative || gap > timeout;
}

/// Watches the app lifecycle and locks the Profile when the User stays away.
///
/// It holds two instants rather than a live timer. A timer does not run while
/// the process is suspended, so a phone asleep for a week would come back
/// unlocked.
class AutoLock with WidgetsBindingObserver {
  AutoLock({
    required this.lock,
    this.clock = const Clock(),
    this.timeout = defaultLockTimeout,
  });

  /// What this runs when it decides to lock. It is the one way to lock.
  final Future<void> Function() lock;

  final Clock clock;

  /// How long the app may be away before it locks.
  ///
  /// It is read at the moment the app comes back, so a change written while
  /// the app is away is in force for that return. The value is a setting the
  /// User owns (ADR-0011), and this object neither reads nor stores it.
  Duration timeout;

  DateTime? _wentAway;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _wentAway ??= clock.now();
      case AppLifecycleState.detached:
        _wentAway = null;
        unawaited(lock());
      case AppLifecycleState.resumed:
        _comeBack();
      case AppLifecycleState.inactive:
        break;
    }
  }

  void _comeBack() {
    final wentAway = _wentAway;
    _wentAway = null;
    if (wentAway == null) return;

    if (shouldLock(
      wentAway: wentAway,
      cameBack: clock.now(),
      timeout: timeout,
    )) {
      unawaited(lock());
    }
  }
}
