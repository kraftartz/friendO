import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/app/app.dart';
import 'package:friendo/core/db/database_session.dart';
import 'package:friendo/core/profiles/data_key_store.dart';
import 'package:friendo/core/profiles/profile_creator.dart';
import 'package:friendo/core/profiles/profile_list.dart';
import 'package:friendo/features/first_run/bloc/first_run_cubit.dart';
import 'package:friendo/features/first_run/bloc/first_run_state.dart';
import 'package:friendo/features/first_run/view/first_run_page.dart';
import 'package:hashlib/hashlib.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory directory;
  late DatabaseSession databases;
  late ProfileCreator creator;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    directory = Directory.systemTemp.createTempSync('friendo_flow');
    databases = DatabaseSession(directory);
    creator = ProfileCreator(
      profiles: ProfileList(directory),
      databases: databases,
      dataKeys: const DataKeyStore(),
      security: Argon2Security.test,
    );
  });

  tearDown(() async {
    await databases.close();
    directory.deleteSync(recursive: true);
  });

  testWidgets('a phone with no Profile starts on the creation screen', (
    tester,
  ) async {
    await tester.pumpWidget(FriendoApp(firstRun: creator));

    expect(find.byType(FirstRunPage), findsOneWidget);
  });

  testWidgets('a phone with a Profile starts on the Dial', (tester) async {
    await tester.pumpWidget(const FriendoApp());

    expect(find.byType(FirstRunPage), findsNothing);
    expect(find.text('Dial'), findsOneWidget);
  });

  testWidgets('the cost screen leads to the Dial', (tester) async {
    await tester.pumpWidget(FriendoApp(firstRun: creator));

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
