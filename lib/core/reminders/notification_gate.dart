import 'dart:io' show Platform;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Asks for and reads the permission a reminder needs.
///
/// ADR-0012 ships reminders off so that First Run demands no permission, and
/// the app earns the prompt later. The switch follows the permission and not
/// the intention: a switch reading on over a system that will deliver nothing
/// is a lie the User has no way to detect.
abstract interface class NotificationGate {
  /// Whether the phone will deliver a notification now.
  Future<bool> isAllowed();

  /// Ask the User for the permission, once, at the moment they turn the
  /// switch on.
  Future<bool> request();
}

/// [NotificationGate] over `flutter_local_notifications`.
class PlatformNotificationGate implements NotificationGate {
  /// Ask through [plugin].
  const PlatformNotificationGate(this.plugin);

  /// The plugin this app asks with.
  final FlutterLocalNotificationsPlugin plugin;

  @override
  Future<bool> isAllowed() async {
    if (Platform.isAndroid) {
      final android = plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      return await android?.areNotificationsEnabled() ?? false;
    }

    final darwin = plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    return await darwin?.checkPermissions().then(
          (held) => held?.isEnabled ?? false,
        ) ??
        false;
  }

  @override
  Future<bool> request() async {
    if (Platform.isAndroid) {
      final android = plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      return await android?.requestNotificationsPermission() ?? false;
    }

    final darwin = plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    return await darwin?.requestPermissions(alert: true, sound: true) ?? false;
  }
}
