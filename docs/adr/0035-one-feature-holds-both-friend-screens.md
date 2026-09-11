# ADR-0035: One feature holds both Friend screens

**Status:** Accepted
**Date:** 2026-09-10

## Context

[docs/architecture.md](../architecture.md) sketched two feature folders: `features/friends/` for
"Add, edit, delete people", and `features/journal/` for "Meetings, notes, topics, what is new".
[ADR-0022](0022-one-repository-per-aggregate.md) names the same two, together with
`features/dial/`, as an example of the rule that no feature imports another.

Two screens write: Add a Friend, and the Friend Notepad. Both hold a Cadence picker, and it is the
same picker. [ADR-0032](0032-a-cadence-change-moves-the-due-date.md) requires it to show the Due
Date and the Standing each Cadence would give, so the widget reads `Cadence`, `Orbit`, `dueDateOf`
and `Standing`.

That fixes where it may live. [ADR-0018](0018-ui-package-and-widgetbook.md) forbids `friendo_ui`
from importing the domain, so the picker is not a treatment and cannot go there. A feature may not
import another feature, so it cannot sit in one folder and be used from the other.

The Notepad is also both folders on one screen. It draws the Cadence and the name, which is the
first folder, and the Meetings, Topics, Updates and Notes, which is the second.

## Decision

**`features/friends/` holds Add a Friend and the Friend Notepad. `features/journal/` is not
created.**

The Cadence picker is one widget inside one feature, used on two screens.

This changes an illustration in ADR-0022 and not its decision. That record decides that a
repository lives in `core/`, and this keeps it exactly: `core/friends/FriendRepository` remains the
only reader and writer of these tables. Merging the two folders leaves the no-cross-import rule
stronger, because the import that would have broken it can no longer be written.

## Consequences

**Good.** The picker has one home, and neither screen reaches into the other. The rule that a
feature imports no feature holds by having nothing to import.

**Good.** One bloc reads the whole aggregate for the Notepad, which is the load
[ADR-0022](0022-one-repository-per-aggregate.md) asks a writing screen for. Splitting the screen
would have meant two loads of one Friend on one build.

**Bad.** `features/friends/` is the largest feature folder. It holds two screens, their two states
and the picker they share. A reader looking for Meetings finds them under a folder named for
people.

**Bad.** The module map in `docs/architecture.md` and the example in ADR-0022 both named
`features/journal/`, and somebody reading either without this record could recreate it. That is
what this record exists to stop.

## Alternatives considered

**Two feature folders, and the picker duplicated.** Two copies of the arithmetic that ADR-0032
governs, in two files, with one of them going stale. The record's whole point is that the User
reads the consequence before choosing, and a stale second copy shows the wrong one.

**Two feature folders, and the picker in `friendo_ui`.** It would have to take a Due Date, a
Standing and three preset day counts as plain values, worked out by each caller. That moves the
domain call into both features rather than removing it, and it puts a concept in the package
ADR-0018 keeps for treatments.

**Two feature folders, and the picker in `core/`.** `core/` holds services below the feature layer.
A widget there would be the only one, and the layering would say that a screen may be built from
`core/`, which is a larger change than this problem needs.
