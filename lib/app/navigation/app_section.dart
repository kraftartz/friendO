import 'package:flutter/material.dart';

/// One area of the app that the navigation bar can reach.
///
/// The declaration order is the order of the destinations in the bar, and
/// `index` is used to pick the matching page. Reordering these values reorders
/// the bar.
enum AppSection {
  /// The main screen.
  dial(label: 'Dial', icon: Icons.track_changes),

  /// The list of Friends.
  friends(label: 'Friends', icon: Icons.people_outline),

  /// Reminders and app options.
  settings(label: 'Settings', icon: Icons.settings_outlined);

  const AppSection({required this.label, required this.icon});

  /// The text under the destination icon.
  final String label;

  /// The destination icon.
  final IconData icon;
}
