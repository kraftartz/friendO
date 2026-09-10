import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/profiles/profile_creator.dart';
import '../core/profiles/profile_session.dart';
import '../core/security/auto_lock.dart';
import '../core/security/screen_cover.dart';
import '../features/auth/view/damaged_list_page.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(_autoLock);
  }

  @override
  void dispose() {
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
      // The keypad and the picker arrive with friendO-fff.7. Until they do,
      // a phone that holds a Profile opens the way it always has.
      AskForPin() || PickProfile() || null => _theApp(),
    },
  );

  Widget _firstRun() => BlocProvider(
    create: (_) => FirstRunCubit(widget.creator),
    child: BlocListener<FirstRunCubit, FirstRunState>(
      listenWhen: (_, state) => state.step == FirstRunStep.done,
      listener: (_, _) => setState(() => _screen = null),
      child: const FirstRunPage(),
    ),
  );

  Widget _theApp() =>
      BlocProvider(create: (_) => NavigationCubit(), child: const HomeShell());
}
