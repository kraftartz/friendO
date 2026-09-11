import 'dart:async';

import 'package:friendo_domain/friendo_domain.dart'
    show CivilDate, dueDateOf, isOverdue;

import '../db/database_session.dart';
import '../friends/dial_friend.dart';
import '../friends/friend_repository.dart';
import '../settings/profile_settings.dart';
import '../settings/settings_store.dart';
import '../time/clock.dart';
import 'reminder.dart';

/// How many reminders the phone will hold at once.
///
/// iOS allows 64 pending local notifications and the product allows about a
/// hundred Friends, so the nearest Due Dates are scheduled and the rest wait.
/// See ADR-0012.
const pendingReminderLimit = 64;

/// Keeps the phone's pending reminders equal to what the Profile asks for.
///
/// It watches two things, the repository and the reminder settings, and works
/// out what should be pending. Because it watches rather than being called, a
/// new write path cannot forget to reschedule. That is ADR-0022's answer to
/// ADR-0012's hardest sentence: a missed path causes a wrong reminder, and
/// that bug is hard to notice.
///
/// No screen calls it. A screen writes through the repository and stops.
///
/// A Profile that locks cancels nothing. The reminders belong to the Profile,
/// and locking the app is not turning them off.
class ReminderScheduler {
  /// Watch [friends] and [settings], and write to [sink].
  ReminderScheduler({
    required this.friends,
    required this.settings,
    required this.sink,
    this.clock = const Clock(),
    this.limit = pendingReminderLimit,
  });

  /// The one reader of the Friend tables.
  final FriendRepository friends;

  /// The Profile's own options.
  final SettingsStore settings;

  /// Where a reminder is handed to.
  final ReminderSink sink;

  /// Where every `now` comes from.
  final Clock clock;

  /// How many reminders may be pending at once.
  final int limit;

  StreamSubscription<List<DialFriend>>? _roster;
  StreamSubscription<ProfileSettings>? _options;

  List<DialFriend>? _held;
  ProfileSettings? _wanted;
  bool _ready = false;
  Future<void> _working = Future<void>.value();

  /// Follow the roster and the settings from now on.
  void start() {
    _roster ??= friends.watchDialFriends().listen((rows) {
      _held = rows;
      topUp().ignore();
    });
    _options ??= settings.watch().listen((options) {
      _wanted = options;
      topUp().ignore();
    });
  }

  /// Make the phone agree with the Profile, now.
  ///
  /// The app calls this when it opens, which is how the schedule is topped up
  /// as earlier reminders pass. It is not a background job: ADR-0012 accepted
  /// that the app has to be open.
  Future<void> topUp() {
    // One run at a time. Two overlapping runs would read the same pending set
    // and both write the difference, which cancels a reminder that the other
    // has already scheduled.
    final run = _working.then((_) => _makeItAgree());

    // The queue holds no error. A run that fails is one lost update, and the
    // next call starts clean; an error kept here would fail every later call.
    _working = run.catchError((Object _) {});

    return run;
  }

  /// Stop following, and leave the pending reminders where they are.
  Future<void> dispose() async {
    await _roster?.cancel();
    await _options?.cancel();
    _roster = null;
    _options = null;
  }

  /// What should be pending, given the roster and the settings held.
  List<Reminder> wanted() {
    final options = _wanted;
    final roster = _held;
    if (options == null || roster == null || !options.remindersOn) {
      return const [];
    }

    final now = clock.now();
    final today = CivilDate.from(now);

    final due = <Reminder>[
      for (final friend in roster)
        if (_fireTimeFor(friend, today: today, hour: options.reminderHour)
            case final DateTime fireAt when fireAt.isAfter(now))
          Reminder(
            friendId: friend.id,
            text: reminderTextFor(friend.name),
            fireAt: fireAt,
          ),
    ]..sort((a, b) => a.fireAt.compareTo(b.fireAt));

    return List.unmodifiable(due.take(limit));
  }

  /// The moment a Friend's reminder fires, or null when it schedules none.
  ///
  /// A Due Date that has passed schedules nothing (ADR-0032). The Beads Queue
  /// and the Overdue banner already carry the Friend, and a notification about
  /// a day that has gone is noise.
  DateTime? _fireTimeFor(
    DialFriend friend, {
    required CivilDate today,
    required int hour,
  }) {
    final dueAt = dueDateOf(lastMet: friend.lastMet, cadence: friend.cadence);
    if (isOverdue(today: today, dueAt: dueAt)) return null;

    return dueAt.startOfDayLocal().add(Duration(hours: hour));
  }

  Future<void> _makeItAgree() async {
    final List<Reminder> wantedNow;
    try {
      wantedNow = wanted();
    } on DatabaseLockedError {
      return;
    }

    if (!_ready) {
      await sink.prepare();
      _ready = true;
    }

    final held = {
      for (final reminder in await sink.pending()) reminder.friendId: reminder,
    };
    final byFriend = {
      for (final reminder in wantedNow) reminder.friendId: reminder,
    };

    for (final friendId in held.keys) {
      if (!byFriend.containsKey(friendId)) await sink.cancel(friendId);
    }
    for (final reminder in wantedNow) {
      if (held[reminder.friendId] != reminder) await sink.schedule(reminder);
    }
  }
}
