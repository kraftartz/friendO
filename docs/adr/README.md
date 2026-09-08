# Architecture Decision Records

Each file records one choice. Read the file before you change the choice it describes.

An ADR is a historical note. Do not rewrite a record to match a new opinion. Write a new record
instead and set the old one to `Superseded`.

Two changes take a shorter route. A **factual correction** may be edited in place, marked in the
header with the date and what changed. A record may be **superseded in part**, which names the
replaced part in its header and leaves the rest standing. The test is one question: does the change
alter what somebody would decide? See
[ADR-0019](0019-correcting-and-partly-superseding-a-record.md).

## Status meanings

| Status | Meaning |
|---|---|
| `Proposed` | The problem is known. The choice is not made yet. |
| `Accepted` | The choice is made. Build to it. |
| `Deprecated` | The choice no longer applies. Nothing replaced it. |
| `Superseded` | A newer ADR replaced this one. The newer ADR is named in the header. |

## Index

| # | Title | Status |
|---|---|---|
| [0001](0001-record-architecture-decisions.md) | Record architecture decisions | Accepted |
| [0002](0002-flutter-and-bloc.md) | Use Flutter and BLoC | Accepted |
| [0003](0003-offline-only-no-internet-permission.md) | Ship without the INTERNET permission | Accepted |
| [0004](0004-pure-domain-core-feature-shell.md) | Pure domain core, feature-first shell | Accepted, partly superseded by [0022](0022-one-repository-per-aggregate.md) |
| [0005](0005-drift-and-encrypted-sqlite.md) | Store data in drift over an encrypted SQLite | Accepted |
| [0006](0006-keystore-dek-with-pin-gate.md) | Keep the data key in the Keystore, gate it with a PIN | Accepted, described accurately by [0024](0024-keystore-holds-a-wrapping-key.md) |
| [0007](0007-database-per-profile.md) | Give each profile its own database file | Accepted |
| [0008](0008-cadence-as-duration.md) | Store cadence as a duration, derive the orbit | Accepted |
| [0009](0009-derived-phase-and-overdue-queue.md) | Derive phase, order overdue friends by due date | Accepted, partly superseded by [0021](0021-civil-date-time-model.md) |
| [0010](0010-encrypted-logical-backup.md) | Export an encrypted logical backup | Accepted, partly superseded by [0026](0026-attachments-as-blobs-and-a-framed-backup.md) |
| [0011](0011-app-lock-and-screen-privacy.md) | Lock the app and hide the screen preview | Accepted |
| [0012](0012-opt-in-local-notifications.md) | Offer local reminders, off by default | Accepted |
| [0013](0013-testing-strategy.md) | Test the domain without mocks | Accepted |
| [0014](0014-dial-layout-and-bead-packing.md) | Pack beads per orbit, not across the whole dial | Accepted |
| [0015](0015-dial-overflow-treatment.md) | Handle beads that do not fit on an orbit | **Proposed** |
| [0016](0016-derive-lastmet-from-meetings.md) | Derive lastMet from meeting dates | Accepted |
| [0017](0017-note-kinds-are-labels.md) | Note kinds are labels, and nothing clears itself | Accepted |
| [0018](0018-ui-package-and-widgetbook.md) | Put design tokens and dumb widgets in their own package | Accepted |
| [0019](0019-correcting-and-partly-superseding-a-record.md) | Correct a record in place, and supersede one in part | Accepted |
| [0020](0020-no-os-level-backup.md) | Turn off the operating system backup | Accepted |
| [0021](0021-civil-date-time-model.md) | A Meeting happens on a Civil Date, with an optional time | Accepted |
| [0022](0022-one-repository-per-aggregate.md) | One repository per aggregate, kept in `core/` | Accepted |
| [0023](0023-check-the-guarantees-in-ci.md) | Check the stated guarantees in CI | Accepted |
| [0024](0024-keystore-holds-a-wrapping-key.md) | The Keystore holds a wrapping key, and the Profile list has a home | Accepted |
| [0025](0025-one-owner-for-the-database-connection.md) | One owner for the database connection | Accepted |
| [0026](0026-attachments-as-blobs-and-a-framed-backup.md) | Store attachments as BLOBs, and write the Backup as a framed file | Accepted |
| [0027](0027-domain-value-objects-and-equality.md) | Wrap the domain's values in types, and get equality from `equatable` | Accepted |
| [0028](0028-priority-order-as-two-groups.md) | Hold the Priority Order as two groups, not one sorted list | Accepted |
| [0029](0029-name-the-dial-counts.md) | Name the Dial counts, and set their boundaries in Phase | Accepted |

## Template

Copy this shape for a new record.

A `Proposed` record has no rejections yet. Use `## Options` in place of
`## Alternatives Considered`, and rename the section when the choice is made.

```markdown
# ADR-XXXX: Title

**Status:** Proposed | Accepted | Deprecated | Superseded
**Date:** YYYY-MM-DD

## Context
What problem do we face? What limits our options?

## Decision
What did we choose?

## Consequences

### Positive
- What gets better.

### Negative
- What gets worse. Be honest here.

## Alternatives Considered

### Option name
**Why rejected:** The reason.
```
