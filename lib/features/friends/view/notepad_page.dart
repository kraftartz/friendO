import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocBuilder, ReadContext;
import 'package:friendo/features/friends/bloc/notepad_cubit.dart'
    show NotepadCubit;
import 'package:friendo/features/friends/bloc/notepad_state.dart'
    show NotepadReading;
import 'package:friendo/features/friends/view/cadence_picker.dart'
    show CadencePicker;
import 'package:friendo/features/friends/view/phase_ring.dart' show PhaseRing;
import 'package:friendo/features/friends/view/words.dart'
    show noteGroupWord, noteLabelWord, orbitWord, standingWord;
import 'package:friendo_domain/friendo_domain.dart'
    show CivilDate, Meeting, Note, NoteLabel;
import 'package:friendo_ui/friendo_ui.dart'
    show AvatarHalo, Pill, SoftButton, SoftCard, SoftWell, colourOf, initialOf;

/// The key on the control that logs a Meeting dated today.
const logMeetingKey = ValueKey<String>('log-meeting');

/// The key on the control that writes the tuner's Cadence.
const saveCadenceKey = ValueKey<String>('save-cadence');

/// The key on the control that deletes the Friend.
const deleteFriendKey = ValueKey<String>('delete-friend');

/// One Friend, top to bottom.
///
/// Who they are and where they stand, the writing waiting for the next
/// Meeting, the history newest first, the Facts and Milestones, and the
/// Cadence tuner.
///
/// A locked screen draws nothing. A Friend with nothing written about them
/// draws a calm page, which is a different thing.
class NotepadPage extends StatelessWidget {
  /// Draw the Notepad.
  const NotepadPage({this.onGone, super.key});

  /// Called once the Friend has been deleted.
  final VoidCallback? onGone;

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<NotepadCubit, NotepadReading>(
        builder: (context, reading) => Scaffold(
          appBar: AppBar(title: Text(reading.name)),
          body: reading.friend == null
              ? Center(child: Text(reading.refusal ?? ''))
              : _NotepadBody(reading: reading, onGone: onGone),
        ),
      );
}

class _NotepadBody extends StatelessWidget {
  const _NotepadBody({required this.reading, this.onGone});

  final NotepadReading reading;

  final VoidCallback? onGone;

  @override
  Widget build(BuildContext context) {
    final notepad = context.read<NotepadCubit>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _header(context),
        const SizedBox(height: 16),
        _writing(context, notepad),
        const SizedBox(height: 16),
        _history(context, notepad),
        const SizedBox(height: 16),
        _standingFacts(context),
        const SizedBox(height: 16),
        _tuner(context, notepad),
        const SizedBox(height: 16),
        SoftButton(
          key: deleteFriendKey,
          onPressed: () => _confirmDelete(context, notepad),
          child: const Text('Delete this Friend'),
        ),
      ],
    );
  }

  Widget _header(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colour = colourOf(reading.avatarSeed);

    return SoftCard(
      child: Row(
        children: [
          PhaseRing(
            fraction: reading.placing!.phase.value,
            colour: colour,
            child: AvatarHalo(label: initialOf(reading.name), colour: colour),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reading.name, style: text.titleLarge),
                Text(
                  '${orbitWord(reading.orbit!)} Orbit · every '
                  '${reading.cadence!.days} days',
                  style: text.bodyMedium,
                ),
                Text(standingWord(reading.standing!), style: text.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _writing(BuildContext context, NotepadCubit notepad) => SoftCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          children: [
            for (final label in NoteLabel.values)
              Pill(
                label: noteLabelWord(label),
                isChosen: reading.draftLabel == label,
                onTap: () => notepad.chooseNoteLabel(label),
              ),
          ],
        ),
        const SizedBox(height: 8),
        _NoteComposer(
          draft: reading.draftNote,
          onTyped: notepad.typeNote,
          onWrite: notepad.writeNote,
        ),
        for (final label in NoteLabel.values)
          ..._group(context, notepad, label),
      ],
    ),
  );

  List<Widget> _group(
    BuildContext context,
    NotepadCubit notepad,
    NoteLabel label,
  ) {
    final held = reading.notesLabelled(label);
    if (held.isEmpty) return const [];

    return [
      const SizedBox(height: 16),
      Text(
        noteGroupWord(label),
        style: Theme.of(context).textTheme.titleMedium,
      ),
      for (final note in held) _noteRow(context, notepad, note),
    ];
  }

  Widget _noteRow(BuildContext context, NotepadCubit notepad, Note note) =>
      ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(note.body),
        subtitle: Text(note.writtenOn.toString()),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PopupMenuButton<NoteLabel>(
              icon: const Icon(Icons.label_outline),
              onSelected: (label) => notepad.relabelNote(note.id, label),
              itemBuilder: (_) => [
                for (final label in NoteLabel.values)
                  PopupMenuItem<NoteLabel>(
                    value: label,
                    child: Text(noteLabelWord(label)),
                  ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => notepad.dropNote(note.id),
            ),
          ],
        ),
      );

  Widget _history(BuildContext context, NotepadCubit notepad) => SoftCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Meetings', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SoftButton(
          key: logMeetingKey,
          onPressed: notepad.logMeeting,
          child: const Text('We met today'),
        ),
        for (final meeting in reading.meetings)
          _meetingRow(context, notepad, meeting),
      ],
    ),
  );

  Widget _meetingRow(
    BuildContext context,
    NotepadCubit notepad,
    Meeting meeting,
  ) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(_meetingWords(meeting)),
    subtitle: meeting.recap == null ? null : Text(meeting.recap!),
    trailing: reading.canDropMeeting
        ? IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => notepad.dropMeeting(meeting.id),
          )
        : const Tooltip(
            message: 'A Friend keeps their last Meeting.',
            child: Icon(Icons.delete_outline, size: 20),
          ),
  );

  String _meetingWords(Meeting meeting) {
    final place = meeting.place;

    return place == null
        ? meeting.happenedOn.toString()
        : '${meeting.happenedOn} · $place';
  }

  Widget _standingFacts(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About them', style: text.titleMedium),
          for (final fact in reading.facts)
            Text('${fact.label}: ${fact.value}', style: text.bodyMedium),
          for (final milestone in reading.milestones)
            Text(
              '${milestone.label} · ${_milestoneWords(milestone.onDate)}',
              style: text.bodyMedium,
            ),
          if (reading.affinities.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final affinity in reading.affinities)
                  Pill(label: affinity.label),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _milestoneWords(CivilDate onDate) {
    final away = reading.daysUntil(onDate);

    return away < 0 ? '$onDate' : '$onDate, in $away days';
  }

  Widget _tuner(BuildContext context, NotepadCubit notepad) => SoftCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How often do you want to see them?',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        CadencePicker(
          choice: reading.tuner!,
          lastMet: reading.friend!.lastMet,
          now: reading.now!,
          onChosen: notepad.moveTuner,
          onTyped: notepad.typeCadence,
          refusal: reading.refusal,
        ),
        const SizedBox(height: 12),
        SoftButton(
          key: saveCadenceKey,
          onPressed: reading.tunerHasMoved ? notepad.saveCadence : null,
          child: const Text('Save this Cadence'),
        ),
      ],
    ),
  );

  Future<void> _confirmDelete(
    BuildContext context,
    NotepadCubit notepad,
  ) async {
    final going = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${reading.name}?'),
        content: const Text(
          'Their Meetings, Topics, Updates, Notes, Facts and Milestones go '
          'with them. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep them'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (!(going ?? false)) return;

    await notepad.deleteFriend();
    onGone?.call();
  }
}

/// The field the User types a Topic, an Update or a Note into.
///
/// The words live in the state, and this holds the cursor. It follows the
/// state only when the state is empty, because a state carries the text it was
/// built from and that text is one keystroke behind a fast typist.
class _NoteComposer extends StatefulWidget {
  const _NoteComposer({
    required this.draft,
    required this.onTyped,
    required this.onWrite,
  });

  final String draft;

  final ValueChanged<String> onTyped;

  final VoidCallback onWrite;

  @override
  State<_NoteComposer> createState() => _NoteComposerState();
}

class _NoteComposerState extends State<_NoteComposer> {
  late final TextEditingController _typed = TextEditingController(
    text: widget.draft,
  );

  @override
  void didUpdateWidget(_NoteComposer old) {
    super.didUpdateWidget(old);
    if (widget.draft.isEmpty && _typed.text.isNotEmpty) _typed.clear();
  }

  @override
  void dispose() {
    _typed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SoftWell(
        child: TextField(
          controller: _typed,
          minLines: 1,
          maxLines: 4,
          decoration: const InputDecoration(
            border: InputBorder.none,
            labelText: 'What do you want to remember?',
          ),
          onChanged: widget.onTyped,
        ),
      ),
      const SizedBox(height: 8),
      SoftButton(onPressed: widget.onWrite, child: const Text('Write it down')),
    ],
  );
}
