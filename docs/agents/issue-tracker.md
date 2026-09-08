# Issue tracker: beads (`bd`)

Issues for this repo live in **beads**, a local issue tracker with a command line client. Run
`bd prime` for the full command reference; this file records only what the agent skills need.

Beads runs in **stealth mode**. Nothing under `.beads/` is committed, so the issues are local to
this machine. Do not run `bd dolt push`, and do not expect a teammate to see them.

Every command below was run against this repo on 2026-09-08 and does what this file says it does.

## Conventions

- One issue per unit of work. Create the issue before writing the code.
- Types: `bug`, `feature`, `task`, `epic`, `chore`, `decision`. `adr` and `dec` are aliases for
  `decision`.
- Priority is `0` to `4`, where `0` is critical and `2` is the middle. It is never `high`,
  `medium` or `low`.
- An id looks like `friendO-a3f`. A child id extends its parent: `friendO-a3f.1`.
- Set fields from the command line with `--title`, `--description`, `--design`, `--notes` and
  `--acceptance`.

**Never run `bd edit`.** It opens `$EDITOR` and the agent then waits for a person who is not
there. Use `bd update <id> --title=... --description=...` instead.

## When a skill says "publish to the issue tracker"

```bash
bd create --title="One line that says what this is" \
          --description="Why the issue exists and what has to happen" \
          --type=task --priority=2
```

Add `--acceptance="..."` when the skill asks for acceptance criteria, and `--design="..."` for a
decision that the issue records.

## When a skill says "fetch the relevant ticket"

```bash
bd show <id>          # one issue, with its dependencies
bd list --status=open # everything open
bd search "<text>"    # by text
bd ready              # open, unblocked, not in progress
```

## Wayfinding operations

Used by `/wayfinder`. The **map** is one epic. Its **tickets** are child issues of that epic.

- **Map**: an epic labelled `wayfinder:map`, holding the Destination, Notes, Decisions-so-far,
  Not-yet-specified and Out-of-scope body.

  ```bash
  bd create --type=epic --labels=wayfinder:map \
            --title="<the effort>" --description="<the map body>"
  ```

  Find it again with `bd list --label=wayfinder:map --flat`. Update the body in place with
  `bd update <map> --description="<new body>"`.

- **Child ticket**: an issue whose parent is the map. Label it `wayfinder:<type>`, one of
  `research`, `prototype`, `grilling`, `task`.

  ```bash
  bd create --parent=<map> --labels=wayfinder:grilling --no-inherit-labels \
            --title="<the question>" --description="## Question\n\n<the decision to resolve>"
  ```

  **`--no-inherit-labels` is not optional.** Without it a child inherits `wayfinder:map` from its
  parent, every ticket then answers the map query, and the map can no longer be found.

  List the map's tickets with `bd children <map>`, which includes the closed ones.

- **Blocking**: the native dependency. The first id is the ticket that waits.

  ```bash
  bd dep add <blocked-ticket> <blocking-ticket>
  ```

  `bd blocked` lists everything waiting. A ticket is unblocked when every ticket it depends on is
  closed.

- **Frontier**: open, unblocked and unclaimed children of the map, in priority order.

  ```bash
  bd ready --parent=<map> --unassigned
  ```

  One command covers all three tests. `bd ready` is blocker-aware and excludes `in_progress`, and
  `--unassigned` also drops a ticket that somebody assigned without claiming. Use
  `bd ready --parent=<map> --explain` to see why a ticket is held back. Add `--limit=<n>` to see
  more than the first ten.

  **`bd list --ready` is not the same thing.** It filters on status alone and ignores blockers.

- **Claim**: the session's first write, before any other work.

  ```bash
  bd update <ticket> --claim
  ```

  This sets the assignee to you and the status to `in_progress`, so the ticket leaves the frontier
  at once. It is idempotent when you already hold it.

- **Resolve**: comment with the answer, close, then write one line into the map's
  Decisions-so-far.

  ```bash
  bd comment <ticket> "<the answer>"
  bd close <ticket> --reason="<one line>"
  bd update <map> --description="<map body with the new Decisions-so-far line>"
  ```

- **Out of scope**: close the ticket, and record the gist and the reason in the map's Out-of-scope
  section.

  ```bash
  bd close <ticket> --reason="Out of scope: <why it sits past the destination>"
  ```

A ticket that carries a decision takes `--type=decision`. What that then obliges you to write is
the ADR process's business, not this file's. See [domain.md](domain.md).
