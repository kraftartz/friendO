import 'package:equatable/equatable.dart';
import 'package:friendo_domain/friendo_domain.dart'
    show Cadence, CivilDate, Placing;

/// One Friend, reduced to what the Dial reads.
///
/// A read that only draws does not load the aggregate. Drawing a hundred
/// Friends as a hundred Beads out of the whole aggregate would read the
/// Meetings, Notes, Facts, Affinities and Milestones of every one of them to
/// fill in some circles. See ADR-0022.
///
/// It carries no reading of its own. [placingAt] works one out from a `now`
/// that the caller supplies, so one packing takes one instant and a reading
/// never has to be thrown away because the clock moved.
final class DialFriend extends Equatable {
  const DialFriend({
    required this.id,
    required this.name,
    required this.cadence,
    required this.lastMet,
  });

  final String id;

  final String name;

  final Cadence cadence;

  /// The Civil Date of the newest Meeting, which ADR-0016 derives and never
  /// stores.
  final CivilDate lastMet;

  /// What the Avatar's colour and initial are worked out from.
  ///
  /// The id, so the colour is stable for the life of the Friend and needs no
  /// column of its own.
  String get avatarSeed => id;

  Placing placingAt(DateTime now) =>
      Placing(friendId: id, lastMet: lastMet, cadence: cadence, now: now);

  @override
  List<Object?> get props => [id, name, cadence, lastMet];
}
