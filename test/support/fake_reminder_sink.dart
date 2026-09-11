import 'package:friendo/core/reminders/reminder.dart'
    show Reminder, ReminderSink;

/// A sink that holds what the phone would hold.
///
/// It stands in for the platform, and it is not the platform. ADR-0012
/// accepted that the 64-notification limit, a daylight-saving shift and a
/// revoked permission behave in ways only a device shows.
class FakeReminderSink implements ReminderSink {
  final Map<String, Reminder> _held = {};

  /// How many times [prepare] was called.
  int prepares = 0;

  /// How many reminders were written before [prepare] was called.
  int writesBeforePrepare = 0;

  /// When true, the next [schedule] throws and writes nothing. It turns
  /// itself off, so the call after that one behaves.
  bool failsNextSchedule = false;

  /// The reminders the sink is holding, nearest first.
  List<Reminder> get held =>
      [..._held.values]..sort((a, b) => a.fireAt.compareTo(b.fireAt));

  /// The Friends the sink is holding a reminder for.
  Set<String> get friendIds => _held.keys.toSet();

  /// Drop the reminders whose fire time has passed, as the phone does when it
  /// delivers them.
  void deliverUpTo(DateTime now) =>
      _held.removeWhere((_, reminder) => !reminder.fireAt.isAfter(now));

  @override
  Future<void> prepare() async => prepares++;

  @override
  Future<List<Reminder>> pending() async => held;

  @override
  Future<void> schedule(Reminder reminder) async {
    if (failsNextSchedule) {
      failsNextSchedule = false;
      throw StateError('the platform refused this reminder');
    }
    if (prepares == 0) writesBeforePrepare++;
    _held[reminder.friendId] = reminder;
  }

  @override
  Future<void> cancel(String friendId) async {
    if (prepares == 0) writesBeforePrepare++;
    _held.remove(friendId);
  }
}
