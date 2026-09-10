import 'package:flutter/material.dart';
import 'package:friendo/features/friends/bloc/friends_state.dart'
    show FriendCard;
import 'package:friendo/features/friends/view/phase_bar.dart' show PhaseBar;
import 'package:friendo/features/friends/view/words.dart'
    show orbitWord, standingWord;
import 'package:friendo_domain/friendo_domain.dart' show CivilDate, Standing;
import 'package:friendo_ui/friendo_ui.dart'
    show AvatarHalo, Soft, SoftButton, SoftCard, colourOf, initialOf;

/// One Friend, in words.
///
/// It draws and it writes nothing. A tap on its one button asks the caller to
/// log a Meeting, and the button sits on the card that names the Friend, so a
/// mis-tap can never write against somebody the User cannot see.
class FriendCardView extends StatelessWidget {
  const FriendCardView({
    required this.card,
    required this.today,
    this.onLogMeeting,
    this.onOpen,
    super.key,
  });

  final FriendCard card;

  /// The one Civil Date the whole screen was built from.
  final CivilDate today;

  final void Function(String friendId)? onLogMeeting;

  final void Function(String friendId)? onOpen;

  @override
  Widget build(BuildContext context) {
    final soft = Soft.of(context);
    final colour = _standingColour(context);

    return GestureDetector(
      onTap: onOpen == null ? null : () => onOpen!(card.id),
      child: SoftCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AvatarHalo(
                  label: initialOf(card.name),
                  colour: colourOf(card.avatarSeed),
                  isLit: card.standing == Standing.overdue,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${orbitWord(card.orbit)} · '
                        'every ${card.cadenceDays} days',
                        style: TextStyle(
                          fontSize: 12,
                          color: soft.glow.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  standingWord(card.standing),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colour,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: PhaseBar(fraction: card.barFraction, colour: colour),
                ),
                const SizedBox(width: 8),
                Text(
                  '${card.daysSinceMeeting(today)}/${card.cadenceDays}d',
                  style: TextStyle(fontSize: 12, color: colour),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _lastMeetingLine(context),
              style: TextStyle(
                fontSize: 12,
                color: soft.glow.withValues(alpha: 0.7),
              ),
            ),
            if (card.friend.newestTopic case final topic?) ...[
              const SizedBox(height: 8),
              Text(
                card.friend.topicsWaiting > 1
                    ? '$topic  (+${card.friend.topicsWaiting - 1} more)'
                    : topic,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: SoftButton(
                key: Key('friends-log-meeting-${card.id}'),
                onPressed: onLogMeeting == null
                    ? null
                    : () => onLogMeeting!(card.id),
                child: const Text('Log a Meeting'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The last Meeting, its Civil Date, its time when the User set one, and
  /// its place when the User wrote one.
  String _lastMeetingLine(BuildContext context) {
    final words = MaterialLocalizations.of(context);
    final line = StringBuffer(
      'Last Meeting ${words.formatMediumDate(card.friend.lastMet.startOfDayLocal())}',
    );

    if (card.friend.lastMetAtMinute case final minute?) {
      line.write(
        ' at ${words.formatTimeOfDay(TimeOfDay(hour: minute ~/ 60, minute: minute % 60))}',
      );
    }
    if (card.friend.lastMetPlace case final place?) line.write(' · $place');

    return line.toString();
  }

  Color _standingColour(BuildContext context) {
    final soft = Soft.of(context);

    return switch (card.standing) {
      Standing.overdue => Theme.of(context).colorScheme.error,
      Standing.nearing => soft.glow,
      Standing.inOrbit => soft.glow.withValues(alpha: 0.75),
      Standing.freshlyReset => soft.glow.withValues(alpha: 0.5),
    };
  }
}
