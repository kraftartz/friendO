# ADR-0008: Store cadence as a duration, derive the ring

**Status:** Accepted
**Date:** 2026-09-07

## Context

Each friend has a cadence. You want to see family weekly, friends monthly, colleagues quarterly.

The dial shows three rings. Close friends orbit on a small ring. Distant friends orbit on a large
ring. Three rings and three example cadences line up neatly, which suggests storing a ring per
friend.

That neatness is a trap. It ties the stored data to today's picture of the screen.

## Decision

Store cadence as a **duration**, for example 30 days. Do not store a ring or a tier.

Work out the ring when drawing:

```
ring(cadence) = inner   when cadence <= 14 days
                middle  when cadence <= 60 days
                outer   otherwise
```

The domain speaks in days. The UI speaks in rings.

## Consequences

### Positive

- A user can pick any cadence. Every 10 days works. Every 45 days works. No new ring is needed.
- Changing the ring boundaries is a one-line change. It touches no stored data and needs no
  migration.
- Adding a fourth ring later is a display change only.
- `phase` divides by cadence, so it needs a real duration anyway. Storing the duration keeps one
  source of truth.

### Negative

- Two friends on the same ring may have different cadences. A user who reads the ring as an exact
  value will be slightly wrong. The friend detail screen shows the real number.
- The bucket boundaries are arbitrary. They need tuning against real use, and there is no data yet.

## Alternatives Considered

### Store a tier enum: CLOSE, FRIEND, DISTANT

**Why rejected:** It welds the data model to the current screen design. A fourth ring, or a tablet
layout with different rings, would become a data migration. It also forces every user into three
cadences when the underlying idea is a free duration.

### Store both the duration and the tier

**Why rejected:** Two sources of truth for one fact. They drift apart, and then code has to decide
which one wins.
