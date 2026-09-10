import 'package:flutter/material.dart';
import 'package:friendo_domain/friendo_domain.dart';
import 'package:friendo_ui/friendo_ui.dart' show SoftCard;

/// A placeholder for the Dial.
///
/// It draws no Dial and no Bead yet. It exists to hold one wire open: a screen
/// in the app calls the pure-Dart domain and renders the answer with a
/// friendo_ui widget. Replace the body when the real Dial arrives; keep the two
/// imports.
class DialPage extends StatelessWidget {
  /// Create the page.
  const DialPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Fixed dates rather than DateTime.now(). The domain takes `now` as an
    // argument, so this screen reads the same on every run and in every test.
    final lastMet = CivilDate(2026, 1, 1);
    final phase = phaseOf(
      lastMet: lastMet,
      cadence: Cadence.ofDays(30),
      now: lastMet.startOfDayLocal().add(const Duration(days: 12)),
    );

    return Center(
      child: SoftCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Phase'),
            Text(
              phase.value.toStringAsFixed(2),
              key: const Key('dial-phase'),
              style: const TextStyle(fontSize: 32),
            ),
          ],
        ),
      ),
    );
  }
}
