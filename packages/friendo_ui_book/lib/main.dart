import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';

import 'use_cases/avatar_halo_use_case.dart';
import 'use_cases/pill_use_case.dart';
import 'use_cases/pin_keypad_use_case.dart';
import 'use_cases/soft_button_use_case.dart';
import 'use_cases/soft_card_use_case.dart';
import 'use_cases/soft_well_use_case.dart';

void main() => runApp(const FriendoBook());

/// The Widgetbook workspace for friendo_ui.
///
/// Run it with `flutter run -d chrome` from this package.
///
/// The tree below is written by hand. Adding a use case means adding a
/// [WidgetbookUseCase] entry here and a builder under `lib/use_cases/`. That is
/// about four lines, which is cheaper than the code generator it replaces.
///
/// The tree lists what is worth previewing, not everything that exists. A
/// primitive with no entry is not an error.
class FriendoBook extends StatelessWidget {
  /// Create the workspace.
  const FriendoBook({super.key});

  @override
  Widget build(BuildContext context) => Widgetbook.material(
    directories: [
      WidgetbookFolder(
        name: 'widgets',
        children: [
          WidgetbookComponent(
            name: 'AvatarHalo',
            useCases: [
              WidgetbookUseCase(name: 'Default', builder: avatarHaloUseCase),
            ],
          ),
          WidgetbookComponent(
            name: 'Pill',
            useCases: [
              WidgetbookUseCase(name: 'Default', builder: pillUseCase),
            ],
          ),
          WidgetbookComponent(
            name: 'PinKeypad',
            useCases: [
              WidgetbookUseCase(name: 'Default', builder: pinKeypadUseCase),
            ],
          ),
          WidgetbookComponent(
            name: 'SoftButton',
            useCases: [
              WidgetbookUseCase(name: 'Default', builder: softButtonUseCase),
            ],
          ),
          WidgetbookComponent(
            name: 'SoftCard',
            useCases: [
              WidgetbookUseCase(name: 'Default', builder: softCardUseCase),
            ],
          ),
          WidgetbookComponent(
            name: 'SoftWell',
            useCases: [
              WidgetbookUseCase(name: 'Default', builder: softWellUseCase),
            ],
          ),
        ],
      ),
    ],
  );
}
