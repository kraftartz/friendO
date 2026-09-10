import 'package:equatable/equatable.dart';

/// One pending reminder about one Friend.
///
/// [text] carries a name and nothing else. ADR-0012 fixes it: no Topic, no
/// place, no recap and no count. A notification is the one part of this app
/// that draws outside its own lock.
final class Reminder extends Equatable {
  /// Hold the three values a pending reminder is.
  const Reminder({
    required this.friendId,
    required this.text,
    required this.fireAt,
  });

  /// The Friend the reminder is about, which is also its key in the sink.
  final String friendId;

  /// The words the phone shows.
  final String text;

  /// The local moment it fires at.
  final DateTime fireAt;

  @override
  List<Object?> get props => [friendId, text, fireAt];

  @override
  String toString() => 'Reminder for $friendId at $fireAt: $text';
}

/// The words a reminder carries.
String reminderTextFor(String name) => 'Time to catch up with $name';

/// Where a reminder is handed to, so that the scheduler can be read without a
/// phone.
///
/// One Reminder per Friend. The sink keys on [Reminder.friendId], so
/// scheduling a Friend twice replaces the first, and cancelling takes the one
/// that Friend holds.
abstract interface class ReminderSink {
  /// Make the sink ready to schedule.
  ///
  /// ADR-0012 needs the `timezone` package set up before anything is
  /// scheduled, because a daylight-saving change moves a fire time and the
  /// package handles it only when it is set up. The scheduler calls this
  /// before its first write and never after it.
  Future<void> prepare();

  /// Every reminder the phone is holding.
  Future<List<Reminder>> pending();

  /// Hold [reminder], replacing any this Friend already had.
  Future<void> schedule(Reminder reminder);

  /// Drop the reminder this Friend holds, if any.
  Future<void> cancel(String friendId);
}
