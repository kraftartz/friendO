import 'package:friendo/app/platform_edges.dart' show PlatformEdges;
import 'package:friendo/core/reminders/notification_gate.dart'
    show NotificationGate;
import 'package:friendo/core/reminders/reminder.dart'
    show Reminder, ReminderSink;
import 'package:friendo/core/security/biometric_gate.dart' show BiometricGate;
import 'package:friendo/core/security/screen_privacy.dart' show ScreenPrivacy;

/// A notification permission the test decides the answer to.
class FakeNotificationGate implements NotificationGate {
  /// What [request] answers.
  bool grants = true;

  /// What [isAllowed] answers. It follows [grants] until a test moves it,
  /// which is how a permission revoked outside the app is written.
  bool? allowedNow;

  /// How many times the app asked for the permission.
  int requests = 0;

  @override
  Future<bool> isAllowed() async => allowedNow ?? grants;

  @override
  Future<bool> request() async {
    requests++;

    return grants;
  }
}

/// An operating system confirmation the test decides the answer to.
class FakeBiometricGate implements BiometricGate {
  /// Whether the phone can ask for a fingerprint at all.
  bool available = true;

  /// Whether the User confirms.
  bool confirms = true;

  /// How many times the app asked the operating system to confirm.
  int confirmations = 0;

  /// The Profile names the prompt was asked to name.
  final List<String> named = [];

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<bool> confirm({required String profileName}) async {
    confirmations++;
    named.add(profileName);

    return confirms;
  }
}

/// A screen privacy that records what it was told.
class FakeScreenPrivacy implements ScreenPrivacy {
  /// Every value the app asked the platform for, in order.
  final List<bool> told = [];

  @override
  Future<void> allowScreenshots({required bool allowed}) async =>
      told.add(allowed);
}

/// A reminder sink that holds nothing and goes nowhere.
///
/// It stands in for the phone in a test that is about something else, so that
/// the app's own wiring can run without a notification plugin behind it.
class SilentReminderSink implements ReminderSink {
  @override
  Future<void> prepare() async {}

  @override
  Future<List<Reminder>> pending() async => const [];

  @override
  Future<void> schedule(Reminder reminder) async {}

  @override
  Future<void> cancel(String friendId) async {}
}

/// The four platform edges, all faked.
PlatformEdges fakeEdges({
  ScreenPrivacy? screens,
  NotificationGate? notifications,
  BiometricGate? biometrics,
  ReminderSink? reminders,
}) => PlatformEdges(
  screens: screens ?? FakeScreenPrivacy(),
  notifications: notifications ?? FakeNotificationGate(),
  biometrics: biometrics ?? FakeBiometricGate(),
  reminders: reminders ?? SilentReminderSink(),
);
