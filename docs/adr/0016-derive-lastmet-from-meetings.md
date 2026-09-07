# ADR-0016: Derive lastMet from meeting dates

**Status:** Accepted
**Date:** 2026-09-08

## Context

[ADR-0009](0009-derived-phase-and-overdue-queue.md) first said that logging a meeting sets
`lastMet` to now. Two everyday scenarios break that rule.

**A friend you have never met.** You add Kasia today. She has no meeting. `phase` divides by a
`lastMet` that does not exist. The dial has nowhere to draw her.

**A meeting entered late.** You saw Anna last Tuesday and log it today. Later you remember a coffee
from three weeks ago and log that too. Under the old rule the older entry overwrites the newer one.
Anna's bead jumps backwards, and the app now says she is fine when she is not.

The second case is not rare. People log things when they remember them, not when they happen.

## Decision

**Ask for a date when adding a friend.** The add screen asks when you last saw the person. It
defaults to today. Store that answer as the friend's first meeting.

**Let a meeting carry any past date.** The date picker allows today and earlier. Reject future
dates. A future date is a plan, not a meeting, and the app does not hold plans.

**Derive `lastMet`.** It is `max(dates of this friend's meetings)`. It is not a stored field.

Because creation always records one meeting, every friend always has at least one. `lastMet` is
never empty, so no code needs a null case.

## Consequences

### Positive

- The "friend with no meetings" case stops existing. It is removed, not handled.
- The order you enter meetings no longer matters. `max` gives the same answer either way.
- Adding an old acquaintance places them correctly. Somebody unseen for two years shows as overdue
  at once, which is true and useful.
- The meeting list stays the single source of truth, which is what
  [ADR-0009](0009-derived-phase-and-overdue-queue.md) argues for throughout.

### Negative

- Creating a friend writes a meeting the user may not have thought about. A user who accepts the
  default without reading it records a meeting that did not happen. Word the field clearly.
- Every dial read runs a `max` over each friend's meetings. At about 100 friends with a handful of
  meetings each this costs nothing. It would matter at a much larger size.
- Deleting the only meeting would empty `lastMet` again. Block that, or write a replacement meeting
  in the same step.

## Alternatives Considered

### Keep `lastMet` as a stored column, updated on every write

**Why rejected:** It is faster and it creates a second source of truth. A late entry for an old
date would still corrupt it unless the write compared dates first, which is the `max` rule with
extra steps and more ways to get it wrong.

### Allow an empty `lastMet` and treat those friends as overdue

**Why rejected:** Adding thirty people in one sitting would fill the dial with thirty overdue beads
on the first day. The app would open in its worst state.

### Treat adding a friend as a meeting today, and forbid backdating

**Why rejected:** It is the simplest rule and it makes the app lie. Add somebody you have not seen
for two years and the app reports them as freshly seen.
