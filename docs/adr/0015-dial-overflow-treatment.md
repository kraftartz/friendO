# ADR-0015: Handle beads that do not fit on a ring

**Status:** Proposed
**Date:** 2026-09-07

## Context

[ADR-0014](0014-dial-layout-and-bead-packing.md) packs beads with a gap between them. Each ring
therefore holds a limited number: about 11 inner, 19 middle, 27 outer.

The app allows about 100 friends. Most people will stay under the per-ring limits. Eleven close
friends is already a lot. So this is a graceful-degradation problem, not a common one.

It still needs an answer. A user who ignores the app for a year will have every friend overdue at
once.

The choice is open. This record exists to hold the problem in view.

## Decision

**Not decided yet.** Four options are on the table.

The packer already returns the beads that did not fit, so every option below reads the same data.
No option changes the domain. All four are layout and interaction only. That is why this decision
can wait with no cost.

### Interim behaviour for the first version

Drop the beads that do not fit. The packer walks in priority order, so the ones that fall off are
the least urgent people, seen most recently. This needs no new code and no new concept.

## Options

### 1. Stack the extra beads and open a list on tap

Group the beads that do not fit into one marker. Tapping it lists who is inside. This is the usual
map-marker cluster pattern. Everyone stays represented.

**Cost:** medium. Needs cluster drawing and a list sheet.

### 2. Drop the beads that do not fit

The interim behaviour above, kept as the final answer. The dial shows who matters now and hides the
rest.

**Cost:** none. It falls out of the priority order.

### 3. Draw the extra beads as small dots

Keep everyone on the dial, but draw the overflow as plain dots without an avatar. Identity is lost,
presence is kept.

**Cost:** low. Needs a second bead style.

### 4. Add a zoom mode

Let the user pinch to zoom into the dial and see everyone with full spacing. A 3D view, with the
friends drawn as planets in space, would fit the theme.

**Cost:** high. It is a feature, not a fix.

## Consequences

Deciding late costs nothing here, because the packer already produces the overflow set and the
domain is untouched by all four options.

Shipping the interim behaviour has one real risk. A user with 30 close friends will see some of
them disappear with no explanation. Show a count somewhere, even in the first version.

## Note

Do not build seams for option 4 now. It may turn out to be the best answer, and building for it
before it is chosen is exactly the speculative work this project should avoid. When it is chosen,
it reads the same overflow set as the others.
