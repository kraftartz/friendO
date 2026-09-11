import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/core/db/database_session.dart' show DatabaseLockedError;
import 'package:friendo/core/friends/friend_repository.dart'
    show FriendRepository;
import 'package:friendo/core/ids/new_id.dart' show newId;
import 'package:friendo/features/friends/bloc/add_friend_cubit.dart'
    show AddFriendCubit;
import 'package:friendo/features/friends/bloc/add_friend_state.dart'
    show AddFriendDraft;
import 'package:friendo/features/friends/cadence/cadence_choice.dart'
    show CadenceChoice;
import 'package:friendo_domain/friendo_domain.dart'
    show Cadence, CivilDate, Fact, Friend, Meeting, NoteLabel, Orbit, Standing;

import '../../support/fixed_clock.dart';
import '../../support/wiring.dart';

/// Add a Friend's own state, over a real repository, over a real database.
///
/// The validation, the domain call, the write, the transaction and the lock
/// all meet here, so one test reads what the form would write without drawing
/// it.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Local midnight, in a month no zone shifts its clock in.
  final today = DateTime(2026, 9, 10);

  late Directory directory;
  late Wiring wiring;
  late FriendRepository friends;
  late FixedClock clock;
  late String profileId;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    directory = Directory.systemTemp.createTempSync('friendo_add');
    wiring = Wiring(directory);
    clock = FixedClock(today);
    friends = FriendRepository(wiring.databases, clock: clock);
    profileId = (await wiring.creator.createProfile('Michal', '123456')).id;
    await wiring.session.unlock(profileId, '123456');
  });

  tearDown(() async {
    await wiring.dispose();
    directory.deleteSync(recursive: true);
  });

  AddFriendCubit theForm() => AddFriendCubit(
    friends: friends,
    databases: wiring.databases,
    clock: clock,
  );

  /// A form that has read the Profile's Affinities and Fact labels.
  Future<AddFriendCubit> anOpenForm() async {
    final form = theForm();
    while (form.state.isLocked) {
      await Future<void>.delayed(Duration.zero);
    }

    return form;
  }

  /// Fill in the three parts a save needs.
  AddFriendCubit fill(
    AddFriendCubit form, {
    String name = 'Anna',
    int daysAgo = 0,
    int cadenceDays = 30,
  }) {
    form
      ..typeName(name)
      ..chooseLastMet(CivilDate.from(today).addDays(-daysAgo))
      ..chooseCadence(CadenceChoice(Cadence.ofDays(cadenceDays)));

    return form;
  }

  Future<List<Friend>> everyFriend() async {
    final rows = await friends.watchDialFriends().first;

    return [for (final row in rows) (await friends.load(row.id))!];
  }

  group('saving a new Friend', () {
    test('writes one Friend and exactly one Meeting', () async {
      final form = await anOpenForm();
      fill(form);

      await form.save();

      final roster = await everyFriend();
      expect(roster, hasLength(1));
      expect(roster.single.name, 'Anna');
      expect(roster.single.meetings, hasLength(1));
      await form.close();
    });

    test('dates that Meeting on the day the User chose', () async {
      final form = await anOpenForm();
      fill(form, daysAgo: 40);

      await form.save();

      final friend = (await everyFriend()).single;
      expect(friend.lastMet, CivilDate.from(today).addDays(-40));
      expect(friend.lastMet, isNot(CivilDate.from(today)));
      await form.close();
    });

    test('offers today as the day the User last saw them', () async {
      final form = await anOpenForm();

      expect(form.state.lastMet, CivilDate.from(today));
      await form.close();
    });

    test('refuses a day that has not come, and writes nothing', () async {
      final form = await anOpenForm();
      fill(form).chooseLastMet(CivilDate.from(today).addDays(1));

      await form.save();

      expect(form.state.refusal, contains('today or an earlier day'));
      expect(form.state.isSaved, isFalse);
      expect(await everyFriend(), isEmpty);
      await form.close();
    });

    test('refuses a blank name and a name of spaces alone', () async {
      final form = await anOpenForm();
      fill(form, name: '');

      await form.save();
      expect(form.state.refusal, 'A Friend needs a name.');

      form.typeName('   ');
      await form.save();
      expect(form.state.refusal, 'A Friend needs a name.');
      expect(await everyFriend(), isEmpty);
      await form.close();
    });

    test('trims the ends of a name and leaves its inner text alone', () async {
      final form = await anOpenForm();
      fill(form, name: '  Anna  Maria  ');

      await form.save();

      expect((await everyFriend()).single.name, 'Anna  Maria');
      await form.close();
    });

    test('lets two Friends hold one name', () async {
      final first = await anOpenForm();
      fill(first, name: 'Anna');
      await first.save();
      await first.close();

      final second = await anOpenForm();
      fill(second, name: 'Anna');
      await second.save();
      await second.close();

      final roster = await everyFriend();
      expect(roster, hasLength(2));
      expect(roster.map((friend) => friend.name), everyElement('Anna'));
    });

    test('stores a stroke as typed and finds it by plain letters', () async {
      final form = await anOpenForm();
      fill(form, name: 'Michał Łódź');

      await form.save();

      final friend = (await everyFriend()).single;
      expect(friend.name, 'Michał Łódź');
      expect(await friends.friendIdsMatching('michal'), {friend.id});
      expect(await friends.friendIdsMatching('lodz'), {friend.id});
      await form.close();
    });

    test('refuses a Cadence of zero days and a negative one', () async {
      final form = await anOpenForm();
      final held = form.state.choice;

      form.typeCadence('0');
      expect(form.state.cadenceRefusal, isNotNull);
      expect(form.state.choice, held);

      form.typeCadence('-7');
      expect(form.state.cadenceRefusal, isNotNull);
      expect(form.state.choice, held);
      await form.close();
    });

    test('reads Overdue on a Friend last seen two years ago', () async {
      final form = await anOpenForm();
      fill(form, daysAgo: 730, cadenceDays: 30);

      expect(form.state.preview!.standing, Standing.overdue);
      await form.save();

      final friend = (await everyFriend()).single;
      expect(friend.placing(now: today).standing, Standing.overdue);
      await form.close();
    });

    test('reads Freshly Reset on a Friend seen today', () async {
      final form = await anOpenForm();
      fill(form);

      expect(form.state.preview!.standing, Standing.freshlyReset);
      await form.save();

      expect(
        (await everyFriend()).single.placing(now: today).standing,
        Standing.freshlyReset,
      );
      await form.close();
    });

    test('joins the Priority Order on the next read', () async {
      final before = await friends.watchDialFriends().first;

      final form = await anOpenForm();
      fill(form, name: 'Kasia', daysAgo: 90, cadenceDays: 7);
      await form.save();

      final after = await friends.watchDialFriends().first;
      expect(before, isEmpty);
      expect(after.map((row) => row.name), ['Kasia']);
      await form.close();
    });

    test('keeps a time of day when given, and stores none when not', () async {
      final withTime = await anOpenForm();
      fill(withTime, name: 'Anna');
      withTime.chooseMetAtMinute(19 * 60 + 30);
      await withTime.save();
      await withTime.close();

      final without = await anOpenForm();
      fill(without, name: 'Kasia');
      await without.save();
      await without.close();

      final roster = {
        for (final friend in await everyFriend()) friend.name: friend,
      };
      expect(roster['Anna']!.newestMeeting.happenedAtMinute, 19 * 60 + 30);
      expect(roster['Kasia']!.newestMeeting.happenedAtMinute, isNull);
    });
  });

  group('what the User already knows', () {
    test('links the Affinities chosen at creation', () async {
      final form = await anOpenForm();
      fill(form)
        ..chooseAffinity('Climbing')
        ..chooseAffinity('Coffee');

      await form.save();

      expect(
        (await everyFriend()).single.affinities.map(
          (affinity) => affinity.label,
        ),
        containsAll(['Climbing', 'Coffee']),
      );
      await form.close();
    });

    test(
      'writes a new Affinity once and offers it for the next Friend',
      () async {
        final first = await anOpenForm();
        fill(first, name: 'Anna').chooseAffinity('Bouldering');
        await first.save();
        await first.close();

        final second = await anOpenForm();
        expect(second.state.knownAffinities.map((affinity) => affinity.label), [
          'Bouldering',
        ]);
        await second.close();
      },
    );

    test('gives two Friends one Affinity row and not two', () async {
      final first = await anOpenForm();
      fill(first, name: 'Anna').chooseAffinity('Bouldering');
      await first.save();
      await first.close();

      final second = await anOpenForm();
      fill(second, name: 'Kasia').chooseAffinity('Bouldering');
      await second.save();
      await second.close();

      final labels = await friends.affinities();
      expect(labels, hasLength(1));

      final roster = await everyFriend();
      expect(roster, hasLength(2));
      expect(roster.map((friend) => friend.affinities.single.id).toSet(), {
        labels.single.id,
      });
    });

    test('stores the Facts and Milestones written at creation', () async {
      final form = await anOpenForm();
      fill(form)
        ..writeFact(label: 'Drinks', value: 'Flat white')
        ..writeMilestone(
          label: 'Birthday',
          onDate: CivilDate(1991, 4, 2),
          repeatsYearly: true,
        )
        ..writeMilestone(
          label: 'The day we met',
          onDate: CivilDate(2015, 6, 1),
        );

      await form.save();

      final friend = (await everyFriend()).single;
      expect(friend.facts.single.label, 'Drinks');
      expect(friend.facts.single.value, 'Flat white');

      final byLabel = {
        for (final milestone in friend.milestones)
          milestone.label: milestone.repeatsYearly,
      };
      expect(byLabel, {'Birthday': true, 'The day we met': false});
      await form.close();
    });

    test('stores the Topics, Updates and Notes written at creation', () async {
      final form = await anOpenForm();
      fill(form)
        ..writeNote(label: NoteLabel.topic, body: 'Ask about the move')
        ..writeNote(label: NoteLabel.update, body: 'Started a new job');

      await form.save();

      final friend = (await everyFriend()).single;
      expect(
        {for (final note in friend.notes) note.body: note.label},
        {
          'Ask about the move': NoteLabel.topic,
          'Started a new job': NoteLabel.update,
        },
      );
      await form.close();
    });
  });

  group('nothing half made', () {
    test(
      'leaves no Friend and no Meeting when the save fails part way',
      () async {
        // Two Facts under one id. The Friend row and the Meeting row are
        // written before the second Fact hits the primary key, so this is a
        // failure between the rows and not before them.
        final clash = newId();
        final friend = Friend.started(
          id: newId(),
          name: 'Anna',
          cadence: Cadence.ofDays(30),
          firstMeeting: Meeting(id: newId(), happenedOn: CivilDate.from(today)),
          now: today,
          facts: [
            Fact(id: clash, label: 'Drinks', value: 'Tea'),
            Fact(id: clash, label: 'Lives', value: 'Kraków'),
          ],
        );

        await expectLater(friends.save(friend), throwsA(isA<Object>()));

        expect(await friends.watchDialFriends().first, isEmpty);
        expect(await friends.load(friend.id), isNull);
      },
    );

    test('asks about abandoning only when something was typed', () async {
      final form = await anOpenForm();

      expect(form.state.hasTyping, isFalse);

      form.chooseLastMet(CivilDate.from(today).addDays(-3));
      expect(form.state.hasTyping, isFalse, reason: 'a date carries a default');

      form.chooseCadence(CadenceChoice.preset(Orbit.outer));
      expect(
        form.state.hasTyping,
        isFalse,
        reason: 'a Cadence carries a default',
      );

      form.typeName('An');
      expect(form.state.hasTyping, isTrue);

      form.typeName('');
      expect(form.state.hasTyping, isFalse);

      form.writeNote(label: NoteLabel.topic, body: 'Ask about the move');
      expect(form.state.hasTyping, isTrue);
      await form.close();
    });
  });

  group('the lock', () {
    blocTest<AddFriendCubit, AddFriendDraft>(
      'clears a half-typed Friend, and asks nothing first',
      build: theForm,
      wait: const Duration(milliseconds: 10),
      act: (form) async {
        form
          ..typeName('Anna')
          ..writeNote(label: NoteLabel.topic, body: 'Ask about the move');

        await wiring.session.lock();
      },
      verify: (form) {
        expect(form.state.isLocked, isTrue);
        expect(form.state.name, isEmpty);
        expect(form.state.notes, isEmpty);
        expect(form.state.hasTyping, isFalse);
      },
    );

    blocTest<AddFriendCubit, AddFriendDraft>(
      'tells a locked screen apart from a form with nothing typed',
      build: theForm,
      wait: const Duration(milliseconds: 10),
      act: (form) async => wiring.session.lock(),
      verify: (form) {
        final locked = form.state;
        final fresh = AddFriendDraft.fresh(now: today, friendId: 'f1');

        expect(locked.isLocked, isTrue);
        expect(fresh.isLocked, isFalse);
        expect(locked, isNot(fresh));
        expect(locked.now, isNull, reason: 'a locked screen reads nothing');
        expect(fresh.lastMet, isNotNull);
      },
    );

    test('refuses to write while locked', () async {
      final form = await anOpenForm();
      fill(form);
      await wiring.session.lock();

      await expectLater(form.save(), throwsA(isA<DatabaseLockedError>()));
      expect(form.state.isSaved, isFalse);
      await form.close();
    });

    test('comes back with fresh data on unlock', () async {
      final form = await anOpenForm();
      fill(form, name: 'Anna').chooseAffinity('Climbing');
      await form.save();
      await form.close();

      await wiring.session.lock();
      final locked = theForm();
      expect(locked.state.isLocked, isTrue);

      await wiring.session.unlock(profileId, '123456');
      while (locked.state.isLocked) {
        await Future<void>.delayed(Duration.zero);
      }

      expect(locked.state.knownAffinities.map((affinity) => affinity.label), [
        'Climbing',
      ]);
      await locked.close();
    });
  });
}
