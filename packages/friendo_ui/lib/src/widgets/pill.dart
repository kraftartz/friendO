import 'package:flutter/material.dart';

import '../tokens/soft.dart';

/// A small rounded control that carries a label, and a count beside it.
///
/// A chosen Pill is filled in the glow colour. An unchosen one rests on the
/// surface. The two must be told apart without reading the label, because a
/// row of them says which one is in force.
class Pill extends StatelessWidget {
  const Pill({
    required this.label,
    this.count,
    this.isChosen = false,
    this.onTap,
    super.key,
  });

  final String label;

  /// The number beside the label, or null for a Pill that counts nothing.
  final int? count;

  final bool isChosen;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final soft = Soft.of(context);
    final count = this.count;
    final ink = isChosen ? soft.well : soft.glow;

    return Semantics(
      button: onTap != null,
      selected: isChosen,
      child: GestureDetector(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: isChosen ? soft.glow : soft.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: soft.glow.withValues(alpha: 0.35)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Text(
              count == null ? label : '$label $count',
              style: TextStyle(
                color: ink,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
