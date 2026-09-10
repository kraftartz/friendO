import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/app/app.dart';
import 'package:friendo/app/boot.dart';
import 'package:friendo/features/first_run/bloc/first_run_cubit.dart';
import 'package:friendo/features/first_run/bloc/first_run_state.dart';
import 'package:friendo/features/first_run/view/first_run_page.dart';

import '../../support/wiring.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory directory;
  late Wiring wiring;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    directory = Directory.systemTemp.createTempSync('friendo_flow');
    wiring = Wiring(directory);
  });

  tearDown(() async {
    await wiring.dispose();
    directory.deleteSync(recursive: true);
  });

  testWidgets('a phone with no Profile starts on the creation screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      FriendoApp(
        creator: wiring.creator,
        session: wiring.session,
        firstScreen: const StartFirstRun(),
      ),
    );

    expect(find.byType(FirstRunPage), findsOneWidget);
  });

  testWidgets('a phone with a Profile starts on the Dial', (tester) async {
    await tester.pumpWidget(
      FriendoApp(creator: wiring.creator, session: wiring.session),
    );

    expect(find.byType(FirstRunPage), findsNothing);
    expect(find.text('Dial'), findsOneWidget);
  });

  testWidgets('the cost screen leads to the Dial', (tester) async {
    await tester.pumpWidget(
      FriendoApp(
        creator: wiring.creator,
        session: wiring.session,
        firstScreen: const StartFirstRun(),
      ),
    );

    final cubit = BlocProvider.of<FirstRunCubit>(
      tester.element(find.byType(FirstRunPage)),
    );
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
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.byType(FirstRunPage), findsNothing);
    expect(find.text('Dial'), findsOneWidget);
  });
}
