# The Dial

The main screen. It answers one question: who should I see next?

This spec covers the screen that [docs/architecture.md](../architecture.md) calls the product's
heartbeat. It reads the ranking that `friendo_domain` already builds, turns it into Beads on three
Orbits, and gives the User one tap to log a Meeting.

It follows nine records:

| Record | What it settles here |
|---|---|
| [ADR-0008](../adr/0008-cadence-as-duration.md) | The Orbit is derived from the Cadence. Nothing stores one. |
| [ADR-0009](../adr/0009-derived-phase-and-overdue-queue.md) | Nothing stores an angle. Overdue Beads stop at 12:00. |
| [ADR-0014](../adr/0014-dial-layout-and-bead-packing.md) | The geometry, the packer, and the capacity of each Orbit. |
| [ADR-0015](../adr/0015-dial-overflow-treatment.md) | The Overflow Badge takes the last slot, and a tap opens the Friends List. |
| [ADR-0021](../adr/0021-civil-date-time-model.md) | Overdue compares two Civil Dates. A Friend is not Overdue on their Due Date. |
| [ADR-0028](../adr/0028-priority-order-as-two-groups.md) | The ranking arrives as two groups, already sorted. |
| [ADR-0029](../adr/0029-name-the-dial-counts.md) | The four Standings, and where their boundaries fall. |
| [ADR-0032](../adr/0032-a-cadence-change-moves-the-due-date.md) | A Cadence change moves the Bead, and can move its Orbit. |
| [ADR-0034](../adr/0034-how-a-bead-moves.md) | How a Bead travels when it moves. |

It sits on top of [docs/spec/boot-and-data.md](boot-and-data.md), which gives it an open
connection, a repository contract and a lock. It does not repeat those rules; it obeys them.

## Problem Statement

The User has a roster of Friends and a Cadence for each one. The two stored facts, the Cadence and
the Meetings, answer the question the User actually has, but they answer it as arithmetic. Nobody
reads arithmetic to decide who to phone this evening.

Four things go wrong without the screen.

**The answer is invisible.** `PriorityOrder` ranks every Friend correctly and nothing draws it. The
User cannot see who became Overdue first, or who is one day from their Due Date.

**A list would not carry it either.** A list says who is late. It does not say how late, or how far
through a lap somebody is, or that two Friends on different Cadences are in the same state. The
product is a loop, and a loop needs a picture of a loop.

**Logging a Meeting is the one thing the User does often.** If it takes a search, a screen and a
date picker, it will not happen, and a roster nobody updates is a roster that lies.

**A crowded roster hides the person who matters.** Fifty-nine Beads fit. About a hundred Friends
are allowed. Something must say so on the screen rather than quietly leaving people out.

## Solution

One round screen. Three Orbits, drawn as debossed troughs. Every Friend is a Bead on the Orbit that
their Cadence puts them on, at the angle their Phase puts them at, clockwise from 12:00.

12:00 means "due now". A Bead that reaches it stops there and joins the Beads Queue behind the ones
already resting. A soft conic glow warms the last quarter of the lap, so a Friend who is Nearing
looks like a Friend who is Nearing.

Three counts sit beside the Dial: Nearing, In Orbit, Freshly Reset. The fourth Standing needs no
chip, because the Overdue Friends are the Beads Queue and the User is looking straight at it.

One Bead carries emphasis: the Friend at the head of the Priority Order. A button under the Dial
names that Friend and logs a Meeting with them in one tap. A tap on any other Bead names that
Friend and offers the same.

When an Orbit runs out of room, the last slot becomes an Overflow Badge holding a count. A tap on
it opens the Friends List, filtered to that Orbit.

## User Stories

### Reading the Dial

1. As a User, I want to open the app and see every Friend at once, so that I can judge the state of
   my friendships without reading a list.
2. As a User, I want a Friend's Bead to sit further round the Dial the longer it has been since we
   met, so that distance from the top means the same thing for everybody.
3. As a User, I want a Friend on a short Cadence to travel an inner Orbit, so that a quick lap looks
   like a quick lap.
4. As a User, I want the top of the Dial to mean "due now" and nothing else, so that I never have to
   ask what 12:00 means on this screen.
5. As a User, I want the last quarter of the lap to glow, so that I can see who is close to their
   Due Date without counting days.
6. As a User, I want the glow to start where the Nearing count starts, so that the picture and the
   number beside it never disagree.
7. As a User, I want empty Orbits to be drawn as troughs, so that the Dial reads as an instrument
   rather than as a screen that failed to load.
8. As a User, I want two Friends I saw on the same day to sit at the same place on their Orbit, so
   that the Dial does not reward me for filling in a time of day.

### Who to see next

9. As a User, I want exactly one Bead to carry emphasis, so that I know who the app would have me
   see next.
10. As a User, I want that emphasis to be a glow rather than a change of place, so that the Bead
    still tells me the truth about its Phase.
11. As a User, I want an Overdue Friend to come before every on-track Friend, so that the person I
    have let slip is never ranked below somebody I saw last week.
12. As a User, I want the oldest Due Date to win among Overdue Friends, so that the ranking follows
    the calendar rather than a fraction I cannot see.
13. As a User with nobody Overdue, I want the Friend closest to their Due Date to carry the
    emphasis, so that the screen still names somebody.
14. As a User with three Beads resting at 12:00 on three Orbits, I want to see which one is the
    real next Friend, so that the top of the Dial does not present three equal answers.

### The Beads Queue

15. As a User, I want an Overdue Bead to stop at 12:00 rather than keep travelling, so that a Friend
    I have neglected for a month cannot draw beside one I saw yesterday.
16. As a User, I want the Beads Queue to rest in Priority Order, so that the Bead nearest the top is
    the Friend I should see first.
17. As a User, I want a Friend whose Due Date is today to rest at the top with the queue, so that the
    day the Meeting is wanted looks like the day the Meeting is wanted.
18. As a User, I want that Friend to still count as Nearing rather than Overdue, so that the app does
    not call me late on the day itself.
19. As a User, I want an on-track Bead that catches the back of the queue to slow into it, so that
    Beads never overlap and the queue never has a gap in it.

### When an Orbit is full

20. As a User with more Friends than an Orbit can hold, I want the Orbit to say so on the Orbit, so
    that the Dial never looks complete while it is not.
21. As a User, I want the Overflow Badge to hold a count, so that I know how many Friends are behind
    it.
22. As a User, I want a tap on the Overflow Badge to open the Friends List filtered to that Orbit,
    so that I can see the faces the Dial had no room for.
23. As a User, I want at most one Overflow Badge per Orbit, so that a full Dial does not turn into a
    row of counters.
24. As a User whose roster fits, I want no Badge at all, so that the normal case carries no apology.

### Logging a Meeting

25. As a User, I want one tap to log a Meeting with the Friend the Dial names as next, so that the
    thing I do most often is the cheapest thing on the screen.
26. As a User, I want the button to carry that Friend's name, so that I can never log a Meeting with
    somebody I did not mean.
27. As a User, I want a tap on any Bead to name that Friend and offer the same log, so that I can
    record a Meeting with anybody without leaving the Dial.
28. As a User, I want the logged Meeting to fall on today, so that the fast path stays fast.
29. As a User, I want a Meeting on an earlier day to be somebody else's screen, so that the Dial does
    not grow a date picker.
30. As a User, I want the Bead to return to the top the moment I log, so that the tap has an obvious
    result.
31. As a User with no Friends yet, I want the button to invite me to add the first one, so that an
    empty Dial still offers the next step.

### How a Bead moves

32. As a User who has just logged a Meeting, I want the Bead to carry on clockwise to 12:00, so that
    the lap looks completed rather than rewound.
33. As a User who has changed a Cadence, I want the Bead to take the shorter way round, so that a
    change of ruler does not look like a lap that happened.
34. As a User, I want a Bead that changes Orbit to travel its own Orbit first and then step across,
    so that it never drags over the Beads in between.
35. As a User, I want the other Beads to move at the same time, so that the repack reads as one
    result rather than as a sequence of jumps.
36. As a User whose logged Meeting pushes that Friend into the Overflow, I want the Bead to rest at
    12:00 for a moment before it collapses into the Badge, so that my tap is confirmed before the
    Friend disappears.
37. As a User, I want the movement to finish quickly, so that the Dial does not feel slow on the one
    action I repeat.

### The counts

38. As a User, I want three counts beside the Dial, so that I can read the shape of my roster
    without counting Beads.
39. As a User, I want the counts to add up to every Friend I have, so that I can trust them.
40. As a User, I want a count to agree with the picture, so that a Friend counted as Nearing is a
    Bead I can see near the top.
41. As a User, I want the counts to follow a logged Meeting at once, so that the numbers and the
    Beads never describe two different moments.

### Time passing

42. As a User who leaves the app open past midnight, I want a Friend who became Overdue to be drawn
    as Overdue, so that the screen does not hold yesterday's answer.
43. As a User who returns to the app after a week, I want the Dial to be correct on arrival, so that
    nothing has to run in the background to keep it true.
44. As a User who flies to another zone, I want the Dial to stay readable, so that a Bead does not
    jump because a plane did.

### Privacy

45. As a User whose Profile locks, I want the Dial to hold nothing, so that no Friend is drawn behind
    the PIN screen.
46. As a User who unlocks again, I want the Dial to come back with fresh data, so that I do not have
    to leave the screen and return to it.
47. As a User, I want a quiet Dial during a lock to look different from a Dial with no Friends, so
    that the app never tells me my roster is empty when it is only closed.

## Implementation Decisions

### What the Dial reads, and what it must never read

The Dial needs one row per Friend: the id, the name, the Avatar seed, the Cadence, and the date of
that Friend's newest Meeting. Nothing else.

That is a read model, not the aggregate.
[ADR-0022](../adr/0022-one-repository-per-aggregate.md) already draws the line: "A read that only
draws does not load the aggregate." Loading a hundred Friends with their Meetings, Notes, Facts,
Affinities and Milestones to draw a hundred dots would read most of the database to fill in 59
circles.

**A Dial query never selects a BLOB.** The Avatar photo and the audio recap are BLOB columns in the
same file ([ADR-0026](../adr/0026-attachments-as-blobs-and-a-framed-backup.md)), and a list query
that pulls them reads megabytes to draw thumbnails. The rule is already written in
[docs/feature-backlog.md](../feature-backlog.md); this screen is the first place it binds.

**In v1 a Bead draws an initial and a colour.** No photo is loaded. The Avatar seed is the Friend's
id, so the colour is stable and needs no stored column. When photos land, they load per Bead through
a separate read, and the Dial's own query does not change.

`lastMet` is `max` of that Friend's Meeting dates
([ADR-0016](../adr/0016-derive-lastmet-from-meetings.md)). The repository works it out in SQL and
returns one date per Friend. It does not return the Meetings.

### The domain is already finished, and this spec adds nothing to it

`Placing`, `PriorityOrder`, `Standing` and `DialCounts` exist and are tested. The Dial builds one
`Placing` per row with one `now`, hands the lot to `PriorityOrder`, and reads `all`, `next` and
`counts` back.

**One `now` for the whole build.** Every `Placing` in one packing takes the same instant. Two
readings taken a millisecond apart would be indistinguishable on screen and would make a test that
compares two Beads flaky for no reason.

`now` comes from `core/time/`, which [docs/spec/boot-and-data.md](boot-and-data.md) already uses for
the auto-lock. Nothing on this screen calls `DateTime.now()`.

### The packer lives in the Dial feature, and it cannot live anywhere else

[ADR-0014](../adr/0014-dial-layout-and-bead-packing.md) is firm that spacing is geometry and geometry
belongs to the UI. Two other homes are ruled out by rules already in force:

- **Not `friendo_domain`.** The domain knows nothing about orbits, angles or pixels. `minGap` is a
  ratio of an avatar's width to a circumference, and no product rule could explain the number 59.
- **Not `friendo_ui`.** [ADR-0018](../adr/0018-ui-package-and-widgetbook.md) forbids that package
  from importing `friendo_domain`, and the packer's input is a list of `Placing`. The package holds
  treatments such as `SoftCard` and `AvatarHalo`, never concepts.

So the packer sits in `features/dial/`, as pure Dart with no widget in it.
[ADR-0013](../adr/0013-testing-strategy.md) already names this layer and how to test it: "Dial
layout | Pure function over friends and geometry | `test` only."

### The packer

Input: the Priority Order, and the geometry. Output: for each Orbit, the Beads that fit with the
Phase each is drawn at, and the Overflow.

```
for each orbit r:
    members = orderedFriends where orbit == r      # stable partition
    cursor  = 1.0
    first   = none
    for f in members:
        placed = min(phase(f), cursor)
        if first is not none and placed < minGap(r) + first - 1:
            f joins the Overflow                   # the lap has closed
            continue
        if first is none: first = placed
        place f at placed
        cursor = placed - minGap(r)
```

Four things about it are easy to get wrong, so they are written here as well as in the record.

**The partition is stable.** Each Orbit then keeps the global order, and Orbit order can never
contradict Priority Order. It holds by construction, so no test guards it.

**The stop condition is not `cursor >= 0`.** Phase 1.0 and Phase 0.0 are the same place on the lap.
The last Bead has to keep a full `minGap` from the first one, measured the short way round. Stopping
at zero admits one Bead too many, and on the inner Orbit that Bead lands 6px from a Bead 28px wide.

**A placed Phase can be negative, and the angle is taken modulo one lap.** When the leading Bead on
an Orbit is not at 12:00, the cursor walks below zero and the queue wraps up past 12:00 on the other
side. That is correct: an Orbit is a circle. A painter that forgets the modulo draws those Beads off
the top of the Dial.

**A Phase above 1 clamps to 1.** `min(phase, cursor)` does it with no special case, which is why
Overdue needs no branch. A Friend due today has a Phase above 1 and rests at the top with the queue.

Geometry, from the design and from the record:

| Orbit | Radius | Circumference | Capacity | `minGap` |
|---|---|---|---|---|
| Inner | 62 | 390 | 12 | 59 dial-minutes |
| Middle | 102 | 641 | 20 | 36 dial-minutes |
| Outer | 142 | 892 | 27 | 26 dial-minutes |

`minGap(r) = (28 + 4) / circumference(r)`, in lap fractions. One lap is 720 dial-minutes, so a gap
in dial-minutes is that fraction times 720. The Bead is 28 units wide on every Orbit, because Bead
size buys arc and the outer Orbit needs arc most.

### The design size is 340, and the whole instrument scales

Nothing inside the Dial is measured in device pixels. The Dial is laid out at a design size of 340
and scaled uniformly to the width it is given.

This is not only tidiness. `minGap` is a ratio of a Bead's width to a circumference, so a uniform
scale leaves it unchanged, and **the capacities of 12, 20 and 27 hold on every phone**. Scaling the
radii while holding the Bead at 28 real pixels would change the capacity with the screen, and
ADR-0014's warning — "Measure them again if the dial is resized" — would come due on every device.

### The glow and the Nearing boundary are one number

The PRD asks for a conic glow over the last quarter of the lap, from 9:00 to 12:00.
[ADR-0029](../adr/0029-name-the-dial-counts.md) puts the Nearing boundary at Phase 0.75. Those are
the same place, because 9:00 is three quarters of the way clockwise from 12:00.

**The painter reads the boundary from the domain and never from a hand-tuned angle.** If the
boundary is ever tuned — and ADR-0029 says plainly that 0.25 and 0.75 are arbitrary and need tuning
— the glow moves with it. Two copies of that number would let the screen contradict the count
printed beside it, which is the exact failure ADR-0029 rejected day counts to avoid.

### Emphasis marks the next Friend, and position never does

`PriorityOrder.next` names one Friend. That Bead gets a glow. It does not move, does not grow, and
does not change Orbit.

ADR-0014 records the cost honestly: up to three Beads rest at 12:00, one per Orbit, and only one is
the true next Friend. The emphasis is the only thing that separates them. At a hundred Friends, all
Overdue, it is lost in a solid ring of Beads, and ADR-0015 accepts that picture as it is.

### The Overflow Badge

The Badge takes the last slot on a crowded Orbit, replacing the Bead that would have rested there.
It holds the count of the Friends behind it, **including the one it displaced**. It names no Friend
and carries no Avatar, because it is not a Bead.

A tap opens the Friends List filtered to that Orbit. It does not open a sheet of its own.

That filter is a piece of wiring between two features, and `app/` owns it. The Friends List is out
of scope here; what this spec fixes is the shape of the request: an Orbit, and nothing else.

### One tap logs a Meeting, and it always names the Friend

The button under the Dial carries the name of the Friend that `PriorityOrder.next` returns, and one
tap writes a Meeting with them, dated today.

A tap on any Bead opens a small sheet that names that Friend and offers the same log, plus a way to
open that Friend. The sheet belongs to the Dial. It is not the Friend Detail screen.

**No tap ever writes a Meeting for an unnamed Friend.** A button that logs for whoever happens to be
first, without saying who that is, would write the wrong row on a misread and the User would not
know it had happened.

With no Friends at all, the button invites the User to add the first one. An empty Dial is the
normal state after First Run, and it must offer the next step rather than a disabled control.

### Motion

[ADR-0034](../adr/0034-how-a-bead-moves.md) sets the movement. Three decisions turn it into
something buildable.

**The bloc holds no animation state.** It publishes successive packings. The view diffs the packing
it is drawing against the one that arrives and moves the Beads between them. A bloc that held "which
Bead is in flight" would hold a fact that a rebuild, a lock or a Profile switch could not restore,
and ADR-0025 requires a bloc to clear on lock — an in-flight movement across a lock is dropped, not
resumed.

**The cause travels with the state, because the diff cannot recover it.** A Bead moving from Phase
0.3 to Phase 0 is a completed lap when a Meeting caused it, and a rescale when a Cadence change did.
The two take opposite ways round. The state therefore carries what caused the newest packing: a
logged Meeting with a Friend id, a Cadence change with a Friend id, or nothing.

**A change the Dial did not cause takes the short way.** A Cadence edited on another screen arrives
through the watch stream with no cause attached. The User was not looking at the Dial when they made
it, so there is no lap to narrate, and the shortest path is the honest redraw.

The direction rule is a pure function of the two Phases and the cause. It is not buried in a widget:

| Cause | Way round |
|---|---|
| A logged Meeting | Clockwise, completing the lap |
| Anything else | The shorter of the two ways |

An Orbit change is two stages: travel the old Orbit to the finishing angle, then step across. A Bead
that keeps its Orbit runs the same rule with an empty second stage, so there is no boundary between
the common case and the rare one. The whole movement stays under 600 ms.

**A Bead that a Meeting sends into the Overflow rests at 12:00 for about one second, then collapses
into the Badge and raises its count.** For that second the Dial draws a picture the packer disagrees
with. That is deliberate and recorded: logging a Meeting is the one rewarding act in the app, and a
Bead that vanishes on touch reads as a fault.

### A Bead carries no permanent name label

The mockup in [docs/initial-design/dial/](../initial-design/dial/) draws a name under every Bead. It
draws five Beads.

A label is wider than the 28-unit Bead it belongs to, and the gap between two Beads is 4 units. On a
full inner Orbit the labels would overlap each other and the Beads on both sides. The name appears
on a tap, in the sheet that already names the Friend.

This joins the list of conflicts between the designs and the records in
[docs/feature-backlog.md](../feature-backlog.md), beside the spinning animation that the same file
already drops.

### Three counts, and why not four

`PriorityOrder.counts` returns all four Standings. The screen shows three of them: Nearing, In
Orbit, Freshly Reset.

The fourth needs no chip. The Overdue Friends are the Beads Queue, drawn at the top of the Orbits,
and the User is looking straight at them. ADR-0029 says this in one line: the screen shows three
"beside the Beads Queue, which is the Overdue group drawn."

One case deserves care. When an Overflow Badge swallows part of a queue, the Overdue Friends are no
longer all countable by eye. The Badge's own count carries them, which is what the Badge is for.

### When the Dial recomputes

Nothing keeps the Dial correct by running. That is ADR-0009's central promise, and it is why the
Dial is right after the phone sleeps for a month. Recomputing is therefore an event, not a tick:

| Trigger | Why |
|---|---|
| The watch stream emits | A Friend, a Cadence or a Meeting changed |
| The app resumes | Time passed while the app was away |
| The Profile unlocks | The stream comes back, per ADR-0025 |
| Local midnight passes while the Dial is open | A Friend can become Overdue with nothing else changing |

The last one is the only timer on this screen, and it is one timer to the next local midnight, not a
tick. Without it a Dial left open across midnight keeps yesterday's answer, and the Standing that
changes at midnight is exactly the one the app exists to surface. The timer is cancelled on lock and
on leaving the screen, and it re-reads rather than moving anything.

A Bead creeps by a fraction of a percent an hour, so no timer is needed to make the picture move.
[ADR-0021](../adr/0021-civil-date-time-model.md) chose midnight over whole days precisely so the
creep exists at all; it does not ask anything to animate it.

### Lock

The Dial obeys the contract in [docs/spec/boot-and-data.md](boot-and-data.md) and adds nothing.

The bloc listens to the connection state and **clears on lock**. No Friend, no name, no count and no
Avatar stays in memory behind the PIN screen. The watch stream goes quiet rather than failing, and
one subscription lives for the life of the screen.

**Locked and empty are different states, and the Dial draws them differently.** ADR-0025 names this
as the thing that goes wrong. An empty Dial invites the User to add their first Friend. A locked
Dial invites nothing, because there is nothing to say until the Profile is open.

### What draws what

The instrument is one painter: the three debossed troughs, the 12:00 axis, and the conic glow over
the last quarter. Those are one shape each and never take a tap.

**The Beads are positioned widgets, not painted circles.** They are the only things on the Dial that
take a tap, and they are the things that move. Hit testing and implicit animation both come free
from the framework, and 59 small widgets cost nothing at this size. The Overflow Badge is a widget
in the same way, in the slot the packer left for it.

`AvatarHalo` joins `friendo_ui` as one of the six treatments ADR-0018 names. It is a treatment, not
a concept: a circular surface with a halo whose colour is given to it. It knows nothing about
Friends, Cadence or Standing, so the boundary holds. It gets a Widgetbook use case, like `SoftCard`.

`DialView` and the Bead itself stay in `features/dial/`, because they are concepts.

The debossed trough runs into the open question ADR-0018 already recorded: Flutter's `BoxShadow`
has no inset field. A painter can draw an inner shadow directly, so the Dial does not wait for that
question to be settled elsewhere.

### What the Dial does not own

Routing. `friendO-njf` holds the open question of `go_router` against the current cubit, and this
spec neither settles it nor depends on the answer. The Dial produces two requests — open this
Friend, and open the Friends List filtered to this Orbit — and whatever routes them reads those
values.

## Testing Decisions

### What a good test looks like here

The Dial is a picture, and a picture is the worst thing to assert on. Every test below asserts on a
value that the screen is built from, not on pixels, and not on how the value was reached.

Three properties make that possible, and all three are already decided:

- `now` is an argument everywhere, so no test stubs a clock.
- The packer is a pure function, so Bead positions need no widget tree.
- The repository runs against a real drift engine, so no repository is mocked.
  [ADR-0013](../adr/0013-testing-strategy.md) rejected both mocks by name.

### One new seam: the Dial's state

Everything the screen draws is one value: the placed Beads per Orbit with the Phase each is drawn
at, the Overflow count per Orbit, the id of the Friend carrying emphasis, the three counts, the
cause of the newest packing, and whether the Profile is locked or the roster is empty.

A test builds the bloc over a **real repository on a real in-memory database** with a fixed `now`,
writes Friends and Meetings, and reads the state. That is one seam, and it covers the query, the
domain call, the packing and the lock behaviour together.

No second seam is added. The packer's own tests use the seam that
[ADR-0013](../adr/0013-testing-strategy.md) already named for this layer, and the widget tests use
`flutter_test` as the same record allows.

### Why the packer is tested directly as well

The numbers that ADR-0014 argues hardest about — 12, 20, 27, and the Bead that must not be admitted
— are reached by filling an Orbit. Proving them through the bloc means writing a hundred Friends
into a database to assert on one boundary.

The packer takes a list and returns a list. Its tests read as examples, and they pin the one rule
that a reader is most likely to simplify back into `cursor >= 0`.

### One golden, and what it may not be used for

ADR-0013 allows exactly one golden test, for the Dial. It is taken at a fixed `now` with a fixed
roster, and it guards the picture as a whole: the troughs, the axis, the glow, a queue at the top
and one Overflow Badge.

**It never guards a position.** The packer's tests own positions. A golden that fails when a Bead
moves teaches the reader to regenerate it, and a golden that is regenerated on reflex guards
nothing. ADR-0013 says this will be tempting to delete; it survives by testing only what no other
test can see.

### What to test

Numbered so that a ticket can name one.

**The packing**

1. A Friend on a Cadence of 7 days packs on the inner Orbit; 30 days on the middle; 90 on the outer.
2. One Friend on an Orbit, Overdue, rests at Phase 1.
3. One Friend on an Orbit, on track, rests at their own Phase.
4. Two Overdue Friends on one Orbit rest one `minGap` apart, in Priority Order.
5. An on-track Friend whose Phase falls inside the queue is pushed to the back of it.
6. A Friend due today rests at Phase 1 and is not Overdue.
7. Thirteen Friends on the inner Orbit place 12 and overflow 1.
8. Twenty-one on the middle place 20 and overflow 1. Twenty-eight on the outer place 27 and
   overflow 1.
9. Twelve on the inner place all 12, and the last keeps a full `minGap` from the first.
10. The thirteenth is refused because the lap has closed, not because the cursor reached zero.
11. A leading Bead below Phase 1 lets the queue wrap past 12:00, and the wrapped angles are taken
    modulo one lap.
12. An Orbit with no members returns no Beads and no Overflow.
13. Orbits do not compete: a lone Friend on the outer Orbit rests at the top of it while the inner
    Orbit is full.
14. The order within an Orbit matches the global Priority Order for every roster in the tests above.

**The state**

15. An empty roster gives an empty state, and it is not the locked state.
16. A locked Profile gives the locked state, and it holds no Friend.
17. Unlocking replays the query and fills the state without the screen being rebuilt.
18. The three counts equal the domain's counts for the same roster.
19. The counts plus the Overdue group equal the number of Friends.
20. The emphasised id equals `PriorityOrder.next`.
21. With nobody Overdue, the emphasised id is the highest on-track Phase.
22. With no Friends, there is no emphasised id and the state says so.
23. Logging a Meeting moves that Friend's Bead to Phase 0 and sets the cause to a logged Meeting
    with that Friend's id.
24. Logging a Meeting writes exactly one row, dated today.
25. A change arriving through the watch stream sets no cause.
26. A Cadence change made through the Dial sets the rescale cause with that Friend's id.
27. A Cadence change that crosses 14 or 60 days moves the Friend to another Orbit in the next state.
28. A Cadence change that puts the Due Date in the past makes the Friend Overdue in the next state.
29. A Friend pushed into the Overflow by a logged Meeting appears in the Overflow count, and the
    displaced Friend is counted in it.
30. Two states built from the same roster and the same `now` are equal.

**The direction rule**

31. A logged Meeting from Phase 0.3 travels clockwise, the long way.
32. A logged Meeting from Phase 0.9 travels clockwise, the short way, and both are clockwise.
33. A rescale from Phase 1.0 to Phase 0.22 takes the shorter way.
34. A rescale that shortens a Cadence takes the shorter way even when it crosses 12:00.
35. A move with no cause takes the shorter way.
36. A move that changes Orbit reports two stages; a move that does not reports one.

**The widgets**

37. A tap on a Bead names that Friend.
38. The log button carries the emphasised Friend's name.
39. The locked state draws no name, no initial and no count.
40. The empty state draws the invitation to add a Friend.
41. One golden of a fixed roster at a fixed `now`, with a queue and one Overflow Badge.

`tool/lint.sh` and `tool/test.sh` both pass.

## Out of Scope

**The Friends List.** The Overflow Badge opens it filtered to an Orbit. This spec fixes the shape of
that request and nothing else about the screen.

**Friend Detail, Add a Friend, and the Cadence picker.** A tap on a Bead offers to open a Friend.
What opens is another spec. [ADR-0032](../adr/0032-a-cadence-change-moves-the-due-date.md) puts the
preview of the result beside each Cadence in the picker, which is that screen's work; the Dial only
draws what the change did.

**Avatar photos.** Beads draw an initial and a colour in v1. Photos are BLOB columns
([ADR-0026](../adr/0026-attachments-as-blobs-and-a-framed-backup.md)) and load per Bead when they
land, which is why the Dial's own query is written to never select one.

**Reminders.** [ADR-0012](../adr/0012-opt-in-local-notifications.md) owns scheduling, and
`core/reminders/` watches the repository rather than the screen. Logging a Meeting from the Dial
reschedules because the repository writes, not because the Dial asks.

**Routing.** `friendO-njf` is open. The Dial produces two requests and routes neither.

**The zoom mode.** ADR-0015 keeps it available as a later addition and ends with an instruction this
spec obeys: "Do not build seams for the zoom mode now."

**Milestones on the Dial.** A Milestone does not move a Bead
([docs/feature-backlog.md](../feature-backlog.md)).

**Search, Orbit filter chips, and the Overdue banner.** They belong to the Friends List.

**Swipe between Orbits, and the tablet and desktop layouts.** [docs/DESIGN.md](../DESIGN.md)
describes them. One phone-sized Dial is v1.

**Undoing a logged Meeting.** Deleting a Meeting is an aggregate rule
([ADR-0022](../adr/0022-one-repository-per-aggregate.md)) and belongs with the screen that lists
Meetings.

## Further Notes

**Two issues have to land first.** `friendO-xdb` writes the Friend aggregate, and `friendO-fff`
gives this screen an open connection and a repository to ask. Neither edge is drawn against this
epic; draw them against the children, because an edge to an epic holds it blocked until every child
closes.

**The numbers in this spec are all arbitrary, and every record says so.** The Orbit boundaries at 14
and 60 days ([ADR-0008](../adr/0008-cadence-as-duration.md)), the Standing boundaries at 0.25 and
0.75 ([ADR-0029](../adr/0029-name-the-dial-counts.md)), and the capacities that follow from a 28px
Bead ([ADR-0014](../adr/0014-dial-layout-and-bead-packing.md)) all need tuning against real use, and
there is no usage data. Each is a one-line change with a test beside it, and none of them is stored
in a row.

**The crowded Dial is accepted as it is.** At a hundred Friends, all Overdue, every Orbit is an
unbroken ring and the emphasis on the next Friend is lost in it. ADR-0015 records that no treatment
in it repairs that, because the wall is made of the Beads that fit rather than of the Overflow.

**The motion may need damping.** ADR-0034 measured five or six Beads changing place on one tap out
of thirty, and notes that there is no usage data. Build the movement first and judge it on a device.

**The Dial is where the design and the records disagree most.** Three conflicts are already listed
in [docs/feature-backlog.md](../feature-backlog.md) — the spinning animation, the 57 slots against
59, and the 32px outer Bead against 28px everywhere. This spec adds a fourth: the name label under
every Bead. All four come from a mockup that draws five Friends.
