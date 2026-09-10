import 'package:flutter/material.dart';
import 'package:friendo_ui/friendo_ui.dart' show Pill, Soft;
import 'package:widgetbook/widgetbook.dart';

Widget pillUseCase(BuildContext context) {
  final label = context.knobs.string(label: 'label', initialValue: 'Inner');
  final count = context.knobs.int.slider(
    label: 'count',
    initialValue: 4,
    min: 0,
    max: 99,
  );
  final isChosen = context.knobs.boolean(label: 'chosen');

  return Center(
    child: Theme(
      data: ThemeData(extensions: const [Soft.dark()]),
      child: Pill(label: label, count: count, isChosen: isChosen, onTap: () {}),
    ),
  );
}
