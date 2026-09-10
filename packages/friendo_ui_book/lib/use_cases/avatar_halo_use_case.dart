import 'package:flutter/material.dart';
import 'package:friendo_ui/friendo_ui.dart' show AvatarHalo;
import 'package:widgetbook/widgetbook.dart';

/// Show an AvatarHalo against knobs for its label, its colour, its size and
/// its glow.
///
/// The size knob runs from the width a full Orbit allows to a width worth
/// tapping, because the treatment has to hold at both.
///
/// Register this builder in the tree in `main.dart`. Nothing finds it
/// automatically.
Widget avatarHaloUseCase(BuildContext context) {
  final label = context.knobs.string(label: 'label', initialValue: 'M');
  final size = context.knobs.double.slider(
    label: 'size',
    initialValue: 28,
    min: 16,
    max: 96,
  );
  final isLit = context.knobs.boolean(label: 'lit', initialValue: false);
  final colour = context.knobs.double.slider(
    label: 'hue',
    initialValue: 265,
    max: 360,
  );

  return Center(
    child: AvatarHalo(
      label: label,
      colour: HSLColor.fromAHSL(1, colour, 0.45, 0.65).toColor(),
      size: size,
      isLit: isLit,
    ),
  );
}
