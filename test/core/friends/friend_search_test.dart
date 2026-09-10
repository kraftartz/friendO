import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/core/friends/friend_repository.dart'
    show FriendRepository;
import 'package:friendo_domain/friendo_domain.dart'
    show Affinity, Cadence, CivilDate, Friend, Meeting, Note, NoteLabel, Orbit;

import '../../support/wiring.dart';

/// Search, run against the engine the app ships.
///
/// No test here names a column or reads the text of a statement. What LIKE
/// does with an upper case letter that holds a stroke is the thing most
/// likely to break, and only the engine can answer it. See ADR-0033.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final today = DateTime(2026, 9, 10);

  late Directory directory;
  late Wiring wiring;
  late FriendRepository friends;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    directory = Directory.systemTemp.createTempSync('friendo_search');
    wiring = Wiring(directory);
    friends = FriendRepository(wiring.databases);
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

  Future<void> writeFriend(
    String id, {
    required String name,
    int cadenceDays = 30,
    List<String> topics = const [],
    List<String> affinities = const [],
  }) => friends.save(
    Friend.started(
      id: id,
      name: name,
      cadence: Cadence.ofDays(cadenceDays),
      firstMeeting: Meeting(id: 'm-$id', happenedOn: CivilDate(2026, 9, 1)),
      now: today,
      notes: [
        for (var at = 0; at < topics.length; at++)
          Note(
            id: 'n-$id-$at',
            label: NoteLabel.topic,
            body: topics[at],
            writtenOn: CivilDate(2026, 9, 1 + at),
          ),
      ],
      affinities: [
        for (final label in affinities) Affinity(id: label, label: label),
      ],
    ),
  );

  Future<Set<String>?> matching(String term) => friends.friendIdsMatching(term);

  test('finds a term in the middle of a name', () async {
    await writeFriend('f1', name: 'Quinzelfarb');
    await writeFriend('f2', name: 'Anna');

    expect(await matching('farb'), {'f1'});
  });

  test('gives the same answer whatever case the User types', () async {
    await writeFriend('f1', name: 'SARAH');
    await writeFriend('f2', name: 'sarah');

    expect(await matching('sarah'), {'f1', 'f2'});
    expect(await matching('SARAH'), {'f1', 'f2'});
  });

  test('finds a name with a stroke from a plain spelling', () async {
    await writeFriend('f1', name: 'Michał');

    expect(await matching('michal'), {'f1'});
  });

  test('finds a name with a stroke from the spelling that holds it', () async {
    await writeFriend('f1', name: 'Michał');

    expect(await matching('michał'), {'f1'});
  });

  test('finds a name with a diaeresis from a plain spelling', () async {
    await writeFriend('f1', name: 'Zoë');

    expect(await matching('zoe'), {'f1'});
  });

  test('finds a name with the sharp s from a plain spelling', () async {
    await writeFriend('f1', name: 'Straße');

    expect(await matching('strasse'), {'f1'});
  });

  test('finds the Friend a matching Topic belongs to', () async {
    await writeFriend('f1', name: 'Anna', topics: ['ask about Kyoto']);
    await writeFriend('f2', name: 'Ben');

    expect(await matching('kyoto'), {'f1'});
  });

  test('finds every Friend who holds a matching Affinity', () async {
    await writeFriend('f1', name: 'Anna', affinities: ['Climbing']);
    await writeFriend('f2', name: 'Ben', affinities: ['Climbing']);
    await writeFriend('f3', name: 'Cara', affinities: ['Pottery']);

    expect(await matching('climb'), {'f1', 'f2'});
  });

  test('finds every Friend on an Orbit the term names', () async {
    await writeFriend('f1', name: 'Anna', cadenceDays: 7);
    await writeFriend('f2', name: 'Ben', cadenceDays: 30);
    await writeFriend('f3', name: 'Cara', cadenceDays: 90);

    expect(await matching('inner'), {'f1'});
  });

  test('names a Friend once however many of their Topics match', () async {
    await writeFriend(
      'f1',
      name: 'Kyoto Anna',
      topics: ['kyoto trip', 'kyoto food', 'kyoto again'],
    );

    expect(await matching('kyoto'), {'f1'});
  });

  test('reads a percent the User types as a letter', () async {
    await writeFriend('f1', name: '50% Anna');
    await writeFriend('f2', name: 'Ben');

    expect(await matching('%'), {'f1'});
  });

  test('reads an underscore the User types as a letter', () async {
    await writeFriend('f1', name: 'a_b');
    await writeFriend('f2', name: 'axb');

    expect(await matching('a_b'), {'f1'});
  });

  test('reads a backslash the User types as a letter', () async {
    await writeFriend('f1', name: r'A\B');
    await writeFriend('f2', name: 'AB');

    expect(await matching(r'\'), {'f1'});
  });

  test('narrows nothing when the term holds nothing', () async {
    await writeFriend('f1', name: 'Anna');

    expect(await matching(''), isNull);
    expect(await matching('   '), isNull);
  });

  test('names nobody when the term matches nobody', () async {
    await writeFriend('f1', name: 'Anna');

    expect(await matching('zebra'), isEmpty);
  });

  group('the Orbit arm and the Orbit of a Cadence agree', () {
    const boundaries = {
      14: Orbit.inner,
      15: Orbit.middle,
      60: Orbit.middle,
      61: Orbit.outer,
    };

    for (final boundary in boundaries.entries) {
      test(
        'a Cadence of ${boundary.key} days is on ${boundary.value.name}',
        () async {
          await writeFriend('f1', name: 'Anna', cadenceDays: boundary.key);

          for (final orbit in Orbit.values) {
            final byName = await matching(orbit.name);
            final byCadence = orbit == boundary.value ? {'f1'} : <String>{};

            expect(byName, byCadence, reason: 'the ${orbit.name} Orbit');
          }
        },
      );
    }
  });
}
