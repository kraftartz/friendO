# ADR-0018: Put design tokens and dumb widgets in their own package

**Status:** Accepted
**Date:** 2026-09-08

## Context

Flutter has no CSS classes. A widget carries its own style inline. Every new button starts as a
Material button and gets restyled by hand.

The design makes this worse. Counted across the five screens:

| Treatment | Uses |
|---|---|
| Inset shadow (debossed well) | 118 |
| Glow | 89 |
| Dual outer shadow (convex card) | 29 |
| Gradient pill button | 9 |
| **All shadow declarations** | **272** |
| **Distinct shadow strings** | **92** |

Most of those 92 strings are the same few treatments at different sizes. The designer tuned each
one by hand. Written inline, they would be tuned by hand again in Dart.

Flutter theming solves part of this. `ThemeData` styles Material widgets. `ThemeExtension<T>` holds
custom tokens, which is the closest thing Flutter has to a CSS variable.

Theming does not solve the rest. **Material models one light source.** `ButtonStyle` carries
`elevation` and `shadowColor`, so it draws one shadow. Neumorphism needs two: a light from the top
left and a dark from the bottom right. No `ButtonStyle` can express that pair. The primary button
must be a decorated box with its own ink response.

So a custom widget layer exists whether or not we plan for it. The only open question is whether it
exists once or many times.

One more risk. A widget that reads a BLoC cannot be reused and cannot be previewed. Nothing stops
that from happening inside `lib/`.

Inset shadows carry an open question of their own. Flutter's `BoxShadow` appears to have no `inset`
field. This is unconfirmed. It is deferred, and it does not change the decision below. Wherever the
widget lives, the problem is solved once.

## Decision

Add two packages.

### `packages/friendo_ui`

It holds two things:

- **Tokens.** A `Soft` class that extends `ThemeExtension<Soft>`, plus the values as `Soft.dark()`.
- **Primitives.** About six widgets, one per repeated treatment.

It depends on Flutter. **It must not depend on `flutter_bloc`, on drift, or on `friendo_domain`.**

That import list is the boundary. A widget that cannot import `flutter_bloc` cannot call
`context.read()`. The rule holds by compilation, not by review.

**The package holds treatments. It does not hold concepts.** `SoftCard`, `SoftWell`, `SoftButton`,
`Pill`, `Glow` and `AvatarRing` belong in it. `DialView`, `FriendBead` and `MeetingCard` do not.
The test is simple: if `friendo_ui` needs `friendo_domain`, something is filed wrong.

The tokens must live here. The widgets read them, so the package must see the type. Putting `Soft`
in `lib/` would make the package import the app and invert the dependency.

The values ship from the package as well. The brief fixes the app to dark, so the app has no reason
to supply its own. `lib/app/theme.dart` installs `Soft.dark()` into `ThemeData.extensions` and does
nothing else.

**Build only what repeats.** Six treatments now. The seventh earns its place when it appears twice.

### `packages/friendo_ui_book`

A Widgetbook workspace. It depends on `friendo_ui` and nothing else. This matches the layout that
Widgetbook documents for a design system in a monorepo.

Use the code generator: `@UseCase` annotations with `build_runner`. drift already needs
`build_runner`, so the generator costs one dev dependency and no new tooling.

## Consequences

### Positive

- The compiler enforces dumb widgets. This is the same trick that keeps Flutter out of
  `friendo_domain`, used a second time.
- The workspace tests the boundary. It can reach `friendo_ui` alone. Add a BLoC to a primitive and
  the workspace stops compiling, so CI catches it.
- Widgetbook knobs bind properties to sliders. Shadow offset, blur and opacity can be tuned against
  a real surface. This replaces a cycle of edit, save and reload.
- Six widgets replace 272 inline declarations.
- The inset shadow problem, once solved, is solved in one file.

### Negative

- Two more `pubspec.yaml` files and two more path dependencies.
- Use cases go stale when nobody opens them.
- A UI package invites a component library that nobody needs. The rule above is the only guard, and
  it needs discipline.
- A token change rebuilds the app package. At this size that costs nothing.

## Alternatives Considered

### A `lib/ui/` folder instead of a package

**Why rejected:** A folder cannot fail to compile. "Widgets hold no BLoC" would stay a review
convention, and review conventions decay. The package turns the same rule into a build error. That
difference is the whole reason to pay for a package.

### Theme only, no shared widgets

**Why rejected:** `ThemeData` styles Material widgets well, and this design is not Material.
`ButtonStyle` draws one shadow and the primary button needs two. A custom widget appears either
way. The choice is only how many times it appears.

### Token schema in the package, token values in the app

**Why rejected:** It adds a hook with one caller. The brief fixes the app to dark, so no second set
of values exists. Add `Soft.light()` beside `Soft.dark()` if a second theme ever appears.

### A hand-written Widgetbook tree, no code generation

**Why rejected:** The tree needs an edit for every new use case, and it falls behind in silence.
The generator reads the annotations instead. `build_runner` is already required, so the objection
to code generation does not apply here.
