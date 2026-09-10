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
