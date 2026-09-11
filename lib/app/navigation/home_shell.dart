import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/db/database_session.dart';
import '../../core/friends/friend_repository.dart';
import '../../core/time/civil_date_change.dart';
import '../../core/time/clock.dart';
import '../../features/dial/view/dial_page.dart';
import '../../features/friends/bloc/add_friend_cubit.dart';
import '../../features/friends/bloc/add_friend_state.dart';
import '../../features/friends/bloc/friends_cubit.dart';
import '../../features/friends/bloc/notepad_cubit.dart';
import '../../features/friends/bloc/notepad_state.dart';
import '../../features/friends/view/add_friend_page.dart';
import '../../features/friends/view/friends_page.dart';
import '../../features/friends/view/notepad_page.dart';
import '../../features/settings/view/settings_page.dart';
import 'app_section.dart';
import 'navigation_cubit.dart';

/// The frame around every section: a page above, a navigation bar below.
///
/// This widget imports three features, which is why it lives in `app/`. A
/// feature must never import another feature. Joining them is the app layer's
/// job.
///
/// The pages sit in an [IndexedStack], so a page keeps its state and its scroll
/// position while the user is somewhere else.
class HomeShell extends StatelessWidget {
  /// Create the shell over the collaborators the two pushed screens need.
  const HomeShell({
    required this.friends,
    required this.databases,
    required this.dayChange,
    this.clock = const Clock(),
    super.key,
  });

  /// The one reader and writer of the Friend tables.
  final FriendRepository friends;

  /// The owner of the open connection.
  final DatabaseSession databases;

  /// The announcement that the local Civil Date has turned.
  final CivilDateChange dayChange;

  /// Where every `now` comes from.
  final Clock clock;

  /// The page for each section.
  ///
  /// This list is indexed by [AppSection.index], so its order must match the
  /// order of the enum values.
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, AppSection>(
      builder: (context, section) => Scaffold(
        body: SafeArea(
          child: IndexedStack(
            index: section.index,
            children: [
              // Wiring one feature to another is this layer's job. The Dial
              // raises the request and routes none of it itself.
              DialPage(
                onAddFriend: () => _addAFriend(context),
                onShowOrbit: (orbit) {
                  context.read<FriendsCubit>().showOrbit(orbit);
                  context.read<NavigationCubit>().select(AppSection.friends);
                },
              ),
              FriendsPage(
                onAddFriend: () => _addAFriend(context),
                onOpenFriend: (friendId) => _openFriend(context, friendId),
              ),
              const SettingsPage(),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: section.index,
          onDestinationSelected: (index) =>
              context.read<NavigationCubit>().select(AppSection.values[index]),
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

  /// Open the form that writes a Friend.
  ///
  /// The route is pushed over the whole shell, so the cubit it needs is made
  /// here rather than found above: a pushed route is built by the Navigator,
  /// which sits over every provider the shell was given.
  void _addAFriend(BuildContext context) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => BlocProvider(
        create: (_) => AddFriendCubit(
          friends: friends,
          databases: databases,
          clock: clock,
        ),
        child: Builder(
          builder: (context) => BlocListener<AddFriendCubit, AddFriendDraft>(
            // A lock takes this screen off the stack. It would otherwise
            // rest over the keypad, drawn blank and holding the User
            // away from the one control that gets them back.
            listenWhen: (was, now) => now.isLocked && !was.isLocked,
            listener: (context, _) => Navigator.of(context).pop(),
            child: AddFriendPage(onDone: () => Navigator.of(context).pop()),
          ),
        ),
      ),
    ),
  );

  /// Open one Friend, top to bottom.
  void _openFriend(BuildContext context, String friendId) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => BlocProvider(
            create: (_) => NotepadCubit(
              friendId: friendId,
              friends: friends,
              databases: databases,
              dayChange: dayChange,
              clock: clock,
            ),
            child: Builder(
              builder: (context) => BlocListener<NotepadCubit, NotepadReading>(
                listenWhen: (was, now) => now.isLocked && !was.isLocked,
                listener: (context, _) => Navigator.of(context).pop(),
                child: NotepadPage(onGone: () => Navigator.of(context).pop()),
              ),
            ),
          ),
        ),
      );
}
