# friendo_ui_book

The Widgetbook workspace for `friendo_ui`. It draws every widget on its own, at every size and in
every state, with no app and no data around it.

## Running it

```bash
flutter run -d chrome
```

## Why it is a separate package

This workspace sees `friendo_ui` and nothing else. That import list is a test in itself: if a
widget ever grows a dependency on `flutter_bloc` or on the domain, this package stops compiling and
CI reports it. See [ADR-0018](../../docs/adr/0018-ui-package-and-widgetbook.md).

The widget tree in `lib/` is written by hand. No generator runs here. See
[ADR-0018](../../docs/adr/0018-ui-package-and-widgetbook.md) for why the generator was dropped.

## Version pins

`widgetbook` is held at 3.23.x. Version 3.24.0 and above need Flutter 3.44.0, and this project
builds on 3.41.7. Raise the widgetbook constraint, the CI pin and the project pin together, or
raise none of them.
