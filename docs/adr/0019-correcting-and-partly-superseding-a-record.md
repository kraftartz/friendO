# ADR-0019: Correct a record in place, and supersede one in part

**Status:** Accepted
**Date:** 2026-09-08

## Context

[ADR-0001](0001-record-architecture-decisions.md) gives one rule for changing a record:

> Do not edit an accepted record to match a new opinion. Write a new record and mark the old one
> `Superseded`.

That rule is right for an opinion. It fits two other cases badly, and both have already happened.

**A wrong number.** `docs/feature-backlog.md` instructs "Orbit radii: 62 / 102 / 142 versus
60 / 100 / 140 — Correct ADR-0014". One measurement in ADR-0014 is mistyped. The reasoning around
it is correct. Superseding the whole record would bury good reasoning to fix a typing mistake, and
a reader would then have to hold two files in their head to learn one number.

**One sentence out of many.** [ADR-0022](0022-one-repository-per-aggregate.md) changes a single
sentence of [ADR-0004](0004-pure-domain-core-feature-shell.md). The rest of ADR-0004 stands, and it
is quoted approvingly elsewhere. Marking the whole record `Superseded` would tell a reader to
ignore a page that is still the best statement of the design.

With no third and fourth option, either the backlog's instruction or ADR-0001 gets broken quietly.

## Decision

Add two routes beside the existing one.

**A factual correction may be edited in place.** A fact is a number, a package name, a file path,
an API level, or a quotation. It is not a choice and it is not a reason. Mark the edit in the
header, with the date and what changed:

```markdown
**Date:** 2026-09-07. Encryption mechanism revised 2026-09-08.
```

[ADR-0005](0005-drift-and-encrypted-sqlite.md) already writes its header this way. This makes that
pattern the rule.

**A record may be superseded in part.** When a new record replaces some of an old one, name the
part in the old record's header and leave the rest standing:

```markdown
**Status:** Accepted. The repository sentence is superseded by ADR-0022.
```

The test between the two routes is one question: *does the change alter what somebody would
decide?* If it does, it is an opinion, and it needs a new record. If it does not, it is a fact, and
it may be corrected in place.

## Consequences

### Positive

- A mistyped number gets fixed where a reader will look for it.
- A record that is 95% right keeps saying so, instead of carrying a header that says "ignore this".
- The edit marker keeps the history honest. A reader sees that the file changed and when.
- `docs/feature-backlog.md` and ADR-0001 stop contradicting each other.

### Negative

- Someone has to judge which route a change takes, and the line is not always sharp. A wording
  change that alters a meaning is an opinion wearing a fact's clothes.
- An in-place edit loses the old text from the file. Git holds it, and nobody reads git for this.
- Three routes are harder to remember than one.

## Alternatives Considered

### Keep one rule and supersede for everything

**Why rejected:** It makes the index grow by one line for every typing mistake. It also gives the
reader of ADR-0014 no way to learn the right radius without opening a second file, which is the
cost the record format exists to remove.

### Correct facts silently, with no marker

**Why rejected:** It is the same as editing history. A reader who quoted the old number has no way
to learn that it moved.

### Add a `Amended` status

**Why rejected:** A status describes the whole record. These two cases are about a part of one. A
status would say less than the sentence it replaced, and a reader would still have to hunt for what
changed.
