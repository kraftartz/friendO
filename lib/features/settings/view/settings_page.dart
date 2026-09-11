import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocBuilder, ReadContext;
import 'package:friendo/core/profiles/profile.dart' show Profile;
import 'package:friendo/core/settings/profile_settings.dart'
    show autoLockChoices;
import 'package:friendo/features/settings/bloc/settings_cubit.dart'
    show SettingsCubit;
import 'package:friendo/features/settings/bloc/settings_state.dart'
    show
        SettingsReading,
        forgottenPinWords,
        nothingLeavesWords,
        permissionRefusedWords,
        screenshotCostWords;
import 'package:friendo_ui/friendo_ui.dart' show SoftButton, SoftCard, SoftWell;

/// The key on the reminder switch.
const remindersSwitchKey = ValueKey<String>('reminders-switch');

/// The key on the screenshot allowance switch.
const screenshotsSwitchKey = ValueKey<String>('screenshots-switch');

/// The key on the biometric unlock switch.
const biometricSwitchKey = ValueKey<String>('biometric-switch');

/// The key on the control that locks the app now.
const lockNowKey = ValueKey<String>('lock-now');

/// The Profile's own options, in three groups.
///
/// Nothing here touches a Friend. The screen writes settings and calls two
/// methods that already exist; it owns no mechanism of its own.
class SettingsPage extends StatelessWidget {
  /// Draw the screen.
  const SettingsPage({this.onSwitchProfile, super.key});

  /// Called with the Profile the User wants to switch to.
  ///
  /// Switching needs that Profile's PIN, which this screen does not ask for.
  /// The keypad is the one place a PIN is typed.
  final void Function(Profile profile)? onSwitchProfile;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<SettingsCubit, SettingsReading>(
        builder: (context, reading) => reading.isLocked
            ? const SizedBox.shrink()
            : _SettingsBody(reading: reading, onSwitchProfile: onSwitchProfile),
      );
}

class _SettingsBody extends StatelessWidget {
  const _SettingsBody({required this.reading, this.onSwitchProfile});

  final SettingsReading reading;

  final void Function(Profile profile)? onSwitchProfile;

  @override
  Widget build(BuildContext context) {
    final settings = context.read<SettingsCubit>();
    final text = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Reminders', style: text.titleMedium),
              SwitchListTile(
                key: remindersSwitchKey,
                contentPadding: EdgeInsets.zero,
                title: const Text('Remind me when a Friend is due'),
                subtitle: const Text(
                  'A reminder names the Friend and says nothing else.',
                ),
                value: reading.remindersOn,
                onChanged: (on) => settings.turnRemindersOn(on: on),
              ),
              if (reading.permissionRefused)
                Text(permissionRefusedWords, style: text.bodySmall),
              if (reading.remindersOn) ...[
                const SizedBox(height: 8),
                Text('At what time of day?', style: text.bodyMedium),
                _hours(settings),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Privacy', style: text.titleMedium),
              const SizedBox(height: 8),
              Text('Lock this Profile after', style: text.bodyMedium),
              _waits(settings),
              const SizedBox(height: 8),
              SoftButton(
                key: lockNowKey,
                onPressed: settings.lockNow,
                child: const Text('Lock now'),
              ),
              SwitchListTile(
                key: biometricSwitchKey,
                contentPadding: EdgeInsets.zero,
                title: const Text('Unlock with a fingerprint'),
                subtitle: const Text('The PIN keeps working.'),
                value: reading.usesBiometricUnlock,
                onChanged: reading.biometricAvailable
                    ? (uses) => settings.useBiometricUnlock(uses: uses)
                    : null,
              ),
              SwitchListTile(
                key: screenshotsSwitchKey,
                contentPadding: EdgeInsets.zero,
                title: const Text('Allow my own screenshots'),
                subtitle: const Text(screenshotCostWords),
                value: reading.screenshotsAllowed,
                onChanged: (allowed) =>
                    settings.allowScreenshots(allowed: allowed),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('This Profile', style: text.titleMedium),
              const SizedBox(height: 8),
              _NameField(name: reading.profileName, onRenamed: settings.rename),
              for (final profile in reading.otherProfiles)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Switch to ${profile.displayName}'),
                  onTap: () => onSwitchProfile?.call(profile),
                ),
              const SizedBox(height: 8),
              Text(forgottenPinWords, style: text.bodySmall),
              Text(nothingLeavesWords, style: text.bodySmall),
            ],
          ),
        ),
      ],
    );
  }

  Widget _hours(SettingsCubit settings) => DropdownButton<int>(
    value: reading.reminderHour,
    onChanged: (hour) =>
        hour == null ? null : settings.chooseReminderHour(hour),
    items: [
      for (var hour = 0; hour < 24; hour++)
        DropdownMenuItem<int>(
          value: hour,
          child: Text('${hour.toString().padLeft(2, '0')}:00'),
        ),
    ],
  );

  Widget _waits(SettingsCubit settings) => DropdownButton<Duration>(
    value: autoLockChoices.contains(reading.autoLock)
        ? reading.autoLock
        : autoLockChoices.first,
    onChanged: (wait) => wait == null ? null : settings.chooseAutoLock(wait),
    items: [
      for (final wait in autoLockChoices)
        DropdownMenuItem<Duration>(value: wait, child: Text(_waitWords(wait))),
    ],
  );

  String _waitWords(Duration wait) => wait.inMinutes < 1
      ? '${wait.inSeconds} seconds'
      : '${wait.inMinutes} minutes';
}

class _NameField extends StatefulWidget {
  const _NameField({required this.name, required this.onRenamed});

  final String name;

  final ValueChanged<String> onRenamed;

  @override
  State<_NameField> createState() => _NameFieldState();
}

class _NameFieldState extends State<_NameField> {
  late final TextEditingController _typed = TextEditingController(
    text: widget.name,
  );

  @override
  void dispose() {
    _typed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SoftWell(
    child: TextField(
      controller: _typed,
      decoration: const InputDecoration(
        border: InputBorder.none,
        labelText: 'The name on the lock screen',
      ),
      onSubmitted: widget.onRenamed,
    ),
  );
}
