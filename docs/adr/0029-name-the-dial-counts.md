# ADR-0029: Name the Dial counts, and set their boundaries in Phase

**Status:** Accepted
**Date:** 2026-09-08

## Context

PRD 4.1 asks for "Live counts of Friends who are *near their Due Date*, *on track*, and *recently
met*". The designs draw them as `1 Nearing 12:00`, `4 In Orbit`, `2 Freshly Reset`.
`docs/feature-backlog.md` says the domain can return them and stores nothing new.

No document says where the boundaries fall. Is "near their Due Date" a Phase above 0.75, or a Due
Date within three days? Those give different answers for a weekly Friend and a quarterly one, which
is the same distinction [ADR-0009](0009-derived-phase-and-overdue-queue.md) was careful enough to
record for the Priority Order.

`CONTEXT.md` defines **Overdue** and nothing else in this family, and the app shows three more
states on its main screen. The project's own rule applies:

> If a needed word is missing, add it there first.

## Decision

### Four names, and every Friend has exactly one

`Standing` is the name for how far through their Cadence a Friend has reached. Phase gives the
number; Standing gives the name.

| Standing | Boundary |
|---|---|
| Freshly Reset | Phase below 0.25 |
| In Orbit | Phase from 0.25 up to 0.75 |
| Nearing | Phase from 0.75, up to and including the Due Date |
| Overdue | The Due Date has passed |

The four cover every Friend and never two at once, so the counts add up to the whole Dial. The
screen shows three of them beside the Beads Queue, which is the Overdue group drawn.

The last two split on a comparison of Civil Dates and not on a Phase, because
[ADR-0021](0021-civil-date-time-model.md) settles that a Friend is not Overdue on their own Due
Date. A Friend due today reads as Nearing with a Phase above 1, and their Bead rests at the top of
its Orbit.

### The boundaries are fractions of a Cadence, not counts of days

A Bead's place on the Dial **is** its Phase. A Phase boundary therefore means a count agrees with
what the owner sees: a Friend counted as Nearing is a Bead visibly near the top.

A day count would not. "Three days before the Due Date" is 43% of a weekly Cadence and 3% of a
quarterly one, so a quarterly Friend would be counted as Nearing while their Bead sat a long way
round. The screen would contradict the number printed above it.

### The counting lives in `friendo_domain`

`Standing.of` and `DialCounts` sit beside `phase`, because they are pure functions of the same
ordered list, with the same tests and the same absence of a clock. `PriorityOrder.counts` returns
them, so the Dial reads one object.

### The three names go in `CONTEXT.md`

`Freshly Reset`, `In Orbit` and `Nearing` become glossary entries beside `Overdue`, with their
avoided words. They are the designs' own words, they fit the Dial that the glossary already
describes, and inventing plainer ones would put a third vocabulary between the design and the code.

## Consequences

### Positive

- The three counts have one definition, written once, used by the Dial and the Directory.
- The numbers agree with the picture, because both are the same Phase.
- Changing a boundary is a one-line change in the domain with a test beside it. No row stores a
  Standing.
- `CONTEXT.md` covers the whole family, so the next screen that needs one of these words has it.

### Negative

- 0.25 and 0.75 are arbitrary. They are round, and there is no usage data. They need tuning, which
  is the same honest position [ADR-0008](0008-cadence-as-duration.md) takes about its Orbit
  boundaries.
- Freshly Reset lasts a day and a half on a weekly Cadence, and three weeks on a quarterly one. That
  is what proportional means, and an owner may still find it surprising.
- Four names is one more than the PRD asked for. Overdue was already defined, so the fourth is a
  name for something that existed rather than a new state.

## Alternatives Considered

### Boundaries in days, for example "due within 3 days"

**Why rejected:** It reads well in a sentence and it disagrees with the Dial. A quarterly Friend
would be counted as Nearing with their Bead a quarter of the way round. The count and the picture
must be the same fact.

### Three states, with Overdue folded into Nearing

**Why rejected:** Overdue is the state the app exists to surface, and `CONTEXT.md` already defines
it. Hiding it inside a larger count would make the most important number the hardest to read.

### Let the UI decide the boundaries

**Why rejected:** The Directory shows the same counts as the Dial. Two screens would drift, and the
rule is a pure function of the same ordered list, which is what the domain package is for.

### Plainer names, such as Recent, Middle and Due Soon

**Why rejected:** The designs, the PRD and `CONTEXT.md` already share one vocabulary built on the
Dial. A third set of words would need translating at every boundary between design and code, which
is the cost the glossary exists to remove.
