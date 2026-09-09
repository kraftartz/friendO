import 'package:flutter/material.dart';
import 'package:friendo_ui/friendo_ui.dart';

/// The stop the app makes when it cannot read the list of Profiles.
///
/// It offers no way forward on purpose. Every way forward from here writes a
/// new list over Profiles that may still be on the phone.
class DamagedListPage extends StatelessWidget {
  const DamagedListPage({required this.path, required this.reason, super.key});

  final String path;

  final String reason;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'friendO cannot start',
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              SoftCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'The list of Profiles on this phone cannot be read. '
                      'friendO has changed nothing, and it will not make a '
                      'new Profile over the ones that may still be here.',
                    ),
                    const SizedBox(height: 16),
                    Text(path, style: theme.textTheme.bodySmall),
                    const SizedBox(height: 8),
                    Text(reason, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
