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
