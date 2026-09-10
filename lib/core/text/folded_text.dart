import 'package:diacritic/diacritic.dart' show removeDiacritics;

/// Fold [written] to the copy a search matches.
///
/// The fold has three steps, in this order: spell the sharp s out, lower the
/// case over all of Unicode, then take the diacritics off an explicit table.
///
/// Step one comes first because the table maps the sharp s to one letter. The
/// other order folds Straße to `strase`, and a User who types `strasse` finds
/// nobody.
///
/// One function serves both sides. The store folds what it writes, and the
/// search folds what the User types. A second fold on one side would match in
/// one direction only. See ADR-0033, which holds the table this returns.
String foldedText(String written) => removeDiacritics(
  written.replaceAll('ß', 'ss').replaceAll('ẞ', 'ss').toLowerCase(),
);
