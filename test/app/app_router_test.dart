import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/app/boot.dart'
    show AskForPin, ListDamaged, PickProfile, StartFirstRun;
import 'package:friendo/app/navigation/app_router.dart'
    show
        addFriendPath,
        decideLocation,
        dialPath,
        friendsPath,
        isGate,
        openingLocation,
        settingsPath,
        waitingPath;
import 'package:friendo/core/crypto/pin_hash.dart' show KdfParams;
import 'package:friendo/core/profiles/profile.dart' show Profile;

import 'dart:typed_data';

/// The one rule that decides which screen the app is on.
///
/// It is the whole of ADR-0037's argument: a locked Profile takes the User off
/// every screen that draws their Friends, wherever they are and however they
/// got there. Reading it here rather than through a tap means the rule is
/// checked for every screen and not only the ones a test remembers to visit.
void main() {
  Profile aProfile(String id, String name) => Profile(
    id: id,
    displayName: name,
    pinHash: Uint8List(0),
    kdfParams: KdfParams(
      algorithm: 'argon2id',
      version: 19,
      m: 1,
      t: 1,
      p: 1,
      salt: Uint8List(0),
    ),
    failedAttempts: 0,
  );

  final michal = aProfile('michal', 'Michal');
  final kasia = aProfile('kasia', 'Kasia');

  /// Every screen that draws a Friend, or the way to one.
  const behindTheLock = [
    dialPath,
    friendsPath,
    settingsPath,
    addFriendPath,
    '$friendsPath/anna',
  ];

  group('before the first reading', () {
    test('waits on the screen that draws nothing', () {
      for (final path in behindTheLock) {
        expect(
          decideLocation(path: path, firstScreen: null, isOpen: false),
          waitingPath,
        );
      }
    });

    test('waits there even when a Profile is open', () {
      expect(
        decideLocation(path: dialPath, firstScreen: null, isOpen: true),
        waitingPath,
        reason: 'the app draws no Friend until it knows it should',
      );
    });

    test('opens where the reading says, and nowhere else', () {
      expect(openingLocation(null), waitingPath);
      expect(openingLocation(const StartFirstRun()), '/first-run');
      expect(openingLocation(AskForPin(michal)), '/unlock/michal');
      expect(openingLocation(PickProfile([michal, kasia])), '/profiles');
      expect(openingLocation(const ListDamaged('p', 'r')), '/damaged');
    });
  });

  group('while no Profile is open', () {
    test('takes the User off every screen that draws a Friend', () {
      for (final path in behindTheLock) {
        expect(
          decideLocation(
            path: path,
            firstScreen: AskForPin(michal),
            isOpen: false,
          ),
          '/unlock/michal',
          reason: '$path is drawn behind the lock',
        );
      }
    });

    test('sends a phone with no Profile to First Run', () {
      expect(
        decideLocation(
          path: dialPath,
          firstScreen: const StartFirstRun(),
          isOpen: false,
        ),
        '/first-run',
      );
    });

    test('sends a phone with two Profiles to the picker', () {
      expect(
        decideLocation(
          path: dialPath,
          firstScreen: PickProfile([michal, kasia]),
          isOpen: false,
        ),
        '/profiles',
      );
    });

    test('leaves the User on a screen in front of the lock', () {
      for (final gate in ['/first-run', '/profiles', '/unlock/michal']) {
        expect(
          decideLocation(
            path: gate,
            firstScreen: AskForPin(michal),
            isOpen: false,
          ),
          isNull,
          reason: '$gate stands in front of the lock',
        );
      }
    });

    test('sends the User to the keypad for the Profile they asked for', () {
      expect(
        decideLocation(
          path: dialPath,
          firstScreen: PickProfile([michal, kasia]),
          isOpen: false,
          wantedProfileId: kasia.id,
        ),
        '/unlock/kasia',
        reason: 'switching Profile is a lock and then an unlock',
      );
    });
  });

  group('once a Profile is open', () {
    test('takes the User off every screen in front of the lock', () {
      for (final gate in [
        '/first-run',
        '/profiles',
        '/unlock/michal',
        waitingPath,
      ]) {
        expect(
          decideLocation(
            path: gate,
            firstScreen: AskForPin(michal),
            isOpen: true,
          ),
          dialPath,
        );
      }
    });

    test('leaves the User where they are', () {
      for (final path in behindTheLock) {
        expect(
          decideLocation(
            path: path,
            firstScreen: AskForPin(michal),
            isOpen: true,
          ),
          isNull,
        );
      }
    });
  });

  group('a Profile list that cannot be read', () {
    test('stops the app, whatever else is true', () {
      for (final open in [true, false]) {
        expect(
          decideLocation(
            path: dialPath,
            firstScreen: const ListDamaged('p', 'r'),
            isOpen: open,
          ),
          '/damaged',
        );
      }
    });
  });

  group('which screens stand in front of the lock', () {
    test('names the four, and no screen that draws a Friend', () {
      expect(isGate('/first-run'), isTrue);
      expect(isGate('/profiles'), isTrue);
      expect(isGate('/unlock/michal'), isTrue);
      expect(isGate('/damaged'), isTrue);

      for (final path in behindTheLock) {
        expect(isGate(path), isFalse, reason: '$path draws a Friend');
      }
    });
  });
}
