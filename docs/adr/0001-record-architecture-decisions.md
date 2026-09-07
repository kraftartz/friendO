# ADR-0001: Record architecture decisions

**Status:** Accepted
**Date:** 2026-09-07

## Context

friendO starts as an empty repository. The first weeks set many choices. Some are cheap to change.
Some are very expensive. Encryption and storage are in the second group.

One person builds this app, in evenings, over a long time. Work stops and restarts. A choice made
in September is a mystery by March. The code shows *what* was built. The code never shows *why*
one option won over another.

A choice with no written reason turns into a rule nobody dares to touch.

## Decision

Write one Markdown file per decision. Keep the files in `docs/adr/`. Number them in order.

Use this shape: Context, Decision, Consequences, Alternatives Considered.

Always list the options that lost, and say why they lost. That section is the point of the record.

Treat a record as history. Do not edit an accepted record to match a new opinion. Write a new
record and mark the old one `Superseded`.

## Consequences

### Positive

- A future reader sees the reason, not just the result.
- A rejected option stays rejected. Nobody re-argues it from scratch.
- A record shows when a reason has expired. The app can then change on purpose.
- Writing the record forces the choice into words. Weak reasons show up fast.

### Negative

- Every real decision costs extra writing time.
- Records go stale if nobody marks them `Superseded`.
- There is a risk of writing records for choices too small to matter.

## Alternatives Considered

### Comments in the code

**Why rejected:** A comment explains one file. It cannot explain a choice that spans the app, such
as "no network". Comments also die in refactors.

### One large design document

**Why rejected:** People edit a design document in place. The old text disappears. You end up with
the current plan and no history of why it changed.

### Write nothing

**Why rejected:** The author works alone across long gaps. Memory is the thing that fails first.
