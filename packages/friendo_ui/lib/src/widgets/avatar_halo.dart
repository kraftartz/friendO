import 'package:flutter/material.dart';

/// A circular surface inside a halo of a given colour.
///
/// A treatment and not a concept. The colour arrives as an argument, so this
/// widget knows nothing about who or what it stands for and cannot grow a rule
/// about one.
///
/// [isLit] adds an ambient glow around the halo. It marks one avatar out of
/// several without moving it or changing its size, so whatever the caller is
/// saying with it stays a matter of appearance.
class AvatarHalo extends StatelessWidget {
  const AvatarHalo({
    required this.label,
    required this.colour,
    this.size = 40,
    this.isLit = false,
    super.key,
  });

  /// The short text in the middle, usually one letter.
  final String label;

  final Color colour;

  /// The width and the height of the whole treatment, halo included.
  final double size;

  final bool isLit;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color.alphaBlend(colour.withValues(alpha: 0.35), Colors.black),
        border: Border.all(color: colour, width: size / 14),
        boxShadow: [
          if (isLit)
            BoxShadow(
              color: colour.withValues(alpha: 0.75),
              blurRadius: size / 2,
              spreadRadius: size / 10,
            ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.clip,
          style: TextStyle(
            color: Colors.white,
            fontSize: size / 2.4,
            fontWeight: FontWeight.w600,
            height: 1,
          ),
        ),
      ),
    ),
  );
}
