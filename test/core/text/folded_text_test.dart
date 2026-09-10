import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/core/text/folded_text.dart';

void main() {
  group('the Folded Text', () {
    test('lowers the case of plain letters', () {
      expect(foldedText('Quinzelfarb'), 'quinzelfarb');
    });

    test('takes the stroke off a single character', () {
      expect(foldedText('MICHAŁ'), 'michal');
    });

    test('takes the accent off a letter', () {
      expect(foldedText('Zoë'), 'zoe');
    });

    test('spells the sharp s out', () {
      expect(foldedText('Straße'), 'strasse');
      expect(foldedText('STRAẞE'), 'strasse');
    });

    test('leaves text that needs no folding alone', () {
      expect(foldedText('anna'), 'anna');
    });
  });
}
