import 'package:local_auth/local_auth.dart';

/// Confirms a User with the operating system's own prompt.
///
/// ADR-0011 bounds biometric unlock in three sentences, and this keeps all
/// three: the PIN stays available, the prompt names the Profile it unlocks,
/// and each Profile enables it on its own. The flag itself lives in
/// `profiles.json`, because the lock screen reads it before any database is
/// open. See ADR-0036.
abstract interface class BiometricGate {
  /// Whether this phone can ask for a fingerprint at all.
  Future<bool> isAvailable();

  /// Ask the operating system to confirm the User for [profileName].
  ///
  /// Answers false when the User cancels, when no finger is enrolled, or when
  /// the phone cannot ask. The caller falls back to the PIN, which never goes
  /// away.
  Future<bool> confirm({required String profileName});
}

/// [BiometricGate] over `local_auth`.
class PlatformBiometricGate implements BiometricGate {
  /// Ask through [auth].
  const PlatformBiometricGate(this.auth);

  /// The plugin this app asks with.
  final LocalAuthentication auth;

  @override
  Future<bool> isAvailable() async =>
      await auth.isDeviceSupported() && await auth.canCheckBiometrics;

  @override
  Future<bool> confirm({required String profileName}) async {
    try {
      return await auth.authenticate(
        localizedReason: 'Unlock $profileName',
        biometricOnly: true,
      );
    } on Object {
      // A refusal, a cancel and a phone that cannot ask are one answer here:
      // the fingerprint is not available, and the PIN is.
      return false;
    }
  }
}
