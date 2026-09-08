# friendO

A private notepad and reminder for friendships. You say how often you want to see each Friend, and
the app tells you who is next. It runs on one phone, stores everything encrypted, and never touches
the network.

## Where things are

Read [CONTEXT.md](CONTEXT.md) first. Every other document uses the words it defines.

| Document | What it answers |
|---|---|
| [CONTEXT.md](CONTEXT.md) | What each word means. Friend, Cadence, Meeting, Phase, Dial, Orbit, Bead. The glossary wins over every other file. |
| [docs/prd.md](docs/prd.md) | Who the app is for, what problem it solves, and what each screen does. |
| [docs/architecture.md](docs/architecture.md) | How the app is built. Containers, the domain core, data and keys, and the module map. |
| [docs/adr/](docs/adr/README.md) | Why it is built that way. One record per decision, with what was rejected. |
| [docs/DESIGN.md](docs/DESIGN.md) | The design tokens and the visual language. Colours, type, spacing, elevation. |
| [docs/feature-backlog.md](docs/feature-backlog.md) | Features the screens implied that the architecture has not accounted for yet. |
| [docs/initial-design/](docs/initial-design/README.md) | The first screen designs, kept as a frozen reference. Not maintained. |
| [AGENTS.md](AGENTS.md) | How to work in this repository. Issue tracking and the session protocol. |

Read a decision record before you change the choice it describes. A record is history, so it is not
rewritten to match a newer opinion once the project is past its research phase.

## Code layout

| Path | Rule |
|---|---|
| `packages/friendo_domain` | Pure Dart. No Flutter, no clock, no storage. |
| `packages/friendo_ui` | Design tokens and dumb widgets. No BLoC, no repository, no domain. |
| `packages/friendo_ui_book` | Widgetbook workspace. Sees `friendo_ui` and nothing else. |
| `lib/` | The app. Features, wiring, and shared services. |

The first two rules hold by compilation, not by review. Each package resolves its own dependencies,
so an import that crosses a boundary fails to build.

## Working on it

```bash
tool/get.sh     # fetch dependencies for every package
tool/lint.sh    # format check and analyse; the pre-commit hook runs this
tool/test.sh    # run every package's tests
flutter run     # the app
```

Run the widget workspace with `flutter run -d chrome` from `packages/friendo_ui_book`.
