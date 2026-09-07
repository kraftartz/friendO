# ADR-0009: Derive phase, order overdue friends by due date

**Status:** Accepted
**Date:** 2026-09-07

## Context

The dial is the product. It answers one question: who should I see next?

A first instinct is to store each bead's angle and move it on a timer. That creates a second source
of truth. It drifts when the app is closed. It needs a background job to stay correct.

A second question follows. A bead reaches 12:00 and the meeting has not happened. What then?

Three answers are possible. The bead can keep lapping. The bead can stop at 12:00. The bead can
move into a special zone past 12:00.

## Decision

Store a `cadence` per friend, plus that friend's meetings. Derive everything else on read.

```
lastMet(f)    = max(dates of f's meetings)
dueAt(f)      = lastMet(f) + cadence(f)
phase(f, now) = (now - lastMet(f)) / cadence(f)
overdue(f)    = phase(f, now) > 1
```

Pass `now` in as an argument. The domain never reads the clock itself.

**Overdue beads stop at 12:00.** They do not lap.

The domain sorts every friend into **one list**:

| Group | Sort key | Meaning |
|---|---|---|
| Overdue | `dueAt` ascending | Who became overdue first |
| On track | `phase` descending | Who is closest to due |

Overdue friends always come before on-track friends. The first item is the friend the banner names.

The domain returns an ordered list and nothing else. It does not know about rings, angles, or
pixels. See [ADR-0014](0014-dial-layout-and-bead-packing.md).

## Consequences

### Positive

- No timer keeps the dial correct. The dial is right after the phone sleeps for a month.
- Logging a meeting adds one row. The whole screen follows on the next read.
- Meetings can arrive in any order. `max` makes late entries safe. See
  [ADR-0016](0016-derive-lastmet-from-meetings.md).
- 12:00 always means one thing: due now. The dial cannot mislead.
- `phase` is a pure function. Tests call it with a fixed `now` and no mocks.
- One list serves the banner, the rings, and any future list view.

### Negative

- Every read recomputes. At 100 friends this is trivial. It would not stay trivial at 100,000.
- Overdue beads pile up at 12:00. The dial has limited room for them. See
  [ADR-0015](0015-dial-overflow-treatment.md).
- Sorting by `dueAt` ignores how late someone is in proportion to their cadence. See below.

## Alternatives Considered

### Let overdue beads keep lapping

**Why rejected:** It looks better and it lies. A friend 8 days late on a 7-day cadence would draw at
12:01, in the same place as a friend seen yesterday. The dial would hide the very people the app
exists to surface.

### Order overdue friends by `phase` descending

**Why rejected:** This orders by how late someone is compared with their own cadence. It is a
defensible rule and it gives different results. A friend 5 days late on a yearly cadence became
overdue before a friend 2 days late on a weekly cadence, but the weekly friend is 29% late against
1.4%.

The product owner chose absolute time: "who was overdue FIRST", grounded in the normal calendar.
This is recorded because the two rules look interchangeable and are not.

### Store the angle and move it on a timer

**Why rejected:** It creates a second source of truth that drifts. It needs the app to be running.
It would be wrong every time the user reopens the app after a gap, which is most of the time.

### Move overdue beads into a compressed arc past 12:00

**Why rejected:** It solves crowding and it puts two different time scales on one dial. Users would
have to learn that the arc past 12:00 does not measure the same thing as the rest of the face.
