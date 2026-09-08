import 'package:friendo_domain/friendo_domain.dart';
import 'package:test/test.dart';

void main() {
  final now = DateTime(2026, 6, 1, 12);
  final weekly = Cadence.ofDays(7);

  Placing placing(String friendId, CivilDate lastMet) =>
      Placing(friendId: friendId, lastMet: lastMet, cadence: weekly, now: now);

  // Due 2026-05-08 and 2026-05-27. Both dates have passed, so both are Overdue.
  final longOverdue = placing('long-overdue', CivilDate(2026, 5, 1));
  final justOverdue = placing('just-overdue', CivilDate(2026, 5, 20));

  // Due 2026-06-04 and 2026-06-06. Neither date has passed.
  final closeToDue = placing('close-to-due', CivilDate(2026, 5, 28));
  final freshlyMet = placing('freshly-met', CivilDate(2026, 5, 30));

  // Due today. The Bead rests at the top and the Friend is not Overdue yet.
  final dueToday = placing('due-today', CivilDate(2026, 5, 25));

  group('Placing', () {
    test('works the Due Date out from the Cadence', () {
      expect(longOverdue.dueAt, CivilDate(2026, 5, 8));
    });

    test('is Overdue once the Due Date has passed', () {
      expect(longOverdue.overdue, isTrue);
      expect(longOverdue.standing, Standing.overdue);
    });

    test('is not Overdue on the Due Date, even with the Bead at the top', () {
      expect(dueToday.overdue, isFalse);
      expect(dueToday.phase.hasArrived, isTrue);
      expect(dueToday.standing, Standing.nearing);
    });
  });

  group('PriorityOrder', () {
    final order = PriorityOrder([
      freshlyMet,
      justOverdue,
      dueToday,
      longOverdue,
      closeToDue,
    ]);

    test('ranks Overdue Friends by the oldest Due Date', () {
      expect(order.overdue.map((p) => p.friendId), [
        'long-overdue',
        'just-overdue',
      ]);
    });

    test('ranks on-track Friends by the highest Phase', () {
      expect(order.onTrack.map((p) => p.friendId), [
        'due-today',
        'close-to-due',
        'freshly-met',
      ]);
    });

    test('puts every Overdue Friend before every on-track Friend', () {
      // The highest Phase on track is above 1, so a single sorted list would
      // need a branch to keep this true. Two groups keep it true by their
      // shape.
      expect(order.onTrack.first.phase.value, greaterThan(1));
      expect(order.all.map((p) => p.friendId), [
        'long-overdue',
        'just-overdue',
        'due-today',
        'close-to-due',
        'freshly-met',
      ]);
    });

    test('names the Friend to see next', () {
      expect(order.next?.friendId, 'long-overdue');
    });

    test('names the closest on-track Friend when nobody is Overdue', () {
      expect(
        PriorityOrder([freshlyMet, closeToDue]).next?.friendId,
        'close-to-due',
      );
    });

    test('names nobody when there is no Friend', () {
      expect(PriorityOrder(const []).next, isNull);
    });

    test('counts every Friend once', () {
      expect(order.counts.total, 5);
      expect(order.counts.overdue, 2);
    });

    test('reads the same whatever order the Friends arrive in', () {
      final reversed = PriorityOrder(order.all.reversed);
      expect(reversed, order);
    });
  });
}
