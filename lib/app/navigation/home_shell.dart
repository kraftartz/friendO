import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/dial/view/dial_page.dart';
import '../../features/friends/view/friends_page.dart';
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
  /// Create the shell.
  const HomeShell({super.key});

  /// The page for each section.
  ///
  /// This list is indexed by [AppSection.index], so its order must match the
  /// order of the enum values.
  static const _pages = [DialPage(), FriendsPage(), SettingsPage()];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, AppSection>(
      builder: (context, section) => Scaffold(
        body: SafeArea(
          child: IndexedStack(index: section.index, children: _pages),
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
}
