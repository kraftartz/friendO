# ADR-0008: Store cadence as a duration, derive the orbit

**Status:** Accepted
**Date:** 2026-09-07

## Context

Each friend has a cadence. You want to see family weekly, friends monthly, colleagues quarterly.

The dial shows three orbits. Close friends orbit on a small orbit. Distant friends orbit on a large
orbit. Three orbits and three example cadences line up neatly, which suggests storing an orbit per
friend.

That neatness is a trap. It ties the stored data to today's picture of the screen.

## Decision

Store cadence as a **duration**, for example 30 days. Do not store an orbit or a tier.

Work out the orbit when drawing:

```
orbit(cadence) = inner   when cadence <= 14 days
                middle  when cadence <= 60 days
                outer   otherwise
```

The domain speaks in days. The UI speaks in orbits.

## Consequences

### Positive

- A user can pick any cadence. Every 10 days works. Every 45 days works. No new orbit is needed.
- Changing the orbit boundaries is a one-line change. It touches no stored data and needs no
  migration.
- Adding a fourth orbit later is a display change only.
- `phase` divides by cadence, so it needs a real duration anyway. Storing the duration keeps one
  source of truth.

### Negative

- Two friends on the same orbit may have different cadences. A user who reads the orbit as an exact
  value will be slightly wrong. The friend detail screen shows the real number.
- The bucket boundaries are arbitrary. They need tuning against real use, and there is no data yet.

## Alternatives Considered

### Store a tier enum: CLOSE, FRIEND, DISTANT

**Why rejected:** It welds the data model to the current screen design. A fourth orbit, or a tablet
layout with different orbits, would become a data migration. It also forces every user into three
cadences when the underlying idea is a free duration.

### Store both the duration and the tier

**Why rejected:** Two sources of truth for one fact. They drift apart, and then code has to decide
which one wins.
