import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/core/db/database_session.dart';
import 'package:friendo/core/profiles/data_key_store.dart';
import 'package:friendo/core/profiles/profile.dart';
import 'package:friendo/core/profiles/profile_creator.dart';
import 'package:friendo/core/profiles/profile_list.dart';
import 'package:friendo/core/profiles/profile_session.dart';
import 'package:friendo/features/auth/bloc/unlock_cubit.dart';
import 'package:friendo/features/auth/bloc/unlock_state.dart';
import 'package:hashlib/hashlib.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory directory;
  late DatabaseSession databases;
  late ProfileSession session;
  late Profile profile;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    directory = Directory.systemTemp.createTempSync('friendo_unlock');
    databases = DatabaseSession(directory);
    final profiles = ProfileList(directory);
    session = ProfileSession(
      profiles: profiles,
      databases: databases,
      dataKeys: const DataKeyStore(),
    );
    profile = await ProfileCreator(
      profiles: profiles,
      databases: databases,
      dataKeys: const DataKeyStore(),
      security: Argon2Security.test,
    ).createProfile('Michal', '123456');
  });

  tearDown(() async {
    await databases.close();
    directory.deleteSync(recursive: true);
  });

  Future<UnlockCubit> keypad() async {
    final cubit = UnlockCubit(session: session, profile: profile);
    await pumpEventQueue();

    return cubit;
  }

  Future<void> type(UnlockCubit cubit, String digits) async {
    for (final digit in digits.split('')) {
      cubit.pressDigit(int.parse(digit));
    }
    if (cubit.state.step == UnlockStep.working) {
      await cubit.stream.firstWhere(
        (state) => state.step != UnlockStep.working,
      );
    }
    await pumpEventQueue();
  }

  test('takes one digit at a time', () async {
    final cubit = await keypad();

    await type(cubit, '12');

    expect(cubit.state.typed, '12');
    await cubit.close();
  });

  test('drops the last digit that was typed', () async {
    final cubit = await keypad();
    await type(cubit, '12');

    cubit.deleteDigit();

    expect(cubit.state.typed, '1');
    await cubit.close();
  });

  test('does not submit on the fifth digit', () async {
    final cubit = await keypad();

    await type(cubit, '12345');

    expect(cubit.state.step, UnlockStep.typing);
    expect(await databases.state.first, DatabaseState.locked);
    await cubit.close();
  });

  test('submits on the sixth digit', () async {
    final cubit = await keypad();

    await type(cubit, '123456');

    expect(cubit.state.step, UnlockStep.open);
    expect(await databases.state.first, DatabaseState.open);
    await cubit.close();
  });

  test('says the PIN is wrong, and takes the digits away', () async {
    final cubit = await keypad();

    await type(cubit, '000000');

    expect(cubit.state.step, UnlockStep.typing);
    expect(cubit.state.typed, isEmpty);
    expect(cubit.state.message, isNotNull);
    await cubit.close();
  });

  test('says a Profile that cannot be opened is not a wrong PIN', () async {
    await const FlutterSecureStorage().delete(key: dataKeyNameOf(profile.id));
    final cubit = await keypad();

    await type(cubit, '123456');

    expect(cubit.state.step, UnlockStep.failed);
    expect(cubit.state.message, contains('cannot be opened'));
    await cubit.close();
  });

  group('while it rests', () {
    Future<UnlockCubit> restingKeypad() async {
      for (var attempt = 0; attempt < 5; attempt++) {
        session.arriveAtKeypad();
        await session.unlock(profile.id, '000000');
      }

      return keypad();
    }

    test('reports what is left of the rest', () async {
      final cubit = await restingKeypad();

      expect(cubit.state.step, UnlockStep.resting);
      expect(cubit.state.rest, greaterThan(const Duration(seconds: 28)));
      await cubit.close();
    });

    test('refuses a digit', () async {
      final cubit = await restingKeypad();

      await type(cubit, '123456');

      expect(cubit.state.typed, isEmpty);
      expect(cubit.state.step, UnlockStep.resting);
      expect(await databases.state.first, DatabaseState.locked);
      await cubit.close();
    });
  });
}
