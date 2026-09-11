import 'package:flutter/services.dart' show MethodChannel;

/// The channel the app changes its own screen privacy over.
const screenPrivacyChannel = MethodChannel('friendo/screen_privacy');

/// Turns the platform's screen privacy on and off.
///
/// ADR-0011 blocks the task switcher preview and the User's own screenshots
/// together, and accepted that some Users want their own screenshots back. One
/// switch, and it changes `FLAG_SECURE` on Android and the cover on iOS,
/// because a User who allows screenshots on one platform means the same thing
/// on both.
///
/// The PIN screen stays secure whatever this says: the allowance lives in the
/// encrypted database and cannot be read before the unlock it would apply to.
abstract interface class ScreenPrivacy {
  /// Allow or block the User's own screenshots.
  Future<void> allowScreenshots({required bool allowed});
}

/// [ScreenPrivacy] over the platform channel.
class PlatformScreenPrivacy implements ScreenPrivacy {
  /// Talk over [channel].
  const PlatformScreenPrivacy({this.channel = screenPrivacyChannel});

  /// The channel the native side listens on.
  final MethodChannel channel;

  @override
  Future<void> allowScreenshots({required bool allowed}) =>
      channel.invokeMethod<void>('allowScreenshots', allowed);
}
