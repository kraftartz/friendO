import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/core/friends/friend_repository.dart'
    show FriendRepository;
import 'package:friendo/core/friends/listed_friend.dart' show ListedFriend;
import 'package:friendo_domain/friendo_domain.dart'
    show Cadence, CivilDate, Friend, Meeting, Note, NoteLabel;

import '../../support/fixed_clock.dart';
import '../../support/wiring.dart';

/// The rows the Friends List draws from.
///
/// One Friend gives one row. The row holds the writing on a card and nothing
/// the domain works out, so no Phase, no Standing and no Due Date arrive here.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final today = DateTime(2026, 9, 10);

  late Directory directory;
  late Wiring wiring;
  late FixedClock clock;
  late FriendRepository friends;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    directory = Directory.systemTemp.createTempSync('friendo_listing');
    wiring = Wiring(directory);
    clock = FixedClock(today);
    friends = FriendRepository(wiring.databases, clock: clock);
    final profileId = (await wiring.creator.createProfile(
      'Michal',
      '123456',
    )).id;
    await wiring.session.unlock(profileId, '123456');
  });

  tearDown(() async {
    await wiring.dispose();
    directory.deleteSync(recursive: true);
  });

  Future<ListedFriend> theOnlyRow() async {
    final rows = await friends.watchListedFriends().first;

    return rows.single;
  }

  test('carries the name as the User wrote it, and the Cadence', () async {
    await friends.save(
      Friend.started(
        id: 'f1',
        name: 'Michał',
        cadence: Cadence.ofDays(21),
        firstMeeting: Meeting(id: 'm1', happenedOn: CivilDate(2026, 9, 1)),
        now: today,
      ),
    );

    final row = await theOnlyRow();

    expect(row.id, 'f1');
    expect(row.name, 'Michał');
    expect(row.cadence, Cadence.ofDays(21));
    expect(row.avatarSeed, 'f1');
  });

  test('carries the newest Meeting, with its place and its time', () async {
    await friends.save(
      Friend.hydrate(
        id: 'f1',
        name: 'Anna',
        cadence: Cadence.ofDays(30),
        meetings: [
          Meeting(
            id: 'm1',
            happenedOn: CivilDate(2026, 8, 1),
            place: 'the old place',
          ),
          Meeting(
            id: 'm2',
            happenedOn: CivilDate(2026, 9, 4),
            happenedAtMinute: 14 * 60,
            place: 'Blue Bottle Coffee',
          ),
        ],
      ),
    );

    final row = await theOnlyRow();

    expect(row.lastMet, CivilDate(2026, 9, 4));
    expect(row.lastMetAtMinute, 14 * 60);
    expect(row.lastMetPlace, 'Blue Bottle Coffee');
  });

  test('leaves the time out when the User set none', () async {
    await friends.save(
      Friend.started(
        id: 'f1',
        name: 'Anna',
        cadence: Cadence.ofDays(30),
        firstMeeting: Meeting(id: 'm1', happenedOn: CivilDate(2026, 9, 1)),
        now: today,
      ),
    );

    final row = await theOnlyRow();

    expect(row.lastMetAtMinute, isNull);
    expect(row.lastMetPlace, isNull);
  });

  test('carries the newest waiting Topic, and how many wait', () async {
    await friends.save(
      Friend.started(
        id: 'f1',
        name: 'Anna',
        cadence: Cadence.ofDays(30),
        firstMeeting: Meeting(id: 'm1', happenedOn: CivilDate(2026, 9, 1)),
        now: today,
        notes: [
          Note(
            id: 'n1',
            label: NoteLabel.topic,
            body: 'the older Topic',
            writtenOn: CivilDate(2026, 9, 2),
          ),
          Note(
            id: 'n2',
            label: NoteLabel.topic,
            body: 'the newest Topic',
            writtenOn: CivilDate(2026, 9, 6),
          ),
          Note(
            id: 'n3',
            label: NoteLabel.update,
            body: 'an Update, which is not a Topic',
            writtenOn: CivilDate(2026, 9, 8),
          ),
        ],
      ),
    );

    final row = await theOnlyRow();

    expect(row.newestTopic, 'the newest Topic');
    expect(row.topicsWaiting, 2);
  });

  test('carries no Topic when the Friend has none waiting', () async {
    await friends.save(
      Friend.started(
        id: 'f1',
        name: 'Anna',
        cadence: Cadence.ofDays(30),
        firstMeeting: Meeting(id: 'm1', happenedOn: CivilDate(2026, 9, 1)),
        now: today,
      ),
    );

    final row = await theOnlyRow();

    expect(row.newestTopic, isNull);
    expect(row.topicsWaiting, 0);
  });

  test('gives one row for each Friend', () async {
    for (final id in ['f1', 'f2', 'f3']) {
      await friends.save(
        Friend.started(
          id: id,
          name: id,
          cadence: Cadence.ofDays(30),
          firstMeeting: Meeting(id: 'm-$id', happenedOn: CivilDate(2026, 9, 1)),
          now: today,
          notes: [
            Note(
              id: 'n-$id',
              label: NoteLabel.topic,
              body: 'a Topic',
              writtenOn: CivilDate(2026, 9, 2),
            ),
          ],
        ),
      );
    }

    final rows = await friends.watchListedFriends().first;

    expect(rows.map((row) => row.id).toList(), ['f1', 'f2', 'f3']);
  });
}
