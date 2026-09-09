# FTS5 over the encrypted database

**Question:** Can the Friends List search use FTS5 over the encrypted database?
**Short answer:** Yes. FTS5 is compiled in, it works over the encrypted file, and it leaks nothing.
But at 100 Friends it buys nothing, and it cannot search two of the four things the PRD asks for.
**Recommendation:** Do not add FTS5 for v1. Use `LIKE`. It costs less than a millisecond.

Ticket: `friendO-cc1.3`. Measured on 2026-09-09. Machine: Linux x86-64, no macOS.

---

## What was pinned when this was measured

| Thing | Version | Source |
|---|---|---|
| `sqlite3` (Dart package) | 3.5.2 | `pubspec.lock` |
| `drift` | 2.34.4 | `pubspec.lock` |
| `drift_dev` | 2.34.0 | `pubspec.lock` |
| `sqlparser` | 0.44.5 | `pubspec.lock` |
| SQLite engine | 3.53.4 | `sqlite3_libversion()`, read from the artefact |
| Build hook define | `hooks: user_defines: sqlite3: source: sqlite3mc` | `pubspec.yaml` |
| Release the hook fetches | `sqlite3-3.5.2` | `sqlite3-3.5.2/lib/src/hook/asset_hashes.dart:9` |

The hook does not compile SQLite here. `source: sqlite3mc` resolves to
`PrecompiledFromGithubAssets(LibraryType.sqlite3mc)`, which downloads a hash-checked binary from
one GitHub release
(`sqlite3-3.5.2/lib/src/hook/compile/description.dart`, `SqliteBinary.forBuild`).

---

## 1. Does the build compile FTS5 in? Yes, on every artefact reachable here

Four artefacts were already on disk under `.dart_tool/hooks_runner/shared/sqlite3/build/`.
Nothing was built for this note.

| Artefact | Target | Evidence |
|---|---|---|
| `download-32d8d11b` | Linux x64 (host, used by `flutter test`) | loaded and run |
| `download-d864384a` | Android x86_64 | read with `strings` and `nm` |
| `download-f0c07e18` | Android arm64 | read with `strings` and `nm` |
| `download-dfcf871c` | Android armeabi-v7a | read with `strings` and `nm` |

**Direct evidence.** The Linux artefact was loaded through `ctypes` and asked itself:

    sqlite3_libversion()                        -> 3.53.4
    sqlite3_compileoption_used("ENABLE_FTS5")   -> 1
    sqlite3_compileoption_get(...)              -> 56 options, including ENABLE_FTS5

The 56 options include `ENABLE_FTS5`, `ENABLE_RTREE` and `TEMP_STORE=2`. They do **not** include
`ENABLE_FTS3`, `ENABLE_FTS4` or `ENABLE_ICU`.

**Direct evidence, Android.** SQLite keeps its compile options as string literals, because
`SQLITE_OMIT_COMPILEOPTION_DIAGS` is not set. All three Android artefacts carry `ENABLE_FTS5`, and
each holds about 287 FTS5 symbols. The full feature-flag set of every Android artefact is
**byte-identical** to the Linux one; only `COMPILER=` differs (clang-18.1.3 against clang-21.0.0).
One pipeline, one define set.

All four tokenizers work: `unicode61`, `ascii`, `porter` and `trigram`.

### iOS: strong inference, not measurement

There is no macOS on this machine, and no iOS artefact was downloaded. Three documents settle it
short of running the binary:

1. The release holds iOS artefacts under the same tag. `asset_hashes.dart` pins SHA-256 hashes for
   `libsqlite3mc.arm64.ios.dylib`, `libsqlite3mc.arm64.ios_sim.dylib` and
   `libsqlite3mc.x64.ios_sim.dylib`.
2. Every target takes the same code path. `TargetOperatingSystem.forConfig` maps iOS to the same
   `PrecompiledFromGithubAssets` download that Android and Linux take
   (`lib/src/hook/assets.dart`).
3. The define set is one constant. `description.dart` holds `_defaultDefines`, which names
   `SQLITE_ENABLE_FTS5` and `SQLITE_TEMP_STORE=2`, under the comment
   `// Keep in sync with tool/compile_sqlite.dart`.

The four artefacts measured here agree with that constant exactly. **Confidence that iOS also has
FTS5: high (about 95%).** To make it certain, run `PRAGMA compile_options` on an iOS device or
simulator once the app first builds for iOS.

---

## 2. Does drift generate and migrate an FTS5 table? Yes, at the pinned version

drift 2.34.4 and drift_dev 2.34.0 support FTS5 fully. Nothing needs upgrading.

**Declaring one.** Only in a `.drift` file, with
`CREATE VIRTUAL TABLE search USING fts5(...);`. There is no Dart `Table` class route.
`drift_dev` recognises the module as `DriftFts5Table`, and it understands external-content tables
and their explicit rowid (`drift_dev/lib/src/analysis/results/table.dart:259`).

**Enabling the analyser.** The project has **no `build.yaml`**. One must be added:

    targets:
      $default:
        builders:
          drift_dev:
            options:
              sqlite:
                modules:
                  - fts5

The key is `modules` inside a `sqlite:` block (`drift_dev/lib/src/analysis/options.dart:88,313`).
Without it, `MATCH` and the FTS5 functions fail the build-time SQL check.

**Migrating one.** `Migrator.createAll()` walks every schema entity and calls `createTable`, which
branches on `VirtualTableInfo` and writes
`CREATE VIRTUAL TABLE IF NOT EXISTS <name> USING <moduleAndArgs>;`
(`drift/lib/src/runtime/query_builder/migration.dart:130,397`).

**Migration tests.** `schema_version_writer.dart:221` writes `moduleAndArgs` into the versioned
schema dumps, and `find_differences.dart` compares a `CreateVirtualTableStatement` by AST. So
`drift_dev schema dump` and `verifySelf` both handle FTS5.

**One trap.** Schema verification hides the shadow tables by name prefix:
`isInternalElement` returns true for any name starting with `<virtualTableName>_`
(`verifier_common.dart:15`). If the FTS5 table is called `search`, then a *real* table called
`search_history` would be skipped by the verifier and its drift would go unreported. Name the
virtual table so that no ordinary table shares its prefix.

---

## 3. Does the index copy any text outside the encrypted file? No, unless you ask for it

An encrypted database was built with this exact library, given an FTS5 table, and read back.

**The shadow tables are ordinary tables inside the main file.** `sqlite_master` shows
`search`, `search_config`, `search_content`, `search_data`, `search_docsize` and `search_idx`.
Every one is a normal table, so every one is stored in encrypted pages.

**Nothing leaks.** Rare words were written into the FTS5 table, then every file on disk was
scanned for them as raw bytes:

| File | Contains those words? |
|---|---|
| the `.db` file | no |
| `-wal` (4 MB, uncheckpointed) | no |
| `-shm` | no |
| `-journal`, mid-transaction | no |

The main file does not begin with `SQLite format 3` either. The header is encrypted.

**The relevant defaults, read from the open database:**

| Pragma | Value | Why it matters |
|---|---|---|
| `cipher` | `chacha20` | matches ADR-0005 |
| `plaintext_header_size` | `0` | no part of the header stays in the clear |
| `mc_legacy_wal` | `0` | the WAL is encrypted |
| `secure_delete` | `1` | freed pages are zeroed |
| `temp_store` | `0` (compile default = memory) | temp data never reaches disk |

### The one real hazard: `PRAGMA temp_store = FILE`

`SQLITE_TEMP_STORE=2` means memory *by default*, and a pragma may still force files.
This was measured both ways, watching `/proc/self/fd` because SQLite unlinks its temp files the
moment it opens them, so they never appear in a directory listing:

- **At the default** (memory): a sort over 20 000 stored values, with a 16 KiB cache, produced
  **zero** temp files.
- **With `PRAGMA temp_store = FILE`**: the same sort spilled two files of about **8 MB each**, and
  both held those words **in cleartext**. sqlite3mc does not encrypt them.

This is not an FTS5 problem. Any large sort or index build can do it. The rule that follows is
simple and belongs in the database setup:

> Never set `PRAGMA temp_store = FILE`, and never set `plaintext_header_size` or `mc_legacy_wal`.
> Leave all three at their defaults.

At 100 Friends nothing will ever spill anyway. The rule guards against a later edit.

---

## 4. The `LIKE` fallback, priced

A Profile was built at the largest realistic size and at ten times that size, in an encrypted
database, with the artefact this app ships.

- **Realistic largest:** 100 Friends, 20 Topics each (2 000 Topics), 12 Affinities, 300 links.
  File on disk: **124 KB**.
- **Ten times that:** 1 000 Friends, 20 000 Topics. File on disk: 1.1 MB.

The query is a four-arm `UNION` of `LIKE '%term%'`, one arm per searched thing. Orbit is derived
from Cadence with a `CASE`, because it is not stored. Timings are engine time only, the median of
400 runs. The query is wrapped in `SELECT count(*)`, so that reading the results back does not
count.

| Term | 100 Friends | 1 000 Friends |
|---|---|---|
| `quin` | 0.30 ms | 2.39 ms |
| `glassblowing` | 0.33 ms | 2.67 ms |
| `kyoto` | 0.39 ms | 3.20 ms |
| `inner` | 0.38 ms | 3.14 ms |
| `e` (matches everything) | 0.83 ms | 7.84 ms |

Write the query as a `UNION` of four arms, not as one `LEFT JOIN` with `OR`. The join form fans
out the work and measured **3 to 4 ms** on the same 100-Friend data, about ten times worse.

FTS5 on the same 100 Friends, for comparison: 0.06 to 0.18 ms. Real, and irrelevant. Both are far
below one frame at 60 Hz (16.7 ms), so search can run on every keystroke.

These numbers come from a desktop x86-64 CPU. A mid-range phone is perhaps three to five times
slower, which puts the realistic case near **1 to 4 ms**. Still nothing.

For scale, opening the database, deriving the key and running the first search took **59 ms**.
The key derivation dominates (`kdf_iter` is 64 007). Search is noise next to unlocking.

---

## Why `LIKE` wins for v1

Speed is not the reason. These four are.

1. **FTS5 cannot search two of the four things.** Orbit is derived from Cadence, not stored, so
   FTS5 could only index it by denormalising it and keeping the copy in step with every Cadence
   edit. Affinity lives in a join table, so it needs the same treatment.

2. **FTS5 cannot match inside a word.** The default tokenizer matches whole words and prefixes.
   Measured: `quin*` finds *Quinzelfarb*; `farb*` finds nothing. A search box where typing `farb`
   finds *Quinzelfarb* needs the `trigram` tokenizer, which is present but stores three times the
   text and ignores terms shorter than three characters. `LIKE '%farb%'` just works.

3. **FTS5 needs a second copy of the text, and triggers to keep it honest.** Measured on the
   124 KB database: **200 KB** with a `unicode61` index (+61%), **340 KB** with a `trigram` one
   (+174%). Every insert, update and delete on Friends, Topics and Affinities then needs a trigger.
   That is a class of bug for no measurable gain. (External-content tables avoid the copy but still
   need the triggers.)

4. **It costs a new build step.** A new `build.yaml`, a first `.drift` file, and a virtual table in
   every future migration test.

### What this forces

**On the schema:** nothing. No FTS5 table, no shadow tables, no denormalised search column. The
schema stays as `docs/feature-backlog.md` describes it.

**On the Friends List spec:** four things.

- Search matches a substring, case-insensitively, across Friend name, Topic body, Affinity label
  and Orbit name.
- Write it as a `UNION` of four arms. Do not write one `LEFT JOIN` with `OR`.
- **`LIKE` folds case for ASCII only, and never folds accents.** This is measured, not assumed:

  | Test | Result |
  |---|---|
  | `'Quinzelfarb' LIKE '%quin%'` | matches |
  | `'Zoë' LIKE '%zoë%'` | matches (the `Z` folds) |
  | `'ZOË' LIKE '%zoë%'` | **no match** (`Ë` does not fold) |
  | `'MICHAŁ' LIKE '%michał%'` | **no match** (`Ł` does not fold) |
  | `'Zoë' LIKE '%zoe%'` | **no match** (accents are never stripped) |

  Any Friend whose name carries a non-ASCII letter searches badly. The owner types `michal` and
  finds nothing. This needs a decision, not silence: either store a folded copy of each searched
  string and search that, or register a custom collation from Dart. Say which in the spec.
- Escape `%` and `_` in what the owner types, with `LIKE ... ESCAPE '\'`. Measured: without it,
  `a_b` matches `axb`; with it, it does not.

**On the database setup:** one rule, from section 3. Leave `temp_store`, `plaintext_header_size`
and `mc_legacy_wal` alone.

### When to revisit

If a Profile ever holds thousands of Friends, or if Notes, Updates and Meeting bodies join the
search and each Friend carries a page of prose. Neither is v1. ADR-0005 already fixes the size at
about 100 Friends.

**No ADR is needed.** This confirms what ADR-0005 already assumed: "Query speed is not a concern
at this size." It alters nothing anybody would build.

---

## What could not be established here

| Claim | Confidence | Why |
|---|---|---|
| FTS5 on Android (3 ABIs) | certain | read from the shipped artefacts |
| FTS5 on the Linux host used by tests | certain | the library was run and asked |
| FTS5 on iOS | high, about 95% | no macOS here, and no artefact was downloaded. Rests on the pinned hashes, the shared code path and the shared define constant. Confirm with `PRAGMA compile_options` on the first iOS build. |
| No plaintext in the db, WAL, shm or journal | certain | rare words written, then every file scanned as raw bytes |
| Temp files stay in memory at the default | certain | measured through `/proc/self/fd` |
| Timings | certain on desktop, estimated on a phone | measured on Linux x86-64. No device or emulator run was made. The three-to-five-times figure is an estimate. |
| `LIKE` folding behaviour | certain | measured against this exact library |

The artefacts were also never checked inside a built APK. No APK exists in `build/`, and building
one was not needed: the artefacts under `.dart_tool/hooks_runner/shared/` are the exact files
Gradle packages.

## How to repeat this

Load `.dart_tool/hooks_runner/shared/sqlite3/build/download-*/libsqlite3mc.so` through `ctypes` or
`dart:ffi`, then call `sqlite3_compileoption_used("ENABLE_FTS5")`. Only `sqlite3_open_v2` is
exported, not `sqlite3_open`; the package trims its exported symbols to 90.
