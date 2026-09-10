import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/core/friends/listed_friend.dart' show ListedFriend;
import 'package:friendo/features/friends/bloc/friends_state.dart'
    show FriendCard;
import 'package:friendo/features/friends/view/friend_card_view.dart'
    show FriendCardView;
import 'package:friendo/features/friends/view/phase_bar.dart' show PhaseBar;
import 'package:friendo_domain/friendo_domain.dart'
    show Cadence, CivilDate, Standing;
import 'package:friendo_ui/friendo_ui.dart' show Soft;

/// What a card says.
///
/// It takes a reading and reports taps, so a test of the words needs no store
/// and no clock.
void main() {
  /// Late in the afternoon, so that a label taken from the Phase and rounded
  /// would disagree with the whole days between two Civil Dates. At local
  /// midnight the two agree and the test would prove nothing.
  final today = DateTime(2026, 9, 10, 18);

  FriendCard aCard({
    int cadenceDays = 30,
    int daysAgo = 28,
    String? place,
    int? atMinute,
    String? topic,
    int topicsWaiting = 0,
  }) {
    final friend = ListedFriend(
      id: 'f1',
      name: 'Anna',
      cadence: Cadence.ofDays(cadenceDays),
      lastMet: CivilDate.from(today).addDays(-daysAgo),
      lastMetAtMinute: atMinute,
      lastMetPlace: place,
      newestTopic: topic,
      topicsWaiting: topicsWaiting,
    );

    return FriendCard(friend: friend, placing: friend.placingAt(today));
  }

  Future<void> draw(
    WidgetTester tester,
    FriendCard card, {
    void Function(String friendId)? onLogMeeting,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(extensions: const [Soft.dark()]),
      home: Scaffold(
        body: FriendCardView(
          card: card,
          today: CivilDate.from(today),
          onLogMeeting: onLogMeeting,
        ),
      ),
    ),
  );

  testWidgets('names the Friend, their Orbit and their Cadence in days', (
    tester,
  ) async {
    await draw(tester, aCard(cadenceDays: 30));

    expect(find.text('Anna'), findsOneWidget);
    expect(find.text('Middle · every 30 days'), findsOneWidget);
  });

  group('the Standing', () {
    const words = {
      Standing.freshlyReset: 'Freshly Reset',
      Standing.inOrbit: 'In Orbit',
      Standing.nearing: 'Nearing',
      Standing.overdue: 'Overdue',
    };

    const days = {
      Standing.freshlyReset: 1,
      Standing.inOrbit: 15,
      Standing.nearing: 28,
      Standing.overdue: 40,
    };

    for (final standing in Standing.values) {
      testWidgets('reads ${words[standing]} in the glossary word', (
        tester,
      ) async {
        final card = aCard(daysAgo: days[standing]!);
        expect(card.standing, standing);

        await draw(tester, card);

        expect(find.text(words[standing]!), findsOneWidget);
      });
    }
  });

  testWidgets('reads no banned word for a Friend who has slipped', (
    tester,
  ) async {
    await draw(tester, aCard(daysAgo: 40));

    expect(find.textContaining('Drifting'), findsNothing);
    expect(find.textContaining('drifting'), findsNothing);
  });

  testWidgets('labels a Friend resting on their Due Date in whole days', (
    tester,
  ) async {
    final card = aCard(cadenceDays: 30, daysAgo: 30);
    expect(card.standing, Standing.nearing);

    await draw(tester, card);

    expect(find.text('30/30d'), findsOneWidget);
  });

  testWidgets('labels an Overdue Friend past their Cadence', (tester) async {
    await draw(tester, aCard(cadenceDays: 30, daysAgo: 33));

    expect(find.text('33/30d'), findsOneWidget);
  });

  testWidgets('fills the bar and no further above a Phase of one', (
    tester,
  ) async {
    await draw(tester, aCard(cadenceDays: 30, daysAgo: 90));

    expect(tester.widget<PhaseBar>(find.byType(PhaseBar)).fraction, 1);
  });

  testWidgets('shows where the last Meeting happened', (tester) async {
    await draw(tester, aCard(place: 'Blue Bottle Coffee'));

    expect(find.textContaining('Blue Bottle Coffee'), findsOneWidget);
  });

  testWidgets('shows the time of a Meeting only when the User set one', (
    tester,
  ) async {
    await draw(tester, aCard());
    expect(find.textContaining(' at '), findsNothing);

    await draw(tester, aCard(atMinute: 14 * 60 + 30));

    expect(find.textContaining(' at '), findsOneWidget);
  });

  testWidgets('shows the newest waiting Topic, and how many wait', (
    tester,
  ) async {
    await draw(tester, aCard(topic: 'ask about Kyoto', topicsWaiting: 3));

    expect(find.textContaining('ask about Kyoto'), findsOneWidget);
    expect(find.textContaining('+2 more'), findsOneWidget);
  });

  testWidgets('shows one Topic alone when one waits', (tester) async {
    await draw(tester, aCard(topic: 'ask about Kyoto', topicsWaiting: 1));

    expect(find.text('ask about Kyoto'), findsOneWidget);
  });

  testWidgets('asks for a Meeting with the Friend it names', (tester) async {
    final asked = <String>[];
    await draw(tester, aCard(), onLogMeeting: asked.add);

    await tester.tap(find.text('Log a Meeting'));

    expect(asked, ['f1']);
  });
}
