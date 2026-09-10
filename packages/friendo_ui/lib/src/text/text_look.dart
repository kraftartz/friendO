import 'package:flutter/material.dart';

/// The one letter that stands for [text].
///
/// It answers a question mark for text that holds nothing but spaces, so that
/// a caller always has something to draw.
String initialOf(String text) {
  final trimmed = text.trim();

  return trimmed.isEmpty ? '?' : trimmed.characters.first.toUpperCase();
}

/// How many colours there are to go round.
const _hues = 360;

/// How far a colour moves when the one it wanted is taken.
///
/// It shares no factor with [_hues], so stepping by it reaches every colour
/// before it comes back to where it started. It is also a long way round, so
/// the two texts that wanted one colour end up plainly different rather than
/// a degree apart.
const _stepAside = 137;

/// A colour worked out from [text].
///
/// The same text always gives the same colour, and the colour is worked out on
/// every read and stored nowhere. Two different texts may land on the same
/// colour, so a colour decorates and never identifies: it belongs beside a
/// name, and never instead of one.
///
/// Use [coloursFor] where two of them are drawn together and telling one from
/// another is the point.
Color colourOf(String text) => _colourAt(_hueOf(text));

/// A colour for each of [seeds], with no two alike.
///
/// Avoiding a collision needs to know the other seeds, so this is an
/// assignment made against a set rather than a mapping made from one string.
/// No pure function of a single text can do it.
///
/// Each seed asks for the colour [colourOf] would give it, and takes the next
/// free one when that is spoken for. The order the seeds are given in does not
/// change the answer.
///
/// Beyond [_hues] seeds there are not enough colours, and the ones after that
/// keep the colour they asked for. That is a roster many times larger than the
/// app is built for.
Map<String, Color> coloursFor(Iterable<String> seeds) {
  final taken = <int>{};
  final given = <String, Color>{};

  for (final seed in seeds.toSet().toList()..sort()) {
    var hue = _hueOf(seed);

    for (var tries = 0; tries < _hues && taken.contains(hue); tries++) {
      hue = (hue + _stepAside) % _hues;
    }

    taken.add(hue);
    given[seed] = _colourAt(hue);
  }

  return given;
}

Color _colourAt(int hue) =>
    HSLColor.fromAHSL(1, hue.toDouble(), 0.45, 0.65).toColor();

/// The colour [text] asks for, as a hue.
///
/// The letters are folded one at a time into a running value, so that two
/// texts holding the same letters in a different order ask for different
/// colours. Adding the letters up instead gives every anagram one colour, and
/// gives short ids a narrow band of them.
int _hueOf(String text) {
  var folded = 0x811c9dc5;

  for (final unit in text.codeUnits) {
    folded = ((folded ^ unit) * 0x01000193) & 0xFFFFFFFF;
  }

  return folded % _hues;
}
