import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendo_ui/friendo_ui.dart' show Soft, SoftCard;

/// Build a SoftCard under a theme carrying [soft], or under no tokens at all.
Widget _app({Soft? soft}) => MaterialApp(
  theme: ThemeData(extensions: soft == null ? const [] : [soft]),
  home: const SoftCard(child: Text('hello')),
);

/// Read the decoration that the card actually painted.
BoxDecoration _decorationOf(WidgetTester tester) =>
    tester
            .widget<DecoratedBox>(
              find.descendant(
                of: find.byType(SoftCard),
                matching: find.byType(DecoratedBox),
              ),
            )
            .decoration
        as BoxDecoration;

void main() {
  group('SoftCard', () {
    testWidgets('paints the surface and radius from the installed tokens', (
      tester,
    ) async {
      await tester.pumpWidget(_app(soft: const Soft.dark()));

      final decoration = _decorationOf(tester);
      expect(decoration.color, const Soft.dark().surface);
      expect(
        decoration.borderRadius,
        BorderRadius.circular(const Soft.dark().radius),
      );
    });

    testWidgets('follows the tokens rather than hard-coded values', (
      tester,
    ) async {
      const custom = Soft(
        surface: Color(0xFF00FF00),
        glow: Color(0xFFFF0000),
        radius: 3,
      );
      await tester.pumpWidget(_app(soft: custom));

      final decoration = _decorationOf(tester);
      expect(decoration.color, const Color(0xFF00FF00));
      expect(decoration.borderRadius, BorderRadius.circular(3));
    });

    testWidgets('falls back to the dark tokens when none are installed', (
      tester,
    ) async {
      await tester.pumpWidget(_app());

      expect(_decorationOf(tester).color, const Soft.dark().surface);
    });

    testWidgets('shows its child', (tester) async {
      await tester.pumpWidget(_app(soft: const Soft.dark()));

      expect(find.text('hello'), findsOneWidget);
    });
  });

  group('Soft', () {
    test('copyWith replaces only the named value', () {
      const base = Soft.dark();
      final changed = base.copyWith(radius: 4);

      expect(changed.radius, 4);
      expect(changed.surface, base.surface);
      expect(changed.glow, base.glow);
    });

    test('lerp moves halfway between two token sets', () {
      const a = Soft(
        surface: Color(0xFF000000),
        glow: Color(0xFF000000),
        radius: 0,
      );
      const b = Soft(
        surface: Color(0xFFFFFFFF),
        glow: Color(0xFFFFFFFF),
        radius: 10,
      );

      expect(a.lerp(b, 0.5).radius, 5);
    });
  });
}
