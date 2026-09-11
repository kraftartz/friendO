import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_gates.dart';
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

  tearDown(() => directory.deleteSync(recursive: true));

  /// Closes the connection through the tester.
  ///
  /// A real file closed in a plain tearDown makes no progress inside the fake
  /// clock a widget test runs in, and the test hangs rather than failing.
  void closeLater(WidgetTester tester) =>
      addTearDown(() => tester.runAsync(wiring.dispose));

  /// Pumps until [finder] finds something, letting real work run between.
  ///
  /// The app takes its own reading of the Profile list, which is a file, and
  /// a redirect onto the answer is a route transition.
  Future<void> waitFor(WidgetTester tester, Finder finder) async {
    for (var pumps = 0; pumps < 60 && finder.evaluate().isEmpty; pumps++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump(const Duration(milliseconds: 32));
    }
  }

  /// Pumps until [finder] finds nothing, letting real work run between.
  Future<void> waitUntilGone(WidgetTester tester, Finder finder) async {
    for (var pumps = 0; pumps < 60 && finder.evaluate().isNotEmpty; pumps++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump(const Duration(milliseconds: 32));
    }
  }

  testWidgets('a phone with no Profile starts on the creation screen', (
    tester,
  ) async {
    closeLater(tester);
    await tester.pumpWidget(
      FriendoApp(
        edges: fakeEdges(),
        creator: wiring.creator,
        session: wiring.session,
        firstScreen: const StartFirstRun(),
      ),
    );

    expect(find.byType(FirstRunPage), findsOneWidget);
  });

  testWidgets('a phone whose Profile is open starts on the Dial', (
    tester,
  ) async {
    closeLater(tester);
    await tester.runAsync(() async {
      final profile = await wiring.creator.createProfile('Michal', '123456');
      await wiring.session.openProfile(profile.id);
    });

    await tester.pumpWidget(
      FriendoApp(
        edges: fakeEdges(),
        creator: wiring.creator,
        session: wiring.session,
      ),
    );
    await waitFor(tester, find.text('Dial'));

    expect(find.byType(FirstRunPage), findsNothing);
    expect(find.text('Dial'), findsOneWidget);
  });

  testWidgets('the cost screen leads to the Dial', (tester) async {
    closeLater(tester);
    closeLater(tester);
    await tester.pumpWidget(
      FriendoApp(
        edges: fakeEdges(),
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
    await waitFor(tester, find.text('Dial'));
    await waitUntilGone(tester, find.byType(FirstRunPage));

    expect(find.byType(FirstRunPage), findsNothing);
    expect(find.text('Dial'), findsOneWidget);

    // The Dial watches the store from the moment it is drawn, and that watch
    // was made inside this test's own async zone. Lock here rather than in the
    // teardown, so that the query is let go while the zone that owns it still
    // runs.
    await tester.runAsync(wiring.session.lock);
    await tester.pump();
  });
}
