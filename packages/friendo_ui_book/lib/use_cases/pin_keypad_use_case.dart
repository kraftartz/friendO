import 'package:flutter/material.dart';
import 'package:friendo_ui/friendo_ui.dart' show PinDots, PinKeypad, Soft;
import 'package:widgetbook/widgetbook.dart';

Widget pinKeypadUseCase(BuildContext context) {
  final length = context.knobs.int.slider(
    label: 'length',
    initialValue: 6,
    min: 4,
    max: 8,
  );
  final filled = context.knobs.int.slider(
    label: 'filled',
    initialValue: 2,
    min: 0,
    max: 8,
  );

  return Theme(
    data: ThemeData.dark().copyWith(extensions: const [Soft.dark()]),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PinDots(length: length, filled: filled),
          const SizedBox(height: 32),
          PinKeypad(onDigit: (_) {}, onDelete: () {}),
        ],
      ),
    ),
  );
}
