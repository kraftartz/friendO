import 'package:flutter/material.dart';
import 'package:friendo_ui/friendo_ui.dart' show Soft, SoftWell;
import 'package:widgetbook/widgetbook.dart';

Widget softWellUseCase(BuildContext context) {
  final label = context.knobs.string(label: 'text', initialValue: 'Search');

  return Center(
    child: Theme(
      data: ThemeData(extensions: const [Soft.dark()]),
      child: SizedBox(
        width: 320,
        child: SoftWell(
          child: Text(label, style: const TextStyle(color: Color(0xFFCBC3D7))),
        ),
      ),
    ),
  );
}
