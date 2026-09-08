# friendo_domain

The friendO domain core. It holds Cadence, Civil Date, Phase, Standing, Due Date and Priority
Order — every rule that decides who the owner should see next.

## The boundary

This package is pure Dart. It has **no Flutter, no clock, no file access and no database**.

The rule holds by compilation and not by review. `pubspec.yaml` names no `flutter` dependency and
no `flutter` key under `environment:`, so this package has no package config entry for Flutter.
An `import 'package:flutter/material.dart'` here fails to build. It does not merely warn.

Do not move these packages into a pub workspace. Workspace members share one `package_config.json`,
which would let this package resolve Flutter and drop the boundary to an info-level lint. See
[ADR-0004](../../docs/adr/0004-pure-domain-core-feature-shell.md).

The rule is "no Flutter, no clock, no input and no output". It is not "no dependencies".
`equatable` is pure Dart and is allowed. `tool/boundaries.sh` fails the build on anything else.
See [ADR-0027](../../docs/adr/0027-domain-value-objects-and-equality.md).

## What it holds

| Type | Answers |
|---|---|
| `CivilDate` | Which day. No time and no zone. |
| `Cadence` | How often, in whole days. Also which Orbit. |
| `Phase` | How far through the current Cadence, as a fraction. |
| `Standing` | The same reading as a name: Freshly Reset, In Orbit, Nearing, Overdue. |
| `Placing` | One Friend with every derived value worked out. |
| `PriorityOrder` | Every Friend ranked, Overdue first. |

Two facts are stored per Friend: the Cadence, and the dates of that Friend's Meetings. Everything
above is worked out on read, so nothing can fall out of step with the rows. See
[ADR-0009](../../docs/adr/0009-derived-phase-and-overdue-queue.md).

## Time

A Meeting happens on a Civil Date. A Meeting may also carry a time of day, which the app shows and
the Dial ignores. `now` is an instant, and it always arrives as an argument. See
[ADR-0021](../../docs/adr/0021-civil-date-time-model.md).

## Tests

```bash
dart test
```

Tests call plain functions with a fixed `now`. There are no mocks and no widget tree. See
[ADR-0013](../../docs/adr/0013-testing-strategy.md).
