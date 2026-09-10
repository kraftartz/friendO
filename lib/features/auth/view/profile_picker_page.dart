import 'package:flutter/material.dart';
import 'package:friendo_ui/friendo_ui.dart' show colourOf, initialOf;

import '../../../core/profiles/profile.dart';

/// The choice of Profile, for a phone that holds more than one.
///
/// It draws a colour and an initial, both worked out on read, so that
/// profiles.json carries neither.
class ProfilePickerPage extends StatelessWidget {
  const ProfilePickerPage({
    required this.profiles,
    required this.onPicked,
    super.key,
  });

  final List<Profile> profiles;

  final ValueChanged<Profile> onPicked;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Who is this?',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          for (final profile in profiles)
            ListTile(
              leading: CircleAvatar(
                backgroundColor: colourOf(profile.id),
                child: Text(initialOf(profile.displayName)),
              ),
              title: Text(profile.displayName),
              onTap: () => onPicked(profile),
            ),
        ],
      ),
    ),
  );
}
