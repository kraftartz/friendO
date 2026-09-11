import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/core/friends/friend_repository.dart'
    show FriendRepository;
import 'package:friendo/core/reminders/reminder_scheduler.dart'
    show ReminderScheduler, pendingReminderLimit;
import 'package:friendo/core/settings/settings_store.dart' show SettingsStore;
import 'package:friendo_domain/friendo_domain.dart'
    show Cadence, CivilDate, Friend, Meeting;

import '../../support/fake_reminder_sink.dart';
import '../../support/fixed_clock.dart';
import '../../support/wiring.dart';

/// The scheduler, over a real repository and a real database, with a fake
/// notification sink standing in for the platform.
///
/// It is tested here rather than through the Settings screen because three of
/// its rules have no home there: the top-up is about a roster larger than a
/// screen test would write, the reschedule on a Cadence change happens on a
/// screen that never calls it, and a Due Date in the past is a rule about the
/// absence of a notification.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Local midnight, in a month no zone shifts its clock in.
  final today = DateTime(2026, 9, 10);

  late Directory directory;
  late Wiring wiring;
  late FriendRepository friends;
  late SettingsStore settings;
  late FakeReminderSink sink;
  late FixedClock clock;
  late String profileId;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    directory = Directory.systemTemp.createTempSync('friendo_reminders');
    wiring = Wiring(directory);
    clock = FixedClock(today);
    friends = FriendRepository(wiring.databases, clock: clock);
    settings = SettingsStore(wiring.databases);
    sink = FakeReminderSink();
    profileId = (await wiring.creator.createProfile('Michal', '123456')).id;
    await wiring.session.unlock(profileId, '123456');
  });

  tearDown(() async {
    await wiring.dispose();
    directory.deleteSync(recursive: true);
  });

  CivilDate day(int daysAgo) => CivilDate.from(today).addDays(-daysAgo);

  Future<void> writeFriend(
    String id, {
    String? name,
    int cadenceDays = 30,
    int daysAgo = 0,
  }) => friends.save(
    Friend.hydrate(
      id: id,
      name: name ?? id,
      cadence: Cadence.ofDays(cadenceDays),
      meetings: [Meeting(id: 'm-$id', happenedOn: day(daysAgo))],
    ),
  );

  ReminderScheduler theScheduler({int limit = pendingReminderLimit}) =>
      ReminderScheduler(
        friends: friends,
        settings: settings,
        sink: sink,
        clock: clock,
        limit: limit,
      );

  /// A scheduler that has read the roster and the settings once.
  Future<ReminderScheduler> aRunningScheduler({
    int limit = pendingReminderLimit,
  }) async {
    final scheduler = theScheduler(limit: limit)..start();
    addTearDown(scheduler.dispose);
    await pumpEventQueue();
    await scheduler.topUp();

    return scheduler;
  }

  group('the switch', () {
    test('schedules nothing while it is off', () async {
      await writeFriend('anna', daysAgo: 0);
      await writeFriend('kasia', daysAgo: 3);

      await aRunningScheduler();

      expect(sink.held, isEmpty);
    });

    test(
      'schedules each Friend whose Due Date is ahead when it goes on',
      () async {
        await writeFriend('anna', name: 'Anna', daysAgo: 0);
        await writeFriend('kasia', name: 'Kasia', daysAgo: 3);
        final scheduler = await aRunningScheduler();

        await settings.change(remindersOn: true);
        await pumpEventQueue();
        await scheduler.topUp();

        expect(sink.friendIds, {'anna', 'kasia'});
        expect(sink.held.first.friendId, 'kasia');
      },
    );

    test('cancels every pending reminder when it goes off', () async {
      await writeFriend('anna', daysAgo: 0);
      await settings.change(remindersOn: true);
      final scheduler = await aRunningScheduler();
      expect(sink.held, isNotEmpty);

      await settings.change(remindersOn: false);
      await pumpEventQueue();
      await scheduler.topUp();

      expect(sink.held, isEmpty);
    });

    test('gives a Friend already Overdue no reminder', () async {
      await writeFriend('late', cadenceDays: 7, daysAgo: 30);
      await writeFriend('ahead', cadenceDays: 30, daysAgo: 3);
      await settings.change(remindersOn: true);

      await aRunningScheduler();

      expect(sink.friendIds, {'ahead'});
    });
  });

  group('a change on a screen', () {
    test('reschedules to the new Due Date when the Cadence changes', () async {
      await writeFriend('anna', cadenceDays: 30, daysAgo: 10);
      await settings.change(remindersOn: true);
      final scheduler = await aRunningScheduler();
      expect(sink.held.single.fireAt.day, day(-20).day);

      await friends.save(
        (await friends.load('anna'))!.copyWith(cadence: Cadence.ofDays(14)),
      );
      await pumpEventQueue();
      await scheduler.topUp();

      expect(sink.held.single.fireAt.day, day(-4).day);
    });

    test('reschedules when a Meeting is logged', () async {
      await writeFriend('anna', cadenceDays: 30, daysAgo: 10);
      await settings.change(remindersOn: true);
      final scheduler = await aRunningScheduler();
      final was = sink.held.single.fireAt;

      await friends.save(
        (await friends.load('anna'))!.logMeeting(
          Meeting(id: 'later', happenedOn: day(0)),
          now: today,
        ),
      );
      await pumpEventQueue();
      await scheduler.topUp();

      expect(sink.held.single.fireAt, isNot(was));
      expect(sink.held.single.fireAt.day, day(-30).day);
    });

    test(
      'cancels and schedules none when the Due Date moves into the past',
      () async {
        await writeFriend('anna', cadenceDays: 30, daysAgo: 20);
        await settings.change(remindersOn: true);
        final scheduler = await aRunningScheduler();
        expect(sink.friendIds, {'anna'});

        await friends.save(
          (await friends.load('anna'))!.copyWith(cadence: Cadence.ofDays(7)),
        );
        await pumpEventQueue();
        await scheduler.topUp();

        expect(sink.held, isEmpty);
      },
    );

    test('cancels a deleted Friend', () async {
      await writeFriend('anna', daysAgo: 0);
      await writeFriend('kasia', daysAgo: 0);
      await settings.change(remindersOn: true);
      final scheduler = await aRunningScheduler();
      expect(sink.friendIds, {'anna', 'kasia'});

      await friends.delete('anna');
      await pumpEventQueue();
      await scheduler.topUp();

      expect(sink.friendIds, {'kasia'});
    });
  });

  group('the platform limit', () {
    test('schedules only the nearest Due Dates', () async {
      for (var friend = 0; friend < 8; friend++) {
        await writeFriend('f$friend', cadenceDays: 10 + friend);
      }
      await settings.change(remindersOn: true);

      await aRunningScheduler(limit: 3);

      expect(sink.friendIds, {'f0', 'f1', 'f2'});
    });

    test('tops the schedule up as earlier reminders pass', () async {
      for (var friend = 0; friend < 6; friend++) {
        await writeFriend('f$friend', cadenceDays: 10 + friend);
      }
      await settings.change(remindersOn: true);
      final scheduler = await aRunningScheduler(limit: 3);
      expect(sink.friendIds, {'f0', 'f1', 'f2'});

      // Twelve days pass with the app shut, and the phone delivers the two
      // whose hour has come. f2 is due later today and still waiting.
      clock.advance(const Duration(days: 12));
      sink.deliverUpTo(clock.now());
      expect(sink.friendIds, {'f2'});

      await scheduler.topUp();

      expect(sink.friendIds, {'f2', 'f3', 'f4'});
    });
  });

  group('what a reminder says and when', () {
    test('carries the name and no Note, place or recap', () async {
      await friends.save(
        Friend.hydrate(
          id: 'anna',
          name: 'Anna',
          cadence: Cadence.ofDays(30),
          meetings: [
            Meeting(
              id: 'm1',
              happenedOn: day(0),
              place: 'Karma',
              recap: 'She is moving in March.',
            ),
          ],
        ),
      );
      await settings.change(remindersOn: true);

      await aRunningScheduler();

      expect(sink.held.single.text, 'Time to catch up with Anna');
      expect(sink.held.single.text, isNot(contains('Karma')));
      expect(sink.held.single.text, isNot(contains('moving')));
    });

    test('fires at the hour the setting holds', () async {
      await writeFriend('anna', cadenceDays: 30, daysAgo: 0);
      await settings.change(remindersOn: true, reminderHour: 19);
      final scheduler = await aRunningScheduler();

      expect(sink.held.single.fireAt, DateTime(2026, 10, 10, 19));

      await settings.change(reminderHour: 8);
      await pumpEventQueue();
      await scheduler.topUp();

      expect(sink.held.single.fireAt, DateTime(2026, 10, 10, 8));
    });

    test('makes the sink ready before it writes anything', () async {
      await writeFriend('anna', daysAgo: 0);
      await settings.change(remindersOn: true);

      await aRunningScheduler();

      expect(sink.writesBeforePrepare, 0);
      expect(sink.prepares, 1, reason: 'it prepares once and not on every run');
    });
  });

  group('a run that fails', () {
    test('loses that run only, and the next one schedules', () async {
      await writeFriend('anna', daysAgo: 0);
      await settings.change(remindersOn: true);
      final scheduler = await aRunningScheduler();
      await sink.cancel('anna');

      sink.failsNextSchedule = true;
      await expectLater(scheduler.topUp(), throwsStateError);
      expect(sink.friendIds, isEmpty);

      await scheduler.topUp();

      expect(sink.friendIds, {'anna'});
    });
  });

  group('a lock', () {
    test('cancels nothing, because reminders belong to the Profile', () async {
      await writeFriend('anna', daysAgo: 0);
      await settings.change(remindersOn: true);
      final scheduler = await aRunningScheduler();
      expect(sink.friendIds, {'anna'});

      await wiring.session.lock();
      await pumpEventQueue();
      await scheduler.topUp();

      expect(sink.friendIds, {'anna'});
    });
  });
}
