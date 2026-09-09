import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/core/db/database_session.dart';
import 'package:friendo/core/profiles/data_key_store.dart';
import 'package:friendo/core/profiles/profile_creator.dart';
import 'package:friendo/core/profiles/profile_list.dart';
import 'package:friendo/features/first_run/bloc/first_run_cubit.dart';
import 'package:friendo/features/first_run/bloc/first_run_state.dart';
import 'package:friendo/features/first_run/view/first_run_page.dart';
import 'package:friendo_ui/friendo_ui.dart';
import 'package:hashlib/hashlib.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory directory;
  late DatabaseSession databases;
  late FirstRunCubit cubit;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    directory = Directory.systemTemp.createTempSync('friendo_first_run_page');
    databases = DatabaseSession(directory);
    cubit = FirstRunCubit(
      ProfileCreator(
        profiles: ProfileList(directory),
        databases: databases,
        dataKeys: const DataKeyStore(),
        security: Argon2Security.test,
      ),
    );
  });

  tearDown(() async {
    await cubit.close();
    await databases.close();
    directory.deleteSync(recursive: true);
  });

  Future<void> pump(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      theme: ThemeData.dark().copyWith(extensions: const [Soft.dark()]),
      home: BlocProvider.value(value: cubit, child: const FirstRunPage()),
    ),
  );

  Future<void> typeName(WidgetTester tester, String name) async {
    await tester.enterText(find.byType(TextField), name);
    await tester.tap(find.text('Continue'));
    await tester.pump();
  }

  Future<void> typePin(WidgetTester tester, String digits) async {
    for (final digit in digits.split('')) {
      await tester.tap(find.widgetWithText(TextButton, digit));
      await tester.pump();
    }
  }

  testWidgets('asks for a name before anything else', (tester) async {
    await pump(tester);

    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(PinKeypad), findsNothing);
  });

  testWidgets('shows the keypad once the name is given', (tester) async {
    await pump(tester);

    await typeName(tester, 'Michal');

    expect(find.byType(PinKeypad), findsOneWidget);
  });

  testWidgets('says so when the name holds nothing but spaces', (tester) async {
    await pump(tester);

    await typeName(tester, '   ');

    expect(find.byType(PinKeypad), findsNothing);
    expect(find.text('A Profile needs a name.'), findsOneWidget);
  });

  testWidgets('fills one dot for every digit typed', (tester) async {
    await pump(tester);
    await typeName(tester, 'Michal');

    await typePin(tester, '123');

    final dots = tester.widgetList<PinDot>(find.byType(PinDot));
    expect(dots.where((dot) => dot.filled), hasLength(3));
  });

  testWidgets('asks for the PIN a second time', (tester) async {
    await pump(tester);
    await typeName(tester, 'Michal');

    await typePin(tester, '123456');

    expect(find.text('Type the PIN again'), findsOneWidget);
  });

  /// Makes the Profile for real, which needs the event loop a widget test
  /// holds still. Driving the cubit rather than the keypad keeps the real I/O
  /// inside [WidgetTester.runAsync], where it can finish.
  Future<void> reachCostScreen(WidgetTester tester) async {
    await tester.runAsync(() async {
      cubit.submitName('Michal');
      for (final digits in ['123456', '123456']) {
        for (final digit in digits.split('')) {
          cubit.pressDigit(int.parse(digit));
        }
      }
      await cubit.stream
          .firstWhere((state) => state.step == FirstRunStep.cost)
          .timeout(const Duration(seconds: 30));
    });
    await tester.pump();
  }

  testWidgets('states the cost once the Profile is made', (tester) async {
    await pump(tester);

    await reachCostScreen(tester);

    expect(find.textContaining('this phone'), findsWidgets);
    expect(find.textContaining('lost'), findsWidgets);
  });

  testWidgets('offers no way back from the cost screen', (tester) async {
    await pump(tester);

    await reachCostScreen(tester);

    final scopes = tester
        .widgetList(find.byWidgetPredicate((widget) => widget is PopScope))
        .cast<PopScope<dynamic>>();

    expect(scopes.single.canPop, isFalse);
  });
}
