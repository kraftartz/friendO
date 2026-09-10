import 'dart:async';

import 'package:flutter/widgets.dart'
    show AppLifecycleState, WidgetsBinding, WidgetsBindingObserver;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:friendo/core/db/database_session.dart'
    show DatabaseSession, DatabaseState;
import 'package:friendo/core/friends/dial_friend.dart' show DialFriend;
import 'package:friendo/core/friends/friend_repository.dart'
    show FriendRepository;
import 'package:friendo/core/ids/new_id.dart' show newId;
import 'package:friendo/core/time/civil_date_change.dart' show CivilDateChange;
import 'package:friendo/core/time/clock.dart' show Clock;
import 'package:friendo/features/dial/bloc/dial_state.dart'
    show CadenceChanged, DialState, MeetingLogged, PackingCause;
import 'package:friendo/features/dial/packing/dial_reading.dart' show readDial;
import 'package:friendo/features/dial/packing/dial_geometry.dart'
    show DialGeometry;
import 'package:friendo_domain/friendo_domain.dart'
    show Cadence, CivilDate, Meeting;

/// What the Dial draws, and the two things a tap on it writes.
///
/// It holds the Friends it last read and packs them again on an event. Nothing
/// here runs on a tick: a Bead creeps by a fraction of a percent an hour, so
/// the only moments that change the answer are a write, a return to the app,
/// an unlock, and the turn of the local Civil Date.
///
/// It holds no animation. It publishes successive packings and the view moves
/// the Beads between them. A Bead that was in flight when the Profile locked
/// is dropped rather than resumed, because a rebuild could not restore it.
class DialCubit extends Cubit<DialState> with WidgetsBindingObserver {
  DialCubit({
    required this.friends,
    required this.databases,
    required this.dayChange,
    this.clock = const Clock(),
    this.geometry = const DialGeometry(),
  }) : super(const DialState.locked()) {
    WidgetsBinding.instance.addObserver(this);
    _rows = friends.watchDialFriends().listen(_onRows);
    _whileOpen = databases.state.listen(_onDatabaseState);
  }

  final FriendRepository friends;

  final DatabaseSession databases;

  final CivilDateChange dayChange;

  final Clock clock;

  final DialGeometry geometry;

  /// The Friends the newest read gave, held so that a turn of the Civil Date
  /// packs them again rather than opening a second stream.
  List<DialFriend> _held = const [];

  /// What the Dial did that the next read will show. The read arrives through
  /// the store, which carries no reason of its own.
  PackingCause? _asked;

  StreamSubscription<List<DialFriend>>? _rows;
  StreamSubscription<DatabaseState>? _whileOpen;
  StreamSubscription<void>? _untilMidnight;

  /// Writes a Meeting with [friendId], dated today.
  ///
  /// It names the Friend it writes for. A write for a Friend this Profile does
  /// not hold does nothing.
  Future<void> logMeeting(String friendId) async {
    final friend = await friends.load(friendId);
    if (friend == null) return;

    final now = clock.now();
    _asked = MeetingLogged(friendId);
    await friends.save(
      friend.logMeeting(
        Meeting(id: newId(), happenedOn: CivilDate.from(now)),
        now: now,
      ),
    );
  }

  /// Moves [friendId] to [cadence], which moves their Due Date and can move
  /// their Orbit.
  Future<void> changeCadence(String friendId, Cadence cadence) async {
    final friend = await friends.load(friendId);
    if (friend == null) return;

    _asked = CadenceChanged(friendId);
    await friends.save(friend.copyWith(cadence: cadence));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Time passed while the app was away, and the Standing of a Friend can
    // have turned with it.
    if (state == AppLifecycleState.resumed) _repack(null);
  }

  @override
  Future<void> close() async {
    WidgetsBinding.instance.removeObserver(this);
    await _untilMidnight?.cancel();
    await _whileOpen?.cancel();
    await _rows?.cancel();

    return super.close();
  }

  void _onRows(List<DialFriend> rows) {
    _held = rows;
    final asked = _asked;
    _asked = null;
    _repack(asked);
  }

  void _onDatabaseState(DatabaseState open) {
    if (open == DatabaseState.open) {
      _untilMidnight ??= dayChange.changes.listen((_) => _repack(null));

      return;
    }

    unawaited(_untilMidnight?.cancel());
    _untilMidnight = null;
    _held = const [];
    _asked = null;
    emit(const DialState.locked());
  }

  void _repack(PackingCause? cause) {
    if (databases.stateNow != DatabaseState.open) return;

    emit(
      readDial(
        friends: _held,
        now: clock.now(),
        geometry: geometry,
        cause: cause,
      ),
    );
  }
}
