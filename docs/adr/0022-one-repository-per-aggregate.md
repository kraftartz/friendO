# ADR-0022: One repository per aggregate, kept in `core/`

**Status:** Accepted
**Date:** 2026-09-08

Supersedes one sentence of [ADR-0004](0004-pure-domain-core-feature-shell.md). The rest of that
record stands. See [ADR-0019](0019-correcting-and-partly-superseding-a-record.md).

## Context

[ADR-0004](0004-pure-domain-core-feature-shell.md) states two rules together:

> Each feature holds `bloc/`, `view/`, and a repository.
> A feature must not import another feature.

Read the PRD against them. The Friends List shows, on each card, the date of the last Meeting,
where it happened, the Topics waiting, and a one-tap button to log a Meeting. The Dial needs every
Friend's Meetings to work out `lastMet` at all, and carries its own one-tap logging.

So three features read Meetings and two of them write Meetings. Under the two rules that means
three repositories over the same tables, each with its own queries and its own row mapping.

**The rule that breaks first.** [ADR-0012](0012-opt-in-local-notifications.md) requires a reschedule
on every change to `lastMet` or `cadence`, and names the failure honestly:

> A missed path causes a wrong reminder, and that bug is hard to notice.

Three write paths, and no owner for the reschedule. The reminder switch lives in
`features/settings/`, so the scheduler would live there, and no other feature may import it.

**The deeper version.** [ADR-0016](0016-derive-lastmet-from-meetings.md) sets a rule that spans two
tables:

> Because creation always records one meeting, every friend always has at least one.

and

> Deleting the only meeting would empty `lastMet` again. Block that.

A rule that must hold across a Friend and that Friend's Meetings is an aggregate boundary. Friend is
the root. Meeting, Note, Fact, Affinity and Milestone have no life outside a Friend, and no screen
reaches one except through a Friend. Splitting that across `friends/` and `journal/` splits the
aggregate, and the rule then has nowhere to live except in whichever bloc happens to be running.

ADR-0004 saw this coming and accepted a review convention for it:

> Blocs can slowly collect logic that belongs in the domain. Nothing stops that automatically.
> Watch for it in review.

That is the one place in the whole record set where this project settles for review. Everywhere
else it argues the other way, and argues it well:

> A folder cannot fail to compile. "Widgets hold no BLoC" would stay a review convention, and
> review conventions decay. — [ADR-0018](0018-ui-package-and-widgetbook.md)

## Decision

Keep the feature rule. Move the seam.

### A repository is not feature-private

A repository belongs beside the tables it owns, in `core/`:

```
lib/core/
  db/          drift tables, SQLCipher setup, migrations, the connection owner
  friends/     FriendRepository — the whole aggregate: Friend, Meetings, Notes,
               Facts, Affinities, Milestones. One place that holds "at least one
               Meeting".
  reminders/   Watches the repository. Reschedules. Owned by nobody's feature.
```

`features/dial/`, `features/friends/` and `features/journal/` all depend on `core/friends/` and
never on each other. The feature rule survives, and it now means something, because shared data has
a legal place to live.

### One aggregate, one repository, whole loads and whole saves

`FriendRepository` loads a whole Friend and saves a whole Friend. There is no `MeetingRepository`,
because a Meeting is not an aggregate root and has no life of its own.

Each way of making a Friend gets its own named constructor. `Friend.hydrate()` is for rebuilding a
stored Friend and for nothing else. `Friend.started(...)` makes a new one, and it takes the first
Meeting, because [ADR-0016](0016-derive-lastmet-from-meetings.md) says a Friend cannot exist without
one.

### A read that only draws does not load the aggregate

The Friends List row wants a name, a date, a place and a Phase. Give it a read model: a plain value
returned by one query, with no aggregate built and no rule applied. `Placing` in `friendo_domain` is
one of these. A read model never comes back through `save`.

### Where a rule lives

Rules live in the aggregate. Blocs stay thin.

> **If an operation must hold a rule that spans more than one row, the domain owns it. Otherwise
> the bloc calls the repository.**

Three operations pass that test today:

| Operation | Rule | Written in |
|---|---|---|
| Add a Friend | Creation writes the first Meeting | ADR-0016 |
| Log a Meeting | The date is today or earlier; the reminder reschedules | ADR-0016, ADR-0012 |
| Delete a Meeting | Never leave a Friend with no Meeting | ADR-0016 |

`Friend` owns its Meetings and refuses to lose the last one. `deleteMeeting` cannot produce an
invalid Friend, because the method that would do it does not exist. The rule becomes unreachable
rather than guarded.

Everything else stays exactly as ADR-0004 says. Editing a Note's text is a plain call. Renaming a
Friend is a plain call. No use case class is written for either.

This costs three or four methods on one class. It does not bring back the forty classes that
ADR-0004 rejected, and that rejection still stands.

## Consequences

### Positive

- The "at least one Meeting" rule has one home, and it is the type that would break without it.
- The reminder reschedule has one owner. There is one write path to hook, not three.
- One row mapping, not three. Three mappings of the same table drift, and the drift shows as a bug
  in one screen only.
- "A feature must not import another feature" stops fighting the data model, so it will still be
  true in month six.
- Lists stay fast to write, because a read model needs one query and no rules.

### Negative

- `core/` grows. A reader looking for the Meetings code will look in `features/journal/` first.
  `docs/architecture.md` has to say plainly that it is not there.
- Loading a whole Friend to change one Note is more work than one `UPDATE`. At about 100 Friends
  with a handful of Meetings each this costs nothing. It would matter at a much larger size.
- Two shapes now exist for the same data, the aggregate and the read model. Somebody will use the
  wrong one. The rule "a read model never comes back through `save`" is the guard, and it is a
  review convention.
- ADR-0004 now needs a note in its header, and a reader has to follow one hop.

## Alternatives Considered

### Keep a repository per feature and share the table

**Why rejected:** Three repositories over one table means three row mappings and three write paths.
The "at least one Meeting" rule would then live in every bloc that can delete, which is the same as
living nowhere.

### Let features import each other when they share data

**Why rejected:** It removes the one rule that keeps the feature folders honest. Once `dial` may
import `journal`, nothing says which way the arrows point, and the map becomes a graph nobody can
draw.

### Put the repository in `friendo_domain`

**Why rejected:** The repository talks to drift. `friendo_domain` has no file access and no
database, and that boundary holds by compilation. Breaking it to save one folder would trade a
build error for a rule nobody enforces.

### Give Meeting its own repository

**Why rejected:** A Meeting has no life outside a Friend. Its own repository would be able to
delete the last one, which is exactly the state ADR-0016 forbids.

### Adopt Clean Architecture and write a use case per operation

**Why rejected:** Already rejected by ADR-0004, on reasoning this record does not reopen. The
answer here is three methods on one class, not forty classes.
