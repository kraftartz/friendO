import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/db/database_session.dart';
import '../../core/friends/friend_repository.dart';
import '../../core/profiles/profile_list.dart';
import '../../core/profiles/profile_session.dart';
import '../../core/settings/settings_store.dart';
import '../../core/time/civil_date_change.dart';
import '../../features/dial/bloc/dial_cubit.dart';
import '../../features/friends/bloc/friends_cubit.dart';
import '../../features/settings/bloc/settings_cubit.dart';
import '../platform_edges.dart';
import 'app_section.dart';

/// The frame around every section: a page above, a navigation bar below.
///
/// The router hands it the branch that is on show. The bar reports a tap and
/// routes nothing itself, which is the same shape every screen in this app
/// has: it produces a request, and the router reads it.
///
/// The blocs a section reads are made here and keyed by the Profile, so
/// switching gives every one of them a fresh start rather than a state built
/// from somebody else's rows.
class HomeShell extends StatelessWidget {
  /// Draw the shell around [shell], for the Profile under [profileId].
  const HomeShell({
    required this.shell,
    required this.profileId,
    required this.wantsProfile,
    super.key,
  });

  /// The branch the router is showing, and the way to change it.
  final StatefulNavigationShell shell;

  /// The Profile that is open. The blocs are keyed by it.
  final String? profileId;

  /// Told which Profile the User wants once this one closes.
  final void Function(String profileId) wantsProfile;

  @override
  Widget build(BuildContext context) {
    final databases = context.read<DatabaseSession>();
    final friends = context.read<FriendRepository>();
    final dayChange = context.read<CivilDateChange>();

    return MultiBlocProvider(
      key: ValueKey<String?>(profileId),
      providers: [
        BlocProvider(
          create: (_) => FriendsCubit(
            friends: friends,
            databases: databases,
            dayChange: dayChange,
          ),
        ),
        BlocProvider(
          create: (_) => DialCubit(
            friends: friends,
            databases: databases,
            dayChange: dayChange,
          ),
        ),
        BlocProvider(
          create: (_) => SettingsCubit(
            profileId: profileId,
            wantsProfile: wantsProfile,
            settings: context.read<SettingsStore>(),
            profiles: context.read<ProfileList>(),
            session: context.read<ProfileSession>(),
            databases: databases,
            notifications: context.read<PlatformEdges>().notifications,
            biometrics: context.read<PlatformEdges>().biometrics,
            screens: context.read<PlatformEdges>().screens,
          ),
        ),
      ],
      child: Scaffold(
        body: SafeArea(child: shell),
        bottomNavigationBar: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: shell.goBranch,
          destinations: [
            for (final section in AppSection.values)
              NavigationDestination(
                icon: Icon(section.icon),
                label: section.label,
              ),
          ],
        ),
      ),
    );
  }
}
