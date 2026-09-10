import 'dart:math' show min;

import 'package:equatable/equatable.dart';
import 'package:friendo/core/friends/listed_friend.dart' show ListedFriend;
import 'package:friendo_domain/friendo_domain.dart'
    show CivilDate, Orbit, Placing, Standing;

/// What the screen says when it holds no card.
///
/// Each state has a different next action, and a screen that offers the wrong
/// one is worse than a screen that offers none. A locked Profile is none of
/// these: it is [FriendsListState.isLocked], because a quiet stream read as
/// an empty result would draw an empty roster behind the PIN screen.
enum Emptiness {
  /// The screen holds cards.
  none,

  /// The Profile holds no Friend at all.
  noFriends,

  /// The term matched nobody.
  noMatch,

  /// The chosen Orbit holds nobody the term left.
  noneInOrbit,
}

/// One card: the writing from the store, and the ranking from the domain.
final class FriendCard extends Equatable {
  const FriendCard({required this.friend, required this.placing});

  final ListedFriend friend;

  final Placing placing;

  String get id => friend.id;

  String get name => friend.name;

  Orbit get orbit => friend.cadence.orbit;

  int get cadenceDays => friend.cadence.days;

  Standing get standing => placing.standing;

  double get phase => placing.phase.value;

  /// How far to fill the bar, from nothing to full.
  ///
  /// It clamps, so an Overdue Friend gets a full bar and no more. The label
  /// beside it passes the Cadence, which is the honest reading of a day that
  /// has gone by.
  double get barFraction => min(phase, 1);

  /// The whole days from the last Meeting to today, for the card's label.
  int daysSinceMeeting(CivilDate today) => friend.daysSinceMeeting(today);

  @override
  List<Object?> get props => [friend, placing];
}

/// What each chip says, with the term in force.
///
/// A count is the number of Friends that tapping the chip would show. A count
/// that described the roster while a term narrowed the view would promise
/// three Friends and deliver one.
final class ChipCounts extends Equatable {
  const ChipCounts({required this.all, required this.byOrbit});

  const ChipCounts.none() : all = 0, byOrbit = const {};

  factory ChipCounts.over(Iterable<FriendCard> cards) {
    final byOrbit = {for (final orbit in Orbit.values) orbit: 0};
    var all = 0;
    for (final card in cards) {
      all++;
      byOrbit[card.orbit] = byOrbit[card.orbit]! + 1;
    }

    return ChipCounts(all: all, byOrbit: byOrbit);
  }

  final int all;

  final Map<Orbit, int> byOrbit;

  /// The count on the chip for [orbit], or on the All chip for null.
  int of(Orbit? orbit) => orbit == null ? all : (byOrbit[orbit] ?? 0);

  @override
  List<Object?> get props => [all, byOrbit];
}

/// Everything the Friends List draws.
final class FriendsListState extends Equatable {
  const FriendsListState({
    required this.cards,
    required this.overdue,
    required this.counts,
    required this.rosterCount,
    required this.today,
    this.term = '',
    this.orbit,
    this.isLocked = false,
  });

  const FriendsListState.locked()
    : cards = const [],
      overdue = const [],
      counts = const ChipCounts.none(),
      rosterCount = 0,
      today = null,
      term = '',
      orbit = null,
      isLocked = true;

  /// The cards to draw, in Priority Order, with the term and the chip in
  /// force. Neither narrowing ever sorts them.
  final List<FriendCard> cards;

  /// Every Overdue Friend on the roster, in the order the ranking gives.
  ///
  /// It describes the whole roster and never the narrowed view, because a
  /// filter is a way of looking and must not be a way of silencing. It is
  /// never built from a Phase: a Friend resting on their Due Date has a Phase
  /// above one and is not Overdue.
  final List<FriendCard> overdue;

  final ChipCounts counts;

  /// How many Friends the Profile holds, whatever the term and the chip hide.
  final int rosterCount;

  /// The one Civil Date the whole build was worked out from, or null while
  /// the Profile is locked.
  final CivilDate? today;

  final String term;

  /// The chosen Orbit, or null for the All chip.
  final Orbit? orbit;

  final bool isLocked;

  int get overdueCount => overdue.length;

  bool get hasBanner => overdue.isNotEmpty;

  Emptiness get emptiness =>
      isLocked || cards.isNotEmpty ? Emptiness.none : _whyEmpty;

  Emptiness get _whyEmpty {
    if (rosterCount == 0) return Emptiness.noFriends;

    return counts.all == 0 ? Emptiness.noMatch : Emptiness.noneInOrbit;
  }

  @override
  List<Object?> get props => [
    cards,
    overdue,
    counts,
    rosterCount,
    today,
    term,
    orbit,
    isLocked,
  ];
}
