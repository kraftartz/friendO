import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:local_auth/local_auth.dart';

import '../core/reminders/local_notification_sink.dart';
import '../core/reminders/notification_gate.dart';
import '../core/reminders/reminder.dart';
import '../core/security/biometric_gate.dart';
import '../core/security/screen_privacy.dart';

/// Everything the app asks the phone itself for.
///
/// Four edges, gathered so that the wiring layer names them once and a test
/// can stand in for the phone without standing in for anything else. Each one
/// is a port that `core/` declares; this only says which implementation the
/// app runs with.
class PlatformEdges {
  /// Hold the four.
  const PlatformEdges({
    required this.screens,
    required this.notifications,
    required this.biometrics,
    required this.reminders,
  });

  /// The edges of a real phone.
  factory PlatformEdges.ofThisPhone() {
    final plugin = FlutterLocalNotificationsPlugin();

    return PlatformEdges(
      screens: const PlatformScreenPrivacy(),
      notifications: PlatformNotificationGate(plugin),
      biometrics: PlatformBiometricGate(LocalAuthentication()),
      reminders: LocalNotificationSink(plugin),
    );
  }

  /// FLAG_SECURE on Android, and the cover on iOS.
  final ScreenPrivacy screens;

  /// The permission a reminder needs.
  final NotificationGate notifications;

  /// The operating system's own confirmation.
  final BiometricGate biometrics;

  /// Where a pending reminder is handed to.
  final ReminderSink reminders;
}
