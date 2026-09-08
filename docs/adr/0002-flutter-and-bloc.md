# ADR-0002: Use Flutter and BLoC

**Status:** Accepted
**Date:** 2026-09-07

## Context

friendO is a phone app. It should run on Android and iOS. One person builds it in spare time, so
two native codebases are not realistic.

The app has one screen with heavy custom drawing. The dial has moving beads, orbits, and glow
effects. The UI framework must draw custom shapes well.

The author picked the stack before design started. The choice is fixed and not open for debate.
This record exists to state the reason, not to reopen the question.

## Decision

Use **Flutter** for the app and **flutter_bloc** for state.

Flutter is the author's mobile framework of choice. It draws every pixel itself, which suits the
custom dial.

BLoC is chosen for a second reason that is worth stating plainly: **the author has never used BLoC
and wants to learn it.** On a personal project, learning is a valid goal. A reader should not
assume a performance reason or a benchmark behind this choice, because there is none.

## Consequences

### Positive

- One codebase covers both platforms.
- Flutter draws custom canvases well, so the dial does not fight the framework.
- BLoC makes each state change explicit. The dial is derived state, and explicit transitions suit it.
- `bloc_test` gives a clean way to test state changes.

### Negative

- BLoC is wordy. Simple CRUD screens need events, states, and a bloc for very little logic.
- The author will write beginner BLoC code at the start. Expect rework in the first features.
- A learning goal can pull the design toward BLoC even where BLoC does not help.

To limit the last risk, keep the cadence logic outside BLoC entirely. See
[ADR-0004](0004-pure-domain-core-feature-shell.md).

## Alternatives Considered

### Native Android and iOS

**Why rejected:** Two codebases for one part-time developer. The app has no platform-specific need
that would pay for that cost.

### React Native

**Why rejected:** The author does not use it. Custom drawing is also weaker than Flutter's canvas.

### Riverpod, Provider, or signals

**Why rejected:** Any of these would work, and several are less wordy than BLoC. They lose on the
one point that decides this record: the author wants to learn BLoC. Do not propose these again
without a new reason.
