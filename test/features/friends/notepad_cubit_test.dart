import 'dart:io';

import 'package:flutter/widgets.dart' show AppLifecycleState;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/core/db/database_session.dart' show DatabaseLockedError;
import 'package:friendo/core/friends/friend_repository.dart'
    show FriendRepository;
import 'package:friendo/core/time/civil_date_change.dart' show CivilDateChange;
import 'package:friendo/features/friends/bloc/notepad_cubit.dart'
    show NotepadCubit;
import 'package:friendo/features/friends/cadence/cadence_choice.dart'
    show CadenceChoice;
import 'package:friendo_domain/friendo_domain.dart'
    show
        Affinity,
        Cadence,
        CivilDate,
        Fact,
        Friend,
        Meeting,
        Milestone,
        Note,
        NoteLabel,
        Orbit,
        PriorityOrder,
        Standing;

import '../../support/fixed_clock.dart';
import '../../support/wiring.dart';

/// The Friend Notepad's state, over a real repository, over a real database.
///
/// The screen writes, so the thing worth proving is what survives the write.
/// Every assertion below reads the aggregate back out of the store.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Local midnight, in a month no zone shifts its clock in.
  final today = DateTime(2026, 9, 10);

  late Directory directory;
  late Wiring wiring;
  late FriendRepository friends;
  late FixedClock clock;
  late CivilDateChange dayChange;
  late String profileId;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    directory = Directory.systemTemp.createTempSync('friendo_notepad');
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

  CivilDate day(int daysAgo) => CivilDate.from(today).addDays(-daysAgo);

  Future<void> writeFriend(
    String id, {
    String? name,
    int cadenceDays = 30,
    List<int> metDaysAgo = const [0],
    List<Note> notes = const [],
    List<Fact> facts = const [],
    List<Milestone> milestones = const [],
  }) => friends.save(
    Friend.hydrate(
      id: id,
      name: name ?? id,
      cadence: Cadence.ofDays(cadenceDays),
      meetings: [
        for (final daysAgo in metDaysAgo)
          Meeting(id: 'm-$id-$daysAgo', happenedOn: day(daysAgo)),
      ],
      notes: notes,
      facts: facts,
      milestones: milestones,
    ),
  );

  NotepadCubit theNotepad(String friendId) => NotepadCubit(
    friendId: friendId,
    friends: friends,
    databases: wiring.databases,
    dayChange: dayChange,
    clock: clock,
  );

  /// Wait for [answer], which arrives on a stream and not on a return.
  Future<void> until(bool Function() answer) async {
    for (var tries = 0; tries < 200 && !answer(); tries++) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await pumpEventQueue();
    }
  }

  Future<NotepadCubit> anOpenNotepad(String friendId) async {
    final notepad = theNotepad(friendId);
    while (notepad.state.friend == null) {
      await Future<void>.delayed(Duration.zero);
    }

    return notepad;
  }

  group('what the screen loads', () {
    test('reads the Friend and everything about them', () async {
      await writeFriend(
        'f1',
        name: 'Anna',
        metDaysAgo: [0, 40],
        notes: [
          Note(
            id: 'n1',
            label: NoteLabel.topic,
            body: 'Ask about the move',
            writtenOn: day(2),
          ),
        ],
        facts: [Fact(id: 'k1', label: 'Drinks', value: 'Flat white')],
        milestones: [
          Milestone(
            id: 'ms1',
            label: 'Birthday',
            onDate: CivilDate(1991, 4, 2),
            repeatsYearly: true,
          ),
        ],
      );

      final notepad = await anOpenNotepad('f1');
      final reading = notepad.state;

      expect(reading.name, 'Anna');
      expect(reading.meetings, hasLength(2));
      expect(reading.topics.single.body, 'Ask about the move');
      expect(reading.facts.single.label, 'Drinks');
      expect(reading.milestones.single.repeatsYearly, isTrue);
      expect(reading.cadence, Cadence.ofDays(30));
      expect(reading.orbit, Orbit.middle);
      await notepad.close();
    });

    test('shows every Meeting newest first', () async {
      await writeFriend('f1', metDaysAgo: [30, 0, 90, 7]);

      final notepad = await anOpenNotepad('f1');

      expect(notepad.state.meetings.map((meeting) => meeting.happenedOn), [
        day(0),
        day(7),
        day(30),
        day(90),
      ]);
      await notepad.close();
    });

    test('builds the whole screen on one now', () async {
      await writeFriend('f1', metDaysAgo: [3]);

      final notepad = await anOpenNotepad('f1');
      final reading = notepad.state;

      expect(reading.today, CivilDate.from(reading.now!));
      expect(reading.placing!.dueAt, day(3).addDays(30));
      expect(
        reading.tunerPreview!.dueAt,
        reading.placing!.dueAt,
        reason: 'the header and the tuner read one now',
      );
      await notepad.close();
    });
  });

  group('writing about a Friend', () {
    Future<NotepadCubit> aNotepadWith(String body, NoteLabel label) async {
      await writeFriend('f1');
      final notepad = await anOpenNotepad('f1');
      notepad
        ..chooseNoteLabel(label)
        ..typeNote(body);
      await notepad.writeNote();

      return notepad;
    }

    test('writes a Note into its own label group and no other', () async {
      final notepad = await aNotepadWith('Ask about the move', NoteLabel.topic);

      expect(notepad.state.topics.single.body, 'Ask about the move');
      expect(notepad.state.updates, isEmpty);
      expect(notepad.state.notes, isEmpty);
      await notepad.close();
    });

    test('moves a Note between groups and changes nothing else', () async {
      final notepad = await aNotepadWith('Ask about the move', NoteLabel.topic);
      final was = notepad.state.topics.single;

      await notepad.relabelNote(was.id, NoteLabel.update);

      final now = notepad.state.updates.single;
      expect(notepad.state.topics, isEmpty);
      expect(now.id, was.id);
      expect(now.body, was.body);
      expect(now.writtenOn, was.writtenOn);
      await notepad.close();
    });

    test('leaves a label and a date alone when the words change', () async {
      final notepad = await aNotepadWith('Ask about the mvoe', NoteLabel.topic);
      final was = notepad.state.topics.single;

      await notepad.editNote(was.id, 'Ask about the move');

      final now = notepad.state.topics.single;
      expect(now.body, 'Ask about the move');
      expect(now.label, was.label);
      expect(now.writtenOn, was.writtenOn);
      await notepad.close();
    });

    test('touches nothing else when a Note is deleted', () async {
      final notepad = await aNotepadWith('Ask about the move', NoteLabel.topic);
      notepad.typeNote('Started a new job');
      notepad.chooseNoteLabel(NoteLabel.update);
      await notepad.writeNote();
      final going = notepad.state.topics.single;

      await notepad.dropNote(going.id);

      expect(notepad.state.topics, isEmpty);
      expect(notepad.state.updates.single.body, 'Started a new job');
      expect(notepad.state.meetings, hasLength(1));
      await notepad.close();
    });

    test('sorts each group newest first', () async {
      await writeFriend(
        'f1',
        notes: [
          for (var written = 0; written < 4; written++)
            Note(
              id: 'n$written',
              label: NoteLabel.values[written % 3],
              body: 'written $written days ago',
              writtenOn: day(written),
            ),
        ],
      );
      final notepad = await anOpenNotepad('f1');

      for (final label in NoteLabel.values) {
        final group = notepad.state.notesLabelled(label);
        expect(
          group.map((note) => note.writtenOn),
          _fallingDates(group.map((note) => note.writtenOn)),
          reason: '$label is not newest first',
        );
      }
      expect(notepad.state.topics.first.body, 'written 0 days ago');
      await notepad.close();
    });

    test('carries the day each piece of writing was written on', () async {
      final notepad = await aNotepadWith('Ask about the move', NoteLabel.topic);

      expect(notepad.state.topics.single.writtenOn, CivilDate.from(today));
      await notepad.close();
    });
  });

  group('Meetings', () {
    test('logs one dated today and deletes no Note of any label', () async {
      await writeFriend(
        'f1',
        metDaysAgo: [40],
        notes: [
          for (final label in NoteLabel.values)
            Note(
              id: 'n-${label.name}',
              label: label,
              body: label.name,
              writtenOn: day(3),
            ),
        ],
      );
      final notepad = await anOpenNotepad('f1');

      await notepad.logMeeting();

      expect(notepad.state.meetings, hasLength(2));
      expect(notepad.state.meetings.first.happenedOn, CivilDate.from(today));
      expect(notepad.state.topics, hasLength(1));
      expect(notepad.state.updates, hasLength(1));
      expect(notepad.state.notes, hasLength(1));
      await notepad.close();
    });

    test('moves the Friend in the Priority Order on the next read', () async {
      await writeFriend('f1', metDaysAgo: [90], cadenceDays: 30);
      await writeFriend('f2', metDaysAgo: [40], cadenceDays: 30);

      Future<List<String>> ranking() async {
        final rows = await friends.watchDialFriends().first;

        return [
          for (final placing in PriorityOrder(
            rows.map((row) => row.placingAt(today)),
          ).all)
            placing.friendId,
        ];
      }

      expect(await ranking(), ['f1', 'f2']);

      final notepad = await anOpenNotepad('f1');
      await notepad.logMeeting();

      expect(await ranking(), ['f2', 'f1']);
      await notepad.close();
    });

    test('takes an earlier day and refuses one that has not come', () async {
      await writeFriend('f1', metDaysAgo: [40]);
      final notepad = await anOpenNotepad('f1');

      await notepad.logMeeting(on: day(7));
      expect(notepad.state.meetings, hasLength(2));

      await notepad.logMeeting(on: day(-1));
      expect(notepad.state.meetings, hasLength(2));
      expect(notepad.state.refusal, contains('today or an earlier day'));
      await notepad.close();
    });

    test('keeps the place, the length, the feel and the recap', () async {
      await writeFriend('f1', metDaysAgo: [40]);
      final notepad = await anOpenNotepad('f1');

      await notepad.logMeeting(
        atMinute: 19 * 60,
        place: 'Karma',
        lengthInMinutes: 90,
        feeling: 'Easy',
        recap: 'She is moving in March.',
      );

      final logged = notepad.state.meetings.first;
      expect(logged.happenedAtMinute, 19 * 60);
      expect(logged.place, 'Karma');
      expect(logged.lengthInMinutes, 90);
      expect(logged.feeling, 'Easy');
      expect(logged.recap, 'She is moving in March.');

      final bare = notepad.state.meetings.last;
      expect(bare.place, isNull);
      expect(bare.recap, isNull);
      await notepad.close();
    });
  });

  group('correcting the history', () {
    test('moves lastMet when the newest Meeting moves', () async {
      await writeFriend('f1', metDaysAgo: [3, 40]);
      final notepad = await anOpenNotepad('f1');
      final newest = notepad.state.meetings.first;

      await notepad.amendMeeting(Meeting(id: newest.id, happenedOn: day(1)));

      expect(notepad.state.friend!.lastMet, day(1));
      await notepad.close();
    });

    test('moves nothing when an older Meeting moves further back', () async {
      await writeFriend('f1', metDaysAgo: [3, 40]);
      final notepad = await anOpenNotepad('f1');
      final older = notepad.state.meetings.last;

      await notepad.amendMeeting(Meeting(id: older.id, happenedOn: day(60)));

      expect(notepad.state.friend!.lastMet, day(3));
      expect(notepad.state.meetings.last.happenedOn, day(60));
      await notepad.close();
    });

    test('moves lastMet when an older Meeting passes the newest', () async {
      await writeFriend('f1', metDaysAgo: [3, 40]);
      final notepad = await anOpenNotepad('f1');
      final older = notepad.state.meetings.last;

      await notepad.amendMeeting(Meeting(id: older.id, happenedOn: day(1)));

      expect(notepad.state.friend!.lastMet, day(1));
      expect(notepad.state.meetings.first.id, older.id);
      await notepad.close();
    });

    test('falls back to the Meeting before when the newest goes', () async {
      await writeFriend('f1', metDaysAgo: [3, 40], cadenceDays: 30);
      final notepad = await anOpenNotepad('f1');
      expect(notepad.state.standing, Standing.freshlyReset);

      await notepad.dropMeeting(notepad.state.meetings.first.id);

      expect(notepad.state.friend!.lastMet, day(40));
      expect(notepad.state.standing, Standing.overdue);
      expect(notepad.state.meetings, hasLength(1));
      await notepad.close();
    });

    test('offers no delete on a Friend of one Meeting', () async {
      await writeFriend('f1', metDaysAgo: [3]);
      final notepad = await anOpenNotepad('f1');

      expect(notepad.state.canDropMeeting, isFalse);
      expect(
        () =>
            notepad.state.friend!.dropMeeting(notepad.state.meetings.single.id),
        throwsStateError,
      );
      await notepad.close();
    });
  });

  group('removing a Friend', () {
    test(
      'takes everything about them and leaves the Affinity labels',
      () async {
        final first = Friend.hydrate(
          id: 'f1',
          name: 'Anna',
          cadence: Cadence.ofDays(30),
          meetings: [Meeting(id: 'm1', happenedOn: day(3))],
          notes: [
            Note(
              id: 'n1',
              label: NoteLabel.topic,
              body: 'Ask about the move',
              writtenOn: day(1),
            ),
          ],
          facts: [Fact(id: 'k1', label: 'Drinks', value: 'Tea')],
          milestones: [
            Milestone(
              id: 'ms1',
              label: 'Birthday',
              onDate: CivilDate(1991, 4, 2),
            ),
          ],
          affinities: [Affinity(id: 'a1', label: 'Climbing')],
        );
        await friends.save(first);
        await friends.save(
          Friend.hydrate(
            id: 'f2',
            name: 'Kasia',
            cadence: Cadence.ofDays(30),
            meetings: [Meeting(id: 'm2', happenedOn: day(3))],
            affinities: [Affinity(id: 'a1', label: 'Climbing')],
          ),
        );

        final notepad = await anOpenNotepad('f1');
        await notepad.deleteFriend();

        expect(await friends.load('f1'), isNull);
        expect(notepad.state.friend, isNull);
        expect(notepad.state.isLocked, isFalse);

        final labels = await friends.affinities();
        expect(labels.map((affinity) => affinity.label), ['Climbing']);
        expect((await friends.load('f2'))!.affinities, hasLength(1));
        await notepad.close();
      },
    );
  });

  group('changing the Cadence', () {
    Future<NotepadCubit> aTunedNotepad(int cadenceDays, int daysAgo) async {
      await writeFriend('f1', metDaysAgo: [daysAgo], cadenceDays: cadenceDays);

      return anOpenNotepad('f1');
    }

    test('writes that field and leaves every Meeting alone', () async {
      final notepad = await aTunedNotepad(30, 3);
      final was = notepad.state.meetings;

      notepad.moveTuner(CadenceChoice(Cadence.ofDays(7)));
      await notepad.saveCadence();

      expect(notepad.state.cadence, Cadence.ofDays(7));
      expect(notepad.state.meetings, was);
      expect(notepad.state.friend!.lastMet, day(3));
      await notepad.close();
    });

    test('a shorter Cadence reads Overdue on the next read', () async {
      final notepad = await aTunedNotepad(30, 20);
      expect(notepad.state.standing, isNot(Standing.overdue));

      notepad.moveTuner(CadenceChoice(Cadence.ofDays(7)));
      await notepad.saveCadence();

      expect(notepad.state.standing, Standing.overdue);
      await notepad.close();
    });

    test('a longer Cadence ends an Overdue on the next read', () async {
      final notepad = await aTunedNotepad(7, 20);
      expect(notepad.state.standing, Standing.overdue);

      notepad.moveTuner(CadenceChoice(Cadence.ofDays(90)));
      await notepad.saveCadence();

      expect(notepad.state.standing, Standing.freshlyReset);
      await notepad.close();
    });

    test('crossing 14 or 60 days moves the Friend between Orbits', () async {
      final notepad = await aTunedNotepad(30, 3);
      expect(notepad.state.orbit, Orbit.middle);

      notepad.moveTuner(CadenceChoice(Cadence.ofDays(14)));
      await notepad.saveCadence();
      expect(notepad.state.orbit, Orbit.inner);

      notepad.moveTuner(CadenceChoice(Cadence.ofDays(61)));
      await notepad.saveCadence();
      expect(notepad.state.orbit, Orbit.outer);
      await notepad.close();
    });

    test('setting the old value back returns every reading', () async {
      final notepad = await aTunedNotepad(30, 20);
      final was = notepad.state.placing;

      notepad.moveTuner(CadenceChoice(Cadence.ofDays(7)));
      await notepad.saveCadence();
      expect(notepad.state.placing, isNot(was));

      notepad.moveTuner(CadenceChoice(Cadence.ofDays(30)));
      await notepad.saveCadence();

      expect(notepad.state.placing, was);
      expect(notepad.state.friend!.lastMet, day(20));
      await notepad.close();
    });

    test('previews the result before the User commits', () async {
      final notepad = await aTunedNotepad(30, 20);

      notepad.moveTuner(CadenceChoice(Cadence.ofDays(7)));

      expect(notepad.state.tunerHasMoved, isTrue);
      expect(notepad.state.tunerPreview!.standing, Standing.overdue);
      expect(
        notepad.state.standing,
        isNot(Standing.overdue),
        reason: 'a preview writes nothing',
      );
      await notepad.close();
    });
  });

  group('the lock, midnight and a resume', () {
    test('clears the Friend, the Notes and the Meetings', () async {
      await writeFriend(
        'f1',
        name: 'Anna',
        notes: [
          Note(
            id: 'n1',
            label: NoteLabel.topic,
            body: 'Ask about the move',
            writtenOn: day(1),
          ),
        ],
      );
      final notepad = await anOpenNotepad('f1');
      expect(notepad.state.name, 'Anna');

      await wiring.session.lock();
      await until(() => notepad.state.isLocked);

      expect(notepad.state.isLocked, isTrue);
      expect(notepad.state.friend, isNull);
      expect(notepad.state.name, isEmpty);
      expect(notepad.state.topics, isEmpty);
      expect(notepad.state.meetings, isEmpty);
      await notepad.close();
    });

    test('clears a half-typed Note', () async {
      await writeFriend('f1');
      final notepad = await anOpenNotepad('f1');
      notepad.typeNote('She is moving in');

      await wiring.session.lock();
      await until(() => notepad.state.isLocked);

      expect(notepad.state.draftNote, isEmpty);
      await notepad.close();
    });

    test('reads as locked and not as a Friend with nothing written', () async {
      await writeFriend('f1', name: 'Anna');
      final notepad = await anOpenNotepad('f1');
      final calm = notepad.state;

      await wiring.session.lock();
      await until(() => notepad.state.isLocked);
      final locked = notepad.state;

      expect(calm.isLocked, isFalse);
      expect(calm.topics, isEmpty);
      expect(calm.name, 'Anna');
      expect(locked.isLocked, isTrue);
      expect(locked, isNot(calm));
      await notepad.close();
    });

    test('throws DatabaseLockedError on a write while locked', () async {
      await writeFriend('f1');
      final notepad = await anOpenNotepad('f1');
      await wiring.session.lock();
      await until(() => notepad.state.isLocked);

      notepad.typeNote('Ask about the move');

      await expectLater(
        notepad.writeNote(),
        throwsA(isA<DatabaseLockedError>()),
      );
      await notepad.close();
    });

    test('comes back with fresh data on unlock', () async {
      await writeFriend('f1', name: 'Anna');
      final notepad = await anOpenNotepad('f1');
      await wiring.session.lock();
      await until(() => notepad.state.isLocked);
      expect(notepad.state.isLocked, isTrue);

      await wiring.session.unlock(profileId, '123456');
      await until(() => notepad.state.friend != null);

      expect(notepad.state.name, 'Anna');
      await notepad.close();
    });

    test('reads again when the local Civil Date turns', () async {
      await writeFriend('f1', metDaysAgo: [30], cadenceDays: 30);
      // A tenth of a second before the Civil Date changes, so the timer the
      // screen sets is one a test can wait out.
      clock.advance(
        const Duration(hours: 23, minutes: 59, seconds: 59, milliseconds: 900),
      );
      final notepad = await anOpenNotepad('f1');
      expect(notepad.state.standing, isNot(Standing.overdue));

      clock.advance(const Duration(milliseconds: 200));
      await until(() => notepad.state.standing == Standing.overdue);

      expect(notepad.state.standing, Standing.overdue);
      expect(notepad.state.today, CivilDate(2026, 9, 11));
      await notepad.close();
    });

    test('reads again on a resume', () async {
      await writeFriend('f1', name: 'Anna', metDaysAgo: [3]);
      final notepad = await anOpenNotepad('f1');
      expect(notepad.state.meetings, hasLength(1));

      await friends.save(
        (await friends.load('f1'))!.logMeeting(
          Meeting(id: 'later', happenedOn: day(1)),
          now: today,
        ),
      );
      notepad.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await until(() => notepad.state.meetings.length > 1);

      expect(notepad.state.friend!.lastMet, day(1));
      await notepad.close();
    });
  });
}

/// The same dates, ordered newest first.
Iterable<CivilDate> _fallingDates(Iterable<CivilDate> dates) =>
    [...dates]..sort((a, b) => b.compareTo(a));
