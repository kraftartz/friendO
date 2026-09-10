import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/core/db/database_session.dart';
import 'package:friendo/core/profiles/data_key_store.dart';
import 'package:friendo/core/profiles/profile_creator.dart';
import 'package:friendo/core/profiles/profile_list.dart';
import 'package:friendo/core/profiles/profile_session.dart';
import 'package:friendo/features/first_run/bloc/first_run_cubit.dart';
import 'package:friendo/features/first_run/bloc/first_run_state.dart';
import 'package:hashlib/hashlib.dart';

import '../../support/uncreatable_database.dart';

void _type(FirstRunCubit cubit, String digits) {
  for (final digit in digits.split('')) {
    cubit.pressDigit(int.parse(digit));
  }
}

/// Waits for the Profile to be made, or for the failure that stops it.
///
/// The wait is on the state and not on a clock, because the cost of one PIN
/// hash and one file is whatever the machine running the test makes it.
Future<void> _settle(FirstRunCubit cubit) => cubit.stream
    .firstWhere((state) => state.step != FirstRunStep.working)
    .timeout(const Duration(seconds: 30));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory directory;
  late ProfileList profiles;
  late DatabaseSession databases;
  late ProfileCreator creator;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    directory = Directory.systemTemp.createTempSync('friendo_first_run');
    profiles = ProfileList(directory);
    databases = DatabaseSession(directory);
    creator = ProfileCreator(
      profiles: profiles,
      databases: databases,
      dataKeys: const DataKeyStore(),
      security: Argon2Security.test,
    );
  });

  tearDown(() async {
    await databases.close();
    directory.deleteSync(recursive: true);
  });

  FirstRunCubit build() => FirstRunCubit(
    creator,
    ProfileSession(
      profiles: profiles,
      databases: databases,
      dataKeys: const DataKeyStore(),
    ),
  );

  FirstRunCubit named([String name = 'Michal']) => build()..submitName(name);

  group('the name', () {
    test('starts the PIN when it holds a character', () {
      expect(named().state.step, FirstRunStep.pin);
    });

    test('is refused when it holds nothing but spaces', () {
      final cubit = named('   ');

      expect(cubit.state.step, FirstRunStep.name);
      expect(cubit.state.message, isNotNull);
    });

    test('is kept as it was typed until the Profile is made', () {
      expect(named('  Michal  ').state.name, '  Michal  ');
    });
  });

  group('the PIN typed first', () {
    test('waits at five digits', () {
      final cubit = named();

      _type(cubit, '12345');

      expect(cubit.state.step, FirstRunStep.pin);
      expect(cubit.state.pin, '12345');
    });

    test('asks for the PIN again on the sixth digit', () {
      final cubit = named();

      _type(cubit, '123456');

      expect(cubit.state.step, FirstRunStep.confirm);
    });

    test('takes no seventh digit', () {
      final cubit = named();

      _type(cubit, '1234567');

      expect(cubit.state.confirmation, '7');
    });

    test('drops the last digit typed', () {
      final cubit = named();

      _type(cubit, '123');
      cubit.deleteDigit();

      expect(cubit.state.pin, '12');
    });

    test('drops nothing when nothing is typed', () {
      final cubit = named();

      cubit.deleteDigit();

      expect(cubit.state.pin, isEmpty);
    });
  });

  group('the PIN typed again', () {
    test('starts over when the two differ', () async {
      final cubit = named();

      _type(cubit, '123456');
      _type(cubit, '123457');

      expect(cubit.state.step, FirstRunStep.pin);
      expect(cubit.state.pin, isEmpty);
      expect(cubit.state.confirmation, isEmpty);
      expect(cubit.state.message, isNotNull);
    });

    test('states the cost when the two match', () async {
      final cubit = named();

      _type(cubit, '123456');
      _type(cubit, '123456');
      await _settle(cubit);

      expect(cubit.state.step, FirstRunStep.cost);
    });

    test('makes the Profile before the cost screen appears', () async {
      final cubit = named();

      _type(cubit, '123456');
      _type(cubit, '123456');
      await _settle(cubit);

      expect((await profiles.read()).single.displayName, 'Michal');
    });

    test('keeps the PIN no longer than the call it feeds', () async {
      final cubit = named();

      _type(cubit, '123456');
      _type(cubit, '123456');
      await _settle(cubit);

      expect(cubit.state.pin, isEmpty);
      expect(cubit.state.confirmation, isEmpty);
    });
  });

  group('a failure while the Profile is made', () {
    late FirstRunCubit cubit;

    setUp(() {
      cubit = FirstRunCubit(
        ProfileCreator(
          profiles: profiles,
          databases: UncreatableDatabase(directory),
          dataKeys: const DataKeyStore(),
          security: Argon2Security.test,
        ),
        ProfileSession(
          profiles: profiles,
          databases: databases,
          dataKeys: const DataKeyStore(),
        ),
      )..submitName('Michal');
    });

    test('stays on the creation screen, and says so', () async {
      _type(cubit, '123456');
      _type(cubit, '123456');
      await _settle(cubit);

      expect(cubit.state.step, FirstRunStep.pin);
      expect(cubit.state.message, isNotNull);
      expect(cubit.state.name, 'Michal');
    });
  });

  group('the cost screen', () {
    blocTest<FirstRunCubit, FirstRunState>(
      'is the last thing before the app',
      build: build,
      seed: () => const FirstRunState(step: FirstRunStep.cost),
      act: (cubit) => cubit.continueToApp(),
      expect: () => [const FirstRunState(step: FirstRunStep.done)],
    );
  });
}
