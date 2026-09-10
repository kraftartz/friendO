import 'package:flutter_test/flutter_test.dart';
import 'package:friendo_ui/friendo_ui.dart'
    show colourOf, coloursFor, initialOf;

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

  group('coloursFor', () {
    test('gives no two seeds the same colour', () {
      final seeds = [for (var index = 0; index < 100; index++) 'friend-$index'];

      final given = coloursFor(seeds);

      expect(given, hasLength(seeds.length));
      expect(given.values.toSet(), hasLength(seeds.length));
    });

    test('separates two seeds that ask for one colour', () {
      // Two texts holding the same letters asked for one colour under the fold
      // that added them up. They must not now.
      expect(colourOf('ab'), isNot(colourOf('ba')));

      final given = coloursFor(['ab', 'ba']);
      expect(given['ab'], isNot(given['ba']));
    });

    test('answers the same however the seeds arrive', () {
      final seeds = [for (var index = 0; index < 40; index++) 'friend-$index'];

      expect(coloursFor(seeds), coloursFor(seeds.reversed));
    });

    test('holds the rule as a seed arrives and as one goes', () {
      final seeds = [for (var index = 0; index < 30; index++) 'friend-$index'];

      final more = coloursFor([...seeds, 'ola']);
      expect(more.values.toSet(), hasLength(31));

      final fewer = coloursFor(seeds.skip(1));
      expect(fewer.values.toSet(), hasLength(29));
    });

    test('gives a lone seed the colour it asked for', () {
      expect(coloursFor(['ola'])['ola'], colourOf('ola'));
    });

    test('gives nothing for no seeds', () {
      expect(coloursFor([]), isEmpty);
    });
  });
}
