import 'package:flutter/material.dart';
import 'package:friendo/features/friends/view/words.dart' show noteLabelWord;
import 'package:friendo_domain/friendo_domain.dart' show NoteLabel;
import 'package:friendo_ui/friendo_ui.dart' show Pill, SoftButton, SoftWell;

/// The key on the field that takes the words of a Topic, an Update or a Note.
const noteBodyFieldKey = ValueKey<String>('note-body-field');

/// The key on the control that writes what the field holds.
const writeNoteKey = ValueKey<String>('write-note');

/// One editor for a Topic, an Update and a Note.
///
/// ADR-0017 keeps the three as labels on one record, so there is one field and
/// a choice of label. Changing the label changes how the app groups the
/// record, and nothing else about it.
class NoteEditor extends StatefulWidget {
  /// Draw the editor.
  const NoteEditor({
    required this.onWrite,
    this.startOn = NoteLabel.topic,
    super.key,
  });

  /// Called with the label and the words when the User writes.
  final void Function({required NoteLabel label, required String body}) onWrite;

  /// The label the editor opens on.
  final NoteLabel startOn;

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  final TextEditingController _body = TextEditingController();

  late NoteLabel _label = widget.startOn;

  @override
  void dispose() {
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Wrap(
        spacing: 8,
        children: [
          for (final label in NoteLabel.values)
            Pill(
              label: noteLabelWord(label),
              isChosen: _label == label,
              onTap: () => setState(() => _label = label),
            ),
        ],
      ),
      const SizedBox(height: 8),
      SoftWell(
        child: TextField(
          key: noteBodyFieldKey,
          controller: _body,
          minLines: 1,
          maxLines: 4,
          decoration: const InputDecoration(
            border: InputBorder.none,
            labelText: 'What do you want to remember?',
          ),
        ),
      ),
      const SizedBox(height: 8),
      SoftButton(
        key: writeNoteKey,
        onPressed: _write,
        child: const Text('Write it down'),
      ),
    ],
  );

  void _write() {
    widget.onWrite(label: _label, body: _body.text);
    _body.clear();
  }
}
