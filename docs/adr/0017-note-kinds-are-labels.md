# ADR-0017: Note kinds are labels, and nothing clears itself

**Status:** Accepted
**Date:** 2026-09-08

## Context

The app holds three sorts of writing about a friend: a Topic to raise next time, an Update about
what changed in their life, and a plain Note.

A Topic looks forward, so it is tempting to clear it when you log a meeting. You raised it, so it
is spent. That would keep the Topic list short and let the pre-meeting screen show only open items.

That behaviour deletes the owner's writing on the app's own judgement.

## Decision

Keep Topic, Update, and Note as **labels** on one kind of record. The label changes how the app
groups and filters. It changes nothing else.

**The app never clears, archives, or hides a note by itself.** The owner deletes what has gone
stale.

## Consequences

### Positive

- Nothing the owner wrote disappears without them asking. A mistaken meeting entry cannot destroy
  notes.
- The rule is easy to hold in your head. There is no lifecycle to learn and none to debug.
- The model stays small. One record, one label field.

### Negative

- The Topic list grows without limit. Over time it stops meaning "what to raise next time" and
  starts meaning "everything I ever wanted to say".
- The pre-meeting view cannot show only open topics, because nothing marks a topic as closed.
- Tidying falls to the owner, and most owners will not tidy.

Sort topics newest first, so the stale tail sinks out of the way. If the growing list becomes a
real complaint, revisit this record. Add a manual tick before you add anything automatic.

## Alternatives Considered

### Clear topics when a meeting is logged

**Why rejected:** The app would delete the owner's words based on a guess about what happened. Log
a meeting by mistake and the notes are gone. This one is worth stating plainly, because it looks
like an obvious improvement and somebody will propose it again.

### Keep one freeform note and drop the labels

**Why rejected:** The three sorts were named in the brief because they serve different moments. A
single list loses the grouping that makes the pre-meeting read useful.
