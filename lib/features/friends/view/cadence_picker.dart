import 'package:flutter/material.dart';
import 'package:friendo/features/friends/cadence/cadence_choice.dart'
    show CadenceChoice, cadencePresets;
import 'package:friendo/features/friends/view/words.dart'
    show presetLabel, previewWords;
import 'package:friendo_domain/friendo_domain.dart' show CivilDate;
import 'package:friendo_ui/friendo_ui.dart' show Pill, SoftWell;

/// The key on the field that takes a Cadence in whole days.
const cadenceDaysFieldKey = ValueKey<String>('cadence-days-field');

/// The key on the line that says what the chosen Cadence gives.
const cadencePreviewKey = ValueKey<String>('cadence-preview');

/// Choose how often a Friend is wanted, and read the result first.
///
/// Three presets and a number of days set one value. ADR-0032 requires the
/// consequence to be readable before the User commits, so the Due Date and the
/// Standing sit under the controls and follow every change.
///
/// Nothing here confirms and nothing here warns. An Overdue preview is a
/// reading and not an error, and a dialog over it would teach the opposite.
class CadencePicker extends StatelessWidget {
  /// Draw the picker over [choice].
  const CadencePicker({
    required this.choice,
    required this.lastMet,
    required this.now,
    required this.onChosen,
    required this.onTyped,
    this.refusal,
    this.typedController,
    super.key,
  });

  /// The Cadence in force.
  final CadenceChoice choice;

  /// The Civil Date the Due Date is counted from.
  final CivilDate lastMet;

  /// The moment every reading on this build is worked out at.
  final DateTime now;

  /// Called with the preset a tap chooses.
  final ValueChanged<CadenceChoice> onChosen;

  /// Called with the text typed into the days field, as it is typed.
  final ValueChanged<String> onTyped;

  /// The sentence to draw when the typed text names no Cadence.
  final String? refusal;

  /// The controller for the days field, when the caller holds the text.
  final TextEditingController? typedController;

  @override
  Widget build(BuildContext context) {
    final preview = choice.previewFrom(lastMet: lastMet, now: now);
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final preset in cadencePresets)
              Pill(
                label: presetLabel(preset.preset),
                isChosen: choice.holds(preset.preset),
                onTap: () => onChosen(preset),
              ),
          ],
        ),
        const SizedBox(height: 12),
        SoftWell(
          child: TextField(
            key: cadenceDaysFieldKey,
            controller: typedController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: InputBorder.none,
              labelText: 'Every how many days',
            ),
            onChanged: onTyped,
          ),
        ),
        if (refusal != null) ...[
          const SizedBox(height: 8),
          Text(refusal!, style: text.bodySmall),
        ],
        const SizedBox(height: 12),
        Text(
          previewWords(preview),
          key: cadencePreviewKey,
          style: text.titleMedium,
        ),
      ],
    );
  }
}
