# ADR-0034: A Bead travels its Orbit first, then steps across

**Status:** Accepted
**Date:** 2026-09-09

## Context

One tap moves a Bead. Two taps do it, and they are the two the app exists for.

A logged Meeting returns a Bead to 12:00. A Cadence change moves the Due Date
([ADR-0032](0032-a-cadence-change-moves-the-due-date.md)), and it can also move the Bead to another
Orbit, because `Cadence.orbit` splits at 14 and 60 days.

Neither move is small. A Friend last met 20 days ago sits near the start of the outer Orbit on a
Cadence of 90 days. Move them to 7 days and the same Bead belongs 13 days past its Due Date, in the
inner Beads Queue. It changes radius and angle together.

The Bead that the User touched is not the only one that moves. Both Orbits repack under
[ADR-0014](0014-dial-layout-and-bead-packing.md), so the Beads behind it shift as well. An Overflow
Badge can appear or go ([ADR-0015](0015-dial-overflow-treatment.md)). A prototype measured five to
six Beads changing place on one tap, out of thirty.

ADR-0032 recorded the risk in one line: the Dial must animate the move, or it reads as a fault. It
did not say what the movement is.

## Decision

### A Bead travels its own Orbit first, then steps across to the new one

The move has two stages. First the Bead travels along the Orbit it is on, to the angle it will
finish at. Then it moves across the gap to the new Orbit.

A Bead that keeps its Orbit has no second stage, so the same rule covers the common case. This is
why the rule is written in two stages rather than as two rules.

The other Beads travel along their own Orbits at the same time, because a repack only changes their
angle.

### A Meeting travels clockwise. A Cadence change takes the short way

A Meeting **completes** the lap, so its Bead carries on clockwise to 12:00. This is the loop the
product is built on: the Friend comes back to the top and starts again.

A Cadence change **rescales** the lap. Nothing was completed, so the Bead takes the shorter of the
two ways round.

### A Bead that a Meeting sends into Overflow rests at 12:00 first

On a crowded Orbit, a logged Meeting can push that Friend into the Overflow Badge. The packer sorts
by falling Phase, and a Friend met a moment ago holds a Phase of zero, so they sort last and the
Badge takes them. Measured in the prototype: `inner · 0.42` to `Overflow`, on one tap.

The Bead still travels to 12:00 and rests there for about one second. Then it collapses into the
Badge, and the count on the Badge rises.

The Dial must confirm the tap. Logging a Meeting is the one rewarding act in the app, and a Bead
that disappears the moment it is touched reads as a fault or a loss.

## Consequences

### Positive

- No Bead is ever dragged diagonally across an Orbit that holds other Beads. A travelling Bead
  covers whatever it passes over, and the two-stage path passes over nothing.
- One rule covers the Orbit change and the Meeting, so there is no boundary to get wrong.
- The direction carries the meaning. Clockwise says "the lap is done". The short way says "the
  ruler changed".
- The User always sees that the tap landed, including in the case where the Bead ends up hidden.

### Negative

- The two-stage path is longer than a straight one, so the movement takes longer to finish. It
  needs a duration that stays under about 600 ms, or the Dial feels slow.
- The rest at 12:00 before an Overflow collapse holds the Bead in a place the packer does not
  give it. For about one second the Dial is drawing a picture the packer disagrees with.
- Several Beads move at once. On a crowded Orbit this is a lot of motion for one tap, and it may
  need damping. There is no usage data yet.

## Alternatives Considered

### Travel: move the radius and the angle together

**Why rejected:** It drags the Bead across the Orbits between the two. Measured in the prototype:
halfway through the move, the travelling Bead sat on top of another Bead and hid it. The Dial is
crowded by design, so the path crosses occupied tracks whenever it is used.

### Cross-fade: fade out where it was, fade in where it belongs

**Why rejected:** It shows the two ends and not the move. The User sees a Bead go and another
arrive, and nothing says they are the same Friend. It also gives no help with the case this record
cares about most, where the Bead has to say that it is leaving.

### Snap: redraw the Dial, and animate nothing

**Why rejected:** This is what ADR-0032 already ruled out. Five or six Beads change place at once,
so a redraw reads as a glitch rather than as a result.

### Let the Badge take the next Friend, and never the newest Meeting

**Why rejected:** It is a special case inside the packer, and it makes the Overflow rule depend on
history rather than on Phase. The rest at 12:00 solves the same problem in the drawing, which is
where the problem is.
