import '../core/profiles/profile.dart';
import '../core/profiles/profile_list.dart';

/// The screen the app opens on, decided before anything is unlocked.
sealed class FirstScreen {
  const FirstScreen();
}

/// The phone holds no Profile, so the User makes the first one.
class StartFirstRun extends FirstScreen {
  const StartFirstRun();
}

/// The phone holds one Profile, so the User types six digits for it.
class AskForPin extends FirstScreen {
  const AskForPin(this.profile);

  final Profile profile;
}

/// The phone holds more than one Profile, so the User picks one first.
class PickProfile extends FirstScreen {
  const PickProfile(this.profiles);

  final List<Profile> profiles;
}

/// The Profile list cannot be read, so the app stops and says so.
///
/// It offers no way forward. Starting First Run here would write a new list
/// over Profiles that are still on the phone.
class ListDamaged extends FirstScreen {
  const ListDamaged(this.path, this.reason);

  final String path;

  final String reason;
}

/// Reads the Profile list and decides the first screen.
///
/// It opens no encrypted file and asks the phone for no key, so that the
/// Friends stay encrypted until the User has proved who they are.
Future<FirstScreen> readFirstScreen(ProfileList profiles) async {
  final List<Profile> rows;
  try {
    rows = await profiles.read();
  } on ProfileListDamaged catch (damage) {
    return ListDamaged(damage.path, damage.reason);
  }

  return switch (rows.length) {
    0 => const StartFirstRun(),
    1 => AskForPin(rows.single),
    _ => PickProfile(rows),
  };
}
