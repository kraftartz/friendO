import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/core/friends/friend_repository.dart'
    show FriendRepository;
import 'package:friendo/core/time/civil_date_change.dart' show CivilDateChange;
import 'package:friendo/features/dial/bloc/dial_cubit.dart' show DialCubit;
import 'package:friendo/features/dial/bloc/dial_state.dart'
    show CadenceChanged, DialState, MeetingLogged;
import 'package:friendo/features/dial/packing/dial_geometry.dart'
    show DialGeometry;
import 'package:friendo_domain/friendo_domain.dart'
    show Cadence, CivilDate, Friend, Meeting, Orbit, Standing;

import '../../support/fixed_clock.dart';
import '../../support/wiring.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const geometry = DialGeometry();

  /// Local midnight, in a month no zone shifts its clock in, so a whole number
  /// of days back is a whole number of laps.
  final today = DateTime(2026, 9, 10);

  late Directory directory;
  late Wiring wiring;
  late FriendRepository friends;
  late FixedClock clock;
  late CivilDateChange dayChange;
  late String profileId;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    directory = Directory.systemTemp.createTempSync('friendo_dial');
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

  DialCubit aDial() => DialCubit(
    friends: friends,
    databases: wiring.databases,
    dayChange: dayChange,
    clock: clock,
    geometry: geometry,
  );

  /// Writes a Friend last met [daysAgo] days back, on a Cadence of
  /// [cadenceDays] days.
  Future<void> writeFriend(
    String id, {
    required int cadenceDays,
    required int daysAgo,
    String? name,
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
    ),
  );

  /// The state after the watch has delivered what the store holds.
  Future<DialState> readingOf(DialCubit dial) async {
    await pumpEventQueue();

    return dial.state;
  }

  test('an empty roster reads as empty, and not as locked', () async {
    final dial = aDial();
    addTearDown(dial.close);

    final reading = await readingOf(dial);

    expect(reading.isEmpty, isTrue);
    expect(reading.isLocked, isFalse);
    expect(reading.orbits, hasLength(3));
  });

  test('a locked Profile reads as locked and holds no Friend', () async {
    await writeFriend('ola', cadenceDays: 7, daysAgo: 30);
    final dial = aDial();
    addTearDown(dial.close);
    await readingOf(dial);

    await wiring.session.lock();
    final reading = await readingOf(dial);

    expect(reading.isLocked, isTrue);
    expect(reading.isEmpty, isFalse);
    expect(reading.orbits, isEmpty);
    expect(reading.emphasisedId, isNull);
    expect(reading.counts.total, 0);
  });

  test('unlocking fills the reading again, on the same bloc', () async {
    await writeFriend('ola', cadenceDays: 7, daysAgo: 30);
    final dial = aDial();
    addTearDown(dial.close);
    await readingOf(dial);
    await wiring.session.lock();
    await readingOf(dial);

    await wiring.session.unlock(profileId, '123456');
    final reading = await readingOf(dial);

    expect(reading.isLocked, isFalse);
    expect(reading.orbitOf(Orbit.inner).beads.single.name, 'ola');
  });

  test('the counts are the domain, and they add up to the roster', () async {
    await writeFriend('fresh', cadenceDays: 100, daysAgo: 1);
    await writeFriend('turning', cadenceDays: 10, daysAgo: 5);
    await writeFriend('nearing', cadenceDays: 10, daysAgo: 8);
    await writeFriend('late', cadenceDays: 10, daysAgo: 30);
    final dial = aDial();
    addTearDown(dial.close);

    final counts = (await readingOf(dial)).counts;

    expect(counts.freshlyReset, 1);
    expect(counts.inOrbit, 1);
    expect(counts.nearing, 1);
    expect(counts.overdue, 1);
    expect(counts.total, 4);
  });

  test('the emphasis names the Friend at the head of the ranking', () async {
    await writeFriend('later', cadenceDays: 7, daysAgo: 20);
    await writeFriend('latest', cadenceDays: 90, daysAgo: 200);
    await writeFriend('fine', cadenceDays: 30, daysAgo: 1);
    final dial = aDial();
    addTearDown(dial.close);

    expect((await readingOf(dial)).emphasisedId, 'latest');
  });

  test('with nobody Overdue the emphasis is the highest Phase', () async {
    await writeFriend('quarter', cadenceDays: 20, daysAgo: 5);
    await writeFriend('most', cadenceDays: 20, daysAgo: 19);
    await writeFriend('half', cadenceDays: 20, daysAgo: 10);
    final dial = aDial();
    addTearDown(dial.close);

    final reading = await readingOf(dial);

    expect(reading.emphasisedId, 'most');
    expect(reading.counts.overdue, 0);
  });

  test('with no Friends there is nobody to emphasise', () async {
    final dial = aDial();
    addTearDown(dial.close);

    expect((await readingOf(dial)).emphasisedId, isNull);
  });

  test('logging a Meeting returns the Bead to the top of the lap', () async {
    await writeFriend('ola', cadenceDays: 10, daysAgo: 3);
    final dial = aDial();
    addTearDown(dial.close);
    await readingOf(dial);

    await dial.logMeeting('ola');
    final reading = await readingOf(dial);

    expect(reading.orbitOf(Orbit.inner).beads.single.phase, 0);
    expect(reading.cause, const MeetingLogged('ola'));
  });

  test('logging a Meeting writes one Meeting, dated today', () async {
    await writeFriend('ola', cadenceDays: 10, daysAgo: 3);
    final dial = aDial();
    addTearDown(dial.close);
    await readingOf(dial);

    await dial.logMeeting('ola');
    await readingOf(dial);

    final ola = (await friends.load('ola'))!;
    expect(ola.meetings, hasLength(2));
    expect(ola.lastMet, CivilDate(2026, 9, 10));
  });

  test('a Meeting is never written for a Friend nobody named', () async {
    final dial = aDial();
    addTearDown(dial.close);
    await readingOf(dial);

    await dial.logMeeting('nobody');

    expect(await friends.load('nobody'), isNull);
  });

  test('a change that arrives through the store carries no cause', () async {
    await writeFriend('ola', cadenceDays: 10, daysAgo: 3);
    final dial = aDial();
    addTearDown(dial.close);
    await readingOf(dial);

    await writeFriend('zosia', cadenceDays: 10, daysAgo: 4);
    final reading = await readingOf(dial);

    expect(reading.cause, isNull);
    expect(reading.orbitOf(Orbit.inner).beads, hasLength(2));
  });

  test('a Cadence changed on the Dial says so, and names the Friend', () async {
    await writeFriend('ola', cadenceDays: 10, daysAgo: 3);
    final dial = aDial();
    addTearDown(dial.close);
    await readingOf(dial);

    await dial.changeCadence('ola', Cadence.ofDays(30));
    final reading = await readingOf(dial);

    expect(reading.cause, const CadenceChanged('ola'));
  });

  test('a Cadence across a boundary moves the Friend to another '
      'Orbit', () async {
    await writeFriend('ola', cadenceDays: 10, daysAgo: 3);
    final dial = aDial();
    addTearDown(dial.close);
    expect(
      (await readingOf(dial)).orbitOf(Orbit.inner).beads.single.name,
      'ola',
    );

    await dial.changeCadence('ola', Cadence.ofDays(61));
    final reading = await readingOf(dial);

    expect(reading.orbitOf(Orbit.inner).beads, isEmpty);
    expect(reading.orbitOf(Orbit.outer).beads.single.name, 'ola');
  });

  test('a Cadence that puts the Due Date behind us makes the Friend '
      'Overdue', () async {
    await writeFriend('ola', cadenceDays: 30, daysAgo: 20);
    final dial = aDial();
    addTearDown(dial.close);
    expect((await readingOf(dial)).counts.overdue, 0);

    await dial.changeCadence('ola', Cadence.ofDays(7));
    final reading = await readingOf(dial);

    expect(reading.counts.overdue, 1);
    expect(
      reading.orbitOf(Orbit.inner).beads.single.standing,
      Standing.overdue,
    );
    expect(reading.orbitOf(Orbit.inner).beads.single.phase, 1);
  });

  group('the Overflow Badge', () {
    setUp(() async {
      for (var index = 0; index < 13; index++) {
        await writeFriend('friend-$index', cadenceDays: 7, daysAgo: 30 - index);
      }
    });

    test('takes the last place, and counts the Bead it displaced', () async {
      final dial = aDial();
      addTearDown(dial.close);

      final inner = (await readingOf(dial)).orbitOf(Orbit.inner);

      expect(inner.beads, hasLength(11));
      expect(inner.badge!.count, 2);
      expect(
        inner.badge!.phase,
        inner.beads.last.phase - geometry.minGapOf(Orbit.inner),
      );
    });

    test('grows when a logged Meeting pushes a Friend behind it', () async {
      final dial = aDial();
      addTearDown(dial.close);
      await readingOf(dial);

      await dial.logMeeting('friend-0');
      final inner = (await readingOf(dial)).orbitOf(Orbit.inner);

      expect(inner.badge!.count, 2);
      expect(inner.beads.map((bead) => bead.name), isNot(contains('friend-0')));
    });

    test('is not drawn while the roster fits', () async {
      await friends.delete('friend-12');
      final dial = aDial();
      addTearDown(dial.close);

      final inner = (await readingOf(dial)).orbitOf(Orbit.inner);

      expect(inner.badge, isNull);
      expect(inner.beads, hasLength(12));
    });
  });

  test('two readings of one roster at one now are equal', () async {
    await writeFriend('ola', cadenceDays: 10, daysAgo: 3);
    await writeFriend('zosia', cadenceDays: 40, daysAgo: 50);
    final first = aDial();
    final second = aDial();
    addTearDown(first.close);
    addTearDown(second.close);

    expect(await readingOf(first), await readingOf(second));
  });

  test('the turn of the Civil Date packs the Friends again', () async {
    await writeFriend('ola', cadenceDays: 10, daysAgo: 10);
    // A tenth of a second before the local Civil Date changes, so the timer
    // the Dial sets is one a test can wait out.
    clock.advance(
      const Duration(hours: 23, minutes: 59, seconds: 59, milliseconds: 900),
    );
    final dial = aDial();
    addTearDown(dial.close);
    expect((await readingOf(dial)).counts.overdue, 0);

    clock.advance(const Duration(milliseconds: 200));
    await Future<void>.delayed(const Duration(milliseconds: 400));
    await pumpEventQueue();

    expect(dial.state.counts.overdue, 1);
  });
}
