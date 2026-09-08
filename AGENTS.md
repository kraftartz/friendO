# Agent Instructions

This project uses **bd** (beads) for issue tracking. Run `bd prime` for full workflow context.

## Quick Reference

```bash
bd ready              # Find available work
bd show <id>          # View issue details
bd update <id> --claim  # Claim work atomically
bd close <id>         # Complete work
bd dolt push          # Push beads data to remote
```

## Non-Interactive Shell Commands

**ALWAYS use non-interactive flags** with file operations to avoid hanging on confirmation prompts.

Shell commands like `cp`, `mv`, and `rm` may be aliased to include `-i` (interactive) mode on some systems, causing the agent to hang indefinitely waiting for y/n input.

**Use these forms instead:**
```bash
# Force overwrite without prompting
cp -f source dest           # NOT: cp source dest
mv -f source dest           # NOT: mv source dest
rm -f file                  # NOT: rm file

# For recursive operations
rm -rf directory            # NOT: rm -r directory
cp -rf source dest          # NOT: cp -r source dest
```

**Other commands that may prompt:**
- `scp` - use `-o BatchMode=yes` for non-interactive
- `ssh` - use `-o BatchMode=yes` to fail instead of prompting
- `apt-get` - use `-y` flag
- `brew` - use `HOMEBREW_NO_AUTO_UPDATE=1` env var

<!-- BEGIN BEADS INTEGRATION v:1 profile:minimal hash:ca08a54f -->
## Beads Issue Tracker

This project uses **bd (beads)** for issue tracking. Run `bd prime` to see full workflow context and commands.

### Quick Reference

```bash
bd ready              # Find available work
bd show <id>          # View issue details
bd update <id> --claim  # Claim work
bd close <id>         # Complete work
```

### Rules

- Use `bd` for ALL task tracking — do NOT use TodoWrite, TaskCreate, or markdown TODO lists
- Run `bd prime` for detailed command reference and session close protocol
- Use `bd remember` for persistent knowledge — do NOT use MEMORY.md files

## Session Completion

**When ending a work session**, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

**MANDATORY WORKFLOW:**

1. **File issues for remaining work** - Create issues for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, update in-progress items
4. **PUSH TO REMOTE** - This is MANDATORY:
   ```bash
   git pull --rebase
   bd dolt push
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Clean up** - Clear stashes, prune remote branches
6. **Verify** - All changes committed AND pushed
7. **Hand off** - Provide context for next session

**CRITICAL RULES:**
- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing - that leaves work stranded locally
- NEVER say "ready to push when you are" - YOU must push
- If push fails, resolve and retry until it succeeds
<!-- END BEADS INTEGRATION -->

## Build & Test

Three scripts define what "clean" means. The pre-commit hook and CI both call them, so a green run
here is a green run there.

```bash
tool/get.sh     # pub get in all four packages
tool/lint.sh    # dart format check, then flutter analyze
tool/test.sh    # tests in every package that has them
```

```bash
flutter run                    # the app, on a connected device or emulator
flutter build apk --debug      # the only check that the native Android side links
```

Run the widget workspace from its own package:

```bash
cd packages/friendo_ui_book && flutter run -d chrome
```

Notes that cost time when you do not know them:

- Flutter is pinned to **3.41.7**, in CI and in `packages/friendo_ui_book` (widgetbook 3.24+ needs
  a newer SDK). Move all three pins together or none.
- The Android build needs **SDK platform 37**, because flutter_secure_storage compiles against it.
- Editing `hooks: user_defines:` in `pubspec.yaml` needs `flutter clean` afterwards. Without it
  Gradle keeps packaging the previous native library, the build still succeeds, and the app ships
  the wrong one. See [ADR-0005](docs/adr/0005-drift-and-encrypted-sqlite.md).

## Architecture Overview

see `/docs/architecture.md` for the overview and `/docs/adr/*` for ADRs.

## Conventions & Patterns

### Language

[CONTEXT.md](CONTEXT.md) is the authority. Use the word it defines, and never the words it lists
under `_Avoid_`. This holds in code, in comments, in documents and in text shown to a user. If a
needed word is missing, add it there first.

### Package boundaries

Two rules hold by compilation, not by review. Each package resolves its own dependencies, so an
import that crosses a boundary fails to build rather than raising a warning.

| Package | May depend on |
|---|---|
| `packages/friendo_domain` | Pure Dart only. No Flutter, no clock, no storage. |
| `packages/friendo_ui` | Flutter only. No BLoC, no repository, no domain. |
| `packages/friendo_ui_book` | `friendo_ui` only. |
| `lib/` | Anything above. |

Do not merge the packages into a pub workspace. Workspace members share one `package_config.json`,
which would let the domain resolve Flutter and reduce the boundary to a lint.

### Inside `lib/`

- A feature never imports another feature. Wiring several features together is the job of `app/`.
- `friendo_ui` holds treatments such as `SoftCard`, never concepts such as `FriendBead`.
- Nothing in the domain reads the clock. A function that needs the current time takes it as an
  argument, which is also what makes it testable.

### Tests

Test real behaviour against a real engine. Do not assert on mocks. See
[ADR-0013](docs/adr/0013-testing-strategy.md).

### Comments and documents

Write in ASD-STE100 Simplified Technical English. Short sentences, simple words, active voice, one
idea per sentence. If a sentence needs rereading, rewrite it.

A comment describes the unit it lives in, never that unit's callers. Do not justify a value by
naming who uses it today, because that goes stale as soon as a second caller appears.

### Decisions

Read the record in [docs/adr/](docs/adr/README.md) before you change the choice it describes. Each
record lists what was rejected and why.

### Commits

Use [Conventional Commits](https://www.conventionalcommits.org/): `feat:`, `fix:`, `chore:`,
`refactor:`, `docs:`, `test:`, `ci:`.

Ask before committing. The repository owner usually handles git themselves. This qualifies the
push step in the beads block above, which was written for a different working style.