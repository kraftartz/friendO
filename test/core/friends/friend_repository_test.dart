import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/core/db/database_session.dart';
import 'package:friendo/core/friends/friend_repository.dart';
import 'package:friendo_domain/friendo_domain.dart';

import '../../support/wiring.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final today = DateTime.utc(2026, 9, 10);

  late Directory directory;
  late Wiring wiring;
  late FriendRepository friends;
  late String profileId;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    directory = Directory.systemTemp.createTempSync('friendo_repository');
    wiring = Wiring(directory);
    friends = FriendRepository(wiring.databases);
    profileId = (await wiring.creator.createProfile('Michal', '123456')).id;
    await wiring.session.unlock(profileId, '123456');
  });

  tearDown(() async {
    await wiring.databases.close();
    directory.deleteSync(recursive: true);
  });

  Meeting aMeeting(String id, int day) =>
      Meeting(id: id, happenedOn: CivilDate(2026, 9, day));

  Friend aFriend({
    String id = 'f1',
    String name = 'Michał',
    String meetingId = 'm1',
    int day = 1,
  }) => Friend.started(
    id: id,
    name: name,
    cadence: Cadence.ofDays(7),
    firstMeeting: aMeeting(meetingId, day),
    now: today,
  );

  test('reads back the whole Friend it wrote', () async {
    final written = aFriend().copyWith(
      notes: [
        Note(
          id: 'n1',
          label: NoteLabel.topic,
          body: 'Ask about Zoë',
          writtenOn: CivilDate(2026, 9, 2),
        ),
      ],
      facts: [Fact(id: 'x1', label: 'City', value: 'Kraków')],
      affinities: [Affinity(id: 'a1', label: 'Family')],
      milestones: [
        Milestone(
          id: 's1',
          label: 'Birthday',
          onDate: CivilDate(1988, 10, 14),
          repeatsYearly: true,
        ),
      ],
    );
    await friends.save(written);

    expect(await friends.load('f1'), written);
  });

  test('answers nothing for a Friend this Profile does not hold', () async {
    expect(await friends.load('nobody'), isNull);
  });

  test(
    'writes the Friend and the first Meeting together, or neither',
    () async {
      await friends.save(aFriend());

      // The second Friend carries a Meeting id that is taken, so the Meeting
      // cannot be written after the Friend.
      await expectLater(
        friends.save(aFriend(id: 'f2', name: 'Ola', day: 2)),
        throwsA(isA<Object>()),
      );

      expect(await friends.load('f2'), isNull);
    },
  );

  test('works the last Meeting out from the Meetings it holds', () async {
    await friends.save(
      aFriend()
          .logMeeting(aMeeting('m2', 8), now: today)
          .logMeeting(aMeeting('m3', 4), now: today),
    );

    final placings = await friends.watchPlacings(now: today).first;

    expect(placings.single.placing.dueAt, CivilDate(2026, 9, 15));
  });

  test('stores the last Meeting nowhere', () async {
    await friends.save(aFriend());

    final columns = await wiring.databases.database
        .customSelect('pragma table_info(friends)')
        .get();

    expect(
      columns.map((row) => row.read<String>('name')),
      isNot(contains('last_met')),
    );
  });

  test('folds the name and the Affinity label on the way in', () async {
    await friends.save(
      aFriend().copyWith(
        affinities: [Affinity(id: 'a1', label: 'Ünni')],
      ),
    );

    final rows = await wiring.databases.database
        .customSelect(
          'select f.name_folded as name, a.label_folded as label '
          'from friends f, affinities a',
        )
        .getSingle();

    expect(rows.read<String>('name'), 'michal');
    expect(rows.read<String>('label'), 'unni');
  });

  group('deleting a Friend', () {
    setUp(() async {
      await friends.save(
        aFriend().copyWith(
          facts: [Fact(id: 'x1', label: 'City', value: 'Kraków')],
          affinities: [Affinity(id: 'a1', label: 'Family')],
        ),
      );
      await friends.delete('f1');
    });

    Future<int> countIn(String table) async {
      final row = await wiring.databases.database
          .customSelect('select count(*) as found from $table')
          .getSingle();

      return row.read<int>('found');
    }

    test('takes everything that belonged to them', () async {
      expect(await friends.load('f1'), isNull);
      expect(await countIn('meetings'), 0);
      expect(await countIn('facts'), 0);
      expect(await countIn('friend_affinities'), 0);
    });

    test('leaves the Affinity labels, which belong to the Profile', () async {
      expect(await countIn('affinities'), 1);
    });
  });

  group('across a lock', () {
    test('a write throws one named failure', () async {
      await wiring.session.lock();

      expect(
        () => friends.save(aFriend()),
        throwsA(isA<DatabaseLockedError>()),
      );
    });

    test('a read throws one named failure', () async {
      await wiring.session.lock();

      expect(() => friends.load('f1'), throwsA(isA<DatabaseLockedError>()));
    });

    test('the same repository reads again after the unlock', () async {
      await friends.save(aFriend());
      await wiring.session.lock();

      await wiring.session.unlock(profileId, '123456');

      expect((await friends.load('f1'))!.name, 'Michał');
    });

    test('a watch goes quiet, stays alive, and reads fresh rows', () async {
      final seen = <List<FriendPlacing>>[];
      final watching = friends.watchPlacings(now: today).listen(seen.add);
      await pumpEventQueue();
      await wiring.session.lock();
      await pumpEventQueue();

      expect(seen, [<FriendPlacing>[]]);

      await wiring.session.unlock(profileId, '123456');
      await friends.save(aFriend());
      await pumpEventQueue();

      expect(seen.last.single.name, 'Michał');
      await watching.cancel();
    });
  });
}
