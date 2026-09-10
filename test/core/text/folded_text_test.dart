import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/core/text/folded_text.dart' show foldedText;

/// The eight pairs ADR-0033 measured, held here so that a letter which folds
/// wrongly is a red test and not a report from the one User whose name holds
/// it.
const _theRecordsTable = {
  'MICHAŁ': 'michal',
  'Zoë': 'zoe',
  'Đorđe': 'dorde',
  'Straße': 'strasse',
  'Søren': 'soren',
  'Þór': 'thor',
  'Nguyễn': 'nguyen',
  'Ægir': 'aegir',
};

void main() {
  group('the Folded Text', () {
    for (final pair in _theRecordsTable.entries) {
      test('folds ${pair.key} to ${pair.value}', () {
        expect(foldedText(pair.key), pair.value);
      });
    }

    test('spells the sharp s out before it takes the table to it', () {
      expect(foldedText('Straße'), 'strasse');
      expect(foldedText('STRAẞE'), 'strasse');
    });

    test('leaves a Folded Text it is given a second time alone', () {
      for (final written in _theRecordsTable.keys) {
        final once = foldedText(written);

        expect(foldedText(once), once);
      }
    });

    test('changes plain letters in nothing but their case', () {
      expect(foldedText('Quinzelfarb 42'), 'quinzelfarb 42');
      expect(foldedText('anna'), 'anna');
    });

    test('folds text that holds nothing to text that holds nothing', () {
      expect(foldedText(''), '');
    });
  });
}
