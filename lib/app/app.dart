import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/db/database_session.dart';
import '../core/friends/friend_repository.dart';
import '../core/profiles/profile_creator.dart';
import '../core/profiles/profile_list.dart';
import '../core/profiles/profile_session.dart';
import '../core/reminders/reminder_scheduler.dart';
import '../core/security/auto_lock.dart';
import '../core/security/screen_cover.dart';
import '../core/settings/profile_settings.dart';
import '../core/settings/settings_store.dart';
import '../core/time/civil_date_change.dart';
import '../core/time/clock.dart';
import 'boot.dart';
import 'navigation/app_router.dart';
import 'navigation/app_status.dart';
import 'platform_edges.dart';
import 'theme.dart';

/// The whole app: the collaborators that outlive every screen, and the router.
///
/// This layer wires and draws nothing of its own. The collaborators are
/// provided above the router, because the lock arrives while a screen is being
/// built and they must outlive it.
class FriendoApp extends StatefulWidget {
  /// Build the app over the session and the phone's own edges.
  const FriendoApp({
    required this.creator,
    required this.session,
    required this.edges,
    this.firstScreen,
    this.clock = const Clock(),
    super.key,
  });

  /// The way to make a Profile, for a phone that holds none.
  final ProfileCreator creator;

  /// The way in and out of a Profile. It outlives every screen, because the
  /// lock arrives while a screen is being built.
  final ProfileSession session;

  /// Everything the app asks the phone itself for.
  final PlatformEdges edges;

  /// The reading the app starts on, taken before the first frame.
  ///
  /// It is null when the app is to take its own reading, which is one frame of
  /// drawing nothing.
  final FirstScreen? firstScreen;

  /// Where every `now` comes from.
  final Clock clock;

  @override
  State<FriendoApp> createState() => _FriendoAppState();
}

class _FriendoAppState extends State<FriendoApp> {
  late final AutoLock _autoLock = AutoLock(lock: widget.session.lock);

  late final FriendRepository _friends = FriendRepository(
    widget.session.databases,
    clock: widget.clock,
  );

  /// The one announcement of the Civil Date change in the app. It is built
  /// here because it belongs to no single feature.
  late final CivilDateChange _dayChange = CivilDateChange(clock: widget.clock);

  late final SettingsStore _settings = SettingsStore(widget.session.databases);

  late final ReminderScheduler _reminders = ReminderScheduler(
    friends: _friends,
    settings: _settings,
    sink: widget.edges.reminders,
    clock: widget.clock,
  );

  late final AppStatus _status = AppStatus(
    databases: widget.session.databases,
    profiles: widget.session.profiles,
    firstScreen: widget.firstScreen,
  );

  late final GoRouter _router = buildRouter(
    status: _status,
    session: widget.session,
    creator: widget.creator,
    friends: _friends,
    databases: widget.session.databases,
    settings: _settings,
    dayChange: _dayChange,
    edges: widget.edges,
    clock: widget.clock,
  );

  StreamSubscription<ProfileSettings>? _whileSettings;

  /// What the app does about its own screen privacy.
  ///
  /// It starts covered. The allowance lives in the encrypted database and
  /// cannot be read until a Profile is open, which is the safe direction.
  bool _allowScreenshots = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(_autoLock);
    _whileSettings = _settings.watch().listen(_onSettings);
    _status.addListener(_onStatus);
    _reminders.start();
    if (widget.firstScreen == null) unawaited(_status.readAgain());
  }

  @override
  void dispose() {
    unawaited(_whileSettings?.cancel());
    unawaited(_reminders.dispose());
    unawaited(_dayChange.dispose());
    _status
      ..removeListener(_onStatus)
      ..dispose();
    _router.dispose();
    WidgetsBinding.instance.removeObserver(_autoLock);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MultiRepositoryProvider(
    providers: [
      RepositoryProvider<ProfileSession>.value(value: widget.session),
      RepositoryProvider<ProfileList>.value(value: widget.session.profiles),
      RepositoryProvider<DatabaseSession>.value(
        value: widget.session.databases,
      ),
      RepositoryProvider<FriendRepository>.value(value: _friends),
      RepositoryProvider<SettingsStore>.value(value: _settings),
      RepositoryProvider<CivilDateChange>.value(value: _dayChange),
      RepositoryProvider<PlatformEdges>.value(value: widget.edges),
      RepositoryProvider<Clock>.value(value: widget.clock),
    ],
    child: MaterialApp.router(
      title: 'friendO',
      theme: friendoTheme(),
      routerConfig: _router,
      builder: (_, child) =>
          ScreenCover(allowScreenshots: _allowScreenshots, child: child!),
    ),
  );

  /// Put the two settings the app itself acts on back to their safe values
  /// when the Profile closes.
  ///
  /// Both live in the encrypted database, so a locked app can read neither.
  /// ADR-0036 says it behaves as though every unread setting is at its safest
  /// value, and these are the two the app holds outside a screen.
  void _onStatus() {
    if (_status.isOpen) return;

    _autoLock.timeout = defaultLockTimeout;
    unawaited(widget.edges.screens.allowScreenshots(allowed: false));
    if (_allowScreenshots) setState(() => _allowScreenshots = false);
  }

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
}
