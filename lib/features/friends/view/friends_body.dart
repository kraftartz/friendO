import 'package:flutter/material.dart';
import 'package:friendo/features/friends/bloc/friends_state.dart'
    show Emptiness, FriendCard, FriendsListState;
import 'package:friendo/features/friends/view/friend_card_view.dart'
    show FriendCardView;
import 'package:friendo/features/friends/view/words.dart' show orbitWord;
import 'package:friendo_domain/friendo_domain.dart' show Orbit;
import 'package:friendo_ui/friendo_ui.dart' show Pill, Soft, SoftWell;

/// How many Overdue names the banner draws before it leaves the rest to the
/// count.
const _namesInBanner = 3;

/// The Friends List: the banner, the search field, the chips and the cards.
///
/// It draws a reading and reports taps. It writes nothing, so a test of what
/// the screen says needs a reading and no store.
///
/// A locked Profile draws nothing at all. It is not one of the three empty
/// states, because each of those offers a next action and a locked screen has
/// none to offer.
class FriendsBody extends StatefulWidget {
  const FriendsBody({
    required this.reading,
    required this.onSearch,
    required this.onShowOrbit,
    required this.onReview,
    required this.onLogMeeting,
    this.onAddFriend,
    this.onOpenFriend,
    super.key,
  });

  final FriendsListState reading;

  final void Function(String term) onSearch;

  /// Asks for one Orbit, or for the whole Priority Order with null.
  final void Function(Orbit? orbit) onShowOrbit;

  final VoidCallback onReview;

  final void Function(String friendId) onLogMeeting;

  final VoidCallback? onAddFriend;

  final void Function(String friendId)? onOpenFriend;

  @override
  State<FriendsBody> createState() => _FriendsBodyState();
}

class _FriendsBodyState extends State<FriendsBody> {
  late final TextEditingController _typed = TextEditingController(
    text: widget.reading.term,
  );

  @override
  void didUpdateWidget(FriendsBody old) {
    super.didUpdateWidget(old);
    // A lock and a Review clear the term, and the field follows them. It
    // follows nothing else. A state carries the term it was built from, and
    // that term is one keystroke behind a fast typist, so following every
    // state would take back letters the User has already typed.
    if (widget.reading.term.isEmpty && _typed.text.isNotEmpty) _typed.clear();
  }

  @override
  void dispose() {
    _typed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reading = widget.reading;
    if (reading.isLocked) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (reading.hasBanner) ...[
            _Banner(overdue: reading.overdue, onReview: widget.onReview),
            const SizedBox(height: 12),
          ],
          _searchField(context),
          const SizedBox(height: 12),
          _chips(),
          const SizedBox(height: 12),
          Expanded(child: _cards(reading)),
        ],
      ),
    );
  }

  Widget _searchField(BuildContext context) => SoftWell(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: TextField(
      key: const Key('friends-search'),
      controller: _typed,
      onChanged: widget.onSearch,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: 'Search a Friend, a Topic, an Affinity or an Orbit',
        isDense: true,
        suffixIcon: widget.reading.term.isEmpty
            ? null
            : IconButton(
                key: const Key('friends-clear-search'),
                icon: const Icon(Icons.close),
                tooltip: 'Clear the search',
                onPressed: () {
                  _typed.clear();
                  widget.onSearch('');
                },
              ),
      ),
    ),
  );

  Widget _chips() {
    final reading = widget.reading;

    return Wrap(
      spacing: 8,
      children: [
        Pill(
          label: 'All',
          count: reading.counts.of(null),
          isChosen: reading.orbit == null,
          onTap: () => widget.onShowOrbit(null),
        ),
        for (final orbit in Orbit.values)
          Pill(
            label: orbitWord(orbit),
            count: reading.counts.of(orbit),
            isChosen: reading.orbit == orbit,
            onTap: () => widget.onShowOrbit(orbit),
          ),
      ],
    );
  }

  Widget _cards(FriendsListState reading) => switch (reading.emptiness) {
    Emptiness.noFriends => _Empty(
      key: const Key('friends-empty-roster'),
      says: 'No Friends yet. Add the first one and the list starts here.',
      does: 'Add your first Friend',
      onTap: widget.onAddFriend,
    ),
    Emptiness.noMatch => _Empty(
      key: const Key('friends-empty-search'),
      says: 'No Friend matches that search.',
      does: 'Clear the search',
      onTap: () => widget.onSearch(''),
    ),
    Emptiness.noneInOrbit => _Empty(
      key: const Key('friends-empty-orbit'),
      says: 'No Friend is on this Orbit.',
      does: 'Show All',
      onTap: () => widget.onShowOrbit(null),
    ),
    Emptiness.none => ListView.separated(
      itemCount: reading.cards.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, at) => FriendCardView(
        card: reading.cards[at],
        today: reading.today!,
        onLogMeeting: widget.onLogMeeting,
        onOpen: widget.onOpenFriend,
      ),
    ),
  };
}

/// The banner that names the Friends whose Due Date has passed.
///
/// It draws the Overdue Friends in the order they arrive and sorts nothing.
/// It names the first few and always carries the true count, so the number is
/// right even when the names run out.
class _Banner extends StatelessWidget {
  const _Banner({required this.overdue, required this.onReview});

  final List<FriendCard> overdue;

  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final colour = Theme.of(context).colorScheme.error;
    final named = overdue.take(_namesInBanner).map((card) => card.name);

    return DecoratedBox(
      key: const Key('friends-overdue-banner'),
      decoration: BoxDecoration(
        color: colour.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(Soft.of(context).radius),
        border: Border.all(color: colour.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${overdue.length} Overdue',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: colour,
                    ),
                  ),
                  Text(
                    named.join(', '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            TextButton(
              key: const Key('friends-review'),
              onPressed: onReview,
              child: const Text('Review'),
            ),
          ],
        ),
      ),
    );
  }
}

/// What the screen says when it holds no card, and the one thing to do next.
class _Empty extends StatelessWidget {
  const _Empty({required this.says, required this.does, this.onTap, super.key});

  final String says;

  final String does;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(says, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        FilledButton(onPressed: onTap, child: Text(does)),
      ],
    ),
  );
}
