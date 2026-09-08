# ADR-0021: A Meeting happens on a Civil Date, with an optional time

**Status:** Accepted
**Date:** 2026-09-08

## Context

Five files described the same field five ways.

| Source | Said |
|---|---|
| `docs/architecture.md` | `meetings : [Instant]` |
| ADR-0016 | "Let a meeting carry any past date" |
| `docs/feature-backlog.md` | `meetings(id, friend_id, happened_on, ...)` |
| `CONTEXT.md` | "on any date up to today" |
| `phase.dart` | `DateTime lastMet` |

An instant and a calendar day are different types with different bugs. Dart's `DateTime` is either
one, depending on a flag the caller sets, so the code could not settle the question by itself.

This decides a column type, so it cannot wait. A day number and a count of milliseconds are not the
same column, and swapping one for the other after the first Backup exists means writing the format
migration that [ADR-0010](0010-encrypted-logical-backup.md) warns will grow.

Three failures follow from leaving it open.

1. **An owner who travels.** Store a Meeting as midnight of a local day, fly east, and `now` in the
   new zone can fall before the stored `lastMet`. `phaseOf` returned a negative number quietly, and
   a test asserted that it did. [ADR-0016](0016-derive-lastmet-from-meetings.md) believes that
   state cannot exist.
2. **Daylight saving.** `dueAt = lastMet + cadence` with `DateTime.add` adds absolute time. Across
   a clock change that lands an hour off. Near midnight it moves the Due Date to a different
   calendar day, which moves a reminder to 23:00 the night before.
3. **"Reject future dates" against which clock.** The device clock, read locally, lets a traveller
   log a Meeting for a day that is tomorrow where the row is stored.

## Decision

### A Meeting carries a Civil Date, and may carry a time of day

```
meetings(
  id,
  friend_id,
  happened_on         INTEGER NOT NULL,  -- days from 1970-01-01
  happened_at_minute  INTEGER NULL,      -- minutes from local midnight, 0..1439
  created_at          INTEGER NOT NULL,  -- milliseconds from the epoch, UTC
  ...
)
```

`happened_on` is a **Civil Date**: a calendar day with no time and no zone. "I saw Anna on Tuesday"
stays Tuesday when the owner flies to another zone, because there is no instant to re-read against a
different offset.

`happened_at_minute` is **optional and separate**. The owner may record that they met Paul at 14:00.
The field is null when they do not, and null is the normal case. A single `DateTime` column could
not do this, because it would hold an hour nobody typed, and nothing in the row would mark which
hours were real.

`created_at` is a genuine instant, because the machine wrote it. It gives a stable tiebreak
between two Meetings on one day without inventing an hour for either.

### The Dial reads the date and ignores the time

`phase` measures from **local midnight of `happened_on`**, in the zone the phone is in now.

The optional time is shown to the owner and is never read by the Dial. Two Friends seen on the same
day must draw at the same place. They would not if the Bead moved according to whether the owner
happened to fill in an hour, and a Bead whose place depends on an optional field is a Bead the
owner cannot read.

Midnight, rather than the whole day, because a Bead must creep. Quantising to whole days would give
a 7-day Cadence exactly seven places to stand, and the Dial cannot afford that.

`phase` is **never negative**. A Meeting cannot be in the future, so a reading below zero means the
phone changed zone or its clock moved. Zero is the truthful answer, and `phaseOf` returns it.
Throwing would crash the Dial in an airport, which is worse than drawing a Bead at the top of its
Orbit.

### The Due Date is a Civil Date, and Overdue is a comparison of two of them

```
dueAt(f)   = happened_on + cadence, in whole calendar days
overdue(f) = today > dueAt(f)
```

Whole calendar days, so a clock change cannot move the Due Date to a different day of the month.

Overdue compares two Civil Dates and not two Phases. This is a change to
[ADR-0009](0009-derived-phase-and-overdue-queue.md), which wrote `overdue(f) = phase > 1`. The two
disagree for about an hour after each clock change, and only the calendar answer matches the word
in `CONTEXT.md`: "the state of a Friend whose Due Date has passed".

A Friend is **not** Overdue on their own Due Date. That is the day the Meeting is wanted, so it has
not been missed until the day ends. The Bead reaches the top of its Orbit when the Due Date starts
and rests there through the day. ADR-0009's rule holds and reads more truly: 12:00 means due now.

### A reminder stores a Civil Date, a time, and a zone. Never an instant

**Never write a precomputed UTC instant for a future reminder.** Governments change daylight-saving
rules. A fire time worked out six months ahead drifts by an hour with nothing writing to it.

Store the civil date, the hour, and the IANA zone id. Resolve to an instant at scheduling time with
`TZDateTime`, from the `timezone` package that
[ADR-0012](0012-opt-in-local-notifications.md) already names. This costs nothing, because ADR-0012's
iOS limit of 64 pending notifications already forces a reschedule on every open.

The reminder hour is a **setting**, not a property of a Meeting. One hour chosen once serves every
Friend. Seeing somebody at 03:00 must never produce a 03:00 reminder.

### Three kinds of time, three types

| Value | Type | Why |
|---|---|---|
| A Meeting happened | Civil Date, plus an optional time of day | The owner's calendar is the truth. |
| Due Date | Civil Date | Derived: `happened_on` plus the Cadence in whole days. |
| A Meeting was written | instant | The machine wrote it. It orders two Meetings on one day. |
| A reminder fires | civil datetime **plus IANA zone**, resolved when scheduled | An instant worked out today can be wrong tomorrow. |

## Consequences

### Positive

- A Meeting keeps its day when the owner crosses a zone. The Dial does not move because a plane did.
- A negative Phase stops existing. It is removed, not handled, which is the same move ADR-0016 made
  for the empty `lastMet`.
- Adding a Cadence is integer addition on a day number. No clock change can reach it.
- "Reject future dates" becomes a comparison of two day numbers, which has one answer everywhere.
- `happened_on` is a small integer. It sorts, it subtracts to whole days, and it survives every
  Backup format.
- The optional time is honest. A null says "the owner did not say", which no fabricated midnight
  can say.

### Negative

- Two columns for one idea. Every reader has to know that the time is optional and that the Dial
  ignores it.
- A Meeting logged at 23:50 and remembered at 00:10 lands on two different days. That is what a
  calendar does, and the date picker lets the owner fix it.
- `phase` still uses the local zone for midnight, so an owner who moves zone sees every Bead shift
  by the offset. The shift is small against any Cadence and it corrects itself.
- Reminders need the zone id stored beside every scheduled time. That is one more column and one
  more thing to get right on restore.
- An owner who wants "visiting Paul at 14:00 today" still cannot have it. That is a plan, and
  ADR-0016 excludes plans on purpose.

## Alternatives Considered

### Store one `DateTime` instant

**Why rejected:** The app never collects a time, so the column would hold an hour nobody entered.
Fabricated precision is worse than none, because the column then carries two kinds of value with
nothing marking which is which. It also brings back all three failures in the Context above.

### Store a Civil Date and nothing else

**Why rejected:** It is the simplest model and it throws away a fact the owner may want to keep.
"Coffee at 08:00 before work" and "dinner at 20:00" are different memories. A separate nullable
column records that at the cost of one integer, and it keeps the two kinds of value apart, which is
the objection that ruled out the single `DateTime`.

### Store a Civil Date, a time, and the zone the owner was in

**Why rejected:** The zone of a past Meeting answers no question the app asks. The owner already
knows where they were. It is a third column that only ever appears in a debugger.

### Let the Dial read the optional time when it is there

**Why rejected:** The Bead's place would then depend on whether the owner filled in a field. Two
Friends seen on the same afternoon would sit apart for a reason the screen cannot show.

### Store `lastMet` as a column instead of deriving it

**Why rejected:** Already rejected by [ADR-0016](0016-derive-lastmet-from-meetings.md), and nothing
here changes that reasoning.
