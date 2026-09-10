import 'package:flutter_test/flutter_test.dart';
import 'package:friendo_ui/friendo_ui.dart' show colourOf, initialOf;

void main() {
  group('the initial', () {
    test('is the first letter of the text, in upper case', () {
      expect(initialOf('michal'), 'M');
    });

    test('leaves out the space around the text', () {
      expect(initialOf('  Ola'), 'O');
    });

    test('stands in for text that holds nothing', () {
      expect(initialOf('   '), '?');
    });
  });

  group('the colour', () {
    test('is the same one for the same text', () {
      expect(colourOf('9f2c'), colourOf('9f2c'));
    });

    test('tells two pieces of text apart', () {
      expect(colourOf('9f2c'), isNot(colourOf('4b71')));
    });
  });
}
