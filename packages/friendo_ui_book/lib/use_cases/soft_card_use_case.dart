import 'package:flutter/material.dart';
import 'package:friendo_ui/friendo_ui.dart' show Soft, SoftCard;
import 'package:widgetbook/widgetbook.dart';

/// Show a SoftCard whose corner radius is bound to a slider.
///
/// SoftCard takes no radius argument. It reads the radius from the [Soft]
/// tokens, so the slider overrides the token rather than the widget. Tuning a
/// treatment against a real surface is the reason this workspace exists.
///
/// Register this builder in the tree in `main.dart`. Nothing finds it
/// automatically.
Widget softCardUseCase(BuildContext context) {
  final radius = context.knobs.double.slider(
    label: 'radius',
    initialValue: 20,
    min: 0,
    max: 64,
  );

  return Center(
    child: Theme(
      data: ThemeData(extensions: [const Soft.dark().copyWith(radius: radius)]),
      child: const SoftCard(
        child: Text('SoftCard', style: TextStyle(color: Color(0xFFE6DEFD))),
      ),
    ),
  );
}
