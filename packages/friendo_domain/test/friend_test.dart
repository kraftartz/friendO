import 'package:friendo_domain/friendo_domain.dart';
import 'package:test/test.dart';

void main() {
  final now = DateTime(2026, 6, 1, 12);
  final today = CivilDate(2026, 6, 1);
  final monthly = Cadence.ofDays(30);

  Meeting meeting(String id, CivilDate happenedOn) =>
      Meeting(id: id, happenedOn: happenedOn);

  Friend started({String name = 'Anna', Meeting? first}) => Friend.started(
    id: 'anna',
    name: name,
    cadence: monthly,
    firstMeeting: first ?? meeting('m1', CivilDate(2026, 5, 20)),
    now: now,
  );

  group('Meeting', () {
    test('holds a Civil Date and no time of day by default', () {
      expect(meeting('m1', today).happenedAtMinute, isNull);
    });

    test('accepts a time of day inside the day', () {
      final m = Meeting(id: 'm1', happenedOn: today, happenedAtMinute: 1439);
      expect(m.happenedAtMinute, 1439);
    });

    test('refuses a time of day outside the day', () {
      expect(
        () => Meeting(id: 'm1', happenedOn: today, happenedAtMinute: 1440),
        throwsArgumentError,
      );
      expect(
        () => Meeting(id: 'm1', happenedOn: today, happenedAtMinute: -1),
        throwsArgumentError,
      );
    });

    test('refuses an empty id', () {
      expect(() => Meeting(id: ' ', happenedOn: today), throwsArgumentError);
    });
  });

  group('Friend.started', () {
    test('keeps the first Meeting', () {
      expect(started().meetings, [meeting('m1', CivilDate(2026, 5, 20))]);
    });

    test('takes lastMet from the first Meeting', () {
      expect(started().lastMet, CivilDate(2026, 5, 20));
    });

    test('accepts a first Meeting on today', () {
      expect(started(first: meeting('m1', today)).lastMet, today);
    });

    test('accepts a first Meeting from two years back', () {
      final old = meeting('m1', CivilDate(2024, 6, 1));
      expect(started(first: old).lastMet, CivilDate(2024, 6, 1));
    });

    test('refuses a first Meeting after today', () {
      expect(
        () => started(first: meeting('m1', CivilDate(2026, 6, 2))),
        throwsArgumentError,
      );
    });

    test('refuses an empty name', () {
      expect(() => started(name: '  '), throwsArgumentError);
    });
  });

  group('Friend.hydrate', () {
    test('rebuilds a stored Friend', () {
      final friend = Friend.hydrate(
        id: 'anna',
        name: 'Anna',
        cadence: monthly,
        meetings: [meeting('m1', CivilDate(2026, 5, 20))],
      );
      expect(friend, started());
    });

    test('refuses a Friend with no Meeting', () {
      expect(
        () => Friend.hydrate(
          id: 'anna',
          name: 'Anna',
          cadence: monthly,
          meetings: const [],
        ),
        throwsArgumentError,
      );
    });

    test('orders the Meetings newest first, whatever order they arrive in', () {
      final friend = Friend.hydrate(
        id: 'anna',
        name: 'Anna',
        cadence: monthly,
        meetings: [
          meeting('m1', CivilDate(2026, 3, 1)),
          meeting('m3', CivilDate(2026, 5, 20)),
          meeting('m2', CivilDate(2026, 4, 10)),
        ],
      );
      expect(friend.meetings.map((m) => m.id), ['m3', 'm2', 'm1']);
      expect(friend.newestMeeting.id, 'm3');
    });

    test(
      'takes no now, because a stored Friend states no rule about today',
      () {
        final ahead = Friend.hydrate(
          id: 'anna',
          name: 'Anna',
          cadence: monthly,
          meetings: [meeting('m1', CivilDate(2026, 5, 20))],
        );
        expect(ahead.lastMet, CivilDate(2026, 5, 20));
      },
    );
  });

  group('lastMet', () {
    test('is the newest Civil Date of the Meetings', () {
      final friend = started().logMeeting(
        meeting('m2', CivilDate(2026, 5, 28)),
        now: now,
      );
      expect(friend.lastMet, CivilDate(2026, 5, 28));
    });

    test('does not move when an older Meeting arrives late', () {
      final friend = started()
          .logMeeting(meeting('m2', CivilDate(2026, 5, 28)), now: now)
          .logMeeting(meeting('m3', CivilDate(2026, 5, 2)), now: now);
      expect(friend.lastMet, CivilDate(2026, 5, 28));
    });
  });

  group('logMeeting', () {
    test('adds the Meeting', () {
      final friend = started().logMeeting(
        meeting('m2', CivilDate(2026, 5, 28)),
        now: now,
      );
      expect(friend.meetings.map((m) => m.id), ['m2', 'm1']);
    });

    test('accepts a Meeting on today', () {
      expect(
        started().logMeeting(meeting('m2', today), now: now).lastMet,
        today,
      );
    });

    test('refuses a Meeting after today, because a plan is not a Meeting', () {
      expect(
        () => started().logMeeting(
          meeting('m2', CivilDate(2026, 6, 2)),
          now: now,
        ),
        throwsArgumentError,
      );
    });

    test('refuses an id that the Friend already holds', () {
      expect(
        () => started().logMeeting(meeting('m1', today), now: now),
        throwsArgumentError,
      );
    });
  });

  group('amendMeeting', () {
    test('replaces the Meeting that holds the same id', () {
      final friend = started().amendMeeting(
        Meeting(
          id: 'm1',
          happenedOn: CivilDate(2026, 5, 21),
          place: 'Kawiarnia',
        ),
        now: now,
      );
      expect(friend.meetings.single.place, 'Kawiarnia');
      expect(friend.lastMet, CivilDate(2026, 5, 21));
    });

    test('refuses an id that the Friend does not hold', () {
      expect(
        () => started().amendMeeting(meeting('m9', today), now: now),
        throwsArgumentError,
      );
    });

    test('refuses a Civil Date after today', () {
      expect(
        () => started().amendMeeting(
          meeting('m1', CivilDate(2026, 6, 2)),
          now: now,
        ),
        throwsArgumentError,
      );
    });
  });

  group('deleting a Meeting', () {
    test('has no method that could leave a Friend with no Meeting', () {
      // Every route that returns a Friend either keeps the Meetings or grows
      // them. copyWith takes no Meetings at all.
      final friend = started();
      final reached = [
        friend,
        friend.logMeeting(meeting('m2', today), now: now),
        friend.amendMeeting(meeting('m1', today), now: now),
        friend.copyWith(name: 'Ania'),
        friend.copyWith(cadence: Cadence.ofDays(7)),
        friend.copyWith(notes: const []),
        friend.copyWith(facts: const []),
        friend.copyWith(affinities: const []),
        friend.copyWith(milestones: const []),
      ];
      for (final each in reached) {
        expect(each.meetings, isNotEmpty);
      }
    });
  });

  group('what you remember', () {
    final topic = Note(
      id: 'n1',
      label: NoteLabel.topic,
      body: 'Ask about the pottery workshop',
      writtenOn: CivilDate(2026, 5, 21),
    );
    final update = Note(
      id: 'n2',
      label: NoteLabel.update,
      body: 'Moved to Kraków',
      writtenOn: CivilDate(2026, 5, 22),
    );
    final plain = Note(
      id: 'n3',
      label: NoteLabel.note,
      body: 'Drinks oat milk',
      writtenOn: CivilDate(2026, 5, 23),
    );

    test('one type tells a Topic, an Update and a Note apart by its label', () {
      final friend = started().copyWith(notes: [topic, update, plain]);
      expect(friend.notes.where((n) => n.label == NoteLabel.topic), [topic]);
      expect(friend.notes.where((n) => n.label == NoteLabel.update), [update]);
      expect(friend.notes.where((n) => n.label == NoteLabel.note), [plain]);
    });

    test('a Note is open until the User resolves it', () {
      expect(topic.isResolved, isFalse);
      expect(topic.resolve(on: CivilDate(2026, 5, 30)).isResolved, isTrue);
    });

    test('nothing clears a Note when a Meeting is logged', () {
      final friend = started()
          .copyWith(notes: [topic, update, plain])
          .logMeeting(meeting('m2', today), now: now);
      expect(friend.notes, [topic, update, plain]);
    });

    test('refuses an empty body', () {
      expect(
        () =>
            Note(id: 'n4', label: NoteLabel.note, body: ' ', writtenOn: today),
        throwsArgumentError,
      );
    });
  });

  group('about a Friend', () {
    test('a Fact holds a label and a value that the User wrote', () {
      final fact = Fact(id: 'f1', label: 'City', value: 'Kraków');
      expect(fact.label, 'City');
      expect(fact.value, 'Kraków');
    });

    test('a Fact refuses an empty label or an empty value', () {
      expect(() => Fact(id: 'f1', label: ' ', value: 'x'), throwsArgumentError);
      expect(() => Fact(id: 'f1', label: 'x', value: ' '), throwsArgumentError);
    });

    test('an Affinity refuses an empty label', () {
      expect(() => Affinity(id: 'a1', label: ' '), throwsArgumentError);
    });

    test('a Milestone returns every year, or happens once', () {
      final birthday = Milestone(
        id: 'ms1',
        label: 'Birthday',
        onDate: CivilDate(1991, 10, 14),
        repeatsYearly: true,
      );
      final once = Milestone(
        id: 'ms2',
        label: 'Met at the MIT Media Lab',
        onDate: CivilDate(2019, 3, 2),
      );
      expect(birthday.repeatsYearly, isTrue);
      expect(once.repeatsYearly, isFalse);
    });

    test('the three of them ride on the Friend', () {
      final friend = started().copyWith(
        facts: [Fact(id: 'f1', label: 'City', value: 'Kraków')],
        affinities: [Affinity(id: 'a1', label: 'Family')],
        milestones: [
          Milestone(
            id: 'ms1',
            label: 'Birthday',
            onDate: CivilDate(1991, 10, 14),
          ),
        ],
      );
      expect(friend.facts.single.value, 'Kraków');
      expect(friend.affinities.single.label, 'Family');
      expect(friend.milestones.single.label, 'Birthday');
    });
  });

  group('Folded Text', () {
    test('the name stays exactly as the User wrote it', () {
      expect(started(name: 'Michał').name, 'Michał');
    });
  });

  group('the Dial', () {
    test('works a Placing out from the newest Meeting', () {
      final friend = started(first: meeting('m1', CivilDate(2026, 5, 2)));
      final placing = friend.placing(now: now);
      expect(placing.friendId, 'anna');
      expect(placing.dueAt, CivilDate(2026, 6, 1));
      expect(placing.standing, Standing.nearing);
    });
  });

  group('equality', () {
    test('two Friends that hold the same values are equal', () {
      expect(started(), started());
    });

    test('a different Cadence makes a different Friend', () {
      expect(started().copyWith(cadence: Cadence.ofDays(7)), isNot(started()));
    });
  });

  group('dropping a Meeting', () {
    Friend twoMeetings() => Friend.hydrate(
      id: 'f1',
      name: 'Anna',
      cadence: Cadence.ofDays(30),
      meetings: [
        Meeting(id: 'older', happenedOn: CivilDate(2026, 1, 1)),
        Meeting(id: 'newest', happenedOn: CivilDate(2026, 6, 1)),
      ],
    );

    test('falls back to the Meeting before the newest one', () {
      final left = twoMeetings().dropMeeting('newest');

      expect(left.meetings.map((meeting) => meeting.id), ['older']);
      expect(left.lastMet, CivilDate(2026, 1, 1));
    });

    test('leaves lastMet alone when an older Meeting goes', () {
      final left = twoMeetings().dropMeeting('older');

      expect(left.lastMet, CivilDate(2026, 6, 1));
    });

    test('keeps a Friend of one Meeting whole', () {
      final friend = Friend.started(
        id: 'f1',
        name: 'Anna',
        cadence: Cadence.ofDays(30),
        firstMeeting: Meeting(id: 'only', happenedOn: CivilDate(2026, 6, 1)),
        now: DateTime(2026, 6, 2),
      );

      expect(friend.canDropMeeting, isFalse);
      expect(() => friend.dropMeeting('only'), throwsStateError);
    });

    test('says a Friend of two Meetings may lose one', () {
      expect(twoMeetings().canDropMeeting, isTrue);
    });

    test('refuses a Meeting this Friend does not hold', () {
      expect(
        () => twoMeetings().dropMeeting('somebody elses'),
        throwsArgumentError,
      );
    });
  });
}
