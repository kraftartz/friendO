# ADR-0015: Handle Beads that do not fit on an Orbit

**Status:** Accepted. [ADR-0034](0034-how-a-bead-moves.md) adds one rule. A Bead that a
Meeting sends into the Overflow rests at 12:00 first. The Overflow Badge does not change.
**Date:** 2026-09-09

Opened as `Proposed` on 2026-09-07. Decided on 2026-09-09, against the prototype in
`docs/prototypes/dial-overflow.html`.

## Context

[ADR-0014](0014-dial-layout-and-bead-packing.md) packs Beads with a gap between them. Each Orbit
therefore holds a limited number: 12 inner, 20 middle, 27 outer. That is 59 Beads in total.

**The app allows about 100 Friends. The Dial holds 59.** A full roster cannot fit, whatever the
Phases are. This is not only a queue problem that appears after a long absence. It is a ceiling.

Most Users stay under the per-Orbit limits. Twelve close friends is already a lot. So a normal
roster still fits, and Overflow stays rare.

It still needs an answer. Two cases reach it. A User who ignores the app for a year has every
Friend Overdue at once. A User who fills the roster passes the ceiling even while up to date.

The packer already returns the Overflow set, so the domain side is done. The open question was what
the User sees.

### What the prototype found

The four options below all looked possible on paper. Two of them are impossible, and one drawing
shows why.

**Overflow means the lap is already full.** That is what Overflow is. The packer only reports it
after the cursor has walked the whole lap and passed the start point. So at the exact moment a
treatment wants to draw the Overflow, the Orbit has no free arc left.

Nor is there free radius beside the Orbit. The inner Orbit sits at radius 62 and its Beads are 28px
wide, so they span radius 48 to 76. The hub ends at radius 48. There is no gap.

Any treatment that needs its own space therefore fails, and it fails hardest on the inner Orbit,
which holds only 12 Beads and overflows first. The only space a treatment can spend is space the
Beads already own.

## Decision

**Take the last slot on a crowded Orbit and draw an Overflow Badge there.**

The Overflow Badge replaces the Bead that would have been last in the Beads Queue. It holds the
count of the Friends behind it, including the one it displaced. One Orbit carries at most one.

**A tap opens the Friends List, filtered to that Orbit.** It does not open a new sheet.

The Friends List already holds search, the Overdue banner in Priority Order, and the inline button
to log a Meeting. A Beads Queue with no room is a list of Friends, and the app already has the
screen for a list of Friends.

Nothing goes under the Dial. Three Overflow Badges already carry the count, and each one says
which Orbit it belongs to, which a single total cannot.

## Consequences

### Positive

- The Dial never lies. A full Orbit says so on the Orbit.
- The Overflow Badge reads as part of the instrument, not as an apology printed beneath it.
- It scales in both directions. Thirty close friends give one `+18` on the inner Orbit and change
  nothing else. A hundred Friends, all Overdue, give three Badges at the tail of three queues.
- It spends no new screen. The list it opens is a filter of a screen the app must build anyway.
- Overflow needs no new domain concept. The packer already returns the set.

### Negative

- The Overflow Badge costs one real Bead. An Orbit that overflows by one draws a `+2` Badge rather
  than the Friend it displaced.
- A count is not a face. The User sees how many are missing, not who, until they tap.
- The Friends List filter must accept an Orbit that comes from the Dial. That is a small piece of
  wiring between two features, and `app/` owns it.

### Known and accepted

At 100 Friends, all Overdue, every Orbit is an unbroken ring of Beads and the emphasis on the first
Friend is lost in it. No treatment in this record repairs that, because the wall is made of the
Beads that fit, not of the Overflow. A roster that large is an edge case, and the picture is
accepted as it is.

## Alternatives Considered

### Draw the Overflow as small dots

Keep everyone on the Dial, but draw the Overflow as plain dots without an Avatar. Presence is kept,
identity is lost.

**Why rejected:** there is nowhere to put the dots. They cannot follow the Beads, because the lap is
full. Moved to a companion ring inside the Orbit, they render underneath the Beads: on the inner
Orbit that ring falls at radius 51, and the Beads already cover radius 48 to 76. The prototype draws
them, and they are invisible.

### Draw the Overflow as a band on the Orbit

Draw one arc inside the Orbit, as long as the queue would be. It shows the size of the backlog at a
glance and never runs out of room.

**Why rejected:** the same geometry. The band and its label are hidden behind the Beads. In the
prototype at 100 Friends, all Overdue, only a corner of the count survives.

### Drop the Overflow, and count it under the Dial

Draw 59 Beads and write "38 Friends are not on the Dial" underneath, with a button to show them.

**Why rejected:** it works, and it is the cheapest option. It was rejected on what it says. The Dial
looks complete and correct while it is neither, and the correction lives somewhere else on the
screen. A Badge on the Orbit puts the truth on the object that would otherwise mislead.

### Add a zoom mode

Let the User pinch to zoom into the Dial and see everyone with full spacing. A 3D view, with the
Friends drawn as planets in space, would fit the theme.

**Why rejected:** it is a feature, not a fix, and it is expensive. It stays available as a later
addition. It reads the same Overflow set as the chosen option, so choosing the Badge costs it
nothing.

## Note

Do not build seams for the zoom mode now. Building for it before it is chosen is exactly the
speculative work this project avoids.
