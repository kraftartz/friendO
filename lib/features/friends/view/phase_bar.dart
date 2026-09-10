import 'package:flutter/material.dart';

/// A bar filled to a fraction.
///
/// It takes a fraction and a colour, and never a Phase or a Standing. That
/// keeps it clear of the domain, which friendo_ui may not import, and it is
/// the rule that must hold on the day this bar moves into the package.
///
/// It lives in the feature until a second screen wants the same treatment.
/// See ADR-0018.
///
/// A fraction outside nothing to one is clamped, so a caller that hands it a
/// Phase above one gets a full bar rather than a bar that runs off its track.
class PhaseBar extends StatelessWidget {
  const PhaseBar({
    required this.fraction,
    required this.colour,
    this.height = 6,
    super.key,
  });

  final double fraction;

  final Color colour;

  final double height;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(height),
    child: LinearProgressIndicator(
      value: fraction.clamp(0, 1),
      minHeight: height,
      backgroundColor: colour.withValues(alpha: 0.18),
      valueColor: AlwaysStoppedAnimation<Color>(colour),
    ),
  );
}
