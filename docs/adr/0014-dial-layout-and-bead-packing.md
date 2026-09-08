# ADR-0014: Pack beads per orbit, not across the whole dial

**Status:** Accepted
**Date:** 2026-09-07

## Context

[ADR-0009](0009-derived-phase-and-overdue-queue.md) gives one ordered list of friends. Overdue
friends stop at 12:00. The UI must now place beads on three orbits.

Two problems appear.

**Beads overlap.** Several overdue friends all want 12:00. Beads have a size, so they need space
between them.

**Space differs per orbit.** The design fixes the geometry. The dial is a 340x340 square. The
three orbit radii are 62, 102 and 142. Beads are 28px avatars. Add 4px of padding between them:

| Orbit | Radius | Circumference | Beads that fit | Arc needed per bead |
|---|---|---|---|---|
| Inner | 62px | 390px | 12 | 59 dial-minutes |
| Middle | 102px | 641px | 20 | 36 dial-minutes |
| Outer | 142px | 892px | 27 | 26 dial-minutes |

Those numbers rule out one tempting idea. A rule such as "one queue slot equals one day equals one
minute of arc" would sound like a domain rule. The geometry needs 59 minutes on the inner orbit and
26 on the outer. No business reason could ever explain those two numbers. Spacing is geometry, and
geometry belongs to the UI.

## Decision

Keep the ordering in the domain. Keep the spacing in the UI.

Take the ordered list. Split it by orbit with a **stable** partition, so each orbit keeps the global
order. Then pack each orbit on its own:

```
for each orbit r:
    members = orderedFriends where orbit == r
    cursor  = 1.0                              # 12:00, in phase units
    for f in members:
        placed(f) = min(phase(f), cursor)
        cursor    = placed(f) - minGap(r)      # gap for THIS orbit
```

`minGap(r) = (beadDiameter + padding) / circumference(r)`.

The packer returns two things: the placed beads, and the beads that did not fit. See
[ADR-0015](0015-dial-overflow-treatment.md).

**Use one bead size on every orbit.** All beads are 28px. Bead size buys arc, and the outer orbit
needs arc most: it holds the longest cadences, so it holds the most friends. A larger bead on the
outer orbit spends capacity where capacity is scarcest. One size also keeps `minGap` a function of
the radius alone.

Mark the globally first friend with **emphasis**, not with position. Use a glow or a highlight
orbit. Do not move the bead to show priority.

## Consequences

### Positive

- One expression, `min(phase, cursor)`, gives both behaviours. Overdue beads clamp to 12:00. An
  on-track bead that catches the queue slows into the back of it. Overdue needs no special case.
- A stable partition of a sorted list means orbit order can never contradict global order. That
  holds by construction, so no test has to guard it.
- A friend who is first on their orbit parks at 12:00 on that orbit. Orbits do not compete for space
  they do not share.
- Orbit-local gaps roughly quintuple capacity, from about 12 beads to about 59.
- The packer is a pure function of friends, `now`, and geometry. It tests without a widget tree.

### Negative

- Up to three beads sit at 12:00, one per orbit. Only one is the true next friend. The highlight
  must carry that difference, and a user may miss it.
- `minGap` depends on real measurements. Change the avatar size and the packing changes. The
  numbers above come from the design. Measure them again if the dial is resized.
- The layout runs three passes instead of one. At this data size the cost is nothing.

## Alternatives Considered

### One global cursor across all orbits

**Why rejected:** It was proposed and it is wrong. A lone overdue friend on the outer orbit would be
pushed several slots back from 12:00 because unrelated beads on other orbits outrank it. That friend
is first on their orbit and belongs at the top of it. Orbits are separate tracks, so there is no
overlap to avoid and no reason to spend arc avoiding it. Position already carries time. Global
priority belongs on a different channel.

### Put slot spacing in the domain as "one meeting per day"

**Why rejected:** The rule would need a different number per orbit, tuned by avatar size and screen
width. A domain rule that changes when the avatar grows is a layout constant in disguise. As a
product feature, a one-per-day catch-up plan is worth considering on its own merits. It is deferred,
and it is not a layout mechanism.

### Give overdue friends their own orbit outside the others

**Why rejected:** It removes crowding and it mixes orbits together. It also loses the look
the product owner wants, where beads park on the orbit they already travel.
