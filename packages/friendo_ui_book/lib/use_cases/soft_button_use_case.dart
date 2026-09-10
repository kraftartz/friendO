import 'package:flutter/material.dart';
import 'package:friendo_ui/friendo_ui.dart' show Soft, SoftButton;
import 'package:widgetbook/widgetbook.dart';

Widget softButtonUseCase(BuildContext context) {
  final label = context.knobs.string(
    label: 'label',
    initialValue: 'Log a Meeting',
  );
  final isLive = context.knobs.boolean(label: 'live', initialValue: true);

  return Center(
    child: Theme(
      data: ThemeData(extensions: const [Soft.dark()]),
      child: SoftButton(onPressed: isLive ? () {} : null, child: Text(label)),
    ),
  );
}
