import 'package:flutter/material.dart';

import '../tokens/soft.dart';

/// The button that pushes out of the surface, lit from the top left.
///
/// Material draws one shadow, and this treatment needs two, so the button is
/// a decorated box with its own ink response rather than a restyled
/// [ButtonStyle]. See ADR-0018.
///
/// A null [onPressed] draws the button at rest and takes no tap.
class SoftButton extends StatelessWidget {
  const SoftButton({required this.child, this.onPressed, super.key});

  final Widget child;

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final soft = Soft.of(context);
    final isLive = onPressed != null;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            soft.glow.withValues(alpha: isLive ? 1 : 0.4),
            soft.glow.withValues(alpha: isLive ? 0.7 : 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          if (isLive)
            BoxShadow(
              color: soft.glow.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: soft.well,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
