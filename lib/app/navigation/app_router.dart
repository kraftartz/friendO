import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/database_session.dart';
import '../../core/friends/friend_repository.dart';
import '../../core/profiles/profile_creator.dart';
import '../../core/profiles/profile_session.dart';
import '../../core/settings/settings_store.dart';
import '../../core/time/civil_date_change.dart';
import '../../core/time/clock.dart';
import '../../features/auth/bloc/unlock_cubit.dart';
import '../../features/auth/bloc/unlock_state.dart';
import '../../features/auth/view/damaged_list_page.dart';
import '../../features/auth/view/profile_picker_page.dart';
import '../../features/auth/view/unlock_page.dart';
import '../../features/dial/view/dial_page.dart';
import '../../features/first_run/bloc/first_run_cubit.dart';
import '../../features/first_run/bloc/first_run_state.dart';
import '../../features/first_run/view/first_run_page.dart';
import '../../features/friends/bloc/add_friend_cubit.dart';
import '../../features/friends/bloc/friends_cubit.dart';
import '../../features/friends/bloc/notepad_cubit.dart';
import '../../features/friends/view/add_friend_page.dart';
import '../../features/friends/view/friends_page.dart';
import '../../features/friends/view/notepad_page.dart';
import '../../features/settings/bloc/settings_cubit.dart';
import '../../features/settings/view/settings_page.dart';
import '../boot.dart';
import '../platform_edges.dart';
import 'app_section.dart';
import 'app_status.dart';
import 'home_shell.dart';

/// The Dial, which is where the app opens once a Profile is open.
const dialPath = '/dial';

/// The Friends List.
const friendsPath = '/friends';

/// The Profile's own options.
const settingsPath = '/settings';

/// The form that writes a Friend.
const addFriendPath = '/friends/add';

/// The screens a User reaches before any Profile is open.
///
/// The redirect keeps the User on one of these while the app is locked, and
/// off all of them once it is not.
const gatePaths = <String>['/first-run', '/profiles', '/unlock', '/damaged'];

/// Whether [path] is a screen that stands in front of the lock.
bool isGate(String path) =>
    gatePaths.any((gate) => path == gate || path.startsWith('$gate/'));

/// The screen that draws nothing, while the app has read nothing.
///
/// A boot reading takes a file, and a redirect answers in one step. This is
/// where the app waits, and it holds no Friend, no bar and no Dial. ADR-0011
/// hides the Friends behind the lock, and a Dial drawn for one frame before
/// the reading lands is that leak.
const waitingPath = '/';

/// Where the app opens, from the reading taken before the first frame.
///
/// The redirect would send the User here anyway, one frame later. Starting
/// here means the Dial is never drawn behind a lock, not even for a frame.
String openingLocation(FirstScreen? firstScreen) =>
    firstScreen == null ? waitingPath : gateFor(firstScreen);

/// The screen that stands in front of the lock for [firstScreen].
String gateFor(FirstScreen firstScreen) => switch (firstScreen) {
  StartFirstRun() => '/first-run',
  AskForPin(:final profile) => '/unlock/${profile.id}',
  PickProfile() => '/profiles',
  ListDamaged() => '/damaged',
};

/// Where the app belongs, given what it knows. Null means stay.
///
/// This is the whole of ADR-0037's argument in one function. A locked Profile
/// takes the User off every screen that draws their Friends, wherever they
/// are and however they got there, and a screen cannot forget to be taken off.
///
/// It reads no widget and no context, so the rule can be read on its own.
String? decideLocation({
  required String path,
  required FirstScreen? firstScreen,
  required bool isOpen,
  String? wantedProfileId,
}) {
  // A reading that has not been taken decides nothing, and the app waits on
  // the screen that draws nothing.
  if (firstScreen == null) return path == waitingPath ? null : waitingPath;

  if (firstScreen is ListDamaged) return path == '/damaged' ? null : '/damaged';

  if (isOpen) return isGate(path) || path == waitingPath ? dialPath : null;

  // Already in front of the lock. The User may be on the keypad for a Profile
  // the list would not have offered first, which is what switching Profile is.
  if (isGate(path)) return null;

  return wantedProfileId == null
      ? gateFor(firstScreen)
      : '/unlock/$wantedProfileId';
}

/// One router for the whole app.
///
/// It owns three things that used to be owned separately: which screen stands
/// in front of the lock, which section is on show, and what is pushed over it.
/// The lock is the reason they are one object. A locked Profile must take the
/// User off every screen that draws their Friends, and as a redirect that is
/// one condition checked on every route rather than a rule each screen has to
/// remember. See ADR-0037.
GoRouter buildRouter({
  required AppStatus status,
  required ProfileSession session,
  required ProfileCreator creator,
  required FriendRepository friends,
  required DatabaseSession databases,
  required SettingsStore settings,
  required CivilDateChange dayChange,
  required PlatformEdges edges,
  Clock clock = const Clock(),
  GlobalKey<NavigatorState>? navigatorKey,
}) {
  String? decide(BuildContext _, GoRouterState state) => decideLocation(
    path: state.matchedLocation,
    firstScreen: status.firstScreen,
    isOpen: status.isOpen,
    wantedProfileId: status.wantedProfileId,
  );

  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: openingLocation(status.firstScreen),
    refreshListenable: status,
    redirect: decide,
    routes: [
      GoRoute(path: waitingPath, builder: (_, _) => const SizedBox.shrink()),
      GoRoute(
        path: '/damaged',
        builder: (_, _) => switch (status.firstScreen) {
          ListDamaged(:final path, :final reason) => DamagedListPage(
            path: path,
            reason: reason,
          ),
          _ => const SizedBox.shrink(),
        },
      ),
      GoRoute(
        path: '/first-run',
        builder: (context, _) => BlocProvider(
          create: (_) => FirstRunCubit(creator, session),
          child: BlocListener<FirstRunCubit, FirstRunState>(
            listenWhen: (_, state) => state.step == FirstRunStep.done,
            listener: (context, _) {
              if (status.isOpen) {
                context.go(dialPath);
              } else {
                unawaitedRead(status);
              }
            },
            child: const FirstRunPage(),
          ),
        ),
      ),
      GoRoute(
        path: '/profiles',
        builder: (context, _) => ProfilePickerPage(
          profiles: status.everyProfile,
          onPicked: (profile) => context.go('/unlock/${profile.id}'),
        ),
      ),
      GoRoute(
        path: '/unlock/:profileId',
        builder: (context, state) {
          final profile = status.profileOf(
            state.pathParameters['profileId'] ?? '',
          );
          if (profile == null) return const SizedBox.shrink();

          return BlocProvider(
            create: (_) => UnlockCubit(session: session, profile: profile),
            child: BlocListener<UnlockCubit, UnlockState>(
              listenWhen: (_, state) => state.step == UnlockStep.open,
              listener: (context, _) => context.go(dialPath),
              child: const UnlockPage(),
            ),
          );
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => HomeShell(
          shell: shell,
          profileId: status.openProfileId,
          wantsProfile: status.wants,
        ),
        branches: [
          for (final section in AppSection.values)
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: _pathOf(section),
                  builder: (_, _) => _pageOf(section),
                  routes: _under(section, friends: friends, clock: clock),
                ),
              ],
            ),
        ],
      ),
    ],
  );
}

/// Reads the Profile list again without waiting for the answer.
///
/// First Run that leaves the Profile closed sends the User to the keypad, and
/// the reading is what decides which keypad.
void unawaitedRead(AppStatus status) => status.readAgain();

String _pathOf(AppSection section) => switch (section) {
  AppSection.dial => dialPath,
  AppSection.friends => friendsPath,
  AppSection.settings => settingsPath,
};

Widget _pageOf(AppSection section) => switch (section) {
  AppSection.dial => const _DialSection(),
  AppSection.friends => const _FriendsSection(),
  AppSection.settings => const _SettingsSection(),
};

List<RouteBase> _under(
  AppSection section, {
  required FriendRepository friends,
  required Clock clock,
}) => switch (section) {
  AppSection.friends => [
    GoRoute(path: 'add', builder: (context, _) => const AddFriendRoute()),
    GoRoute(
      path: ':friendId',
      builder: (context, state) =>
          NotepadRoute(friendId: state.pathParameters['friendId']!),
    ),
  ],
  _ => const [],
};

class _DialSection extends StatelessWidget {
  const _DialSection();

  @override
  Widget build(BuildContext context) => DialPage(
    onAddFriend: () => context.go(addFriendPath),
    onShowOrbit: (orbit) {
      context.read<FriendsCubit>().showOrbit(orbit);
      context.go(friendsPath);
    },
  );
}

class _FriendsSection extends StatelessWidget {
  const _FriendsSection();

  @override
  Widget build(BuildContext context) => FriendsPage(
    onAddFriend: () => context.go(addFriendPath),
    onOpenFriend: (friendId) => context.go('$friendsPath/$friendId'),
  );
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection();

  @override
  Widget build(BuildContext context) => SettingsPage(
    onSwitchProfile: (profile) =>
        context.read<SettingsCubit>().leaveFor(profile.id),
  );
}

/// Add a Friend, with the state it writes through.
///
/// The cubit is made here because the screen is a route and not a tab: it
/// comes and goes, and so does what the User has typed into it.
class AddFriendRoute extends StatelessWidget {
  /// Draw the form.
  const AddFriendRoute({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => AddFriendCubit(
      friends: context.read<FriendRepository>(),
      databases: context.read<DatabaseSession>(),
      clock: context.read<Clock>(),
    ),
    child: Builder(
      builder: (context) =>
          AddFriendPage(onDone: () => context.go(friendsPath)),
    ),
  );
}

/// One Friend, with the state it writes through.
class NotepadRoute extends StatelessWidget {
  /// Draw the Notepad on [friendId].
  const NotepadRoute({required this.friendId, super.key});

  /// The Friend this route reads.
  final String friendId;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (context) => NotepadCubit(
      friendId: friendId,
      friends: context.read<FriendRepository>(),
      databases: context.read<DatabaseSession>(),
      dayChange: context.read<CivilDateChange>(),
      clock: context.read<Clock>(),
    ),
    child: Builder(
      builder: (context) => NotepadPage(onGone: () => context.go(friendsPath)),
    ),
  );
}
