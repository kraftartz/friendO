import 'dart:async';

import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../../core/db/database_session.dart';
import '../../core/profiles/profile.dart';
import '../../core/profiles/profile_list.dart';
import '../boot.dart';

/// What the router needs in order to decide the screen, and nothing else.
///
/// A redirect answers in one step and cannot wait for a file, so the boot
/// reading is held here and taken again whenever a Profile closes. The router
/// listens to it, so the reading and the screen cannot disagree.
///
/// It holds no Friend and no setting. It answers two questions: is a Profile
/// open, and if not, which screen stands in the way.
class AppStatus extends ChangeNotifier {
  /// Follow [databases], and read [profiles] when a Profile closes.
  AppStatus({
    required this.databases,
    required this.profiles,
    FirstScreen? firstScreen,
  }) {
    _take(firstScreen);
    _whileOpen = databases.state.listen(_onDatabaseState);
  }

  /// The owner of the connection.
  final DatabaseSession databases;

  /// The plaintext Profile list.
  final ProfileList profiles;

  StreamSubscription<DatabaseState>? _whileOpen;

  FirstScreen? _firstScreen;

  List<Profile> _rows = const [];

  String? _wantedProfileId;

  DatabaseState _was = DatabaseState.locked;

  /// The screen that stands between the User and their Friends.
  ///
  /// It is null only before the first reading has been taken, which is the one
  /// moment the app knows nothing and draws nothing.
  FirstScreen? get firstScreen => _firstScreen;

  /// Every Profile on the phone, as the last reading found them.
  List<Profile> get everyProfile => _rows;

  /// The Profile that is open, as the connection owner has it.
  String? get openProfileId => databases.openProfileId;

  /// The Profile the User has asked for next, over whatever the Profile list
  /// would otherwise offer.
  ///
  /// Switching Profile is a lock and then an unlock, and this is the half of
  /// it that says which Profile the second step is for.
  String? get wantedProfileId => _wantedProfileId;

  /// Whether a Profile is open.
  bool get isOpen => databases.stateNow == DatabaseState.open;

  /// The Profile under [profileId], or null when the list holds none.
  Profile? profileOf(String profileId) =>
      _rows.where((row) => row.id == profileId).firstOrNull;

  /// Say which Profile the User wants once this one closes.
  void wants(String profileId) {
    _wantedProfileId = profileId;
    notifyListeners();
  }

  /// Read the Profile list again, and say what it decides.
  ///
  /// The same read decides the first screen at a cold start and after a lock,
  /// so a lock, a switch of Profile and a fresh start all take one path.
  Future<void> readAgain() async {
    _take(await readFirstScreen(profiles));
    notifyListeners();
  }

  /// Hold [screen], and the Profiles it found.
  ///
  /// The keypad is reached by id, so the reading has to carry the Profiles it
  /// read and not only which screen they lead to.
  void _take(FirstScreen? screen) {
    _firstScreen = screen;
    _rows = switch (screen) {
      AskForPin(:final profile) => [profile],
      PickProfile(:final profiles) => profiles,
      _ => const [],
    };
  }

  @override
  void dispose() {
    unawaited(_whileOpen?.cancel());
    super.dispose();
  }

  void _onDatabaseState(DatabaseState state) {
    final was = _was;
    _was = state;
    if (state == DatabaseState.open) {
      _wantedProfileId = null;
      notifyListeners();

      return;
    }

    // Only a Profile that closes sends the User back. The stream replays
    // where it stands to every new listener, and a start that is already
    // locked has a first screen of its own.
    if (was != DatabaseState.open) {
      notifyListeners();

      return;
    }

    unawaited(readAgain());
  }
}
