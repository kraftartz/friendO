import 'package:equatable/equatable.dart';

import 'cadence.dart';
import 'civil_date.dart';
import 'priority_order.dart';

String _required(String value, String name) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    throw ArgumentError.value(value, name, 'must hold some text');
  }
  return trimmed;
}

/// A recorded occasion when the User saw a Friend.
///
/// [happenedOn] is the only member the Dial reads. [happenedAtMinute] counts
/// minutes from local midnight, so it runs from 0 to 1439. It is optional,
/// because a null says that the User gave no time of day.
///
/// A Meeting states no rule about today. The rule "today or earlier" spans a
/// Friend and the current time, so [Friend] owns it.
final class Meeting extends Equatable implements Comparable<Meeting> {
  factory Meeting({
    required String id,
    required CivilDate happenedOn,
    int? happenedAtMinute,
    String? place,
    int? lengthInMinutes,
    String? vibe,
    String? recap,
  }) {
    if (happenedAtMinute != null &&
        (happenedAtMinute < 0 || happenedAtMinute > 1439)) {
      throw ArgumentError.value(
        happenedAtMinute,
        'happenedAtMinute',
        'must fall inside one day',
      );
    }
    if (lengthInMinutes != null && lengthInMinutes < 0) {
      throw ArgumentError.value(
        lengthInMinutes,
        'lengthInMinutes',
        'must be zero or more',
      );
    }
    return Meeting._(
      id: _required(id, 'id'),
      happenedOn: happenedOn,
      happenedAtMinute: happenedAtMinute,
      place: place,
      lengthInMinutes: lengthInMinutes,
      vibe: vibe,
      recap: recap,
    );
  }

  const Meeting._({
    required this.id,
    required this.happenedOn,
    required this.happenedAtMinute,
    required this.place,
    required this.lengthInMinutes,
    required this.vibe,
    required this.recap,
  });

  final String id;
  final CivilDate happenedOn;
  final int? happenedAtMinute;
  final String? place;
  final int? lengthInMinutes;
  final String? vibe;
  final String? recap;

  /// Orders the newest Meeting first. The id breaks a tie, so two Meetings on
  /// one Civil Date always land in the same order.
  @override
  int compareTo(Meeting other) {
    final byDate = other.happenedOn.compareTo(happenedOn);
    return byDate != 0 ? byDate : id.compareTo(other.id);
  }

  @override
  List<Object?> get props => [
    id,
    happenedOn,
    happenedAtMinute,
    place,
    lengthInMinutes,
    vibe,
    recap,
  ];
}

/// What a Note is about. The label changes how the app groups and filters it,
/// and it changes nothing else. See ADR-0017.
enum NoteLabel {
  /// Something to raise the next time. It looks forward.
  topic,

  /// Something that has changed in a Friend's life. It looks back.
  update,

  /// Free text that is neither a Topic nor an Update.
  note,
}

/// One piece of writing about a Friend, under one [NoteLabel].
///
/// Nothing here clears itself. [resolvedOn] is empty until the User marks the
/// Note, and no other route sets it.
final class Note extends Equatable {
  factory Note({
    required String id,
    required NoteLabel label,
    required String body,
    required CivilDate writtenOn,
    CivilDate? resolvedOn,
  }) => Note._(
    id: _required(id, 'id'),
    label: label,
    body: _required(body, 'body'),
    writtenOn: writtenOn,
    resolvedOn: resolvedOn,
  );

  const Note._({
    required this.id,
    required this.label,
    required this.body,
    required this.writtenOn,
    required this.resolvedOn,
  });

  final String id;
  final NoteLabel label;
  final String body;
  final CivilDate writtenOn;
  final CivilDate? resolvedOn;

  bool get isResolved => resolvedOn != null;

  Note resolve({required CivilDate on}) => Note._(
    id: id,
    label: label,
    body: body,
    writtenOn: writtenOn,
    resolvedOn: on,
  );

  @override
  List<Object?> get props => [id, label, body, writtenOn, resolvedOn];
}

/// A small piece of standing information about a Friend.
///
/// The User writes both halves and chooses the [label]. The label is text to
/// show, and never a thing to filter by.
final class Fact extends Equatable {
  factory Fact({
    required String id,
    required String label,
    required String value,
    int position = 0,
  }) => Fact._(
    id: _required(id, 'id'),
    label: _required(label, 'label'),
    value: _required(value, 'value'),
    position: position,
  );

  const Fact._({
    required this.id,
    required this.label,
    required this.value,
    required this.position,
  });

  final String id;
  final String label;
  final String value;
  final int position;

  @override
  List<Object?> get props => [id, label, value, position];
}

/// Something a Friend is into, taken from a shared set.
///
/// Two Friends who share one hold the same [id]. An Affinity sets no Cadence.
final class Affinity extends Equatable {
  factory Affinity({required String id, required String label}) =>
      Affinity._(id: _required(id, 'id'), label: _required(label, 'label'));

  const Affinity._({required this.id, required this.label});

  final String id;
  final String label;

  @override
  List<Object?> get props => [id, label];
}

/// A Civil Date in a Friend's life worth coming back to, such as a birthday.
///
/// A Milestone moves no Bead. The Dial reads the Cadence and nothing else.
final class Milestone extends Equatable {
  factory Milestone({
    required String id,
    required String label,
    required CivilDate onDate,
    bool repeatsYearly = false,
  }) => Milestone._(
    id: _required(id, 'id'),
    label: _required(label, 'label'),
    onDate: onDate,
    repeatsYearly: repeatsYearly,
  );

  const Milestone._({
    required this.id,
    required this.label,
    required this.onDate,
    required this.repeatsYearly,
  });

  final String id;
  final String label;
  final CivilDate onDate;
  final bool repeatsYearly;

  @override
  List<Object?> get props => [id, label, onDate, repeatsYearly];
}

/// A person the User has chosen to see on a repeating [Cadence].
///
/// Friend is the root of one aggregate. A Meeting, a Note, a Fact, an Affinity
/// and a Milestone have no life outside it, so they arrive and leave with the
/// whole Friend. See ADR-0022.
///
/// Two rules hold here, because each one spans more than one row:
///
/// - A Friend always holds at least one Meeting. Both ways of building one ask
///   for a Meeting, and nothing here takes one away.
/// - A Meeting happens on today or earlier. Every route that accepts a Meeting
///   takes `now` as an argument. This library reads no clock.
///
/// Nothing here holds Folded Text. The fold happens on the way to the store,
/// and this library knows nothing about it. See ADR-0033.
final class Friend extends Equatable {
  /// Builds a Friend that the User has just added.
  ///
  /// [firstMeeting] is what makes `lastMet` answerable from the first moment.
  /// Its Civil Date must be [now] or earlier.
  factory Friend.started({
    required String id,
    required String name,
    required Cadence cadence,
    required Meeting firstMeeting,
    required DateTime now,
    List<Note> notes = const [],
    List<Fact> facts = const [],
    List<Affinity> affinities = const [],
    List<Milestone> milestones = const [],
  }) {
    _refuseAfterToday(firstMeeting, now);
    return Friend._build(
      id: id,
      name: name,
      cadence: cadence,
      meetings: [firstMeeting],
      notes: notes,
      facts: facts,
      affinities: affinities,
      milestones: milestones,
    );
  }

  /// Rebuilds a Friend that a store holds already, and does nothing else.
  ///
  /// It takes no `now`, because a stored Meeting was checked against today on
  /// the way in. It still refuses an empty [meetings], because that state is
  /// unreachable and a store that produces one is broken.
  factory Friend.hydrate({
    required String id,
    required String name,
    required Cadence cadence,
    required List<Meeting> meetings,
    List<Note> notes = const [],
    List<Fact> facts = const [],
    List<Affinity> affinities = const [],
    List<Milestone> milestones = const [],
  }) => Friend._build(
    id: id,
    name: name,
    cadence: cadence,
    meetings: meetings,
    notes: notes,
    facts: facts,
    affinities: affinities,
    milestones: milestones,
  );

  factory Friend._build({
    required String id,
    required String name,
    required Cadence cadence,
    required List<Meeting> meetings,
    required List<Note> notes,
    required List<Fact> facts,
    required List<Affinity> affinities,
    required List<Milestone> milestones,
  }) {
    if (meetings.isEmpty) {
      throw ArgumentError.value(
        meetings,
        'meetings',
        'a Friend holds at least one Meeting',
      );
    }
    final ids = meetings.map((meeting) => meeting.id).toSet();
    if (ids.length != meetings.length) {
      throw ArgumentError.value(meetings, 'meetings', 'holds one id twice');
    }
    final ordered = [...meetings]..sort();
    return Friend._(
      id: _required(id, 'id'),
      name: _required(name, 'name'),
      cadence: cadence,
      meetings: List.unmodifiable(ordered),
      notes: List.unmodifiable(notes),
      facts: List.unmodifiable(facts),
      affinities: List.unmodifiable(affinities),
      milestones: List.unmodifiable(milestones),
    );
  }

  const Friend._({
    required this.id,
    required this.name,
    required this.cadence,
    required this.meetings,
    required this.notes,
    required this.facts,
    required this.affinities,
    required this.milestones,
  });

  final String id;
  final String name;
  final Cadence cadence;

  /// Every Meeting, newest first. It is never empty.
  final List<Meeting> meetings;

  final List<Note> notes;
  final List<Fact> facts;
  final List<Affinity> affinities;
  final List<Milestone> milestones;

  /// The newest Meeting. It always exists.
  Meeting get newestMeeting => meetings.first;

  /// The Civil Date of the newest Meeting.
  ///
  /// It is worked out on every read and never stored, so a Meeting written
  /// late cannot move it backwards. See ADR-0016.
  CivilDate get lastMet => newestMeeting.happenedOn;

  /// Reduces this Friend to what the Dial needs.
  Placing placing({required DateTime now}) =>
      Placing(friendId: id, lastMet: lastMet, cadence: cadence, now: now);

  /// Adds a Meeting that the Friend does not hold yet.
  Friend logMeeting(Meeting meeting, {required DateTime now}) {
    _refuseAfterToday(meeting, now);
    if (meetings.any((held) => held.id == meeting.id)) {
      throw ArgumentError.value(
        meeting.id,
        'meeting.id',
        'this Friend holds it already',
      );
    }
    return _withMeetings([...meetings, meeting]);
  }

  /// Corrects a Meeting that the Friend holds already.
  ///
  /// It replaces the Meeting that carries the same id, so the count stays the
  /// same. A Meeting written by mistake is corrected this way.
  Friend amendMeeting(Meeting meeting, {required DateTime now}) {
    _refuseAfterToday(meeting, now);
    if (!meetings.any((held) => held.id == meeting.id)) {
      throw ArgumentError.value(
        meeting.id,
        'meeting.id',
        'this Friend holds no Meeting under it',
      );
    }
    return _withMeetings([
      for (final held in meetings)
        if (held.id == meeting.id) meeting else held,
    ]);
  }

  /// Replaces the parts that carry no rule.
  ///
  /// It takes no Meetings on purpose. Together with the two builders and the
  /// two Meeting routes above, that leaves no method in this library that can
  /// return a Friend with no Meeting. The rule is unreachable rather than
  /// guarded. See ADR-0022.
  Friend copyWith({
    String? name,
    Cadence? cadence,
    List<Note>? notes,
    List<Fact>? facts,
    List<Affinity>? affinities,
    List<Milestone>? milestones,
  }) => Friend._build(
    id: id,
    name: name ?? this.name,
    cadence: cadence ?? this.cadence,
    meetings: meetings,
    notes: notes ?? this.notes,
    facts: facts ?? this.facts,
    affinities: affinities ?? this.affinities,
    milestones: milestones ?? this.milestones,
  );

  Friend _withMeetings(List<Meeting> meetings) => Friend._build(
    id: id,
    name: name,
    cadence: cadence,
    meetings: meetings,
    notes: notes,
    facts: facts,
    affinities: affinities,
    milestones: milestones,
  );

  static void _refuseAfterToday(Meeting meeting, DateTime now) {
    if (meeting.happenedOn > CivilDate.from(now)) {
      throw ArgumentError.value(
        meeting.happenedOn,
        'meeting.happenedOn',
        'a Meeting happens on today or earlier',
      );
    }
  }

  @override
  List<Object?> get props => [
    id,
    name,
    cadence,
    meetings,
    notes,
    facts,
    affinities,
    milestones,
  ];

  @override
  String toString() => 'Friend $id ($name, $cadence, last met $lastMet)';
}
