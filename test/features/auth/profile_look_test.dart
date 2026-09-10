import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/features/auth/view/profile_look.dart';

void main() {
  group('the initial', () {
    test('is the first letter of the name, in upper case', () {
      expect(initialOf('michal'), 'M');
    });

    test('leaves out the space around the name', () {
      expect(initialOf('  Ola'), 'O');
    });

    test('stands in for a name that holds nothing', () {
      expect(initialOf('   '), '?');
    });
  });

  group('the colour', () {
    test('is the same one for the same Profile', () {
      expect(colourOf('9f2c'), colourOf('9f2c'));
    });

    test('tells two Profiles apart', () {
      expect(colourOf('9f2c'), isNot(colourOf('4b71')));
    });
  });
}
