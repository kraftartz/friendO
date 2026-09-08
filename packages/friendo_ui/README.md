# friendo_ui

Design tokens and dumb widgets for friendO. It holds treatments such as `SoftCard`, never concepts
such as `FriendBead`.

## The boundary

This package depends on Flutter and on nothing else. It must never depend on `flutter_bloc`, on
`drift`, or on `friendo_domain`.

The rule holds by compilation and not by review. A widget that cannot import `flutter_bloc` cannot
call `context.read()`, so it cannot reach a bloc even by accident. A folder named `widgets/` could
not do that job, because a folder cannot fail to compile. See
[ADR-0018](../../docs/adr/0018-ui-package-and-widgetbook.md).

`tool/boundaries.sh` fails the build when a forbidden dependency appears in `pubspec.yaml`.

## What belongs here

A widget belongs here when it takes everything it draws as an argument, and when its name says how
it looks rather than what it means.

| Belongs | Does not belong |
|---|---|
| `SoftCard`, `SoftWell`, `SoftButton`, `Pill`, `Glow`, `AvatarHalo` | `FriendBead`, `DialPage`, anything that reads a Cadence |

Colours, shadows and radii live in `tokens/` as a theme extension, so a widget reads them from the
theme and never hard-codes one.

## Seeing the widgets

Every widget has a use case in `packages/friendo_ui_book`.

```bash
cd ../friendo_ui_book && flutter run -d chrome
```
