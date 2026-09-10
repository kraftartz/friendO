import 'dart:async';

import 'package:flutter/widgets.dart'
    show AppLifecycleState, WidgetsBinding, WidgetsBindingObserver;
import 'package:flutter_bloc/flutter_bloc.dart' show Cubit;
import 'package:friendo/core/db/database_session.dart'
    show DatabaseSession, DatabaseState;
import 'package:friendo/core/friends/friend_repository.dart'
    show FriendRepository;
import 'package:friendo/core/friends/listed_friend.dart' show ListedFriend;
import 'package:friendo/core/ids/new_id.dart' show newId;
import 'package:friendo/core/time/civil_date_change.dart' show CivilDateChange;
import 'package:friendo/core/time/clock.dart' show Clock;
import 'package:friendo/features/friends/bloc/friends_state.dart'
    show ChipCounts, FriendCard, FriendsListState;
import 'package:friendo_domain/friendo_domain.dart'
    show CivilDate, Meeting, Orbit, PriorityOrder;

/// The Friends List's state.
///
/// It holds two narrowings of one ranked list. The term and the chip are
/// independent, they compose in either order, and neither ever sorts what it
/// leaves. Nothing is ordered by how well it matched, so the first card is
/// the Friend to see next whatever is typed above it.
///
/// It reads again on four triggers and polls on none: the watch stream emits,
/// the Profile unlocks, the app resumes, and the local Civil Date changes.
class FriendsCubit extends Cubit<FriendsListState> with WidgetsBindingObserver {
  FriendsCubit({
    required this.friends,
    required this.databases,
    required this.dayChange,
    this.clock = const Clock(),
    Orbit? startOn,
  }) : _orbit = startOn,
       super(const FriendsListState.locked()) {
    WidgetsBinding.instance.addObserver(this);
    _rows = friends.watchListedFriends().listen(_onRows);
    _whileOpen = databases.state.listen(_onDatabaseState);
  }

  final FriendRepository friends;

  final DatabaseSession databases;

  final CivilDateChange dayChange;

  final Clock clock;

  List<ListedFriend> _held = const [];

  String _term = '';

  Orbit? _orbit;

  /// Which rebuild is the current one. A term the User has moved on from must
  /// never overwrite the answer to the one they are typing now.
  int _turn = 0;

  StreamSubscription<List<ListedFriend>>? _rows;
  StreamSubscription<DatabaseState>? _whileOpen;
  StreamSubscription<void>? _untilMidnight;

  /// Narrow the list to what [term] matches. The chip stays as it is.
  void search(String term) {
    _term = term;
    _rebuild();
  }

  /// Show one Orbit, or the whole Priority Order for null. The term stays as
  /// it is.
  void showOrbit(Orbit? orbit) {
    _orbit = orbit;
    _rebuild();
  }

  /// Return the view to the top of the Priority Order, where the Overdue
  /// Friends are.
  ///
  /// It clears the term and the chip. No Overdue filter exists, and none is
  /// needed: the list is in Priority Order, so those Friends are already the
  /// first cards.
  void review() {
    _term = '';
    _orbit = null;
    _rebuild();
  }

  /// Write a Meeting with this Friend, dated today.
  ///
  /// The write goes through the aggregate, which owns the rule that a Friend
  /// never loses their last Meeting. Nothing is deleted: a logged Meeting
  /// clears no Topic. See ADR-0017.
  Future<void> logMeeting(String friendId) async {
    final friend = await friends.load(friendId);
    if (friend == null) return;

    final now = clock.now();
    await friends.save(
      friend.logMeeting(
        Meeting(id: newId(), happenedOn: CivilDate.from(now)),
        now: now,
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _rebuild();
  }

  @override
  Future<void> close() async {
    WidgetsBinding.instance.removeObserver(this);
    await _untilMidnight?.cancel();
    await _whileOpen?.cancel();
    await _rows?.cancel();

    return super.close();
  }

  void _onRows(List<ListedFriend> rows) {
    _held = rows;
    _rebuild();
  }

  void _onDatabaseState(DatabaseState open) {
    if (open == DatabaseState.open) {
      _untilMidnight ??= dayChange.changes.listen((_) => _rebuild());

      return;
    }

    unawaited(_untilMidnight?.cancel());
    _untilMidnight = null;
    _held = const [];
    _term = '';
    _orbit = null;
    _turn++;
    emit(const FriendsListState.locked());
  }

  void _rebuild() {
    if (databases.stateNow != DatabaseState.open) return;

    unawaited(_readAgain(++_turn, _term, _orbit));
  }

  Future<void> _readAgain(int mine, String term, Orbit? orbit) async {
    final matched = await friends.friendIdsMatching(term);
    if (mine != _turn || isClosed) return;
    if (databases.stateNow != DatabaseState.open) return;

    emit(_reading(matched: matched, term: term, orbit: orbit));
  }

  /// One `now` builds the whole list.
  ///
  /// Two reads could fall on either side of midnight, and then two cards on
  /// one screen would disagree about what day it is.
  FriendsListState _reading({
    required Set<String>? matched,
    required String term,
    required Orbit? orbit,
  }) {
    final now = clock.now();
    final cards = {
      for (final row in _held)
        row.id: FriendCard(friend: row, placing: row.placingAt(now)),
    };
    final ranked = PriorityOrder(cards.values.map((card) => card.placing));

    final found = [
      for (final placing in ranked.all)
        if (matched == null || matched.contains(placing.friendId))
          cards[placing.friendId]!,
    ];

    return FriendsListState(
      cards: [
        for (final card in found)
          if (orbit == null || card.orbit == orbit) card,
      ],
      overdue: [for (final placing in ranked.overdue) cards[placing.friendId]!],
      counts: ChipCounts.over(found),
      rosterCount: cards.length,
      today: CivilDate.from(now),
      term: term,
      orbit: orbit,
    );
  }
}
