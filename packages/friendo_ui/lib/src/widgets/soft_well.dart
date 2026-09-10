import 'package:flutter/material.dart';

import '../tokens/soft.dart';

/// A field that sinks into the surface behind it.
///
/// It is the debossed treatment, and it holds anything the User writes into
/// or reads out of a hollow: a search field, a text field, a read-out.
///
/// Flutter's [BoxShadow] draws outside a box and never inside one, so the
/// hollow is drawn as a dark ground with a light hairline along its edge.
/// That reads as depth at the sizes this app uses.
class SoftWell extends StatelessWidget {
  const SoftWell({
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    super.key,
  });

  final Widget child;

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final soft = Soft.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: soft.well,
        borderRadius: BorderRadius.circular(soft.radius),
        border: Border.all(color: soft.glow.withValues(alpha: 0.12)),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
