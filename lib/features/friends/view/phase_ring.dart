import 'package:flutter/material.dart';

/// A ring drawn round to a fraction.
///
/// It takes a fraction and a colour, and never a Phase or a Standing, for the
/// same reason `PhaseBar` does: it must stay clear of the domain to be able to
/// move into `friendo_ui` one day.
///
/// The Friends List draws the same fraction as a bar. Covering both shapes in
/// one treatment is a larger question than either screen, so the two stay
/// apart until a third caller asks. See ADR-0018.
class PhaseRing extends StatelessWidget {
  /// Draw the ring.
  const PhaseRing({
    required this.fraction,
    required this.colour,
    required this.child,
    this.size = 72,
    this.width = 5,
    super.key,
  });

  /// How far round the ring is filled. Values above one draw a whole ring.
  final double fraction;

  /// The colour of the filled part.
  final Color colour;

  /// What sits inside the ring.
  final Widget child;

  /// The width and the height of the whole treatment.
  final double size;

  /// How thick the ring is drawn.
  final double width;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: Stack(
      alignment: Alignment.center,
      children: [
        SizedBox.expand(
          child: CircularProgressIndicator(
            value: fraction.clamp(0, 1),
            strokeWidth: width,
            backgroundColor: colour.withValues(alpha: 0.18),
            valueColor: AlwaysStoppedAnimation<Color>(colour),
          ),
        ),
        child,
      ],
    ),
  );
}
