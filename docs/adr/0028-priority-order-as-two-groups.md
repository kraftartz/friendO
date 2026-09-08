# ADR-0028: Hold the Priority Order as two groups, not one sorted list

**Status:** Accepted
**Date:** 2026-09-08

## Context

[ADR-0009](0009-derived-phase-and-overdue-queue.md) defines the Priority Order as two groups with
different sort keys:

| Group | Sort key | Meaning |
|---|---|---|
| Overdue | `dueAt` ascending | Who became Overdue first |
| On track | `phase` descending | Who is closest to due |

> Overdue friends always come before on-track friends.

The record then says "The domain sorts every friend into **one list**", and the obvious reading of
that is one `List` and one comparator. Written that way, the rule above becomes a branch inside a
compare function:

```dart
list.sort((a, b) {
  if (a.overdue != b.overdue) return a.overdue ? -1 : 1;
  if (a.overdue) return a.dueAt.compareTo(b.dueAt);
  return b.phase.compareTo(a.phase);
});
```

Every line of that is a place to get a sign wrong, and a wrong sign sorts a screen wrongly with no
test obviously missing. It also mixes two orderings that are not comparable: `dueAt` and `phase`
answer different questions, and the comparator has to keep them apart by hand on every call.

[ADR-0021](0021-civil-date-time-model.md) makes this sharper. A Friend whose Due Date is today has a
Phase above 1 and is **not** Overdue. So the highest on-track Phase can exceed the lowest Overdue
Phase, and any attempt to fall back on one numeric key would put them in the wrong order.

ADR-0014 already names the move that fixes this, and praises it:

> A stable partition of a sorted list means orbit order can never contradict global order. That
> holds by construction, so no test has to guard it.

## Decision

`PriorityOrder` holds the two groups and never a flat list with a branch.

```dart
final class PriorityOrder {
  factory PriorityOrder(Iterable<Placing> placings);  // splits, then sorts each
  final List<Placing> overdue;   // by dueAt ascending
  final List<Placing> onTrack;   // by phase descending
  List<Placing> get all;         // overdue, then onTrack
  Placing? get next;             // the first of all, or null
  DialCounts get counts;
}
```

Each group is sorted by its own key, and `all` concatenates them. "Overdue Friends come before
on-track Friends" then holds because of the shape of the type. No comparator can get it wrong,
because no comparator ever sees both groups.

`Placing` is one Friend reduced to what the ranking needs: the id, the Cadence, the Due Date, the
Phase and the Standing. It is a read model. It is built from the two stored facts, so nothing in it
can fall out of step with the rows, and it never comes back through a `save`. See
[ADR-0022](0022-one-repository-per-aggregate.md).

`all` and `next` keep ADR-0009's promise that the domain returns one ranking. That record's decision
does not change. This one says how it is held.

## Consequences

### Positive

- The rule that the product depends on most holds by construction. There is no branch to test.
- Each group's sort reads as one line and one key, so a wrong sign is visible.
- The Dial and the Friends List can take the whole ranking through `all`, or the Beads Queue on its
  own through `overdue`, without re-filtering.
- Adding a third group later, if one is ever wanted, is a field and not a rewrite of a comparator.

### Negative

- Two lists to build instead of one. Every reader has to know that `all` is where the total order
  is.
- `all` allocates a new list on each read. At about 100 Friends that costs nothing, and a caller who
  reads it in a build method will do it often.
- A caller can read `onTrack` alone and forget the Overdue group, which is a mistake a flat list
  would not allow.

## Alternatives Considered

### One list and one comparator

**Why rejected:** The rule then lives inside a branch in a compare function. That branch is exactly
what ADR-0014 avoids elsewhere, and a Friend due today makes it necessary rather than merely tidy.

### Sort by one number that combines lateness and Phase

**Why rejected:** [ADR-0009](0009-derived-phase-and-overdue-queue.md) already settled that ordering
Overdue Friends by Phase is a different rule that gives different answers, and the product owner
chose absolute time. Combining the two keys would quietly reopen that decision.

### Return an ordered list and let the caller filter for Overdue

**Why rejected:** Every caller that wants the Beads Queue would repeat the same filter, and one of
them would use `phase > 1` instead of the Due Date comparison, which ADR-0021 shows is a different
question.
