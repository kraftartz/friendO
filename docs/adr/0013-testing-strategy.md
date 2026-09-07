# ADR-0013: Test the domain without mocks

**Status:** Accepted
**Date:** 2026-09-07

## Context

The app has one part worth testing hard: the cadence rules. Which friend is due? Who became overdue
first? Where does a bead sit?

Those rules depend on time. A naive design reads `DateTime.now()` inside the logic. Tests then need
a fake clock, a mocking library, and setup code for what is really arithmetic.

The rest of the app is forms and lists. Heavy testing there costs time and finds little.

## Decision

Split testing to match the structure in
[ADR-0004](0004-pure-domain-core-feature-shell.md).

| Layer | How to test | Tools |
|---|---|---|
| `friendo_domain` | Plain unit tests. Pass `now` as an argument. | `test` only. No mocks. |
| Blocs | State transition tests | `bloc_test` |
| Repositories | Real SQL against a real engine | drift in-memory driver |
| Dial layout | Pure function over friends and geometry | `test` only |
| Widgets | Golden test for the dial only | `flutter_test` |

Pass `now` into every domain function. Never read the clock inside the domain. Get `now` from the
injected `Clock` in `core/time/` everywhere else.

Write the domain tests first. That code is small, pure, and where the bugs would hurt most.

## Consequences

### Positive

- Domain tests need no mocking library and no fake clock class. They call a function and check a
  number.
- Tests read as examples. "Met 8 days ago, 7-day cadence, expect overdue" is the whole test.
- Repository tests run real SQL, so they catch real query bugs. In-memory drift keeps them fast.
- Time-dependent tests are deterministic. There is no clock to stub and no flake to chase.
- The dial layout is a pure function, so bead positions can be tested without a widget tree.

### Negative

- Passing `now` through call sites adds a parameter to many functions. It is noise, and it is the
  price of the rest.
- A golden test for the dial breaks on any visual change. It needs regenerating often, and it will
  be tempting to delete.
- Light CRUD testing means CRUD bugs reach the device. Accepted for a solo personal project.

## Alternatives Considered

### Mock the clock with a mocking library

**Why rejected:** It solves a problem created by reading the clock inside the logic. Passing `now`
removes the problem instead of tooling around it.

### Mock repositories in bloc tests

**Why rejected:** In-memory drift is fast enough and tests real behaviour. A mocked repository only
proves the bloc calls the mock the way the test says it should.

### Full widget test coverage

**Why rejected:** High cost, brittle under design changes, and low value on screens with no logic.
