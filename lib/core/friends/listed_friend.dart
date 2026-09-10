import 'package:equatable/equatable.dart';
import 'package:friendo_domain/friendo_domain.dart'
    show Cadence, CivilDate, Placing;

/// One Friend, as the Friends List reads them.
///
/// It holds the writing on a card. It holds no Phase, no Standing and no Due
/// Date, because the domain works those out from the Cadence and the newest
/// Meeting. A field holding one would be a stored derived value, which
/// ADR-0009 refused.
///
/// It holds no Folded Text either. ADR-0033 says a Folded Text is never
/// shown, and a field that never leaves the query cannot be drawn by mistake.
///
/// A card is two halves that meet in the view: this writing, and the reading
/// the domain works out, which is a [Placing].
final class ListedFriend extends Equatable {
  const ListedFriend({
    required this.id,
    required this.name,
    required this.cadence,
    required this.lastMet,
    this.lastMetAtMinute,
    this.lastMetPlace,
    this.newestTopic,
    this.topicsWaiting = 0,
  });

  final String id;

  /// The name as the User wrote it. A rule about matching never changes how a
  /// Friend's name appears.
  final String name;

  final Cadence cadence;

  final CivilDate lastMet;

  /// Minutes from local midnight, or null when the User set no time.
  final int? lastMetAtMinute;

  final String? lastMetPlace;

  /// The body of the newest Topic still waiting, or null when none waits.
  final String? newestTopic;

  final int topicsWaiting;

  String get avatarSeed => id;

  Placing placingAt(DateTime now) =>
      Placing(friendId: id, lastMet: lastMet, cadence: cadence, now: now);

  /// The number of whole days from the last Meeting to [today].
  ///
  /// The card's label reads this over the Cadence in days. It comes from two
  /// Civil Dates and never from the Phase. A Phase rounded down reads one day
  /// short for a Friend resting on their Due Date, and the label would then
  /// disagree with the Standing beside it.
  int daysSinceMeeting(CivilDate today) => today.daysFrom(lastMet);

  @override
  List<Object?> get props => [
    id,
    name,
    cadence,
    lastMet,
    lastMetAtMinute,
    lastMetPlace,
    newestTopic,
    topicsWaiting,
  ];
}
