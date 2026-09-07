# ADR-0004: Pure domain core, feature-first shell

**Status:** Accepted
**Date:** 2026-09-07

## Context

The app splits into two very different halves.

One half is the dial. It works out who you should see next. It has real rules: cadences, due dates,
overdue order. It is the reason the app exists. It needs tests.

The other half is forms and lists. Add a friend. Edit a note. Delete a meeting. There is almost no
logic there. A repository call does the whole job.

A common Flutter pattern applies Clean Architecture evenly across an app. Every action gets a use
case class. Applied here, that would produce about forty classes shaped like this:

```dart
class AddFriendUseCase {
  Future<void> call(Friend f) => repo.add(f);
}
```

Those classes add words and no safety. They also hide the one place that does have rules.

## Decision

Split the app by how much logic each part holds.

Put the cadence and orbit rules in `packages/friendo_domain`. Make it a plain Dart package. Do not
put Flutter in its `pubspec.yaml`. The package must not read files, touch the network, or read the
clock. Pass `now` in as an argument.

Build everything else feature-first. Each feature holds `bloc/`, `view/`, and a repository. Call
the repository straight from the bloc. Write no use case class for a plain CRUD call.

A feature may use `core/` and `friendo_domain`. A feature must not import another feature.

## Consequences

### Positive

- The compiler guards the boundary. An `import 'package:flutter/...'` inside the domain fails to
  build. The rule does not depend on anyone remembering it.
- Domain tests need no mocks, no fake clock class, and no widget tree. They are plain function
  calls. See [ADR-0013](0013-testing-strategy.md).
- The structure shows a reader where the thinking lives.
- CRUD screens stay short.

### Negative

- Two `pubspec.yaml` files and a path dependency to set up.
- The layering is uneven. A reader who expects the usual even layering will be surprised. This
  record is the answer to that surprise.
- Blocs can slowly collect logic that belongs in the domain. Nothing stops that automatically.
  Watch for it in review.

## Alternatives Considered

### Flat feature-first, no domain package

**Why rejected:** The cadence rules would live inside blocs. Testing them would need bloc plumbing
for what is really pure arithmetic. The most valuable code would become the hardest to test.

### Strict Clean Architecture across the whole app

**Why rejected:** It charges a fixed cost per operation for a benefit that scales with logic. This
app has one dense spot and a wide flat plain. Paying evenly would bury the dense spot in noise.

### Domain in `lib/domain/`, enforced by a lint rule

**Why rejected:** It works, but a lint rule can be turned off or skipped. A separate package with
no Flutter dependency cannot be bypassed by accident.
