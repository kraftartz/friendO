import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocBuilder, ReadContext;
import 'package:friendo/features/friends/bloc/add_friend_cubit.dart'
    show AddFriendCubit;
import 'package:friendo/features/friends/bloc/add_friend_state.dart'
    show AddFriendDraft;
import 'package:friendo/features/friends/view/cadence_picker.dart'
    show CadencePicker;
import 'package:friendo/features/friends/view/note_editor.dart' show NoteEditor;
import 'package:friendo_domain/friendo_domain.dart' show CivilDate;
import 'package:friendo_ui/friendo_ui.dart'
    show AvatarHalo, Pill, SoftButton, SoftCard, SoftWell, colourOf, initialOf;

/// The key on the control that writes the Friend.
const saveFriendKey = ValueKey<String>('save-friend');

/// The words that say the last-seen field records a Meeting.
///
/// ADR-0016 asked for this wording by name. A User who accepts a default
/// without reading it records a Meeting that did not happen, so the field says
/// what saving does.
const lastSeenWords = 'Saving records a Meeting on this day.';

/// Add a Friend: one form in four parts, of which three are needed.
///
/// Nothing on this screen is written until the save. Leaving it with anything
/// typed asks first, and a lock clears it without asking.
class AddFriendPage extends StatelessWidget {
  /// Draw the form.
  const AddFriendPage({this.onDone, super.key});

  /// Called once the Friend is written, and once an abandon is confirmed.
  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<AddFriendCubit, AddFriendDraft>(
        builder: (context, draft) => Scaffold(
          appBar: AppBar(
            title: const Text('Add a Friend'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => _leave(context, draft),
            ),
          ),
          body: draft.isLocked
              ? const SizedBox.shrink()
              : _AddFriendForm(draft: draft, onDone: onDone),
        ),
      );

  Future<void> _leave(BuildContext context, AddFriendDraft draft) async {
    if (!draft.hasTyping) {
      onDone?.call();

      return;
    }

    final leaving = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave without saving?'),
        content: const Text('What you have written here is not kept.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep writing'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (leaving ?? false) onDone?.call();
  }
}

class _AddFriendForm extends StatefulWidget {
  const _AddFriendForm({required this.draft, this.onDone});

  final AddFriendDraft draft;

  final VoidCallback? onDone;

  @override
  State<_AddFriendForm> createState() => _AddFriendFormState();
}

class _AddFriendFormState extends State<_AddFriendForm> {
  final TextEditingController _cadenceDays = TextEditingController();

  final TextEditingController _affinity = TextEditingController();

  @override
  void dispose() {
    _cadenceDays.dispose();
    _affinity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    final form = context.read<AddFriendCubit>();
    final text = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SoftCard(
          child: Row(
            children: [
              AvatarHalo(
                label: initialOf(draft.name),
                colour: colourOf(draft.friendId!),
                size: 56,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SoftWell(
                  child: TextField(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      labelText: 'Their name',
                    ),
                    onChanged: form.typeName,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('When did you last see them?', style: text.titleMedium),
              const SizedBox(height: 4),
              Text(lastSeenWords, style: text.bodySmall),
              const SizedBox(height: 12),
              SoftButton(
                onPressed: () => _pickLastMet(context, form, draft),
                child: Text(draft.lastMet!.toString()),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How often do you want to see them?',
                style: text.titleMedium,
              ),
              const SizedBox(height: 12),
              CadencePicker(
                choice: draft.choice!,
                lastMet: draft.lastMet!,
                now: draft.now!,
                typedController: _cadenceDays,
                refusal: draft.cadenceRefusal,
                onChosen: form.chooseCadence,
                onTyped: form.typeCadence,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Anything you already know', style: text.titleMedium),
              const SizedBox(height: 4),
              Text('All of this is optional.', style: text.bodySmall),
              const SizedBox(height: 12),
              NoteEditor(onWrite: form.writeNote),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final affinity in draft.knownAffinities)
                    Pill(
                      label: affinity.label,
                      isChosen: draft.affinities.any(
                        (chosen) => chosen.id == affinity.id,
                      ),
                      onTap: () => form.chooseAffinity(affinity.label),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              SoftWell(
                child: TextField(
                  controller: _affinity,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    labelText: 'Add an Affinity',
                  ),
                  onSubmitted: (label) {
                    form.chooseAffinity(label);
                    _affinity.clear();
                  },
                ),
              ),
            ],
          ),
        ),
        if (draft.refusal != null) ...[
          const SizedBox(height: 16),
          Text(draft.refusal!, style: text.bodyMedium),
        ],
        const SizedBox(height: 24),
        SoftButton(
          key: saveFriendKey,
          onPressed: () => _save(form),
          child: const Text('Save this Friend'),
        ),
      ],
    );
  }

  Future<void> _save(AddFriendCubit form) async {
    await form.save();
    if (!mounted) return;
    if (form.state.isSaved) widget.onDone?.call();
  }

  Future<void> _pickLastMet(
    BuildContext context,
    AddFriendCubit form,
    AddFriendDraft draft,
  ) async {
    final today = CivilDate.from(draft.now!);
    final picked = await showDatePicker(
      context: context,
      initialDate: draft.lastMet!.startOfDayLocal(),
      firstDate: DateTime(today.year - 50),
      lastDate: today.startOfDayLocal(),
    );
    if (picked == null) return;

    form.chooseLastMet(CivilDate.from(picked));
  }
}
