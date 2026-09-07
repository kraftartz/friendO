# Architecture Decision Records

Each file records one choice. Read the file before you change the choice it describes.

An ADR is a historical note. Do not rewrite a record to match a new opinion. Write a new record
instead and set the old one to `Superseded`.

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
| [0004](0004-pure-domain-core-feature-shell.md) | Pure domain core, feature-first shell | Accepted |
| [0005](0005-drift-and-sqlcipher.md) | Store data in drift over SQLCipher | Accepted |
| [0006](0006-keystore-dek-with-pin-gate.md) | Keep the data key in the Keystore, gate it with a PIN | Accepted |
| [0007](0007-database-per-profile.md) | Give each profile its own database file | Accepted |
| [0008](0008-cadence-as-duration.md) | Store cadence as a duration, derive the ring | Accepted |
| [0009](0009-derived-phase-and-overdue-queue.md) | Derive phase, order overdue friends by due date | Accepted |
| [0010](0010-encrypted-logical-backup.md) | Export an encrypted logical backup | Accepted |
| [0011](0011-app-lock-and-screen-privacy.md) | Lock the app and hide the screen preview | Accepted |
| [0012](0012-opt-in-local-notifications.md) | Offer local reminders, off by default | Accepted |
| [0013](0013-testing-strategy.md) | Test the domain without mocks | Accepted |
| [0014](0014-dial-layout-and-bead-packing.md) | Pack beads per ring, not across the whole dial | Accepted |
| [0015](0015-dial-overflow-treatment.md) | Handle beads that do not fit on a ring | **Proposed** |
| [0016](0016-derive-lastmet-from-meetings.md) | Derive lastMet from meeting dates | Accepted |
| [0017](0017-note-kinds-are-labels.md) | Note kinds are labels, and nothing clears itself | Accepted |

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
