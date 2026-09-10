import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/core/db/database_session.dart' show DatabaseLockedError;
import 'package:friendo/core/friends/friend_repository.dart'
    show FriendRepository;
import 'package:friendo/core/time/civil_date_change.dart' show CivilDateChange;
import 'package:friendo/features/friends/bloc/friends_cubit.dart'
    show FriendsCubit;
import 'package:friendo/features/friends/bloc/friends_state.dart'
    show Emptiness, FriendsListState;
import 'package:friendo_domain/friendo_domain.dart'
    show Cadence, CivilDate, Friend, Meeting, Note, NoteLabel, Orbit, Standing;

import 'package:flutter/widgets.dart' show AppLifecycleState;

import '../../support/fixed_clock.dart';
import '../../support/running_clock.dart';
import '../../support/wiring.dart';

/// The Friends List's state, over a real repository, over a real database.
///
/// The term, the chip, the Priority Order, the banner, the counts, the empty
/// states and the lock all meet here, so one test can read what the screen
/// would show without drawing it.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Local midnight, in a month no zone shifts its clock in, so a whole
  /// number of days back is a whole number of laps.
  final today = DateTime(2026, 9, 10);

  late Directory directory;
  late Wiring wiring;
  late FriendRepository friends;
  late FixedClock clock;
  late CivilDateChange dayChange;
  late String profileId;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    directory = Directory.systemTemp.createTempSync('friendo_friends');
    wiring = Wiring(directory);
    clock = FixedClock(today);
    friends = FriendRepository(wiring.databases, clock: clock);
    dayChange = CivilDateChange(clock: clock);
    profileId = (await wiring.creator.createProfile('Michal', '123456')).id;
    await wiring.session.unlock(profileId, '123456');
  });

  tearDown(() async {
    await dayChange.dispose();
    await wiring.dispose();
    directory.deleteSync(recursive: true);
  });

  FriendsCubit aList({Orbit? startOn}) => FriendsCubit(
    friends: friends,
    databases: wiring.databases,
    dayChange: dayChange,
    clock: clock,
    startOn: startOn,
  );

  Future<void> writeFriend(
    String id, {
    required int cadenceDays,
    required int daysAgo,
    String? name,
    List<String> topics = const [],
  }) => friends.save(
    Friend.started(
      id: id,
      name: name ?? id,
      cadence: Cadence.ofDays(cadenceDays),
      firstMeeting: Meeting(
        id: 'm-$id',
        happenedOn: CivilDate.from(today).addDays(-daysAgo),
      ),
      now: today,
      notes: [
        for (var at = 0; at < topics.length; at++)
          Note(
            id: 'n-$id-$at',
            label: NoteLabel.topic,
            body: topics[at],
            writtenOn: CivilDate.from(today).addDays(-at),
          ),
      ],
    ),
  );

  Future<FriendsListState> readingOf(FriendsCubit list) async {
    await pumpEventQueue();

    return list.state;
  }

  List<String> namesOn(FriendsListState reading) =>
      reading.cards.map((card) => card.name).toList();

  group('the order', () {
    test('names the Overdue Friends oldest Due Date first', () async {
      await writeFriend('slipped-first', cadenceDays: 10, daysAgo: 30);
      await writeFriend('slipped-later', cadenceDays: 10, daysAgo: 15);
      final list = aList();
      addTearDown(list.close);

      expect(namesOn(await readingOf(list)), [
        'slipped-first',
        'slipped-later',
      ]);
    });

    test('follows them with the On Track Friends, highest Phase '
        'first', () async {
      await writeFriend('quarter', cadenceDays: 20, daysAgo: 5);
      await writeFriend('most', cadenceDays: 20, daysAgo: 19);
      await writeFriend('half', cadenceDays: 20, daysAgo: 10);
      final list = aList();
      addTearDown(list.close);

      expect(namesOn(await readingOf(list)), ['most', 'half', 'quarter']);
    });

    test('puts every Overdue Friend above every On Track Friend', () async {
      await writeFriend('late', cadenceDays: 90, daysAgo: 91);
      await writeFriend('nearly-there', cadenceDays: 10, daysAgo: 9);
      final list = aList();
      addTearDown(list.close);

      final reading = await readingOf(list);

      expect(namesOn(reading), ['late', 'nearly-there']);
      expect(reading.cards.first.standing, Standing.overdue);
    });

    test('leaves the order of what remains alone when a term '
        'narrows it', () async {
      await writeFriend('late anna', cadenceDays: 10, daysAgo: 30);
      await writeFriend('ben', cadenceDays: 10, daysAgo: 20);
      await writeFriend('cara anna', cadenceDays: 20, daysAgo: 10);
      final list = aList();
      addTearDown(list.close);
      final whole = namesOn(await readingOf(list));

      list.search('anna');
      final narrowed = namesOn(await readingOf(list));

      expect(whole, ['late anna', 'ben', 'cara anna']);
      expect(narrowed, ['late anna', 'cara anna']);
    });
  });

  group('the term and the chips', () {
    Future<void> aRoster() async {
      await writeFriend('anna inner', cadenceDays: 7, daysAgo: 1);
      await writeFriend('ben inner', cadenceDays: 10, daysAgo: 2);
      await writeFriend('anna middle', cadenceDays: 30, daysAgo: 3);
      await writeFriend('cara outer', cadenceDays: 90, daysAgo: 4);
    }

    test('shows the whole roster while the term holds nothing', () async {
      await aRoster();
      final list = aList();
      addTearDown(list.close);

      expect((await readingOf(list)).cards, hasLength(4));
    });

    test('shows nobody, and says why, when the term matches '
        'nobody', () async {
      await aRoster();
      final list = aList();
      addTearDown(list.close);

      list.search('zebra');
      final reading = await readingOf(list);

      expect(reading.cards, isEmpty);
      expect(reading.emptiness, Emptiness.noMatch);
    });

    test('gives the same set whichever narrowing arrives first', () async {
      await aRoster();
      final first = aList();
      final second = aList();
      addTearDown(first.close);
      addTearDown(second.close);

      first.search('anna');
      first.showOrbit(Orbit.inner);
      second.showOrbit(Orbit.inner);
      second.search('anna');

      expect(namesOn(await readingOf(first)), ['anna inner']);
      expect(namesOn(await readingOf(first)), namesOn(await readingOf(second)));
    });

    test('keeps the chip while the User edits the term', () async {
      await aRoster();
      final list = aList();
      addTearDown(list.close);

      list.showOrbit(Orbit.inner);
      list.search('anna');
      list.search('');
      final reading = await readingOf(list);

      expect(reading.orbit, Orbit.inner);
      // Ben is further through his Cadence, so the Priority Order puts him
      // first.
      expect(namesOn(reading), ['ben inner', 'anna inner']);
    });

    test('counts on each chip what tapping it would show', () async {
      await aRoster();
      final list = aList();
      addTearDown(list.close);

      list.search('anna');
      final counts = (await readingOf(list)).counts;

      expect(counts.of(null), 2);
      expect(counts.of(Orbit.inner), 1);
      expect(counts.of(Orbit.middle), 1);
      expect(counts.of(Orbit.outer), 0);

      for (final orbit in Orbit.values) {
        list.showOrbit(orbit);

        expect(
          (await readingOf(list)).cards,
          hasLength(counts.of(orbit)),
          reason: 'the ${orbit.name} chip',
        );
      }
    });

    test('adds the three Orbit counts up to the All count', () async {
      await aRoster();
      final list = aList();
      addTearDown(list.close);

      final counts = (await readingOf(list)).counts;

      expect(
        Orbit.values.map(counts.of).reduce((a, b) => a + b),
        counts.of(null),
      );
      expect(counts.of(null), 4);
    });

    test('starts on the Orbit the screen was opened with', () async {
      await aRoster();
      final list = aList(startOn: Orbit.outer);
      addTearDown(list.close);

      final reading = await readingOf(list);

      expect(reading.orbit, Orbit.outer);
      expect(namesOn(reading), ['cara outer']);
    });

    test('tells the three empty states apart', () async {
      final list = aList();
      addTearDown(list.close);

      expect((await readingOf(list)).emptiness, Emptiness.noFriends);

      await aRoster();
      await readingOf(list);
      list.search('zebra');

      expect((await readingOf(list)).emptiness, Emptiness.noMatch);

      list.search('anna');
      list.showOrbit(Orbit.outer);

      expect((await readingOf(list)).emptiness, Emptiness.noneInOrbit);
    });
  });

  group('the banner', () {
    test(
      'names the Overdue Friends in the order the Priority Order gives',
      () async {
        await writeFriend('slipped-first', cadenceDays: 10, daysAgo: 30);
        await writeFriend('on-track', cadenceDays: 30, daysAgo: 2);
        await writeFriend('slipped-later', cadenceDays: 10, daysAgo: 15);
        final list = aList();
        addTearDown(list.close);

        final reading = await readingOf(list);

        expect(reading.overdue.map((card) => card.name).toList(), [
          'slipped-first',
          'slipped-later',
        ]);
        expect(reading.overdueCount, 2);
      },
    );

    test('is not there while nobody is Overdue', () async {
      await writeFriend('fine', cadenceDays: 30, daysAgo: 2);
      final list = aList();
      addTearDown(list.close);

      final reading = await readingOf(list);

      expect(reading.hasBanner, isFalse);
      expect(reading.overdue, isEmpty);
    });

    test('leaves out a Friend resting on their Due Date', () async {
      await writeFriend('resting', cadenceDays: 30, daysAgo: 30);
      // Midday of the Due Date. The Phase carries the hours since local
      // midnight, so it has passed one while the day has not passed.
      clock.advance(const Duration(hours: 12));
      final list = aList();
      addTearDown(list.close);

      final reading = await readingOf(list);
      final resting = reading.cards.single;

      expect(resting.phase, greaterThan(1));
      expect(resting.standing, Standing.nearing);
      expect(reading.overdue, isEmpty);
    });

    test('holds a Friend a chip has hidden', () async {
      await writeFriend('late outer', cadenceDays: 90, daysAgo: 200);
      await writeFriend('inner', cadenceDays: 7, daysAgo: 1);
      final list = aList();
      addTearDown(list.close);

      list.showOrbit(Orbit.inner);
      final reading = await readingOf(list);

      expect(namesOn(reading), ['inner']);
      expect(reading.overdue.single.name, 'late outer');
    });

    test('holds a Friend a term has hidden', () async {
      await writeFriend('late anna', cadenceDays: 10, daysAgo: 30);
      await writeFriend('ben', cadenceDays: 7, daysAgo: 1);
      final list = aList();
      addTearDown(list.close);

      list.search('ben');
      final reading = await readingOf(list);

      expect(namesOn(reading), ['ben']);
      expect(reading.overdue.single.name, 'late anna');
    });

    test('gives the Overdue Friends back as the first cards on '
        'Review', () async {
      await writeFriend('late anna', cadenceDays: 10, daysAgo: 30);
      await writeFriend('ben', cadenceDays: 7, daysAgo: 1);
      final list = aList();
      addTearDown(list.close);
      list.search('ben');
      list.showOrbit(Orbit.inner);
      await readingOf(list);

      list.review();
      final reading = await readingOf(list);

      expect(reading.term, '');
      expect(reading.orbit, isNull);
      expect(namesOn(reading).first, 'late anna');
    });

    test('loses a Friend as soon as a Meeting with them is '
        'logged', () async {
      await writeFriend('late', cadenceDays: 10, daysAgo: 30);
      final list = aList();
      addTearDown(list.close);
      expect((await readingOf(list)).overdue, hasLength(1));

      await list.logMeeting('late');
      final reading = await readingOf(list);

      expect(reading.overdue, isEmpty);
      expect(reading.cards.single.standing, Standing.freshlyReset);
    });

    test('counts every Overdue Friend, however many names fit', () async {
      for (var index = 0; index < 9; index++) {
        await writeFriend('late-$index', cadenceDays: 10, daysAgo: 20 + index);
      }
      final list = aList();
      addTearDown(list.close);

      final reading = await readingOf(list);

      expect(reading.overdueCount, 9);
      expect(reading.overdue, hasLength(9));
    });
  });

  group('the state', () {
    test('works every card out from one now', () async {
      for (var index = 0; index < 40; index++) {
        await writeFriend('friend-$index', cadenceDays: 30, daysAgo: 10);
      }
      final list = FriendsCubit(
        friends: friends,
        databases: wiring.databases,
        dayChange: dayChange,
        clock: RunningClock(today),
      );
      addTearDown(list.close);

      final phases = (await readingOf(
        list,
      )).cards.map((card) => card.phase).toSet();

      expect(phases, hasLength(1));
    });

    test('moves a card, its Orbit and its place when the Cadence '
        'changes', () async {
      await writeFriend('moving', cadenceDays: 7, daysAgo: 3);
      await writeFriend('steady', cadenceDays: 30, daysAgo: 20);
      final list = aList();
      addTearDown(list.close);
      final before = await readingOf(list);

      expect(namesOn(before), ['steady', 'moving']);
      expect(before.cards.last.orbit, Orbit.inner);

      final moving = (await friends.load('moving'))!;
      await friends.save(moving.copyWith(cadence: Cadence.ofDays(90)));
      final after = await readingOf(list);

      expect(namesOn(after), ['steady', 'moving']);
      expect(after.cards.last.orbit, Orbit.outer);
      expect(after.counts.of(Orbit.inner), 0);
      expect(after.counts.of(Orbit.outer), 1);
    });

    test('writes one Meeting dated today, and moves the card', () async {
      await writeFriend('late', cadenceDays: 10, daysAgo: 30);
      await writeFriend('fine', cadenceDays: 30, daysAgo: 20);
      final list = aList();
      addTearDown(list.close);
      expect(namesOn(await readingOf(list)), ['late', 'fine']);

      await list.logMeeting('late');
      expect(namesOn(await readingOf(list)), ['fine', 'late']);

      final late = (await friends.load('late'))!;
      expect(late.meetings, hasLength(2));
      expect(late.lastMet, CivilDate(2026, 9, 10));
    });

    test('deletes no Topic when a Meeting is logged', () async {
      await writeFriend(
        'late',
        cadenceDays: 10,
        daysAgo: 30,
        topics: ['ask about Kyoto', 'the pottery workshop'],
      );
      final list = aList();
      addTearDown(list.close);
      await readingOf(list);

      await list.logMeeting('late');
      final reading = await readingOf(list);

      expect(reading.cards.single.friend.topicsWaiting, 2);
      expect((await friends.load('late'))!.notes, hasLength(2));
    });

    test('holds no card, no term and no chip behind a lock', () async {
      await writeFriend('anna', cadenceDays: 10, daysAgo: 3);
      final list = aList();
      addTearDown(list.close);
      list.search('anna');
      list.showOrbit(Orbit.inner);
      await readingOf(list);

      await wiring.session.lock();
      final reading = await readingOf(list);

      expect(reading.isLocked, isTrue);
      expect(reading.cards, isEmpty);
      expect(reading.overdue, isEmpty);
      expect(reading.term, '');
      expect(reading.orbit, isNull);
    });

    test('reads as locked rather than as a roster with no Friend', () async {
      final empty = aList();
      addTearDown(empty.close);
      final emptyReading = await readingOf(empty);

      await wiring.session.lock();
      final list = aList();
      addTearDown(list.close);
      final lockedReading = await readingOf(list);

      expect(emptyReading.emptiness, Emptiness.noFriends);
      expect(emptyReading.isLocked, isFalse);
      expect(lockedReading.emptiness, Emptiness.none);
      expect(lockedReading.isLocked, isTrue);
    });

    test('fills again on unlock, on the same bloc', () async {
      await writeFriend('anna', cadenceDays: 10, daysAgo: 3);
      final list = aList();
      addTearDown(list.close);
      await readingOf(list);
      await wiring.session.lock();
      expect((await readingOf(list)).isLocked, isTrue);

      await wiring.session.unlock(profileId, '123456');
      final reading = await readingOf(list);

      expect(reading.isLocked, isFalse);
      expect(namesOn(reading), ['anna']);
    });

    test('refuses a write while the Profile is locked', () async {
      await writeFriend('anna', cadenceDays: 10, daysAgo: 3);
      final list = aList();
      addTearDown(list.close);
      await readingOf(list);
      await wiring.session.lock();

      await expectLater(
        list.logMeeting('anna'),
        throwsA(isA<DatabaseLockedError>()),
      );
    });

    test('reads again when the local Civil Date turns', () async {
      await writeFriend('turning', cadenceDays: 10, daysAgo: 10);
      // A tenth of a second before the Civil Date changes, so the timer the
      // screen sets is one a test can wait out.
      clock.advance(
        const Duration(hours: 23, minutes: 59, seconds: 59, milliseconds: 900),
      );
      final list = aList();
      addTearDown(list.close);
      expect((await readingOf(list)).overdue, isEmpty);

      clock.advance(const Duration(milliseconds: 200));
      // The timer fires when it fires, so wait for the answer rather than for
      // a length of time a loaded machine could miss.
      for (var tries = 0; tries < 40 && list.state.overdue.isEmpty; tries++) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await pumpEventQueue();
      }

      expect(list.state.overdue.single.name, 'turning');
    });

    test('reads again when the app resumes', () async {
      await writeFriend('turning', cadenceDays: 10, daysAgo: 10);
      final list = aList();
      addTearDown(list.close);
      expect((await readingOf(list)).overdue, isEmpty);

      clock.advance(const Duration(days: 1));
      list.didChangeAppLifecycleState(AppLifecycleState.resumed);
      final reading = await readingOf(list);

      expect(reading.overdue.single.name, 'turning');
      expect(reading.today, CivilDate(2026, 9, 11));
    });
  });
}
