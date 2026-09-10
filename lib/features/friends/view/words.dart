import 'package:friendo/features/friends/cadence/cadence_choice.dart'
    show CadencePreview;
import 'package:friendo_domain/friendo_domain.dart' show Orbit, Standing;

/// The glossary's word for each Standing.
///
/// These are the four words CONTEXT.md defines and no others. Drifting is a
/// banned word for Overdue.
String standingWord(Standing standing) => switch (standing) {
  Standing.freshlyReset => 'Freshly Reset',
  Standing.inOrbit => 'In Orbit',
  Standing.nearing => 'Nearing',
  Standing.overdue => 'Overdue',
};

/// The glossary's word for each Orbit.
String orbitWord(Orbit orbit) => switch (orbit) {
  Orbit.inner => 'Inner',
  Orbit.middle => 'Middle',
  Orbit.outer => 'Outer',
};

/// Who an Orbit's preset Cadence is for, in words a User can choose by
/// without knowing what an Orbit is.
String presetWord(Orbit orbit) => switch (orbit) {
  Orbit.inner => 'Often',
  Orbit.middle => 'Regularly',
  Orbit.outer => 'Now and then',
};

/// The label a preset Pill carries: who it is for, and the days it means.
String presetLabel(Orbit orbit) =>
    '${presetWord(orbit)} · ${orbit.cadenceDays.recommended} days';

/// Where the Due Date falls, relative to the day the reading was built on.
///
/// ADR-0032 asks for the consequence in plain words beside each Cadence, and
/// a count of days reads faster than a Civil Date the User has to subtract
/// from today.
String dueWords(CadencePreview preview) => switch (preview.daysUntilDue) {
  0 => 'Due today',
  final int days when days > 0 => 'Due in $days days',
  final int days => 'Due ${-days} days ago',
};

/// The whole of what a preview says: where the Due Date falls, and the
/// Standing it gives.
String previewWords(CadencePreview preview) =>
    '${dueWords(preview)} · ${standingWord(preview.standing)}';
