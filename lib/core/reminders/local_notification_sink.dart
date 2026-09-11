import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'reminder.dart';

/// The Android channel the reminders arrive on.
const reminderChannelId = 'friendo_reminders';

/// The one place that talks to `flutter_local_notifications`.
///
/// Everything else writes through the repository and the settings, and
/// `ReminderScheduler` turns that into calls here. Keeping the plugin behind
/// one class is what lets the schedule be read in a test without a phone.
///
/// A Friend's id is not an integer and the platform keys on one, so each
/// pending notification carries the Friend's id in its payload and the id is
/// hashed to reach the platform's key.
class LocalNotificationSink implements ReminderSink {
  /// Schedule through [plugin].
  LocalNotificationSink(this.plugin);

  /// The plugin this app talks to.
  final FlutterLocalNotificationsPlugin plugin;

  @override
  Future<void> prepare() async {
    // A daylight-saving change moves a fire time, and the package handles it
    // only when it is set up. ADR-0012 asks for this before anything is
    // scheduled.
    tz_data.initializeTimeZones();
  }

  @override
  Future<List<Reminder>> pending() async {
    final held = await plugin.pendingNotificationRequests();

    return [
      for (final request in held)
        if (_reminderOf(request) case final Reminder reminder) reminder,
    ];
  }

  @override
  Future<void> schedule(Reminder reminder) => plugin.zonedSchedule(
    id: _keyOf(reminder.friendId),
    title: reminder.text,
    scheduledDate: tz.TZDateTime.from(reminder.fireAt, tz.local),
    notificationDetails: const NotificationDetails(
      android: AndroidNotificationDetails(
        reminderChannelId,
        'Reminders',
        channelDescription: 'A Friend is due today.',
      ),
      iOS: DarwinNotificationDetails(),
    ),
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    payload: reminder.friendId,
  );

  @override
  Future<void> cancel(String friendId) => plugin.cancel(id: _keyOf(friendId));

  /// The platform's integer key for a Friend.
  ///
  /// Two Friends can collide, and a collision costs one reminder rather than a
  /// wrong one: the second write replaces the first, and the next top-up
  /// writes it again.
  int _keyOf(String friendId) => friendId.hashCode & 0x7fffffff;

  Reminder? _reminderOf(PendingNotificationRequest request) {
    final friendId = request.payload;
    final text = request.title;
    if (friendId == null || text == null) return null;

    // The platform does not give the fire time back. The scheduler compares
    // what it wants against what is held, so a held reminder with no readable
    // time is written again, which is the safe direction.
    return Reminder(friendId: friendId, text: text, fireAt: _unknownFireTime);
  }
}

/// Stands for a fire time the platform will not give back.
final _unknownFireTime = DateTime.fromMillisecondsSinceEpoch(0);
