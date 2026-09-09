# ADR-0032: A change of Cadence moves the Due Date, and never the last Meeting

**Status:** Accepted
**Date:** 2026-09-09

## Context

The User picks a Cadence when they add a Friend, and they can change it later. No document says
what the change does to the Phase.

Take a Friend last met 20 days ago on a Cadence of 30 days. Their Phase is two thirds and their
Standing is In Orbit. The User moves them to 7 days. Two answers are possible. The Due Date fell 7
days after the last Meeting, so it passed 13 days ago and the Friend is Overdue at once. Or the new
Cadence counts from today, and the Friend starts a fresh lap.

The code already gives the first answer:

    phase = (now - midnight of lastMet) / cadence

The Cadence is a divisor and nothing else. `lastMet` is `max(dates of this Friend's Meetings)`,
which [ADR-0016](0016-derive-lastmet-from-meetings.md) settled. Nothing holds the start of a lap.

So the second answer is not a different reading of the same data. It needs data that does not
exist. That is what makes this a decision and not a preference.

A change of Cadence also moves a Friend between Orbits, because `Cadence.orbit` splits at 14 and 60
days. The Bead changes track as well as position.

[ADR-0012](0012-opt-in-local-notifications.md) reschedules a reminder when the Cadence changes.
This record says what it reschedules to.

## Decision

### The Cadence divides. It does not move the last Meeting.

The Due Date is one Cadence after the last Meeting. Change the Cadence and the Due Date moves. The
last Meeting stays, because it records a day that happened.

Three results follow, and the app accepts all three:

- A shorter Cadence can make a Friend Overdue at once. The Bead joins the Beads Queue and the
  Friend enters the Priority Order.
- A longer Cadence can end an Overdue at once. Twenty days on a Cadence of 90 days gives a Phase of
  0.22 and a Standing of Freshly Reset.
- The Bead moves to another Orbit when the new Cadence crosses 14 or 60 days.

Each one is a true statement about the friendship. A Cadence says how often the User wants to see a
Friend. If they want to see Kasia every week, and they last saw her 20 days ago, then they are
late. The app reports that. It does not soften it.

### The Cadence picker shows the result before the User commits

Beside each Cadence the picker shows what that Cadence gives: the Due Date and the Standing, for
example `Due 13 days ago · Overdue`. The User reads the consequence and then chooses.

There is no dialog and no confirmation step. A confirmation on the Overdue case only would teach
the User that Overdue is an error, which contradicts the first product principle: approaching 12:00
is an invitation, not a failure.

### A reminder for a Due Date in the past does not fire

When a Cadence change puts the Due Date in the past, cancel the old reminder and schedule none. The
Beads Queue and the Overdue banner already carry the Friend. A notification about a day that has
gone is noise.

## Consequences

### Positive

- No new stored field. The start of a lap stays derived from the Meetings, so the Meeting list
  remains the one source of truth.
- The edit is reversible. Set the Cadence back and every reading returns, because nothing was
  overwritten.
- The number means one thing on every screen: how often the User wants to see this Friend.
- The Friend who is genuinely neglected appears at once. That is the case the app exists for.

### Negative

- A Friend can become Overdue from an edit, not from time passing. That can feel like a
  punishment. The preview in the picker is the whole mitigation, so word it plainly.
- An Overdue can also be cleared from an edit. A User who dislikes a full Beads Queue can widen a
  Cadence until it empties. The app permits this on purpose. How often to see somebody is the
  User's judgement, and the app holds no opinion about the right answer.
- One tap can move a Bead across two Orbits and most of a lap. The Dial must animate the move, or
  it reads as a fault.

## Alternatives Considered

### Count the new Cadence from today

**Why rejected:** It needs a lap-start date stored beside the Meetings, or a Meeting written on a
day when nobody met. [ADR-0016](0016-derive-lastmet-from-meetings.md) rejected both shapes already.
The stored field is a second source of truth. The invented Meeting makes the app lie, which is the
same fault as its third rejected option.

It also breaks the plain meaning of the number. A Cadence of 7 days would not mean "see them every
week". It would mean "start a fresh week now", which is a different promise and a weaker one.

### Keep the Phase, and move the last Meeting to hold it

Two thirds of 30 days becomes two thirds of 7 days, so the last Meeting moves to 4.7 days ago.

**Why rejected:** It rewrites a Meeting to a day that did not happen, so it fails for the same
reason as the option above. The fraction is also not what the User cares about. Somebody who moves
Kasia to weekly wants to see Kasia weekly. They do not want to keep two thirds of a lap.

### Ask the User each time

**Why rejected:** The question has one honest answer, so the dialog would collect a preference for
an untruth. It also charges a tap on every Cadence edit, including the many that change nothing
important. The preview carries the same information for no tap.
