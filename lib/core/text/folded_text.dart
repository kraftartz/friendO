import 'package:diacritic/diacritic.dart';

/// The Folded Text that search matches, for [written].
///
/// It runs three steps in this order, which ADR-0033 fixes:
///
/// 1. Replace the sharp s with `ss`, so that `Straße` answers `strasse`. The
///    table in step 3 would otherwise give `strase`.
/// 2. Lower case it. This covers the whole of Unicode.
/// 3. Take the diacritics off, from an explicit table. Decomposition alone
///    reaches none of `Ł`, `Đ`, `Ø`, `Æ` or `Þ`, which are single characters.
///
/// The upper case sharp s is replaced beside the lower case one, because step
/// 2 has not run yet when step 1 reads the text.
///
/// Nothing shows Folded Text. It sits beside the text it folds and it is read
/// by a query alone.
String foldedText(String written) => removeDiacritics(
  written.replaceAll('ß', 'ss').replaceAll('ẞ', 'ss').toLowerCase(),
);
