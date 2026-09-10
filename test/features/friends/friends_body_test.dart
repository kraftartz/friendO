import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/core/friends/listed_friend.dart' show ListedFriend;
import 'package:friendo/features/friends/bloc/friends_state.dart'
    show ChipCounts, Emptiness, FriendCard, FriendsListState;
import 'package:friendo/features/friends/view/friend_card_view.dart'
    show FriendCardView;
import 'package:friendo/features/friends/view/friends_body.dart'
    show FriendsBody;
import 'package:friendo_domain/friendo_domain.dart'
    show Cadence, CivilDate, Orbit;
import 'package:friendo_ui/friendo_ui.dart' show Pill, Soft;

/// The screen around the cards: the banner, the search field, the chips and
/// the three empty states.
void main() {
  final now = DateTime(2026, 9, 10, 18);
  final today = CivilDate.from(now);

  FriendCard aCard(String id, {int cadenceDays = 30, int daysAgo = 10}) {
    final friend = ListedFriend(
      id: id,
      name: id,
      cadence: Cadence.ofDays(cadenceDays),
      lastMet: today.addDays(-daysAgo),
    );

    return FriendCard(friend: friend, placing: friend.placingAt(now));
  }

  FriendsListState aReading({
    List<FriendCard> cards = const [],
    List<FriendCard> overdue = const [],
    String term = '',
    Orbit? orbit,
    int? rosterCount,
  }) => FriendsListState(
    cards: cards,
    overdue: overdue,
    counts: ChipCounts.over(cards),
    rosterCount: rosterCount ?? cards.length,
    today: today,
    term: term,
    orbit: orbit,
  );

  Future<void> draw(
    WidgetTester tester,
    FriendsListState reading, {
    void Function(String term)? onSearch,
    void Function(Orbit? orbit)? onShowOrbit,
    VoidCallback? onReview,
    VoidCallback? onAddFriend,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(extensions: const [Soft.dark()]),
      home: Scaffold(
        body: FriendsBody(
          reading: reading,
          onSearch: onSearch ?? (_) {},
          onShowOrbit: onShowOrbit ?? (_) {},
          onReview: onReview ?? () {},
          onLogMeeting: (_) {},
          onAddFriend: onAddFriend,
        ),
      ),
    ),
  );

  testWidgets('draws one card for each Friend', (tester) async {
    await draw(tester, aReading(cards: [aCard('anna'), aCard('ben')]));

    expect(find.byType(FriendCardView), findsNWidgets(2));
  });

  testWidgets('holds nothing at all behind a lock', (tester) async {
    await draw(tester, const FriendsListState.locked());

    expect(find.byType(FriendCardView), findsNothing);
    expect(find.byType(Pill), findsNothing);
    expect(find.textContaining('first Friend'), findsNothing);
  });

  group('the banner', () {
    testWidgets('is not drawn while nobody is Overdue', (tester) async {
      await draw(tester, aReading(cards: [aCard('anna')]));

      expect(find.byKey(const Key('friends-overdue-banner')), findsNothing);
    });

    testWidgets('names the Overdue Friends', (tester) async {
      final late = aCard('anna', cadenceDays: 10, daysAgo: 30);

      await draw(tester, aReading(cards: [late], overdue: [late]));

      expect(find.byKey(const Key('friends-overdue-banner')), findsOneWidget);
      expect(find.textContaining('anna'), findsWidgets);
    });

    testWidgets('carries the true count when fewer names fit', (tester) async {
      final many = [
        for (var index = 0; index < 9; index++)
          aCard('late-$index', cadenceDays: 10, daysAgo: 30),
      ];

      await draw(tester, aReading(cards: many, overdue: many));

      final banner = find.byKey(const Key('friends-overdue-banner'));
      expect(
        find.descendant(of: banner, matching: find.textContaining('9')),
        findsWidgets,
      );
      expect(
        find.descendant(of: banner, matching: find.textContaining('late-8')),
        findsNothing,
      );
    });

    testWidgets('asks for the review of the whole roster', (tester) async {
      final late = aCard('anna', cadenceDays: 10, daysAgo: 30);
      var reviews = 0;

      await draw(
        tester,
        aReading(cards: [late], overdue: [late], term: 'x'),
        onReview: () => reviews++,
      );
      await tester.tap(find.text('Review'));

      expect(reviews, 1);
    });

    testWidgets('reads no banned word', (tester) async {
      final late = aCard('anna', cadenceDays: 10, daysAgo: 30);

      await draw(tester, aReading(cards: [late], overdue: [late]));

      expect(find.textContaining('rifting'), findsNothing);
      expect(find.textContaining('ue soon'), findsNothing);
    });
  });

  group('the chips', () {
    testWidgets('are four, and no more', (tester) async {
      await draw(tester, aReading(cards: [aCard('anna')]));

      expect(find.byType(Pill), findsNWidgets(4));
      expect(find.textContaining('Due Soon'), findsNothing);
    });

    testWidgets('carry a name and a count, and never a Cadence', (
      tester,
    ) async {
      await draw(tester, aReading(cards: [aCard('anna', cadenceDays: 7)]));

      expect(find.text('All 1'), findsOneWidget);
      expect(find.text('Inner 1'), findsOneWidget);
      expect(find.text('Middle 0'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(Pill),
          matching: find.textContaining('7d'),
        ),
        findsNothing,
      );
    });

    testWidgets('ask for the Orbit they name', (tester) async {
      final asked = <Orbit?>[];

      await draw(
        tester,
        aReading(cards: [aCard('anna')]),
        onShowOrbit: asked.add,
      );
      await tester.tap(find.text('Outer 0'));
      await tester.tap(find.text('All 1'));

      expect(asked, [Orbit.outer, null]);
    });
  });

  group('the search field', () {
    testWidgets('reports what the User types', (tester) async {
      final typed = <String>[];

      await draw(tester, aReading(cards: [aCard('anna')]), onSearch: typed.add);
      await tester.enterText(find.byType(TextField), 'ann');

      expect(typed, ['ann']);
    });

    testWidgets('shows the term the state holds', (tester) async {
      await draw(tester, aReading(cards: [aCard('anna')], term: 'ann'));

      expect(find.text('ann'), findsOneWidget);
    });

    testWidgets('empties when the state clears the term', (tester) async {
      await draw(tester, aReading(cards: [aCard('anna')], term: 'ann'));

      await draw(tester, aReading(cards: [aCard('anna')]));

      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '',
      );
    });
  });

  group('the three empty states', () {
    testWidgets('invites a first Friend when the roster is empty', (
      tester,
    ) async {
      var adds = 0;

      await draw(tester, aReading(), onAddFriend: () => adds++);

      expect(find.byKey(const Key('friends-empty-roster')), findsOneWidget);
      await tester.tap(find.text('Add your first Friend'));
      expect(adds, 1);
    });

    testWidgets('says the search matched nobody, and offers to clear it', (
      tester,
    ) async {
      final typed = <String>[];

      await draw(
        tester,
        aReading(term: 'zebra', rosterCount: 3),
        onSearch: typed.add,
      );

      expect(find.byKey(const Key('friends-empty-search')), findsOneWidget);
      await tester.tap(find.text('Clear the search'));
      expect(typed, ['']);
    });

    testWidgets('says the Orbit is empty, and offers All', (tester) async {
      final asked = <Orbit?>[];

      await draw(
        tester,
        FriendsListState(
          cards: const [],
          overdue: const [],
          counts: ChipCounts.over([aCard('anna')]),
          rosterCount: 1,
          today: today,
          orbit: Orbit.outer,
        ),
        onShowOrbit: asked.add,
      );

      expect(find.byKey(const Key('friends-empty-orbit')), findsOneWidget);
      await tester.tap(find.text('Show All'));
      expect(asked, [null]);
    });

    testWidgets('uses plain words and never a decorative one', (tester) async {
      await draw(
        tester,
        FriendsListState(
          cards: const [],
          overdue: const [],
          counts: ChipCounts.over([aCard('anna')]),
          rosterCount: 1,
          today: today,
          orbit: Orbit.outer,
        ),
      );

      expect(find.textContaining('souls'), findsNothing);
    });

    testWidgets('tells one state from another', (tester) async {
      await draw(tester, aReading());
      expect(find.byKey(const Key('friends-empty-search')), findsNothing);

      await draw(tester, aReading(term: 'zebra', rosterCount: 3));

      expect(find.byKey(const Key('friends-empty-roster')), findsNothing);
      expect(
        aReading(term: 'zebra', rosterCount: 3).emptiness,
        Emptiness.noMatch,
      );
    });
  });
}
