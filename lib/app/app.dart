import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/db/database_session.dart';
import '../core/friends/friend_repository.dart';
import '../core/reminders/reminder_scheduler.dart';
import '../core/profiles/profile.dart';
import '../core/profiles/profile_creator.dart';
import '../core/profiles/profile_session.dart';
import '../core/security/auto_lock.dart';
import '../core/security/screen_cover.dart';
import '../core/settings/profile_settings.dart';
import '../core/settings/settings_store.dart';
import '../core/time/civil_date_change.dart';
import '../features/auth/bloc/unlock_cubit.dart';
import '../features/auth/bloc/unlock_state.dart';
import '../features/auth/view/damaged_list_page.dart';
import '../features/auth/view/profile_picker_page.dart';
import '../features/auth/view/unlock_page.dart';
import '../features/first_run/bloc/first_run_cubit.dart';
import '../features/first_run/bloc/first_run_state.dart';
import '../features/dial/bloc/dial_cubit.dart';
import '../features/friends/bloc/friends_cubit.dart';
import '../features/settings/bloc/settings_cubit.dart';
import '../features/first_run/view/first_run_page.dart';
import 'boot.dart';
import 'platform_edges.dart';
import 'navigation/home_shell.dart';
import 'navigation/navigation_cubit.dart';
import 'theme.dart';

class FriendoApp extends StatefulWidget {
  const FriendoApp({
    required this.creator,
    required this.session,
    required this.edges,
    this.firstScreen,
    super.key,
  });

  /// The way to make a Profile, for a phone that holds none.
  final ProfileCreator creator;

  /// The way in and out of a Profile. It outlives every screen, because the
  /// lock arrives while a screen is being built.
  final ProfileSession session;

  /// Everything the app asks the phone itself for.
  final PlatformEdges edges;

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

  late final FriendRepository _friends = FriendRepository(
    widget.session.databases,
  );

  /// The one announcement of the Civil Date change in the app. It is built
  /// here because it belongs to no single feature.
  late final CivilDateChange _dayChange = CivilDateChange();

  late final SettingsStore _settings = SettingsStore(widget.session.databases);

  late final ReminderScheduler _reminders = ReminderScheduler(
    friends: _friends,
    settings: _settings,
    sink: widget.edges.reminders,
  );

  StreamSubscription<DatabaseState>? _whileOpen;

  StreamSubscription<ProfileSettings>? _whileSettings;

  DatabaseState _wasState = DatabaseState.locked;

  /// The Profile the Settings screen is about, known from the unlock.
  String? _profileId;

  /// What the app does about its own screen privacy.
  ///
  /// It starts covered. The allowance lives in the encrypted database and
  /// cannot be read until a Profile is open, which is the safe direction.
  bool _allowScreenshots = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(_autoLock);
    _whileOpen = widget.session.databases.state.listen(_onDatabaseState);
    _whileSettings = _settings.watch().listen(_onSettings);
    _reminders.start();
  }

  @override
  void dispose() {
    unawaited(_whileSettings?.cancel());
    unawaited(_whileOpen?.cancel());
    unawaited(_reminders.dispose());
    unawaited(_dayChange.dispose());
    WidgetsBinding.instance.removeObserver(_autoLock);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'friendO',
    theme: friendoTheme(),
    builder: (_, child) =>
        ScreenCover(allowScreenshots: _allowScreenshots, child: child!),
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
  /// Follow the Profile's own options.
  ///
  /// The auto-lock reads its wait at the moment the app comes back, so a
  /// change written now is in force for the next return.
  void _onSettings(ProfileSettings settings) {
    _autoLock.timeout = settings.autoLock;
    unawaited(
      widget.edges.screens.allowScreenshots(
        allowed: settings.screenshotsAllowed,
      ),
    );
    if (settings.screenshotsAllowed == _allowScreenshots) return;

    setState(() => _allowScreenshots = settings.screenshotsAllowed);
  }

  void _onDatabaseState(DatabaseState state) {
    final was = _wasState;
    _wasState = state;
    if (state == DatabaseState.locked) {
      _autoLock.timeout = defaultLockTimeout;
      if (_allowScreenshots) setState(() => _allowScreenshots = false);
    }
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
      listener: (_, _) => setState(() {
        _profileId = profile.id;
        _screen = null;
      }),
      child: const UnlockPage(),
    ),
  );

  Widget _firstRun() => BlocProvider(
    create: (_) => FirstRunCubit(widget.creator, widget.session),
    child: BlocListener<FirstRunCubit, FirstRunState>(
      listenWhen: (_, state) => state.step == FirstRunStep.done,
      listener: (_, state) => _afterFirstRun(state.profileId),
      child: const FirstRunPage(),
    ),
  );

  /// Shows the app when First Run left the Profile open, and asks for the PIN
  /// when it did not.
  /// Leave First Run for the app, or back to the keypad.
  ///
  /// [profileId] is the Profile First Run made. The unlock path learns the same
  /// thing from the Profile the User picked, so neither path reads the file
  /// again to find out.
  void _afterFirstRun(String? profileId) {
    if (widget.session.databases.stateNow != DatabaseState.open) {
      unawaited(_askAgain());

      return;
    }

    setState(() {
      _profileId = profileId;
      _screen = null;
    });
  }

  /// The app itself, with one set of blocs per Profile.
  ///
  /// The key is the Profile, so switching gives every bloc a fresh start
  /// rather than a state built from somebody else's rows.
  Widget _theApp() => MultiBlocProvider(
    key: ValueKey<String?>(_profileId),
    providers: [
      BlocProvider(create: (_) => NavigationCubit()),
      BlocProvider(
        create: (_) => FriendsCubit(
          friends: _friends,
          databases: widget.session.databases,
          dayChange: _dayChange,
        ),
      ),
      BlocProvider(
        create: (_) => SettingsCubit(
          profileId: _profileId,
          settings: _settings,
          profiles: widget.session.profiles,
          session: widget.session,
          databases: widget.session.databases,
          notifications: widget.edges.notifications,
          biometrics: widget.edges.biometrics,
          screens: widget.edges.screens,
        ),
      ),
      BlocProvider(
        create: (_) => DialCubit(
          friends: _friends,
          databases: widget.session.databases,
          dayChange: _dayChange,
        ),
      ),
    ],
    child: const HomeShell(),
  );
}
