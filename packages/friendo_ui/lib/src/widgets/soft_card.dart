import 'package:flutter/material.dart';

import '../tokens/soft.dart';

/// A raised surface that draws itself from the [Soft] tokens.
///
/// The widget takes no colour and no radius. Reading them from the theme is the
/// point: change a token and every card in the app follows.
class SoftCard extends StatelessWidget {
  /// Create a card around [child].
  const SoftCard({required this.child, super.key});

  /// The content to show inside the card.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Fall back to the dark tokens when no Soft is installed. A card then still
    // renders inside a bare MaterialApp, which keeps previews and widget tests
    // from needing a full theme.
    final soft = Theme.of(context).extension<Soft>() ?? const Soft.dark();

    return DecoratedBox(
      decoration: BoxDecoration(
        color: soft.surface,
        borderRadius: BorderRadius.circular(soft.radius),
        boxShadow: [
          BoxShadow(color: soft.glow.withValues(alpha: 0.25), blurRadius: 16),
        ],
      ),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}
