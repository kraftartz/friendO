import 'package:flutter/material.dart';

/// A placeholder for the Settings screen.
///
/// It holds no behaviour. It exists so the navigation bar has somewhere to go
/// while the real screen is still a preplanned unit of work.
class SettingsPage extends StatelessWidget {
  /// Create the page.
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Settings page'));
}
