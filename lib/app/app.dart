import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/profiles/profile.dart';
import '../core/profiles/profile_creator.dart';
import '../core/profiles/profile_session.dart';
import '../core/security/auto_lock.dart';
import '../core/security/screen_cover.dart';
import '../core/db/database_session.dart';
import '../features/auth/bloc/unlock_cubit.dart';
import '../features/auth/bloc/unlock_state.dart';
import '../features/auth/view/damaged_list_page.dart';
import '../features/auth/view/profile_picker_page.dart';
import '../features/auth/view/unlock_page.dart';
import '../features/first_run/bloc/first_run_cubit.dart';
import '../features/first_run/bloc/first_run_state.dart';
import '../features/first_run/view/first_run_page.dart';
import 'boot.dart';
import 'navigation/home_shell.dart';
import 'navigation/navigation_cubit.dart';
import 'theme.dart';

class FriendoApp extends StatefulWidget {
  const FriendoApp({
    required this.creator,
    required this.session,
    this.firstScreen,
    super.key,
  });

  /// The way to make a Profile, for a phone that holds none.
  final ProfileCreator creator;

  /// The way in and out of a Profile. It outlives every screen, because the
  /// lock arrives while a screen is being built.
  final ProfileSession session;

  /// The screen the app opens on.
  ///
  /// It is null once nothing stands between the User and their Friends.
  final FirstScreen? firstScreen;

  @override
  State<FriendoApp> createState() => _FriendoAppState();
}

class _FriendoAppState extends State<FriendoApp> {
  late FirstScreen? _screen = widget.firstScreen;

  late final AutoLock _autoLock = AutoLock(lock: widget.session.lock);

  StreamSubscription<DatabaseState>? _whileOpen;

  DatabaseState _wasState = DatabaseState.locked;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(_autoLock);
    _whileOpen = widget.session.databases.state.listen(_onDatabaseState);
  }

  @override
  void dispose() {
    unawaited(_whileOpen?.cancel());
    WidgetsBinding.instance.removeObserver(_autoLock);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'friendO',
    theme: friendoTheme(),
    builder: (_, child) => ScreenCover(child: child!),
    home: switch (_screen) {
      ListDamaged(:final path, :final reason) => DamagedListPage(
        path: path,
        reason: reason,
      ),
      StartFirstRun() => _firstRun(),
      AskForPin(:final profile) => _keypadFor(profile),
      PickProfile(:final profiles) => ProfilePickerPage(
        profiles: profiles,
        onPicked: (profile) => setState(() => _screen = AskForPin(profile)),
      ),
      null => _theApp(),
    },
  );

  /// Sends the User back to the first screen when the Profile closes.
  ///
  /// The same read that decided the first screen decides this one, so a lock,
  /// a switch of Profile and a fresh start all take one path.
  void _onDatabaseState(DatabaseState state) {
    final was = _wasState;
    _wasState = state;
    // Only a Profile that closes sends the User back. The stream replays
    // where it stands to every new listener, and a start that is already
    // locked has a first screen of its own.
    if (was != DatabaseState.open || state != DatabaseState.locked) return;
    if (_screen != null) return;

    unawaited(_askAgain());
  }

  Future<void> _askAgain() async {
    final screen = await readFirstScreen(widget.session.profiles);
    if (!mounted) return;

    setState(() => _screen = screen);
  }

  Widget _keypadFor(Profile profile) => BlocProvider(
    create: (_) => UnlockCubit(session: widget.session, profile: profile),
    child: BlocListener<UnlockCubit, UnlockState>(
      listenWhen: (_, state) => state.step == UnlockStep.open,
      listener: (_, _) => setState(() => _screen = null),
      child: const UnlockPage(),
    ),
  );

  Widget _firstRun() => BlocProvider(
    create: (_) => FirstRunCubit(widget.creator, widget.session),
    child: BlocListener<FirstRunCubit, FirstRunState>(
      listenWhen: (_, state) => state.step == FirstRunStep.done,
      listener: (_, _) => _afterFirstRun(),
      child: const FirstRunPage(),
    ),
  );

  /// Shows the app when First Run left the Profile open, and asks for the PIN
  /// when it did not.
  void _afterFirstRun() {
    if (widget.session.databases.stateNow == DatabaseState.open) {
      setState(() => _screen = null);

      return;
    }

    unawaited(_askAgain());
  }

  Widget _theApp() =>
      BlocProvider(create: (_) => NavigationCubit(), child: const HomeShell());
}
