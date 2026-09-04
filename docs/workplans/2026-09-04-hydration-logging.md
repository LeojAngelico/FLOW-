# Workplan: Hydration logging (APP-01 core loop + APP-02 Add Water)

Status: tests
Reference feature: **none complete — see § Reference feature** | Last agent: flutter-unit-tester

---

## Reference feature

**There is no end-to-end feature to mirror.** Per `docs/PROJECT_MAP.md`
§ Features and § Providers, all seven features under `lib/features/` have
`presentation/` only; zero `data/` or `domain/` directories exist anywhere
in the repo, zero use cases, zero repository implementations, zero domain
models, and zero feature-level Notifiers. `lib/core/result/` (`Result` /
`Failure`) exists but has no consumers yet.

**This feature is the reference.** Every later feature (progress,
gamification, reminders, trivia, settings) will copy what lands here, so
the layer wiring below is a precedent decision, not a local one.

Partial references that *do* exist and must be followed:

| Convention | Follow |
|---|---|
| Provider declaration + codegen style | `lib/core/time/clock_provider.dart` (`@riverpod` fn + `@riverpod class X extends _$X`), `lib/core/preferences/onboarding_provider.dart` |
| `keepAlive` + `main()` override for infra | `lib/core/database/database_provider.dart` |
| Notifier shape + test style | `lib/core/design/theme/reduce_motion_provider.dart` + `test/core/design/theme/reduce_motion_provider_test.dart` |
| A listener widget that pokes a provider from a lifecycle event | `lib/core/design/theme/reduce_motion_listener.dart` |
| Design component structure (one class per file, token reads via `Theme.of(context).extension<...>()`, `FlowTappable` wrapper, doc comment citing its `CMP-xx` id) | `lib/core/design/components/quick_add_chip.dart` |
| Directory contract | `.claude/skills/flutter-architecture-map/SKILL.md` |

---

## Requirement

Build the app's core loop: log a water intake entry, see today's total
against the daily target, see today's entries.

### In scope

1. **Quick-add logging (APP-01)** — one tap on a `QuickAddChip` writes an
   entry immediately, no confirmation (`FR-020`). Default chip set
   150 / 250 / 350 / 500 ml, ascending (`FR-021`).
2. **Custom amount (APP-02 `AddWaterPage`)** — stepper (±50 ml,
   long-press auto-repeat at 150 ms), direct numeric entry, quick-amount
   chips that *set* the value rather than logging it, 50–2,000 ml bounds,
   a large-amount confirm above 1,000 ml (`FR-023`, `FR-024`).
3. **Today's progress (APP-01)** — consumed ml, target ml, percentage and
   remaining ml, all four visible without scrolling at 360×640 dp
   (`FR-030`), rendered graphically *and* textually (`FR-031`).
4. **Today's entries list** — time + amount, newest first, max 5 rows
   (`FR-036`).
5. **The `DailyHydration` aggregate** — rebuilt in the same transaction
   as the entry insert: `totalMl`, `entryCount`, `goalCompleted`,
   `goalCompletedAt`, `status`, and the `targetMl` snapshot on the day's
   first entry (`BR-17`).
6. **Local-midnight rollover** — today's total resets at local midnight,
   observable without an app restart while foregrounded (`FR-034`).

### Acceptance criteria

- [ ] From `/home`, one tap on the 250 ml chip persists an entry and the
      displayed total increases by 250 ml with no further interaction.
- [ ] `/home/add` logs a custom amount and pops back to `/home` with the
      total already updated.
- [ ] The first entry of a day creates the `daily_hydration` row with
      `target_ml` copied from `user_profiles.daily_target_ml`. Changing the
      profile target afterwards does **not** change that day's `target_ml`
      (`BR-17`, `FR-092`).
- [ ] With zero entries today, the screen shows target, 0 ml consumed, 0%,
      "full target to go", and no `daily_hydration` row is written.
- [ ] `total >= target` sets `goal_completed = 1`, `goal_completed_at` to
      the logging instant, `status = 'complete'`; the display caps the
      graphic at 100% but the text reads the true total (`FR-033`).
- [ ] Amounts below 50 or above 2,000 ml cannot be submitted; the domain
      rejects them with a `ValidationFailure` even if the UI is bypassed.
- [ ] Rapid double-tap on a chip produces one entry, not two (`FR-039`,
      300 ms debounce).
- [ ] The write is committed before success feedback renders (`FR-037`).
- [ ] A storage failure renders an inline error and leaves the displayed
      total unchanged (APP-01 `writeError` state).
- [ ] Airplane mode changes nothing (`FR-035`) — trivially true, no network
      code exists.
- [ ] `flutter analyze` clean, `dart format .` clean, new tests pass.

### Explicitly out of scope (and why)

| Deferred | Reason |
|---|---|
| XP events (`XpEvents` writes), level row, streak chip, `OVL-01` goal celebration | Gamification feature. **Seam to preserve:** the `log` XP event must eventually be written inside the *same* transaction as the entry insert (`BR-08`) — the repository method must therefore be the single transactional entry point, not two calls. |
| Undo (`FR-027`), delete (`FR-028`), edit (`FR-029`) | All three require the `BR-08` reconciliation pipeline (reverse XP, streak, achievements). A reverse that only rebuilds the aggregate would silently leave the ledger wrong the moment XP lands. Ships with gamification. This means today's log list is **read-only** this pass. |
| "See all (N)" → `OVL-12` | The overlay does not exist; a link to nowhere is a dead end (`QA mindset`). Show max 5 rows with no affordance; the link lands with `OVL-12`. |
| `progress_page.dart` (APP-03), `day_detail_page.dart` (`FR-094`) | Separate feature pass. Both need `materialise_missed_days` (`BR-18`) and week-range queries. Their stubs are only *moved*, not implemented, here. |
| `target_settings_page.dart` (APP-08) | Needs `UserProfile` **writes** and the isolated calculator (`07 §5`). Read-only target access is all this pass needs. |
| Onboarding writing `UserProfile` | Owned by the onboarding pass. See § Dependency below — it blocks on-device QA, not implementation. |
| Configurable quick-add amounts (`FR-022`, Should) | Needs APP-10. Hardcode the `FR-021` default set as a documented const. |
| Imperial units | Nothing writes the `unitSystem` pref yet. Metric-only, but **all** formatting goes through one formatter so imperial is a one-file change later. |
| Bloop mascot companion, `CMP-21` fact card, trivia | Separate features. |
| `docs/guide/ui-kit.md` | Stale (documents the deleted `core/ui_kit/`). Do not extend it; do not fix it here either. |

### Is this several features?

No — but it is close to the line. The single justification for keeping
quick-add and the custom-amount screen together is that they share one use
case, one repository method and one transaction; splitting them would mean
writing `LogWater` twice. Everything that *could* be split has been, above.

---

## API contract

**N/A — this feature has no backend call.**

Confirmed, not assumed: `docs/PROJECT_MAP.md` § Network Layer records no
HTTP client in `pubspec.yaml` (no `dio`, no `http`), and
`lib/core/result/failure.dart` states *"FLOW has no backend, so there are
deliberately no network-related cases here."* `08-data-model.md §10` makes
"no data leaves the device" a product guarantee. This is a fully local,
Drift-backed feature.

The contract that *does* need pinning is the **database** contract, and it
is already implemented and hardened. **The code is the source of truth**,
not `08-data-model.md §4`'s SQL:

```dart
// lib/core/database/tables/daily_hydration.dart  — PK is `localDate`,
// NOT `date` as in 08-data-model.md §4
TextColumn get localDate => text()();               // 'YYYY-MM-DD', PK
IntColumn  get totalMl    => integer().withDefault(const Constant(0))();
IntColumn  get targetMl   => integer()...CHECK (target_ml BETWEEN 500 AND 4000);
BoolColumn get goalCompleted   => boolean().withDefault(const Constant(false))();
IntColumn  get goalCompletedAt => integer().nullable()();
IntColumn  get entryCount      => integer().withDefault(const Constant(0))();
TextColumn get status          => text().withDefault(const Constant('noData'))();

// lib/core/database/tables/hydration_entries.dart
TextColumn get id        => text()();                // PK, UUID v4
IntColumn  get amountMl  => integer()...CHECK (amount_ml BETWEEN 50 AND 2000);
IntColumn  get occurredAt=> integer()();             // UTC epoch millis
TextColumn get localDate => text().references(       // FK → DailyHydration.localDate
      DailyHydration, #localDate,
      onDelete: KeyAction.restrict, initiallyDeferred: true)();
TextColumn get source    => text()();                // 'quickAdd'|'custom'|'imported'
IntColumn  get createdAt => integer()();             // UTC epoch millis
```

Three consequences the implementer must not discover the hard way:

1. **The FK is `initiallyDeferred`.** The day's first entry must insert the
   `DailyHydration` row and the `HydrationEntries` row inside **one**
   `transaction()`; either order is fine, but the commit must contain both
   or SQLite raises the constraint. `PRAGMA foreign_keys = ON` is set in
   `beforeOpen` (`app_database.dart`), so this is live, not theoretical.
2. **`onDelete: restrict` runs the "wrong" way on purpose** (documented in
   the table's own comment): deleting the aggregate must never cascade into
   the real entries it summarizes. Nothing in this pass deletes either, but
   the future delete pass must delete entries first, then rebuild.
3. **Drift's generated row classes collide with our domain names.**
   `app_database.g.dart` declares `class HydrationEntry` (the row) and
   `class DailyHydrationData` (the row). Our domain models are
   `HydrationEntry` and `DailyHydration`. Since `domain/` never imports
   Drift, the collision only exists in `data/` — import the database with a
   prefix there: `import '../../../../core/database/app_database.dart' as db;`

### Dependency: where does `targetMl` come from?

`BR-17`: `targetMl` is snapshotted on the day's first entry; before that,
the effective target is `user_profiles.daily_target_ml` (the profile's
*current* target). Confirmed by grep: **nothing in `lib/` writes
`user_profiles` yet** — the onboarding screens are stubs, so no profile row
exists at runtime.

Resolution — this is not a blocker for implementation:

- Reading the active target is a hydration-domain concern, sanctioned by
  `07-technical-architecture.md §3`, which places `user_profile` in
  `features/hydration/domain/entities`. The hydration local data source
  reads `user_profiles.daily_target_ml` directly. **Read-only.** When the
  profile feature lands it owns the writes; hydration keeps its read.
- A missing profile row is an **invariant violation, not a user state**:
  the router already gates `/home` behind `onboardingComplete`
  (`app_redirect.dart`), and `FR-019` requires the profile write and that
  flag to be set in one transaction. So map "no profile row" to
  `StorageFailure`, surfaced as the `writeError` / load-error state. Do
  **not** invent a fallback default target — that would be inventing
  product behaviour.
- **On-device QA is blocked until onboarding persists a profile.** Unit and
  widget tests are not: they seed a profile row into an in-memory
  `AppDatabase`. See § Manual QA.

---

## File plan

Paths are absolute from the repo root. `.g.dart` files are generated by
`build_runner` and are not listed.

### Core (7 new)

- [x] `lib/core/time/local_date.dart` — pure functions: `DateTime` →
      `'YYYY-MM-DD'` local-calendar-date string, and back. The one place
      the `BR-15` day boundary is expressed. Used by data, domain and
      presentation, so it is core, not feature.
- [x] `lib/core/time/today_provider.dart` — `@riverpod String today(Ref)`
      reading `clockProvider`; schedules a `Timer` to the next local
      midnight and `ref.invalidateSelf()`s, which is what makes `FR-034`
      work while foregrounded. Disposes the timer in `ref.onDispose`.
- [x] `lib/core/time/today_refresh_listener.dart` — invalidates
      `todayProvider` on `AppLifecycleState.resumed`, because a timer is
      not guaranteed to fire while the process is suspended. Mirror
      `core/design/theme/reduce_motion_listener.dart`.
- [x] `lib/core/utils/uuid_v4.dart` — `newUuidV4()` from `Random.secure()`.
      ~15 lines, no new dependency. See § Decisions.
- [x] `lib/core/utils/volume_format.dart` — the *only* place volumes become
      strings: `1250 → '1.25 L'`, `750 → '750 ml'`, `0.63 → '63%'`. Metric
      only for now; the seam where `unitSystem` plugs in later.
- [x] `lib/core/design/components/hydration_glass.dart` — `CMP-47
      HydrationGlass`, the product's signature element. 240 dp hero /
      160 dp compact, clipped water-fill layer under the glass sprite, fill
      height `min(current / target, 1.0)`, `motion.slow` and interruptible
      (retargets on rapid logs), success tint at complete, instant jump
      under `reduceMotion`. **Not `CMP-17 HydrationRing`** — the ring was
      superseded on APP-01 by `06-design-system.md` v3.2; do not build it.
- [x] `lib/core/design/components/log_row.dart` — `CMP-22 LogRow`, time +
      amount. Overflow menu is deliberately absent this pass (no
      edit/delete), so this is presentational only.
- [x] `lib/core/design/components/stepper_button.dart` — `CMP-23
      StepperButton`, 64 dp − / +, long-press auto-repeat at 150 ms,
      disabled at bounds. Wrap `FlowTappable` for the semantics.

*(Count reads 8 because the three components are grouped; treat the
component sub-list as its own three items.)*

### Data (5 new)

- [x] `lib/features/hydration/data/datasources/hydration_local_datasource.dart`
      — every Drift statement lives here and nowhere else.
      `watchDay(localDate)`, `watchEntriesForDate(localDate)`,
      `readActiveTargetMl()`, and
      `insertEntryAndRebuildDay({id, amountMl, occurredAt, localDate, source, targetMlIfFirstEntry})`
      as a single `transaction()` (see API contract note 1).
- [x] `lib/features/hydration/data/models/hydration_entry_mapper.dart` —
      `db.HydrationEntry → domain HydrationEntry`, including the `source`
      string → enum parse with an explicit unknown-value branch.
- [x] `lib/features/hydration/data/models/daily_hydration_mapper.dart` —
      `db.DailyHydrationData → domain DailyHydration`, including the
      `status` string → `DayStatus` parse.
- [x] `lib/features/hydration/data/repositories/hydration_repository_impl.dart`
      — implements the domain interface; owns the `targetMl` snapshot
      decision (read the day row; if absent, read the profile target and
      pass it into the transaction) and the `DriftRemoteException`/
      `SqliteException` → `StorageFailure` mapping. **Revised by the
      domain-layer implementer** to match the granular repository
      interface (Decisions #17): `watchToday` split into
      `watchDailyHydration` + `watchEntries`, and `readActiveTargetMl`
      promoted to a public interface method. `hydration_local_datasource.dart`
      needed no change — it was already granular at this level.
- [x] `lib/features/hydration/data/providers/hydration_data_providers.dart`
      — `hydrationLocalDataSourceProvider` (reads `appDatabaseProvider`) and
      `hydrationRepositoryProvider` **typed as the domain interface**
      `HydrationRepository`, matching `07 §` provider graph
      (`hydrationRepositoryProvider ◄── hydrationLocalDataSource, clock`).
      No `requests/` or `responses/` directory — there is no transport.

### Domain (8 new)

- [x] `lib/features/hydration/domain/models/hydration_entry.dart` —
      `HydrationEntry` (`id`, `amountMl`, `occurredAt`, `localDate`,
      `source`, `createdAt`) + `enum HydrationSource { quickAdd, custom, imported }`.
- [x] `lib/features/hydration/domain/models/daily_hydration.dart` —
      `DailyHydration` + `enum DayStatus { noData, inProgress, complete }`.
- [x] `lib/features/hydration/domain/models/today_hydration.dart` — the
      composite read model the dashboard actually needs:
      `effectiveTargetMl`, `totalMl`, `entryCount`, `goalCompleted`,
      `List<HydrationEntry> entries`, plus derived `remainingMl`,
      `progressFraction` (uncapped) and `displayFraction` (capped at 1.0,
      `FR-033`). **Exists because with zero entries there is no
      `daily_hydration` row**, so the target has to come from the profile —
      the screen must not have to know that.
- [x] `lib/features/hydration/domain/models/logged_water.dart` —
      `LoggedWater` (`amountMl`, `newTotalMl`, `goalJustCompleted`), the
      `LogWater` success value. `goalJustCompleted` is what `OVL-01` will
      read later; it costs nothing now and is wrong to reconstruct later.
- [x] `lib/features/hydration/domain/repositories/hydration_repository.dart`
      — abstract interface. **Revised from the single composed
      `watchToday(String localDate)` line-itemed here** to three granular
      reads (`watchDailyHydration`, `watchEntries`, `readActiveTargetMl`)
      plus `Future<Result<LoggedWater>> logWater(...)`. See Decisions #17.
- [x] `lib/features/hydration/domain/usecases/log_water.dart` — validates
      50–2,000 ml (`FR-024`) into `ValidationFailure`, generates the id,
      reads `occurredAt` from the injected `Clock`, derives `localDate` via
      `local_date.dart` (`BR-15`/`BR-16`), delegates the write. **The only
      place an entry is created.** Also exposes `LogWater.minAmountMl` /
      `maxAmountMl` as public constants so `add_water_notifier.dart`
      (presentation, not yet built) clamps to the same bound instead of
      duplicating it.
- [x] `lib/features/hydration/domain/usecases/get_today_hydration.dart` —
      `Stream<TodayHydration> call(String localDate)`. Composes the day
      row, the entry list and the profile-target fallback into one stream
      — genuinely, not as a pass-through, now that the repository interface
      is granular (Decisions #17).
- [x] `lib/features/hydration/domain/providers/hydration_usecase_providers.dart`
      — `logWaterProvider`, `getTodayHydrationProvider`; reads
      `hydrationRepositoryProvider` and `clockProvider`. This file plus the
      data one are the two-file wiring in SKILL § Provider wiring, which
      nothing in the repo demonstrated until now.

### Presentation (10: 2 moved + rewritten, 8 new)

- [x] `lib/features/hydration/presentation/home/home_page.dart` — *moved*
      from `presentation/home_page.dart`, rewritten. Watches
      `todayHydrationProvider` and `homeProvider`; renders the five APP-01
      states (`firstRun`, `empty`, `inProgress`, `complete`/`overTarget`,
      `writeError`). No business logic.
- [x] `lib/features/hydration/presentation/home/home_notifier.dart` —
      `@riverpod class Home extends _$Home`. Owns the *write* half only:
      `quickAdd(int amountMl)`, the 300 ms debounce (`FR-039`), the
      submitting flag, the transient success feedback and the write
      failure.
- [x] `lib/features/hydration/presentation/home/home_state.dart` —
      `HomeState { bool isSubmitting, LoggedWater? lastLogged, Failure? writeFailure }`.
- [x] `lib/features/hydration/presentation/home/today_hydration_provider.dart`
      — `@riverpod Stream<TodayHydration> todayHydration(Ref)` =
      `getTodayHydration(ref.watch(todayProvider))`. Owns the *read* half.
      Split from the notifier deliberately — see § Decisions.
- [x] `lib/features/hydration/presentation/home/widgets/hydration_summary.dart`
      — the glass + all four numbers (`FR-030`), exposed as **one**
      semantics node with the APP-01 a11y string, and a `liveRegion` that
      announces the new total after a log.
- [x] `lib/features/hydration/presentation/home/widgets/quick_add_row.dart`
      — the four `QuickAddChip`s from a documented const list; horizontally
      scrollable under 400 dp; de-emphasised but **still enabled** after
      goal completion.
- [x] `lib/features/hydration/presentation/home/widgets/todays_logs_section.dart`
      — `CPY-110` header + up to five `LogRow`s, newest first; renders
      nothing at all when the list is empty.
- [x] `lib/features/hydration/presentation/add_water/add_water_page.dart` —
      *moved* from `presentation/add_water_page.dart`, rewritten. Stepper,
      tap-to-type amount, value-setting chips, large-amount confirm,
      discard-on-back confirm (`CPY-108`), `Log Water` CTA disabled at 0.
      Pops on success.
- [x] `lib/features/hydration/presentation/add_water/add_water_notifier.dart`
      — amount state, ±50 ml clamped to 50–2,000, the >1,000 ml confirm
      gate, submit via the same `LogWater` use case with
      `source: HydrationSource.custom`.
- [x] `lib/features/hydration/presentation/add_water/add_water_state.dart` —
      `AddWaterState { int amountMl, bool needsLargeAmountConfirm, bool isSubmitting, Failure? failure, bool isDirty }`.

### Mechanical moves (no behaviour change)

- [x] Move the three out-of-scope hydration stubs into the same
      `presentation/<screen>/` shape so the directory is coherent rather
      than half-converted: `progress_page.dart` →
      `presentation/progress/progress_page.dart`, `day_detail_page.dart` →
      `presentation/day_detail/day_detail_page.dart`,
      `target_settings_page.dart` →
      `presentation/target_settings/target_settings_page.dart`. Contents
      untouched. **Partial — see Decisions #35:** the new files exist and
      the router points at them, but the old flat files could not be
      deleted (no file-delete tool available this dispatch).
- [x] `lib/app/router/app_router.dart` — update the five hydration screen
      import paths. No route paths change.
- [x] `lib/app/app.dart` — wrap the router child in
      `TodayRefreshListener`.
- [x] `lib/l10n/app_en.arb` — add the dashboard/logging strings, verbatim
      from `09-content-copy-spec.md`: `CPY-092` "of {target}", `CPY-093`
      "{amount} to go", `CPY-094` "Goal complete", `CPY-097` "A fresh day",
      `CPY-099` "Today's goal", `CPY-100` "+ Add water", `CPY-101` "Tap an
      amount to log your first drink", `CPY-102` "Add Water", `CPY-103`
      "Log water", `CPY-104` "That's a large amount. Log {amount}?",
      `CPY-106` "+{amount}", `CPY-108` "Discard this amount?", `CPY-109`
      "Quick add", `CPY-110` "Today's logs" — plus the APP-01/APP-02 a11y
      strings and a storage-error message. Do **not** touch the dead
      boilerplate keys (`qrScanner*`, `faceCapture*`, `login*`) in that
      file; they belong to a separate cleanup.

### Tests (11 new)

- [x] `test/features/hydration/domain/usecases/log_water_test.dart` — the
      boundary table: 49 / 50 / 2000 / 2001, 0, negative, and a fake
      repository asserting `localDate` comes from the injected `Clock`.
- [x] `test/features/hydration/domain/usecases/get_today_hydration_test.dart`
      — zero-entry day falls back to the profile target; day row wins once
      it exists.
- [x] `test/features/hydration/domain/models/today_hydration_test.dart` —
      `remainingMl` floors at 0; `displayFraction` caps at 1.0 while
      `progressFraction` does not.
- [x] `test/features/hydration/data/repositories/hydration_repository_impl_test.dart`
      — against an in-memory `AppDatabase` (`NativeDatabase.memory()`) with
      a seeded profile: first entry creates the day row and snapshots
      `targetMl`; a later profile-target change does not rewrite it
      (`BR-17`); `goalCompleted`/`goalCompletedAt`/`status` transition
      correctly; the deferred FK commits.
- [x] `test/features/hydration/presentation/home/home_notifier_test.dart` —
      debounce collapses a double-tap to one write; `StorageFailure`
      surfaces without mutating the total.
- [x] `test/features/hydration/presentation/add_water/add_water_notifier_test.dart`
      — stepper clamps; the >1,000 ml gate blocks the first submit and
      passes the second.
- [x] `test/core/time/local_date_test.dart` — DST forward/backward days and
      a timezone change (`BR-16`).
- [x] `test/core/utils/volume_format_test.dart` — 0, 999, 1000, 1250, 2400.
- [x] `test/core/design/components/hydration_glass_test.dart` — fill height
      at 0 / 50% / 100% / 150%; instant jump under `reduceMotion`.
- [x] `test/core/design/components/log_row_test.dart`,
      `stepper_button_test.dart` — the repo's standing rule is one test
      file per component (18/18 currently covered; do not regress that).

**Layer counts:** Core 8 · Data 5 · Domain 8 · Presentation 10 · Tests 11
· Modified/moved 7.

---

## Decisions log

**1. Reads are `Stream<T>`; writes are `Future<Result<T>>`.**
`07 §` says use cases return `Result<T>` and do not throw. That reads
naturally for a write and badly for a live query — `Stream<Result<T>>`
fights Riverpod's `AsyncValue`, which already models loading/data/error.
Chosen: reactive reads return a plain `Stream<T>` whose *errors are
`Failure` instances* (the repository impl maps `SqliteException` →
`StorageFailure` before letting it reach the stream), so the failure
vocabulary stays uniform even though the envelope differs; writes keep
`Future<Result<T>>` because `LogWater` needs a typed `ValidationFailure`
for the 50–2,000 bound. **Rejected:** re-fetching after every write (loses
`FR-034`'s live midnight reset and makes the post-log update a round trip);
`Stream<Result<T>>` (uniform but unusable with `AsyncValue`).
*This is the precedent every later feature will copy — flag it if you
disagree before it is written five more times.*

**2. `domain/models/`, not `domain/entities/`.**
`07-technical-architecture.md §3` says `entities/`; the repo's own
`SKILL.md` § Directory contract says `models/`, and `PROJECT_MAP.md`
§ Test Coverage tracks "Domain models". The repo's contract wins over the
external doc. Same call for `presentation/<screen>/` grouping: SKILL
mandates it for multi-screen features, `07 §3` shows a flat
`presentation/` + `screens/`. SKILL wins.

**3. Home splits into a read provider and a write notifier.**
`todayHydrationProvider` (stream) and `homeProvider` (`HomeState`: submit
flag, transient feedback, write failure). A single Notifier would have to
`watch` the stream in `build()` *and* hold mutable transient state — the
known-awkward Riverpod case, and it makes the transient toast get discarded
on every stream tick. **Rejected:** one `AsyncNotifier<HomeState>` folding
both. Cost of the split: the page watches two providers. `home_state.dart`
still exists, per the SKILL file trio.

**4. `CMP-47 HydrationGlass`, not `CMP-17 HydrationRing`.**
`05-wireframes.md` APP-01 still draws a ring; `06-design-system.md` v3.2
superseded it ("not currently used by any documented screen"). Newer
decision wins. Also cheaper: fill height, no arc painter.
**Asset note, not a blocker:** `assets/icons/onboarding/` already ships
`sprite-glass-shell.svg`, `sprite-glass-outline.svg` and
`sprite-water-fill.svg`. Start from those. If they do not hold up at 240 dp
(they were drawn for onboarding), that is a design task to raise — not a
reason to fall back to a ring.

**5. The three new components go in `lib/core/design/components/`, not a
feature `widgets/` directory.** SKILL says core "if any feature could use
it". Strictly, `HydrationGlass` is hydration-only — but all `CMP-xx`
catalogue components live in that flat directory (all 18 of them,
`QuickAddChip` included, which is equally hydration-specific), each with a
matching test. Consistency with 18 working neighbours beats the purity
argument. Feature-only composites (`hydration_summary`, `quick_add_row`,
`todays_logs_section`) stay in the feature — they are compositions, not
catalogue entries. **No feature has a `widgets/` directory today; this
creates the first one.**

**6. Hand-rolled `uuid_v4.dart` instead of the `uuid` package.**
`pubspec.yaml` has no `uuid`. The requirement is uniqueness within one
device's database and stability across export/import — `Random.secure()`
plus v4 formatting is ~15 lines and testable. Per CLAUDE.md §16, adding a
dependency needs a reason, and "the format has a name" is not one.
**Rejected:** `uuid: ^4.x` — mention it if you would rather have the
canonical implementation; it is a small, well-maintained pure-Dart package
and a defensible alternative.

**7. Plain immutable classes, not `freezed`.**
`freezed`/`freezed_annotation` are declared but **unreferenced anywhere in
`lib/`** — there is no `.freezed.dart` in the repo. Five small value
classes are not worth adding a third code generator to a loop that already
runs `drift_dev` and `riverpod_generator`, in a codebase whose owner is
actively learning the architecture (CLAUDE.md §22, §20 "boring in a good
way"). Hand-written `==`/`hashCode`/`copyWith`. **Rejected:** `freezed`
(less boilerplate, more machinery, no existing precedent to be consistent
with).

**8. Hydration reads `user_profiles` directly; a missing row is a
`StorageFailure`.** See § API contract → Dependency. The alternative — a
hardcoded fallback target — invents product behaviour that no spec
authorises, and would silently paper over a broken onboarding transaction
(`FR-019`).

**9. `status` default disagreement, harmless.** The schema defaults
`status` to `'noData'`; `08-data-model.md §4`'s SQL defaults it to
`'inProgress'`. Every write in this pass sets `status` explicitly
(`inProgress` or `complete`), so the default is never used. Noted so nobody
"fixes" the table and triggers a migration for nothing.

**10. Today's log list is read-only.** Follows from deferring undo/delete/
edit. `CMP-22 LogRow` is therefore built without its overflow menu, and
`05 APP-01`'s "⋯" is deliberately absent. Do not add a disabled menu — a
control that does nothing is worse than no control.

**11. Data layer built before domain — forward references, documented
here so the domain implementer can match them exactly (or deviate with
reason).** `domain/` does not exist yet. `data/repositories/`,
`data/providers/` and both mappers import these not-yet-written paths
and assume these shapes:
- `domain/repositories/hydration_repository.dart`:
  `abstract class HydrationRepository { Stream<TodayHydration> watchToday(String localDate); Future<Result<LoggedWater>> logWater({required String id, required int amountMl, required DateTime occurredAt, required String localDate, required HydrationSource source}); }`
- `domain/models/hydration_entry.dart`: `HydrationEntry(id, amountMl,
  occurredAt: DateTime, localDate, source: HydrationSource, createdAt:
  DateTime)` — `occurredAt`/`createdAt` as rich `DateTime` (UTC), not
  epoch `int`, because `LogWater` reads `occurredAt` from `Clock.now()`
  (a `DateTime`) and epoch-millis is a persistence detail domain
  shouldn't know. Plus `enum HydrationSource { quickAdd, custom,
  imported }`.
- `domain/models/daily_hydration.dart`: `DailyHydration(localDate,
  totalMl, targetMl, goalCompleted, goalCompletedAt: DateTime?,
  entryCount, status: DayStatus)` + `enum DayStatus { noData,
  inProgress, complete }`.
- `domain/models/today_hydration.dart`: constructor takes only the 5
  raw fields (`effectiveTargetMl`, `totalMl`, `entryCount`,
  `goalCompleted`, `entries`) — `remainingMl`, `progressFraction`,
  `displayFraction` are computed getters on the model itself, not
  constructor params, per the plan's "derived" wording.
- `domain/models/logged_water.dart`: `LoggedWater(amountMl,
  newTotalMl, goalJustCompleted)`.
`flutter analyze` will not be clean until `domain/` lands with these
(or corrected) shapes — expected per the task boundary, not a defect
in this layer.

**12. `watchToday` composes the day row, entry list and profile-target
fallback itself, in the repository — not in the `get_today_hydration`
usecase.** The plan's own bullet for `domain/repositories/` types the
interface method as `Stream<TodayHydration> watchToday(String
localDate)` — already the *composed* shape. But a usecase cannot reach
`user_profiles` or the raw entry list without the repository exposing
them, and the repository can only expose a single `Stream<TodayHydration>`
per that signature — so the composition has to happen on this side of
the boundary. Mechanically: `watchDay(localDate).asyncMap(...)`, using
the day-row stream as the sole reactivity driver (every entry write
also writes `daily_hydration` in the same transaction, so this is a
reliable signal) and taking one snapshot each of
`watchEntriesForDate(...).first` and, only when there's no day row yet,
`readActiveTargetMl()`. **Flag for the domain implementer:** the file
plan describes `get_today_hydration.dart` as "not a pass-through: ...
where the day row, the entry list and the profile-target fallback are
composed" — given the above, that usecase will in practice be a thin
delegation to `hydrationRepositoryProvider.watchToday(localDate)`.
Revisit if the interface is meant to be more granular instead (e.g.
separate `watchDailyHydration`/`watchEntries` methods with the usecase
doing the combining) — that would also work and would make the usecase
bullet literally true, but requires a different, more exposed
repository interface than the one line-itemed in the plan.

**13. The repository providers do not depend on `clockProvider`,
despite the plan's provider-graph note
(`hydrationRepositoryProvider ◄── hydrationLocalDataSource, clock`).**
`occurredAt` is supplied to `logWater(...)` by the caller (the
`LogWater` usecase, which the plan's own domain bullet says reads
`Clock`) — the repository has no independent need for "now". Clock
stays wired at the usecase layer only
(`hydration_usecase_providers.dart` per the plan). Flag if the graph
note intended something else.

**14. `insertEntryAndRebuildDay` is an upsert
(`insertOnConflictUpdate`), not a branched insert/update**, and
computes `goalJustCompleted`/`status`/`goalCompletedAt` from the day
row's *prior* state read inside the same transaction, returning both
via a small `HydrationLogWriteResult` (day + `goalJustCompleted`) —
not a new file, just a supporting class in
`hydration_local_datasource.dart`. `created_at` on the entry row
mirrors `occurredAt`; the plan's own signature for this method has no
separate `createdAt` parameter, and nothing backdates an entry this
pass (that is what the out-of-scope `imported` source is for).

**15. Both mapper files convert in both directions**, not just
`db → domain` as their file-plan description says: `hydrationSourceToDb`
lives in `hydration_entry_mapper.dart` because the write path
(repository → data source) needs the same `HydrationSource ↔ String`
vocabulary as the read path, and duplicating it elsewhere would violate
"the only place this string is parsed or produced." `daily_hydration_mapper.dart`
did **not** need a `dayStatusToDb` — the data source writes the
`'inProgress'`/`'complete'` literals directly (it never receives a
domain `DayStatus`), so a reverse converter would be dead code.

**16. Known gap, not a regression: a profile-target change on a
zero-entry day is not observed live by `watchToday`.** Its only
reactivity driver is the `daily_hydration` row (see #12); with zero
entries there is no such row yet, so nothing re-triggers the stream
until the first entry is logged. Unreachable in practice this pass —
nothing writes `user_profiles` yet — but worth a test once profile
writes exist. **Superseded terminology, not substance, by #17:** the
composed stream this describes is now `GetTodayHydration.call`, not a
repository method called `watchToday` — the gap itself (no reactivity
source for a zero-entry day) is unchanged and still applies.

**17. Resolved open question 1 (domain implementer): composition moved
out of the repository and into `GetTodayHydration`, via a more granular
`HydrationRepository` interface.** Revises #12. `hydration_repository.dart`
no longer declares `Stream<TodayHydration> watchToday(String localDate)`;
it declares `watchDailyHydration`, `watchEntries` and
`readActiveTargetMl` instead, and `GetTodayHydration.call` composes them
with `.asyncMap(...)`, mechanically identical to what the repository
used to do internally.
Reasons, in order of weight:
- The file plan's own test bullet —
  `test/features/hydration/domain/usecases/get_today_hydration_test.dart`
  — reads "zero-entry day falls back to the profile target; day row wins
  once it exists." That is a test of the *fallback logic itself*, run
  against the usecase. With composition left in the repository, this
  usecase test could only exercise a pass-through and the fallback logic
  would only be provable against a real Drift database in
  `hydration_repository_impl_test.dart` — which doesn't need it, since
  its own bullets are about the write path (`BR-17` snapshot, `goalCompleted`
  transitions, the deferred FK). Splitting the interface makes both test
  files true to their stated purpose and makes the fallback logic a fast
  unit test against a fake repository instead of only an integration
  test.
- The file plan's `get_today_hydration.dart` bullet says outright "not a
  pass-through" — leaving composition in the repository would have made
  that description false, not just imprecise.
- Application-layer composition of multiple reads into one view model
  (`CLAUDE.md §2.1`'s "coordinating business/application logic") is a
  usecase's job by this project's own layering rules; a repository's job
  is "abstract data access... coordinate data sources," which the
  granular methods already do individually.
**Cost, acknowledged:** `hydration_repository_impl.dart` (data layer,
already built) had to be revised — `watchToday` split into
`watchDailyHydration`/`watchEntries`, `readActiveTargetMl` promoted from
private-to-`logWater` to a public interface method that `logWater` now
calls internally (no behaviour change to the write path).
`hydration_local_datasource.dart` needed **no** change — `watchDay`,
`watchEntriesForDate` and `readActiveTargetMl` were already exposed at
exactly this granularity; the data implementer had simply composed them
one layer higher than the plan's usecase bullet asked for. Domain and
data now agree.

**18. Resolved open question 2 (domain implementer): confirmed, no
change.** `LogWater` reads `clockProvider` in
`hydration_usecase_providers.dart` and passes the resulting `occurredAt`
into `HydrationRepository.logWater(...)` as a parameter; the repository
providers (`hydration_data_providers.dart`) still do not depend on
`clockProvider`, and should not — "now" is supplied by the caller, not
read independently by the repository. This is what #13 already said;
confirming it here closes the flag rather than reopening it.

**19. Gap, not resolved here: `core/time/local_date.dart` and
`core/utils/uuid_v4.dart` do not exist yet.** Both are Core-layer files
(file plan § Core, still unchecked) that `log_water.dart` imports and
calls: `localDateFromDateTime(DateTime dateTime) -> String` and
`newUuidV4() -> String`. `newUuidV4` matches the plan's own named
function exactly. `localDateFromDateTime`'s name is this implementer's
assumption — the plan only specifies the file's *purpose* ("pure
functions: `DateTime` → `'YYYY-MM-DD'` local-calendar-date string, and
back"), not a function name, since Core was out of scope for this
invocation (the task named `data`, `domain`, `presentation` as the three
layers; Core is a fourth bucket nobody has been assigned yet). Treated
the same way the data implementer treated forward references into
`domain/` (Decisions #11): write against the path and name the plan's
intent implies, document the assumption, expect `flutter analyze` to
stay unclean until Core lands with a matching (or corrected) name.
**Flag for whoever builds Core:** `localDateFromDateTime` must derive
the local-calendar date directly from the `DateTime` it's given, with no
`.toUtc()`/`.toLocal()` conversion inside `log_water.dart` — `Clock.now()`
(see `core/time/clock.dart`) is documented as wall-clock time, and
`BR-15`/`BR-16`'s day boundary is defined in the device's local
calendar, so the conversion responsibility belongs entirely inside
`local_date.dart`, not duplicated at each call site.

**20. Core built (ad-hoc dispatch, outside the Data/Domain/Presentation
sequence). `#19`'s gap is closed: `localDateFromDateTime` and
`newUuidV4` match `log_water.dart`'s imports exactly** — verified by
reading `domain/usecases/log_water.dart` directly rather than trusting
the earlier note; no edit to `log_water.dart` was needed.
`local_date.dart` also exports the reverse conversion,
`dateTimeFromLocalDate(String) -> DateTime`, used only by
`today_provider.dart` (nothing in `data/`/`domain/` needed it, despite
the file plan's "and back" wording implying a public reverse function
should exist).

**21. `today_refresh_listener.dart` mirrors `reduce_motion_listener.dart`'s
*shape* (a `ConsumerStatefulWidget` wrapping `child`, poking a provider
from a lifecycle callback) but not its *mechanism*.**
`ReduceMotionListener` reacts to `didChangeDependencies` +
`MediaQuery.disableAnimations`; there is no existing
`WidgetsBindingObserver`/`AppLifecycleState` listener anywhere in `lib/`
to copy instead. Built one from scratch: `initState` registers the
observer, `didChangeAppLifecycleState` calls
`ref.invalidate(todayProvider)` only on `.resumed`, `dispose`
unregisters. The plan's own instruction ("invalidates `todayProvider` on
`AppLifecycleState.resumed`... Mirror
`core/design/theme/reduce_motion_listener.dart`") already anticipated
this split between shape and trigger.

**22. `today_provider.dart` is plain `@riverpod` (autoDispose), not
`keepAlive`.** Nothing in the file plan asked for `keepAlive`, and
unlike `appDatabaseProvider`/`databaseHealthyProvider` (infra that must
survive with no listeners), `todayProvider` recomputing "today" fresh
the next time something watches it is correct behaviour, not a bug —
autoDispose just means the `Timer` gets cancelled and re-created rather
than idling with no watchers.

**23. `HydrationGlass` takes raw `currentMl`/`targetMl` ints (plus a
`HydrationGlassSize` enum, `goalCompleted`, and `reduceMotion` bools),
not a `TodayHydration`/`displayFraction`.** `lib/core/` cannot import a
feature's domain model (`domain/` dependencies only point one way), so
the component clamps `current / target` to `1.0` itself — duplicating
one line of `TodayHydration.displayFraction`'s logic, not the model
itself. The retarget-on-change behaviour (Decisions #4's "interruptible")
comes from `TweenAnimationBuilder`, which re-interpolates from the
animation's current value when its `tween.end` changes mid-flight (the
same mechanism `AnimatedContainer` et al. use) — no
`AnimationController` needed. `reduceMotion` is a caller-supplied bool,
per Decisions #5's precedent that no `CMP-*` component reads Riverpod
state directly; the caller (`hydration_summary.dart`, presentation, not
yet built) is expected to pass `ref.watch(reduceMotionProvider)`. Asset
role assumption, not specified by the plan: `sprite-glass-shell.svg`
renders behind the water fill, `sprite-glass-outline.svg` renders above
it (rim/highlight detail preserved over the liquid) — flag if Figma says
otherwise once someone can check it visually.

**24. `StepperButton` takes an optional `semanticLabel` (default
`null`) rather than a hardcoded accessibility string.** The file plan's
l10n bullet (§ Mechanical moves) lists exact `CPY-*` strings to add and
does not include a stepper accessibility label — inventing one here
would mean adding an unplanned string outside this dispatch's file
list. Per Decisions #5/FlowBackButton's own doc comment, an explicit
`FlowTappable.label` is only needed for icon-only controls with no
visible `Text` descendant; `StepperButton` has a visible "+"/"−" glyph,
so the default (`null`) behaviour — the glyph becomes the accessible
name via `Semantics` folding — matches every other text-bearing `CMP-*`
component. `semanticLabel` exists purely as a seam for
`add_water_notifier.dart`/`add_water_page.dart` to plug a richer
announcement into later, once that copy is decided. Long-press timing:
the plan specifies the 150ms repeat interval but not an initial delay
before repeating starts; chose 400ms (a conventional long-press
threshold) so a quick tap and the start of a hold are distinguishable —
flag if a different number is wanted. **Also not run: `build_runner`.**
This dispatch has no shell access, so `today_provider.g.dart` (the only
new file needing codegen) is not generated — same situation the earlier
domain/data passes were already in for their own providers (no `.g.dart`
exists yet anywhere in `lib/features/hydration/` or even for the
pre-existing `clock_provider.dart`), consistent with the plan's own
"`.g.dart` files are generated by `build_runner` and are not listed"
note, not a new gap this pass introduced.

**25. Presentation built. APP-01's five states are derived, not stored.**
No dedicated UI-state enum is in the file plan (`HomeState` only carries
the write-side fields it names), so `home_page.dart` maps the five
product states from data that already exists: `firstRun` =
`AsyncValue.loading` on `todayHydrationProvider` (nothing emitted yet
this mount); `empty` = loaded with `TodayHydration.entryCount == 0`;
`inProgress` = loaded, entries exist, `!goalCompleted`;
`complete`/`overTarget` = loaded, `goalCompleted`; `writeError` =
`HomeState.writeFailure != null`, rendered as an inline banner *over*
whichever of the above is current rather than replacing it — since
`writeFailure` lives in the separate write-half state, the read stream
(and therefore the displayed total) is provably untouched by a write
failure, satisfying the acceptance criterion directly rather than by
convention.

**26. `/home/add`'s CTA disables below `LogWater.minAmountMl` (50), not
only at exactly `0`.** The file plan's own words for `add_water_page.dart`
say "`Log Water` CTA disabled at 0"; the acceptance criteria require that
"amounts below 50 ... cannot be submitted." The narrower literal reading
would leave 1–49 submittable from the UI (bouncing off a domain
`ValidationFailure` instead of being disabled up front) and contradict
the acceptance criteria, so the wider bound was implemented — `0` is a
subset of `< minAmountMl`, so both readings are satisfied.

**27. Two different amount-clamp ranges inside `add_water_notifier.dart`.**
The stepper (`increment`/`decrement`) clamps to `[minAmountMl,
maxAmountMl]` — matching the file plan's literal "±50 ml clamped to
50–2,000" wording — and can never send the amount back to `0`. Direct
text entry and the value-setting chips both go through `setAmount`,
which clamps to `[0, maxAmountMl]` instead, so the field can go back to
`0` while the user is typing/clearing it — something the stepper
deliberately can't reach, since `0` is only the screen's pristine
"nothing chosen yet" value. `AddWaterState.isDirty` is recomputed as
`amountMl != 0` on every amount change rather than a monotonic
"has this ever changed" flag, so clearing the field back to empty is
treated as "nothing to discard," matching what the discard-confirm is
actually protecting.

**28. `AddWaterNotifier.submit()` returns `Future<bool>`, `true` only on
an actual commit; the page pops, the notifier doesn't navigate.**
Matches `flutter-architecture-map` SKILL § Placement decisions
("Notifiers expose state; pages navigate"). The same method is called
twice for a large-amount log: the first call past 1,000 ml sets
`AddWaterState.needsLargeAmountConfirm` and returns `false` without
writing; `add_water_page.dart` then shows the `CPY-104` dialog and,
on confirm, calls `submit()` again — this time the flag is already
`true`, so it proceeds. This keeps `AddWaterState` to exactly the five
fields the file plan names, with no extra "confirmed" flag needed.

**29. `HomeState`/`AddWaterState.copyWith` use a private `Object? = _unset`
sentinel for their nullable `Failure?` fields**, distinguishing "not
passed" (keep existing) from "explicitly passed `null`" (clear) — the
plain `value ?? this.value` pattern the domain layer's own models use
(e.g. `TodayHydration.copyWith`) can't express clearing a field back to
`null`, which both notifiers need (clearing `writeFailure`/`failure` on
a fresh attempt or a changed amount).

**30. `QuickAddChip` (CMP-04, pre-existing — not part of this workplan's
file list) is not modified; its accessible name is overridden from
outside instead.** `QuickAddChip` hardcodes its own visible label
("150 ML") and relies on `FlowTappable` folding that into the accessible
name — it has no localization or semantics-override hook, and modifying
it is out of scope for this layer. `quick_add_row.dart` wraps each chip
in `Semantics(button: true, label: ...)` over `ExcludeSemantics(child:
QuickAddChip(...))` to satisfy the workplan's Manual QA item 7 ("Chips
must announce 'Add 250 millilitres' with a button role"). The actual
announcement reads "Add 250 ml" — this project's volume-formatter
abbreviation, not the literal word "millilitres" — flag if the exact QA
wording matters.

**31. `CPY-106` ("+{amount}") is used as a post-log badge in
`hydration_summary.dart`, not as `QuickAddChip`'s own label.**
`QuickAddChip`'s label format is fixed (see #30) and isn't driven by
this ARB key, so CPY-106 had no other concrete placement in this pass's
scope. `hydrationJustLogged` renders as a small "+250 ml"-style line
under the numbers when `HomeState.lastLogged` is set.

**32. One ARB key added beyond the plan's named list and its "a11y
strings and a storage-error message" allowance:** `hydrationAmountUnitLabel`
("ml"), a caption under `/home/add`'s stepper. `FlowTextField`
(pre-existing, out of scope to modify) has no unit/adornment slot, and
CLAUDE.md's no-hardcoded-user-facing-string rule is unconditional, so a
plain ARB-backed label was added rather than left as a literal string.

**33. `TodayRefreshListener` wraps `ReduceMotionListener` (which wraps
`MaterialApp.router`) in `app.dart`.** The file plan says to wrap the
router child in `TodayRefreshListener` but not where relative to the
existing listener; nesting order between two independent
`WidgetsBindingObserver`/`didChangeDependencies`-based listeners over
the same subtree doesn't matter functionally, so this is a plain
readability choice, logged per the task's instruction not to skip this
decision silently.

**34. The hydration summary's single semantics label does not narrate
`CPY-101` (the empty-state hint) or `CPY-106` (the just-logged badge) —
both are visually shown but excluded from the merged announcement along
with everything else under `ExcludeSemantics`.** The composed sentence
matches the exact pattern given in the workplan's Manual QA item 7
("Today's progress: 1.25 litres of 2 litres, 63 percent, 750 millilitres
to go"); extending it to also narrate the hint/badge would mean
inventing additional unscripted phrasing beyond that example. Flag if a
screen-reader user should hear those too.

**35. Tool limitation, not a design decision: the five "moved" hydration
screens could not actually be deleted from their old paths.** This
dispatch has no file-delete/move/shell capability — only read/write/edit.
New files were created at the file plan's nested paths
(`presentation/home/home_page.dart`, `presentation/add_water/add_water_page.dart`,
`presentation/progress/progress_page.dart`,
`presentation/day_detail/day_detail_page.dart`,
`presentation/target_settings/target_settings_page.dart`) and
`app_router.dart`'s five imports now point at them exclusively (verified
by grep before editing that nothing else in `lib/` imported the old flat
paths). The old files —
`lib/features/hydration/presentation/home_page.dart`,
`add_water_page.dart`, `progress_page.dart`, `day_detail_page.dart`,
`target_settings_page.dart` — still physically exist, untouched, and are
now dead code (each is a self-contained library, so the duplicate class
names do not collide or break analysis). **The developer should delete
these five files by hand**; nothing in the app references them.

**36. `flutter gen-l10n` and `build_runner` were not run — no shell
access in this dispatch**, consistent with the Core layer's own note in
Decisions #24. Every new `part '...g.dart'` directive
(`today_hydration_provider.dart`, `home_notifier.dart`,
`add_water_notifier.dart`) and every new `AppLocalizations` accessor
referenced in this layer (`loc.hydrationTodaysGoal` and the rest added
to `app_en.arb`) will not resolve until both generators run.
`flutter analyze` and `dart format .` were not run for the same reason
— a final generate → analyze → format pass is still needed before this
feature is gate-clean.

**37. Two defects fixed in already-drafted test files (test-only; no `lib/`
change), plus the file plan's own count corrected.** All eleven files under
§ Tests existed on disk before this dispatch, already substantially
written and matching this repo's fake-repository/`ProviderContainer`
house style — apparently drafted in an earlier, uncommitted session (they
showed up as untracked in `git status`, workplan checkboxes still
unticked). Read every one against its production source and the plan's
own bullet before trusting it, per this agent's own instructions, rather
than assuming "exists" means "correct." Two were not:
- `hydration_repository_impl_test.dart` failed to compile:
  `package:drift/drift.dart` and `package:matcher` (re-exported through
  `flutter_test`) both export `isNull`/`isNotNull`, and Dart's compiler
  refuses the ambiguous import rather than picking one. Fixed with
  `import 'package:drift/drift.dart' hide isNull, isNotNull;` — a
  test-only import fix, not a rewrite.
- `home_notifier_test.dart` had two tests fail at runtime with "Cannot
  use the Ref of homeProvider after it has been disposed": `homeProvider`
  is plain `@riverpod` (autoDispose), and a bare `container.read(...)`
  does not hold a listener the way `home_page.dart`'s `ref.watch(...)`
  does in production. The two failing tests are the ones that insert a
  real `Future.delayed` gap between two `quickAdd` calls (to prove the
  debounce genuinely measures elapsed time) — long enough for Riverpod to
  tear the provider down between calls, which a same-microtask
  double-tap test never hits. Fixed by adding
  `container.listen(homeProvider, (previous, next) {})` in `setUp`,
  mirroring what the real widget's watch does — not a widening of what
  the test asserts. **Not a production defect**: `home_page.dart` always
  watches `homeProvider`, so this teardown-between-calls scenario cannot
  occur on a real screen; it is purely an artifact of driving the
  notifier directly through a bare `ProviderContainer.read()`.

Also: the file plan's own header still read "Tests (10 new)" while
listing eleven bullets (the log_row/stepper_button pair is one bullet
covering two files) — corrected to "Tests (11 new)" to match the
"Tests 11" already stated in the file plan's own layer-count line, not a
new decision, just a copy-paste mismatch closed here.

---

## Gate results

- analyze: clean (`flutter analyze` — 16 pre-existing info-level lints in `test/`, e.g. `deprecated_member_use` on `hasFlag`/`unnecessary_import`, consistent with the same lints already present in untouched sibling component tests; zero errors, zero warnings)
- tests: 251/251 passing (`flutter test`), including all 95 under `test/features/hydration/` + the 6 new/updated `test/core/` files
- localization:
- platform:
- security:

---

## Manual QA for the developer

**Precondition — read this first.** `/home` is unreachable on a device
today: `app_redirect.dart` sends you to `/onboarding/welcome` until
`onboardingComplete` is set, and no onboarding screen sets it. Nothing
writes a `user_profiles` row either, and this feature requires one for the
target. To QA on a device you need to temporarily seed both (set the
`onboardingComplete` pref and insert a profile row with a known
`dailyTargetMl`). **Do not commit that seeding.** Everything below is
blocked until the onboarding pass lands or you seed manually — the
automated tests are not.

Then, on a real device:

1. **One-tap latency (`FR-020`).** Tap the 250 ml chip. Does the total move
   without a perceptible pause? A commit-then-render write (`FR-037`) is
   correct but must still feel instant.
2. **Rapid tapping.** Tap a chip five times fast. Count the entries in the
   list — the debounce should collapse the burst, but genuinely-intended
   repeat logs (~1 s apart) must all land. Only a human can judge whether
   300 ms feels right here.
3. **Glass animation retargeting.** Log three amounts in quick succession
   and watch the fill. It must retarget smoothly, not restart or jump
   backwards.
4. **Local midnight, foregrounded (`FR-034`).** Log something, then leave
   the app open across midnight (or use the dev-flavor `ClockOverride`).
   The total must reset to 0 without a restart, and yesterday's entries
   must vanish from the list without being deleted.
5. **Timezone change (`BR-16`).** Log an entry, change the device timezone
   across a date boundary, return to the app. Yesterday's entry keeps its
   original `localDate`; today's total recomputes. This is the invariant
   most likely to be subtly wrong and it cannot be fully proven in a unit
   test.
6. **200% text scale, 360×640 dp.** All four numbers still visible without
   scrolling (`FR-030`)? Glass shrinks to 160 dp, numeric readout reflows
   below it? Nothing clipped?
7. **Screen reader.** The summary must read as *one* node
   ("Today's progress: 1.25 litres of 2 litres, 63 percent, 750
   millilitres to go"), not five fragments. Chips must announce "Add 250
   millilitres" with a button role. After a log, the new total must be
   announced once — not on every rebuild.
8. **Stepper long-press.** Hold `+`. Does the 150 ms auto-repeat feel
   controllable, and does it stop cleanly at 2,000 with the button
   disabled?
9. **Back with a changed amount.** On `/home/add`, change the amount then
   press back — and also use the Android system back gesture and the iOS
   swipe. All three must hit the discard confirm (`CPY-108`), and the
   confirm must be dismissible.
10. **Goal completion.** Cross the target. The graphic caps at 100%, text
    shows the true total, chips are de-emphasised **but still tappable**,
    and no celebration fires (`OVL-01` is not built yet — if something
    celebrates, something is wrong).
11. **Force-quit mid-log (`FR-037`).** Tap a chip and immediately kill the
    app. On relaunch: either the entry is fully there with a consistent
    aggregate, or it is fully absent. Never a total that disagrees with the
    list.
12. **Haptics (`FR-038`, Could).** Not implemented this pass. Confirm the
    absence is acceptable for now.
