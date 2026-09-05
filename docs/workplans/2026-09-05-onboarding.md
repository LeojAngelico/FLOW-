# Workplan: Onboarding (FLOW-01 · ONB-02 → ONB-08 → first profile write)

Status: tests
Reference feature: **hydration logging** (`docs/workplans/2026-09-04-hydration-logging.md`) | Last agent: flutter-unit-tester

---

## Reference feature

**`lib/features/hydration/` — the only feature in the repo that exists
end to end.** It was built as a deliberate precedent (its Decisions #1,
#2, #5, #7, #17) and everything below mirrors it rather than re-deciding
it:

| Convention | Source |
|---|---|
| Reads are `Stream<T>` / plain values; **writes are `Future<Result<T>>`** with `Failure` in the `Err` branch | hydration Decisions #1 |
| `domain/models/`, not `domain/entities/` (repo SKILL beats `07 §3`) | hydration Decisions #2 |
| Multi-screen features group as `presentation/<screen>/{page,notifier,state}.dart` + `<screen>/widgets/` | SKILL § Directory contract, hydration Decisions #2 |
| Two-file provider wiring: `data/providers/` exposes the repository **typed as the domain interface**; `domain/providers/` builds the usecases | `hydration_data_providers.dart` / `hydration_usecase_providers.dart` |
| Plain immutable classes with hand-written `==`/`hashCode`/`copyWith`; **no `freezed`** | hydration Decisions #7 |
| `copyWith` uses a private `Object? _unset` sentinel wherever a field must be clearable back to `null` | hydration Decisions #29 |
| Every `CMP-xx` catalogue component lives flat in `lib/core/design/components/`, one class per file, doc comment citing its id, tokens read via `Theme.of(context).extension<...>()`, `FlowTappable` for tap + semantics, **one test file per component** | hydration Decisions #5, `quick_add_chip.dart` |
| Components never read Riverpod; `reduceMotion` and friends are caller-supplied bools | hydration Decisions #23 |
| Notifiers expose state, **pages navigate** | SKILL § Placement decisions, hydration Decisions #28 |
| Drift row classes are imported into `data/` under an `as db` prefix to avoid colliding with domain names | hydration Decisions #3 / API contract note 3 |
| Repository impl tests run against a real in-memory `AppDatabase` (`NativeDatabase.memory()`); notifier tests drive a real `ProviderContainer` with a fake repository, holding a `container.listen(...)` so an autoDispose provider is not torn down mid-test | `hydration_repository_impl_test.dart`, hydration Decisions #37 |
| Test helper: `test/support/pump_flow_widget.dart` (`viewportSize` defaults to 360×640) | hydration Decisions #44 |

**Where onboarding legitimately departs:** hydration's state is per
screen. Onboarding's answers span six screens and `FR-018` requires them
to survive Back. That forces one shared draft notifier that no hydration
screen needed — see Decisions #3.

---

## Requirement

Build FLOW's first run: `ONB-02` Welcome → `ONB-03` Basics → `ONB-04`
Weight → `ONB-05` Activity → `ONB-06` Environment & Circumstances →
`ONB-07` Suggested Target (accept or adjust) → `ONB-08` Reminder Setup →
**one** `user_profiles` row + `onboardingComplete = true` → `/home`.

### In scope

1. **The six answer screens** (`ONB-03`–`ONB-08`) plus `ONB-02`, built
   from `13 §14.1`'s game-forward rules — one shared scaffold, game
   canvas, pixel titles, framed panels, solid depth, pixel-art icons
   only, Bloop as a participant. Not a white form with sprites on it.
2. **The draft** — every answer survives Back and Forward (`FR-018`).
3. **Validation at the boundaries** (`FR-003`–`FR-010`, `FR-014`,
   `FR-015`): name ≤ 24 trimmed chars and optional, age 9–120, weight
   25.0–250.0 kg, activity/environment required, manual target
   500–4,000 ml with a non-blocking caution above 3,500, reminder `end`
   strictly after `start`.
4. **The suggested target** — `reference_intake_v1` (`08 §6`) exactly as
   specified, including `BR-42` (`preferNotToSay` → female baseline),
   `BR-43` (half-up to 100 ml, clamp `[minTarget, 4000]`) and the
   `breakdown[]` / `assumptions[]` / `disclaimer` payload that renders
   `OVL-10` (`FR-012`).
5. **`OVL-10` Calculation Method sheet** — rendered from the calculator
   result, not from hardcoded copy (`FR-012`, `05 OVL-10`).
6. **Accept vs Adjust** (`FR-013`) — Accept stores the suggestion with
   `targetSource = suggested`; Adjust switches to the in-place editor
   (±50 ml, slider 500–4,000 ml) and stores `targetSource = manual`.
7. **Reminder preference capture** (`FR-015`, `FR-017`) — window,
   interval, weekdays, live `BR-30` preview; Skip writes
   `enabled = false`. **Preference capture only** — see § Out of scope.
8. **The completion write** (`FR-019`, ENT-01) — the `user_profiles`
   row and the `reminder_settings` update commit in one Drift
   transaction; `onboardingComplete` is set **only after** that commit
   returns; `onboardingCompleteProvider` is then invalidated so the
   router's redirect gate sees the new value.

### Acceptance criteria

- [ ] A fresh install lands on `/onboarding/welcome` and cannot reach
      `/home` until the flow completes.
- [ ] Filling every step and finishing writes exactly one
      `user_profiles` row, `id = 1`, with the answers given, and routes
      to `/home` without a manual restart.
- [ ] `dailyTargetMl` equals the value shown on `ONB-07` at the moment
      of acceptance, and `targetSource` is `suggested` after Accept /
      `manual` after Adjust — even when the adjusted value happens to
      equal the suggestion.
- [ ] `calculatorMethodId` is `reference_intake_v1` on every row.
- [ ] All ten rows of `08 §6.4`'s boundary table produce the stated
      target. An implementation that disagrees with the table is wrong.
- [ ] Back from any step and forward again preserves every entered value
      including partially-typed text (`FR-018`).
- [ ] Age 8 and 121, weight 24.9 and 250.1, a 25-char name: rejected
      inline, Continue disabled, and rejected again by the domain if the
      UI is bypassed.
- [ ] `ONB-07` at 3,600 ml shows `CPY-074` and **still allows Continue**
      (`FR-014` — the caution never blocks).
- [ ] Any special circumstance checked → `CPY-070` visible on `ONB-07`
      **without scrolling**, verbatim (`FR-011`; the wording is binding).
- [ ] Skipping `ONB-08` writes `reminder_settings.enabled = false` and
      still completes onboarding (`FR-017`).
- [ ] Killing the app after the profile commit but before the pref write
      restarts onboarding from `ONB-02`, and finishing a second time
      leaves exactly one profile row (`FR-019`).
- [ ] A storage failure on completion leaves `onboardingComplete` false,
      shows an inline error, and keeps the user on `ONB-08` with the
      draft intact.
- [ ] After completion, `/home` renders a real target instead of the
      `StorageFailure` the hydration feature currently shows — closing
      that feature's documented QA blocker.
- [ ] Double-tapping the final CTA produces one profile row, not two.
- [ ] `flutter analyze` clean, `dart format .` clean, new tests pass.

### Explicitly out of scope (and why)

| Deferred | Reason |
|---|---|
| **`ONB-01` as a Flutter screen** | It is unreachable. `resolveRedirect` fires on `initialLocation: '/'` before `SplashPage` can render — first run redirects to `/onboarding/welcome`, a returning user to `/home`. The DB open it was meant to cover already happens in `main.dart` *before* `runApp`, so the native launch screen fulfils `FR-001`. `splash_page.dart` is restyled to match the native screen (so the handoff does not flash) and given nothing else. `CMP-18 Spinner` is dropped with it — `PrimaryButton` already owns the only loading affordance this flow needs. |
| **`FR-007` unit system (kg/lb, ml/fl oz)** | A half-imperial app is worse than a metric one. Turning it on means ONB-04's field/slider/validation **and** `core/utils/volume_format.dart` **and** ONB-07 **and** APP-08 **and** APP-10's toggle — that is the hydration workplan's own documented seam ("all formatting goes through one formatter so imperial is a one-file change later"). Propose it as its own pass; `UnitConverter` (`core/utils/unit_converter.dart`) already exists and is unused, waiting for it. This pass is metric-only and writes no `unitSystem` pref. |
| **`FR-016` notification permission + `OVL-14` pre-prompt + `BR-34` scheduling** | `flutter_local_notifications` and `timezone` have **zero references** in `lib/` and no `POST_NOTIFICATIONS` manifest entry exists. Building the pre-prompt without the OS prompt behind it is a dead end (`QA mindset`); building the OS prompt means building the notification service, which is `features/reminders/`. **Seam:** `reminder_settings.enabled = true` after this pass means *"the user asked for reminders"*, not *"reminders are scheduled"*. The reminders feature must request permission on its first run and `FR-069`/`APP-09` already specifies the re-enable path for a denial. |
| `UserProgress` creation (FLOW-01's "State changes on completion") | It is **derived, never stored** (`08 §2`, ENT-08). `progress_meta` is already seeded at `onCreate`. Nothing to write. |
| `ReminderSettings` **creation** | Also already seeded at `onCreate` with exactly `FR-015`'s defaults (`app_database.dart` `_seedSingletonDefaults`). Onboarding **updates** row 1; it must not insert. |
| First-run coach mark on `APP-01` | Dashboard feature, `FR-030`-adjacent, needs no onboarding state. |
| `CPY-089b` "Sources" → the full source list | No source list exists in any doc. A link to nowhere is a dead end. Render the assumptions and the disclaimer; omit the row. |
| `recovery_page.dart` | **Not an onboarding step.** `app_router.dart` routes it at `/recovery`, entered only when `resolveRedirect` sees `!databaseHealthy` — it is `ERR-01`, a database-failure screen. Left byte-for-byte alone. It is misfiled under `features/onboarding/` and should move to its own feature later; churning it here would be an unrelated diff. |
| `features/reminders/reminder_settings_page.dart` (`APP-09`) | Its own feature. This pass writes the table it will read. |
| APP-08 target settings (`FR-101`) | Its own pass. It gets the calculator and `UserProfile` for free from this one. |

### Is this several features?

**It is two, and the split is worth making.** The file plan is grouped so
the first stage can be dispatched, reviewed and merged on its own:

- **Stage 0 — the `reference_intake_v1` calculator** (§ Calculator +
  § Domain — hydration shared, 6 files + 1 test). Pure Dart, zero
  Flutter/Riverpod/Drift, exhaustively table-tested against `08 §6.4`.
  `07 §5` calls it *"the single most important architectural decision in
  the product"*; it deserves its own review, and both `ONB-07` and
  `APP-08` depend on it. It is the only part of this plan that can ship
  and be verified with no UI at all.
- **Stage 1 — the onboarding flow** (everything else).

Everything else genuinely is one feature: the acceptance criterion is a
single row plus a single flag, and any earlier cut leaves the app unable
to reach `/home` at all.

**Recommended dispatch order:** Stage 0 → Core components → Data →
Domain (onboarding) → Presentation → l10n/router wiring → gates.

---

## API contract

**Status: confirmed. N/A — this feature has no backend call.**

Confirmed, not assumed: `docs/PROJECT_MAP.md` § Network Layer records no
HTTP client in `pubspec.yaml`, and `lib/core/result/failure.dart` states
*"FLOW has no backend, so there are deliberately no network-related cases
here."* `08 §10` makes "no data leaves the device" a product guarantee.

The two contracts that *do* need pinning are local, and both are
confirmed.

### 1. `user_profiles` — the code is the source of truth

`lib/core/database/tables/user_profiles.dart` is already implemented and
hardened. Where it disagrees with `08 §4`'s SQL, **the code wins**:

```dart
IntColumn  get id                   => integer()();            // PK, always 1
TextColumn get displayName          => text().nullable()...CHECK (length(display_name) <= 24)
IntColumn  get age                  => integer()...NOT NULL CHECK (age BETWEEN 9 AND 120)
TextColumn get sex                  => text()();
RealColumn get weightKg             => real()...NOT NULL CHECK (weight_kg BETWEEN 25.0 AND 250.0)
TextColumn get activityLevel        => text()();
TextColumn get environment          => text()();
TextColumn get specialCircumstances => text().withDefault(const Constant(''))();
IntColumn  get dailyTargetMl        => integer()...NOT NULL CHECK (daily_target_ml BETWEEN 500 AND 4000)
TextColumn get targetSource         => text()();
TextColumn get calculatorMethodId   => text()();
IntColumn  get profileCreatedAt     => integer()();
IntColumn  get updatedAt            => integer()();
```

Five consequences the implementer must not discover the hard way:

1. **The doc's `id = 1` CHECK is not in the Drift table.** `08 §4` writes
   `INTEGER PRIMARY KEY CHECK (id = 1)`; the Dart table has no such
   constraint. Do **not** add it (that is a schema change and a
   migration). Enforce the singleton in the data source by always
   writing `id: 1` with `insertOnConflictUpdate`.
2. **The CHECKs are real and live.** `age`, `weight_kg` and
   `daily_target_ml` will raise `SqliteException` on a bad value, so
   domain validation is a *second* line, not the only one. `weightKg` is
   `REAL`: 25.0/250.0 inclusive, and a value like `250.05` passes the
   CHECK — round to one decimal (`FR-006`) before writing.
3. **Enum encoding follows the hydration precedent**: store the Dart
   enum's `.name` verbatim, camelCase — `'female' | 'male' |
   'preferNotToSay'`, `'sedentary' | 'light' | 'moderate' | 'high' |
   'athlete'`, `'temperate' | 'warm' | 'hot' | 'veryHot'`,
   `'suggested' | 'manual'`. Matches `'quickAdd'`/`'inProgress'` already
   in `daily_hydration`/`hydration_entries`. There is no CHECK on these
   columns, so a typo fails silently at read time — parse with an
   explicit unknown-value branch, as `hydration_entry_mapper.dart` does.
4. **`specialCircumstances` is a comma-joined string** (ENT-01), default
   `''` for none. Write it in a **stable order** (declaration order of
   the enum) so the same selection always produces the same string.
5. **`profileCreatedAt` / `updatedAt` are `IntColumn`** → UTC epoch
   millis, same as `hydration_entries.occurredAt`. ENT-01 types them
   `DateTime UTC`; the domain model keeps rich `DateTime`, the mapper
   converts. `age` is **age at onboarding**, paired with
   `profileCreatedAt` so it can be recomputed later (ENT-01).

`reminder_settings` (`lib/core/database/tables/reminder_settings.dart`)
is likewise already seeded at `onCreate` with `enabled = true`,
`startMinuteOfDay = 480`, `endMinuteOfDay = 1320`,
`intervalMinutes = 120`, `activeWeekdays = '1,2,3,4,5,6,7'` — exactly
`FR-015`'s defaults. Onboarding issues an **update** on `id = 1`.

### 2. `reference_intake_v1` — fully specified, no gaps

`08 §6.2` gives every constant (baselines by age band and sex, reference
weights, the ±600 ml weight clamp, activity/environment deltas,
`FOOD_WATER_FRACTION = 0.25`, half-up rounding to 100 ml, the
`age < 14 ? 1000 : 1200` floor and the 4,000 ceiling) and `08 §6.4` gives
ten worked assertions. Nothing needs inventing.

### 3. `onboardingComplete` — SharedPreferences, key `'onboardingComplete'`

Currently private (`_onboardingCompleteKey` in
`lib/core/preferences/onboarding_provider.dart`) and read-only. See
Decisions #5.

### Open product questions — assumptions, not blockers

None of these gate the profile write; each has a proposed default that
the implementer should follow and the developer should confirm.

| Question | Proposal |
|---|---|
| `ONB-08`'s interval option set. `FR-015`/`CPY-125` give the default (120 min) but no allowed set, and `05` only says "interval sheet". | 30 · 60 · 90 · 120 · 180 · 240 minutes, as a bottom sheet of `SegmentedChoice`-style rows. Rendered from one documented const list so the set is a one-line change. |
| `ONB-04`'s prefilled weight. `05` says "prefilled 65 kg, marked as an estimate" but there is no `CPY-` id for the estimate marker. | Prefill 65.0 kg and reuse `CPY-042` ("An estimate is fine — you can change it any time.") as the marker. No new copy invented. |
| `ONB-08`'s `messageStyle` / `soundId` / `stopWhenGoalMet`. | Not collected in onboarding by any `05`/`09` spec. Leave the seeded defaults (`'friendly'`, `null`, `true`) untouched. `APP-09` owns them. |

---

## File plan

Paths are from the repo root. `.g.dart` files are generated by
`build_runner` and are not listed.

### Calculator — Stage 0 (3 new)

Isolated per `07 §5`: **zero** dependencies on Flutter, Riverpod, Drift
or any other feature; a pure function of its inputs; no clock, no I/O,
no randomness.

- [x] `lib/features/hydration/calculator/hydration_calculator.dart` —
      `abstract interface class HydrationCalculator` with
      `SuggestedHydrationTarget calculate(HydrationInputs inputs)` and
      `String get methodId`, plus `class HydrationInputs` (`age`, `sex`,
      `weightKg`, `activityLevel`, `environment`,
      `specialCircumstances`).
- [x] `lib/features/hydration/calculator/hydration_result.dart` —
      `SuggestedHydrationTarget` (`amountMl`, `amountLiters`,
      `calculationMethodId`, `methodId`, `breakdown`, `assumptions`,
      `disclaimer`, `requiresProfessionalNotice`) + `BreakdownLine`
      (`labelId`, `labelArg`, `deltaMl`, `isSubtotal`). **Strings are
      ids, not prose** — see Decisions #7.
- [x] `lib/features/hydration/calculator/strategies/reference_intake_v1.dart`
      — the `08 §6.2` algorithm, all seven steps, every constant a named
      `static const`. `FOOD_WATER_FRACTION` (0.25) is the one value most
      likely to change after validation and lives in exactly one place.
      Rounding is **half-up** (`(x / 100).round() * 100` — Dart's
      `round()` already rounds half away from zero; state it in a
      comment, because the banker's-rounding variant produces off-by-100
      failures that are tedious to diagnose).

### Domain — hydration shared (3 new)

- [x] `lib/features/hydration/domain/models/profile_enums.dart` — `Sex`,
      `ActivityLevel`, `Environment`, `SpecialCircumstance`,
      `TargetSource`. Its own file so the calculator can import the
      vocabulary without importing `user_profile.dart`, keeping `07 §5`'s
      purity claim literally true. Pure Dart, no imports at all.
- [x] `lib/features/hydration/domain/models/user_profile.dart` —
      `UserProfile` (ENT-01's thirteen fields, `displayName` nullable,
      `specialCircumstances` a `Set<SpecialCircumstance>`,
      `profileCreatedAt`/`updatedAt` as `DateTime`). Lives in
      `hydration/` per `07 §3`, not in `onboarding/`, because hydration,
      settings and APP-08 all read it and only onboarding writes it —
      see Decisions #2.
- [x] `lib/features/hydration/domain/providers/hydration_calculator_provider.dart`
      — `@riverpod HydrationCalculator hydrationCalculator(Ref)` returning
      `const ReferenceIntakeV1()`. Outside `calculator/` because that
      directory may not import Riverpod. `07 §5`'s "swapping strategies
      requires changing one provider override" is this file.

### Core (8 new)

Eight `CMP-xx` catalogue entries that onboarding needs and that do not
exist yet. `13 §14.1` is binding on all of them: pixel-art icons only
(no Material Symbols anywhere in onboarding), the `06 §2.5` frame recipe
(2 dp ink border + 4 dp **solid** depth that collapses on press + 2 dp
inner top bevel), navy labels on bright fills. Build on the existing
`FlowFrameBox` primitive rather than re-implementing the recipe. Every
asset named below already ships in `assets/` and is declared in
`pubspec.yaml`; `flutter_svg` is already a dependency and
`hydration_glass.dart` is the working `SvgPicture.asset` precedent.

- [x] `lib/core/design/components/pixel_icon.dart` — `CMP-42 PixelIcon`.
      Renders one of `assets/icons/onboarding/*.svg` at 16/20/24/32/40/48
      dp. **2 dp per art pixel, never fractional** (`13 §14.1` — a
      fractional scale produces subpixel seams that read as blur).
      Everything else here depends on it.
- [x] `lib/core/design/components/game_panel.dart` — `CMP-40 GamePanel`,
      variants `flat` · `deep` · `milestone`. The onboarding card. Thin
      wrapper over `FlowFrameBox` that fixes the fill/depth/bevel token
      triples so no screen picks them ad hoc.
- [x] `lib/core/design/components/step_header.dart` — `CMP-09 StepHeader`.
      Back chevron (48 dp target, `icon-chevron-left.svg` via
      `PixelIcon`) + "Step N of 5" (`CPY-030`, caller-supplied string —
      the component does not read l10n) + the existing `StepTrack`
      (CMP-44). Used on `ONB-03`–`ONB-07`.
- [x] `lib/core/design/components/cta_section.dart` — `CMP-45 CtaSection`,
      `primary` and `primary+secondary`. The footer on all seven form
      screens; owns the safe-area inset and the gap so it is identical
      everywhere instead of re-typed seven times.
- [x] `lib/core/design/components/brand_mark.dart` — `CMP-20 BrandMark`,
      `mark` and `mark+wordmark`, from `assets/brand/app-icon.svg` /
      `wordmark-lockup.svg`. `ONB-02` and the `/` placeholder.
- [x] `lib/core/design/components/mascot_frame.dart` — `CMP-43 MascotFrame`,
      `bare` · `plinth` · `plinth+particles`. Bloop at 88–120 dp
      (`13 §14.1`), one pose per `13 §9.3`, `sprite-scale-platform.svg`
      as the plinth, ≤ 3 `particle-sparkle.svg`/`particle-bubble.svg`.
      **4 dp per art pixel** for illustration. Particles are static under
      `reduceMotion` (caller-supplied bool, hydration Decisions #23).
- [x] `lib/core/design/components/stat_display.dart` — `CMP-41 StatDisplay`,
      `value+unit` and `value+unit+meter`. `type.pixelHero` value +
      `type.pixelUnit` unit inside a `GamePanel`; the meter puts the
      bright fill on `color.trackDark`, **not** `trackSubtle` (measured
      1.83:1, `06 §2.5`). `ONB-04`'s weight hero.
- [x] `lib/core/design/components/target_hero.dart` — `CMP-54 TargetHero`,
      `viewing` and `editing`. Eyebrow + ± `StepperButton`s (CMP-23,
      exists) + pixel value + `FlowSlider` (CMP-11, exists) + range
      labels. `ONB-07`'s accept/adjust hero; `APP-08` inherits it.

**Check before building:** `PrimaryButton.isLoading` already renders
something. If it is an inline indicator, leave it — do not extract a
`CMP-18 Spinner` this pass (see § Out of scope).

### Data (5 new)

- [x] `lib/features/onboarding/data/datasources/onboarding_local_datasource.dart`
      — every Drift statement, and nowhere else. One method,
      `Future<void> writeProfileAndReminders({required db.UserProfilesCompanion profile, required db.ReminderSettingsCompanion reminders})`,
      wrapping both writes in a single `transaction()`:
      `insertOnConflictUpdate` on `userProfiles` (`id: 1`) and an
      `update(reminderSettings)..where((t) => t.id.equals(1))`. Import
      the database `as db` (hydration Decisions #3).
- [x] `lib/features/onboarding/data/datasources/onboarding_preferences_datasource.dart`
      — `Future<void> setOnboardingComplete()` against
      `SharedPreferences`, using the now-public key from
      `core/preferences/onboarding_provider.dart`. Separate from the
      Drift source because the **ordering between the two stores is the
      whole `FR-019` guarantee** and belongs to the repository, not to a
      data source that happens to hold both handles.
- [x] `lib/features/onboarding/data/models/user_profile_mapper.dart` —
      domain `UserProfile` → `UserProfilesCompanion`. The only place the
      enum `.name` strings, the comma-joined `specialCircumstances`
      encoding and the `DateTime` → epoch-millis conversion exist.
      Write-direction only for now: a `fromDb` reader would be dead code
      this pass (hydration Decisions #15's precedent), and settings/APP-08
      will add it when they need it.
- [x] `lib/features/onboarding/data/repositories/onboarding_repository_impl.dart`
      — implements the domain interface. **Owns the `FR-019` ordering**
      (Decisions #4): commit the transaction, and only if it returns, set
      the pref. Maps `SqliteException`/`DriftRemoteException` →
      `StorageFailure`; a CHECK-constraint violation is still a
      `StorageFailure` (the domain already rejected those values, so
      reaching one is an invariant break, not user input).
- [x] `lib/features/onboarding/data/providers/onboarding_data_providers.dart`
      — the two data-source providers and
      `onboardingRepositoryProvider` **typed as `OnboardingRepository`**.
      No `requests/` or `responses/` — there is no transport.

### Domain — onboarding (7 new)

- [x] `lib/features/onboarding/domain/models/onboarding_draft.dart` —
      the in-progress answers, every field nullable except the ones with
      spec'd defaults: `displayName`, `age`, `sex`, `weightKg`,
      `activityLevel`, `environment`, `specialCircumstances` (defaults
      `{}`), `manualTargetMl`, `reminders`. Plus `bool get
      isReadyForTarget` (everything the calculator needs) and
      `bool get isComplete`. Hand-written `copyWith` with the `_unset`
      sentinel for the nullable fields that must be clearable
      (`displayName`, `manualTargetMl`).
- [x] `lib/features/onboarding/domain/models/onboarding_rules.dart` —
      the bounds and the validators, as pure functions returning
      `ValidationFailure?`: `validateDisplayName` (trim, 0 allowed,
      ≤ 24, emoji allowed — count **runes**, not code units, or a
      two-emoji name fails at 24), `validateAge` (9–120 inclusive),
      `validateWeightKg` (25.0–250.0, one decimal), `validateTargetMl`
      (500–4,000), `isHighTarget` (> 3,500 → `CPY-074`, non-blocking),
      `validateReminderWindow` (`end` strictly after `start`). Bounds are
      public `static const`s so notifiers clamp to the same numbers
      rather than re-typing them — the `LogWater.minAmountMl` precedent.
      **This is why no validation rule lives in a widget** (CLAUDE.md
      § Placement decisions).
- [x] `lib/features/onboarding/domain/models/reminder_preferences.dart` —
      `ReminderPreferences` (`enabled`, `startMinuteOfDay`,
      `endMinuteOfDay`, `intervalMinutes`, `activeWeekdays`) with
      `FR-015`'s defaults as a `const` factory, plus `BR-30`:
      `List<int> reminderMinutes()` = `start, start+interval, …` up to
      **and including** `end`, dropping anything strictly after. The
      `ONB-08` live preview reads this. See Decisions #9 for why it lives
      here and not in `features/reminders/`.
- [x] `lib/features/onboarding/domain/repositories/onboarding_repository.dart`
      — one method:
      `Future<Result<void>> completeOnboarding({required UserProfile profile, required ReminderPreferences reminders})`.
      One method still earns a repository: it is the seam that lets
      `complete_onboarding_test.dart` run against a fake instead of a
      database, and it keeps Drift and SharedPreferences out of `domain/`.
- [x] `lib/features/onboarding/domain/usecases/calculate_suggested_target.dart`
      — `Result<SuggestedHydrationTarget> call(OnboardingDraft draft)`.
      Maps draft → `HydrationInputs` and delegates to the injected
      `HydrationCalculator`. Not a pointless wrapper: it is where an
      incomplete draft becomes a typed `ValidationFailure` instead of a
      null-check crash, and it is the seam that keeps `ONB-07`'s notifier
      from knowing the calculator exists.
- [x] `lib/features/onboarding/domain/usecases/complete_onboarding.dart`
      — `Future<Result<void>> call(OnboardingDraft draft)`. Re-validates
      the whole draft (a `ValidationFailure` here means the UI let
      something through), reads `profileCreatedAt`/`updatedAt` from the
      injected `Clock`, sets `calculatorMethodId` from the calculator's
      `methodId` — never a literal — and resolves `targetSource` from
      whether `draft.manualTargetMl` is set. **The only place a
      `UserProfile` is constructed.**
- [x] `lib/features/onboarding/domain/providers/onboarding_usecase_providers.dart`
      — `calculateSuggestedTargetProvider`, `completeOnboardingProvider`;
      reads `onboardingRepositoryProvider`, `hydrationCalculatorProvider`
      and `clockProvider`. This file plus the data one are SKILL
      § Provider wiring's two-file pattern.

### Presentation (20: 2 moved + rewritten, 18 new)

- [x] `lib/features/onboarding/presentation/onboarding_draft_notifier.dart`
      — `@Riverpod(keepAlive: true) class OnboardingDraftNotifier` whose
      state **is** the domain `OnboardingDraft` (no separate
      `_state.dart` — the state is already a domain model). One mutator
      per step. `keepAlive` is load-bearing: an autoDispose provider is
      torn down while no screen watches it during a route transition,
      which would silently break `FR-018`. Exposes `reset()`, called
      after a successful completion so a future data-reset starts clean.
- [x] `lib/features/onboarding/presentation/widgets/onboarding_scaffold.dart`
      — **the single highest-leverage file in this plan.** `13 §14.1`:
      *"one scaffold across all eight screens."* Owns the
      `color.canvas.game` ground (not white), the pixel environment band
      behind the header, the scattered `color.particle` bubbles (never
      behind body text, `13 §13`), the 16 dp gutter, the 480 dp max
      content width, keyboard avoidance with 16 dp clearance, and the
      slot for `StepHeader` / body / `CtaSection`. If a screen reaches
      for its own `Scaffold`, the game layer stops reading as a system.
- [x] `lib/features/onboarding/presentation/splash/splash_page.dart` —
      *moved* from `presentation/splash_page.dart`. `BrandMark` on the
      game canvas, matching the native launch screen so the handoff does
      not flash. No notifier, no timer, no spinner — it renders for the
      instant before `resolveRedirect` resolves (see § Out of scope).
- [x] `lib/features/onboarding/presentation/welcome/welcome_page.dart` —
      *moved* from `presentation/welcome_page.dart`, rewritten. `ONB-02`:
      `BrandMark`, `CPY-010`/`CPY-011`, three `Pillar`s (CMP-08, exists)
      with `icon-droplet` / `icon-chart` / `icon-lightbulb`, `CPY-018`
      trust line, `CtaSection` → `CPY-019`. Bloop **Curious** per
      `13 §9.3`. Single static state; each pillar is one semantic node.
- [x] `.../presentation/basics/basics_page.dart` — `ONB-03`, step 1/5.
      Name `FlowTextField` (optional, `CPY-045` helper), age
      `FlowTextField` (numeric, `TextInputType.number` +
      `FilteringTextInputFormatter.digitsOnly` — the parameters
      `FlowTextField` gained in hydration Decisions #42), sex
      `SegmentedChoice` (CMP-05), `CPY-039` helper. Continue disabled
      until age and sex are valid.
- [x] `.../presentation/basics/basics_notifier.dart` — writes through to
      the draft on every change; owns only which fields have been
      **blurred** and the currently-shown error, because `05 ONB-03`
      requires validation on blur, not per keystroke. Validation itself
      is `onboarding_rules.dart`.
- [x] `.../presentation/basics/basics_state.dart` —
      `{ bool ageTouched, bool nameTouched, ValidationFailure? ageError, ValidationFailure? nameError }`.
- [x] `.../presentation/weight/weight_page.dart` — `ONB-04`, step 2/5.
      `StatDisplay` hero (tap to type) + `FlowSlider` 25–250 kg step 0.5,
      prefilled 65.0. Bloop **Steady** on the `sprite-scale-platform`
      plinth. The numeric field is the accessible primary control and the
      slider is the enhancement (`05 ONB-04` a11y); the slider exposes
      `Semantics(value: "68 kilograms")` and steps by 1 for screen
      readers.
- [x] `.../presentation/weight/weight_notifier.dart` — keeps the typed
      text and the slider in sync (the hard part: a slider drag must not
      fight a partially-typed field), clamps to
      `OnboardingRules.minWeightKg/maxWeightKg`, rounds to one decimal
      before writing to the draft.
- [x] `.../presentation/weight/weight_state.dart` —
      `{ double weightKg, String fieldText, ValidationFailure? error }`.
- [x] `.../presentation/activity/activity_page.dart` — `ONB-05`, step
      3/5. Five `ChoiceCard`s (CMP-06, exists), `CPY-050`–`CPY-054` split
      at the `·` into title + descriptor. **Radio semantics**
      (`inMutuallyExclusiveGroup: true`, `selected:`) and selection
      carried by check icon + border + accessible state, never colour
      alone (`06 §2.6` rule 1). No notifier — selection goes straight to
      the draft.
- [x] `.../presentation/environment/environment_page.dart` — `ONB-06`,
      step 4/5. 2×2 `IconChoiceTile` grid (CMP-07, exists), divider, four
      `CheckRow`s (CMP-12, exists) with true checkbox semantics, and the
      conditional `InfoCard` (`CPY-071`) with `liveRegion: true` so its
      appearance is announced. No notifier.
- [x] `.../presentation/target/target_page.dart` — `ONB-07`, step 5/5,
      **the most important screen in the flow.** `viewing` shows
      `CPY-072` (binding wording), the value in `TargetHero`, `CPY-073`
      glasses anchor (1 glass = 250 ml), `CPY-075` → `OVL-10`, `CPY-076`,
      then `CPY-077` Accept / `CPY-078` Adjust. `editing` swaps
      `TargetHero` to its editor variant with `CPY-079` / `CPY-080`.
      `CPY-070` renders above the number when any circumstance is set,
      **above the fold** (`FR-011`). `CPY-074` above 3,500 ml as a
      `liveRegion`, non-blocking. **Forbidden on this screen** (`05`):
      the words *must*, *need to*, *required*, *minimum*; any red; any
      urgency framing. Bloop **Encouraging**.
- [x] `.../presentation/target/target_notifier.dart` — calls
      `CalculateSuggestedTarget` once when the screen is first reached,
      holds the result, owns the `suggested → editing → edited`
      transition, ±50 ml clamped to
      `OnboardingRules.minTargetMl/maxTargetMl`, and the revert to
      suggested. Writes `manualTargetMl` to the draft **only** in the
      `edited` state, which is what makes `targetSource` correct.
- [x] `.../presentation/target/target_state.dart` —
      `{ TargetMode mode, SuggestedHydrationTarget? suggestion, int? draftTargetMl, Failure? failure }`
      + `enum TargetMode { suggested, editing, edited }`.
- [x] `.../presentation/target/widgets/calculation_method_sheet.dart` —
      `OVL-10`. A bottom sheet rendered **from**
      `SuggestedHydrationTarget.breakdown[]` / `.assumptions[]` /
      `.disclaimer` (`FR-012`, `05 OVL-10`: "not hardcoded copy"). Maps
      each id to its ARB key (Decisions #7). `CPY-081`–`CPY-089`,
      `CPY-028` "Got it". The Sources row is omitted (§ Out of scope).
- [x] `.../presentation/reminders/reminders_page.dart` — `ONB-08`.
      `CPY-120` Skip top-right at a 48 dp target (a real, visible
      option — `FR-017`), `CPY-121`, three `SettingRow`s (CMP-14, exists)
      opening the native time picker / the interval sheet, seven
      `DayToggle`s (CMP-15, exists), the `InfoCard` live preview
      (`CPY-126`/`CPY-127`), `CPY-128` CTA. Bloop **Happy**. Times
      formatted with `MaterialLocalizations.formatTimeOfDay` — no new
      formatter. **This screen carries the final write**: both Skip and
      the CTA call `submit()`, and the page `context.go('/home')`s on
      success.
- [x] `.../presentation/reminders/reminders_notifier.dart` — the window
      /interval/weekday mutators (through to the draft), the
      `end > start` validation (`CPY-122`, CTA disabled), and the
      submission half: `Future<bool> submit({required bool enabled})`
      calling `CompleteOnboarding`, guarding re-entry while
      `isSubmitting`, invalidating `onboardingCompleteProvider` and
      resetting the draft on `Ok`. Returns `true` only on an actual
      commit; **the page navigates, not the notifier** (hydration
      Decisions #28).
- [x] `.../presentation/reminders/reminders_state.dart` —
      `{ bool isSubmitting, ValidationFailure? windowError, Failure? submitFailure }`,
      `_unset` sentinel on the nullable fields.
- [x] `.../presentation/reminders/widgets/reminder_preview_card.dart` —
      renders `ReminderPreferences.reminderMinutes()` as `CPY-126`
      ("You'll get {count} reminders today: {times}") plus `CPY-127`, in
      an `InfoCard`. Recomputes on every change; `liveRegion`.

### Modified (3) + deleted (7)

- [x] `lib/core/preferences/onboarding_provider.dart` — rename
      `_onboardingCompleteKey` → `onboardingCompleteKey` (public). One
      line. See Decisions #5 for why this rather than converting the
      provider to a Notifier.
- [x] `lib/app/router/app_router.dart` — update the eight onboarding
      import paths to the new `presentation/<screen>/` locations. **No
      route paths change**, and `/recovery`'s import is untouched.
- [x] `lib/l10n/app_en.arb` — add the onboarding strings. **Not verbatim
      from `09-content-copy-spec.md`** — that file does not exist
      anywhere in this repository (confirmed by grep across `docs/` and
      the whole tree before writing a single string); see Decisions #33.
      Added `continueButton`, `onboardingStepLabel` and every
      `onboarding*` key the six answer screens, `OVL-10`, and `ONB-08`
      need — including the ones `welcome_page.dart`/`basics_page.dart`/
      `weight_page.dart` already referenced but that were never added to
      the ARB by the prior cut-off dispatch (see Decisions #32). Did
      **not** touch the dead boilerplate keys (`qrScanner*`,
      `faceCapture*`, `login*`).
- [ ] Delete the seven flat onboarding stubs replaced by
      `presentation/<screen>/` files: `splash_page.dart`,
      `welcome_page.dart`, `basics_page.dart`, `weight_page.dart`,
      `activity_page.dart`, `environment_page.dart`, `target_page.dart`,
      `reminders_page.dart` (eight, counting splash). **`recovery_page.dart`
      stays exactly where it is.** The hydration pass left five orphans
      behind because its dispatch had no delete tool (its Decisions #35);
      **this dispatch repeats that, for the same reason** — no delete/
      shell tool was available in this session either (Read/Edit/Write/
      Grep/Glob only). `app_router.dart`'s imports were repointed at the
      new `presentation/<screen>/` files (confirmed via grep — no other
      file imports the eight old flat paths), so the eight old files are
      genuinely dead, but they were left byte-for-byte on disk rather
      than being hollowed out, matching this task's "do not modify a
      file outside your layer" instruction as closely as an unfixable
      tooling gap allows. **The developer must delete these eight files
      manually**, e.g.:
      `rm lib/features/onboarding/presentation/{splash_page,welcome_page,basics_page,weight_page,activity_page,environment_page,target_page,reminders_page}.dart`

### Tests (19 new)

- [x] `test/features/hydration/calculator/reference_intake_v1_test.dart`
      — **all ten rows of `08 §6.4` verbatim** (`TC-100`–`TC-115`), plus:
      half-up rounding at exactly `x50` (1,050 → 1,100), the ±600 ml
      weight clamp at both ends, the `age < 14` 1,000 ml floor vs the
      1,200 ml floor at 14, `BR-42` (`preferNotToSay` == female result),
      `requiresProfessionalNotice` true iff circumstances are non-empty,
      and that `breakdown[]` deltas sum to the pre-rounding drinking
      total. If the implementation disagrees with the table, the
      implementation is wrong.
- [x] `test/features/onboarding/domain/models/onboarding_rules_test.dart`
      — the boundary table CLAUDE.md §12 asks for: age 8/9/120/121;
      weight 24.9/25.0/250.0/250.1; name ''/'  '/1 char/24/25/emoji at
      the rune boundary; target 499/500/3500/3501/4000/4001; reminder
      windows where end == start, end < start, end = start + interval.
- [x] `test/features/onboarding/domain/models/reminder_preferences_test.dart`
      — `BR-30`: 08:00–22:00 every 120 → 8 times ending exactly at
      22:00; an interval that overshoots `end` drops the overshoot; a
      window shorter than one interval yields exactly one time.
- [x] `test/features/onboarding/domain/models/onboarding_draft_test.dart`
      — `copyWith` clears `displayName`/`manualTargetMl` back to `null`
      via the sentinel; `isReadyForTarget`/`isComplete` flip on exactly
      the right fields.
- [x] `test/features/onboarding/domain/usecases/calculate_suggested_target_test.dart`
      — draft → `HydrationInputs` mapping is faithful; an incomplete
      draft returns `ValidationFailure`, never throws.
- [x] `test/features/onboarding/domain/usecases/complete_onboarding_test.dart`
      — `targetSource` is `manual` when `manualTargetMl` is set **even if
      it equals the suggestion**, `suggested` otherwise;
      `calculatorMethodId` comes from the calculator's `methodId`;
      `profileCreatedAt`/`updatedAt` come from the injected `Clock`; an
      invalid draft is rejected before the repository is touched.
- [x] `test/features/onboarding/data/repositories/onboarding_repository_impl_test.dart`
      — against `NativeDatabase.memory()`: the profile row lands with
      every column correctly encoded (enum names, comma-joined
      circumstances in stable order, epoch millis); `reminder_settings`
      is **updated, not inserted** (still exactly one row);
      **`onboardingComplete` is not set when the transaction throws**
      (the `FR-019` ordering — assert the pref explicitly); running
      completion twice leaves exactly one `user_profiles` row; a
      CHECK-constraint violation surfaces as `StorageFailure`.
- [x] `test/features/onboarding/presentation/onboarding_draft_notifier_test.dart`
      — `FR-018`: values set at step N survive a step N+1 write and a
      return to N; `reset()` clears everything.
- [x] `test/features/onboarding/presentation/basics/basics_notifier_test.dart`
      — no error before blur, error after blur, error clears when the
      value becomes valid.
- [x] `test/features/onboarding/presentation/weight/weight_notifier_test.dart`
      — slider and field stay in sync in both directions; clamps at
      25.0/250.0; rounds to one decimal.
- [x] `test/features/onboarding/presentation/target/target_notifier_test.dart`
      — Accept leaves `manualTargetMl` null; Adjust then Accept sets it;
      revert clears it; ±50 clamps at 500/4,000; `isHighTarget` above
      3,500 does not disable the CTA.
- [x] `test/features/onboarding/presentation/reminders/reminders_notifier_test.dart`
      — Skip submits with `enabled: false` and still succeeds; a
      double-tap produces one `completeOnboarding` call; a
      `StorageFailure` leaves `isSubmitting` false, the draft intact and
      `submit()` returning `false`.
- [ ] Eight component tests, one per new component, per the repo's
      standing one-file-per-component rule (currently 21/21 covered — do
      not regress it): `pixel_icon_test`, `game_panel_test`,
      `step_header_test`, `cta_section_test`, `brand_mark_test`,
      `mascot_frame_test`, `stat_display_test`, `target_hero_test`.

**Layer counts:** Calculator 3 · Domain (hydration shared) 3 · Core 8 ·
Data 5 · Domain (onboarding) 7 · Presentation 20 · Tests 19 · Modified 3
· Deleted 8.

---

## Decisions log

**1. The calculator lives at `lib/features/hydration/calculator/`, per
`07 §5` verbatim — not in `onboarding/`, not in `core/`.**
Onboarding is not its only consumer: `APP-08` (`FR-101`) re-runs it, and
`08 §6.6` requires that swapping the method touch no screen, repository
or table. Putting it under `onboarding/` would make the settings feature
import the first-run feature. Putting it in `core/` contradicts
CLAUDE.md §4 ("do not put feature business logic in `core/` simply
because multiple files use it") — a hydration methodology is domain
logic, not a shared utility. **Rejected:** `core/hydration/calculator/`.
The cost is an accepted onboarding → hydration dependency, which
`07 §5`'s own layout already implies.

**2. `UserProfile` and the profile enums live in
`lib/features/hydration/domain/models/`, per `07 §3`.**
Onboarding is the only *writer*; hydration, settings/`APP-07` and
`APP-08` are all *readers*. Ownership should follow the long-lived
readers, not the one-time writer, or every later feature ends up
importing `features/onboarding/`. `profile_enums.dart` is split out as
its own dependency-free file so `calculator/` can import the vocabulary
without importing `user_profile.dart`, keeping `07 §5`'s "zero
dependencies" claim literally true rather than approximately.
**Rejected:** duplicating the enums inside `calculator/` (two sources of
truth for `preferNotToSay`, guaranteed to drift).
**Note:** this adds three files to the hydration feature. It does not
modify any existing hydration file — `readActiveTargetMl()` and the rest
are untouched.

**3. One shared, `keepAlive` draft notifier plus four screen notifiers —
not eight `{page,notifier,state}` trios, and not one god-notifier.**
The reference feature keeps state per screen, but its screens do not
share data. Onboarding's answers span six screens and `FR-018` makes
their survival a requirement, so `OnboardingDraftNotifier` holds the
answers and each screen writes through to it. `keepAlive` is not a
convenience: an autoDispose provider is disposed when the outgoing route
stops watching it during a transition, which would drop the draft on the
first Back and fail `FR-018` in a way that only shows up on device.
Screen notifiers exist **only** where a screen owns state the draft does
not: `basics` (which field has been blurred), `weight` (typed text vs
slider position), `target` (`suggested`/`editing`/`edited` + the
suggestion), `reminders` (window validation + the submission). `activity`,
`environment`, `welcome` and the `/` placeholder get **no** notifier and
no state file — SKILL: *"Do not create empty layers to complete a
pattern."* **Rejected:** a single `OnboardingNotifier` owning all eight
screens' transient state (it would be rebuilt on every keystroke on
every screen, and every screen's test would need the whole flow's setup).

**4. `FR-019`'s "atomically" is delivered by ordering, because it cannot
be delivered by a transaction.** SQLite and SharedPreferences cannot
share one commit. The requirement's own acceptance criterion is the real
invariant: *"A crash mid-onboarding must not produce a half-created
profile that skips `ONB-02`."* So: profile + reminder settings commit in
one Drift `transaction()`; the pref is set **only after** that returns.
- Crash between the two → `onboardingComplete` stays `false`, onboarding
  restarts, and the leftover row is harmlessly overwritten because the
  write is an `insertOnConflictUpdate` on `id = 1`. Idempotence is what
  makes this ordering safe, and it is asserted in the repository test.
- The reverse order (pref first) yields a user at `/home` with no profile
  row — exactly the state `FR-019` forbids, and exactly the
  `StorageFailure` the hydration feature maps for a missing profile
  (its Decisions #8).
**Rejected:** writing the flag into a Drift `progress_meta` column to get
a real transaction. `08 §1` puts `onboardingComplete` in
SharedPreferences deliberately, because the router's redirect gate needs
it **synchronously before the database opens**. Moving it would break the
gate to fix a weaker problem.

**5. `onboardingCompleteProvider` gets its key made public; the provider
itself is not converted to a Notifier.**
The write needs the key string, and duplicating `'onboardingComplete'` in
the data source would be a second source of truth for a value that must
match exactly or first-run silently repeats forever. A one-word rename is
the smallest change that removes the duplication.
**Rejected:** converting it to `@Riverpod(keepAlive: true) class
OnboardingComplete` with a `markComplete()` method (the `ReduceMotion`
precedent). It reads better, but it would move the pref write into
`core/` and split the `FR-019` ordering across two files — the one thing
Decisions #4 exists to keep in one place. Instead the reminders notifier
calls `ref.invalidate(onboardingCompleteProvider)` after `Ok`.
**Trap for the implementer:** without that invalidation the provider
returns its cached `false`, `resolveRedirect` bounces
`context.go('/home')` straight back to `/onboarding/welcome`, and the
flow appears to loop. This is the single most likely "it compiles and
still doesn't work" failure in this plan.

**6. `ONB-01` is not built. The native launch screen already satisfies
`FR-001`.**
`app_router.dart` sets `initialLocation: '/'` and `resolveRedirect` sends
first-run to `/onboarding/welcome` and a returning user to `/home` — `/`
is never a resting location, so `SplashPage` cannot hold for 1.5 s even
if it wanted to. The work it was specified to cover (open the database,
migrate, decide the redirect) already happens in `main.dart` **before**
`runApp`, which is why `databaseHealthyProvider` is a `main()` override.
Building a Flutter splash would mean adding an artificial delay to show a
screen with nothing to wait for. `splash_page.dart` is restyled to match
the native screen so the handoff does not flash, and `CMP-18 Spinner` is
dropped from the plan with it. **Flag:** if `ERR-01` handling ever moves
to a runtime database open, `ONB-01` comes back and this decision should
be revisited rather than worked around.

**7. The calculator returns string **ids**, not English prose.**
`08 §6.1` types `assumptions` as `List<String>` and `09` says
`CPY-084`–`CPY-088` render from it — but `07 §5` forbids the calculator
from importing Flutter, and localized strings only exist behind
`AppLocalizations`. Prose in a pure Dart class would bypass l10n
permanently. So `assumptions[]`, `disclaimer` and `BreakdownLine.label`
hold stable ids that map 1:1 to ARB keys, and
`calculation_method_sheet.dart` does the lookup. `BreakdownLine` also
carries a nullable `labelArg` (e.g. the activity level's enum name) for
the "Activity (Lightly active)" interpolation. The types in `08 §6.1` are
unchanged; only the *contents* are ids. This keeps `05 OVL-10`'s "not
hardcoded copy" true in the stronger sense — the sheet's **structure**
comes from the calculator and its **wording** from the ARB.
**Rejected:** English prose in the calculator (works today with one
locale, and is a full-day refactor the moment there are two).

**8. `FR-007` (units) is deferred as its own pass, and that is a
deliberate refusal of a Must.** A user who picks `lb` on `ONB-04` and
then sees `2.0 L` on `ONB-07` has been shown a broken app; making the
whole flow imperial means changing `core/utils/volume_format.dart`, which
`APP-01`, `APP-02` and `APP-08` already render through. That is a
coherent single pass across five screens and one formatter — and an
incoherent half-pass here. Metric-only, no `unitSystem` pref written,
`UnitConverter` stays unused and waiting. **Raise this with the developer
before implementation starts**: it is the one Must this plan does not
deliver, and it should be a conscious call rather than a surprise.

**9. `BR-30` (reminder times) lives in onboarding's domain for now.**
`features/reminders/` has a `presentation/` stub and no domain layer, and
creating one from an onboarding workplan means building a feature nobody
asked for. `ONB-08`'s live preview needs the computation today, so it
lands in `reminder_preferences.dart`. **Seam:** when `features/reminders/`
gets its domain layer it should *move* this file (both the model and its
test) rather than reimplement `BR-30` — two implementations of a
scheduling rule that must agree exactly is a bug waiting for a timezone.

**10. Onboarding captures reminder *preferences*; it does not schedule
anything and does not ask for permission.** See § Out of scope for the
reasoning. The consequence worth stating plainly: after this pass, a user
who taps `CPY-128` "Turn on reminders" gets a row that says `enabled = 1`
and **no notifications**, because nothing schedules them yet. That is
acceptable only because the reminders feature is next; if it slips, this
becomes a broken promise in the product's copy and the CTA should be
revisited.

**11. `reminder_settings` is updated, never inserted.**
`app_database.dart`'s `_seedSingletonDefaults` already inserts row 1 at
`onCreate` with exactly `FR-015`'s defaults. An `insert` here throws on
the primary key; an `insertOnConflictUpdate` would work but would hide
the fact that the row is guaranteed to exist. Use `update ... where id =
1` so a zero-row result is a loud invariant failure rather than a silent
new row. Same reasoning for why `UserProgress` (FLOW-01's "State changes
on completion") is a no-op: `08 §2`/ENT-08 make it derived, and
`progress_meta` is likewise already seeded.

**12. The eight new components go in `lib/core/design/components/`, flat,
one test each — not in `features/onboarding/widgets/`.**
Strictly, `StepHeader` and `MascotFrame` are onboarding-only today. But
all 21 existing `CMP-xx` components live in that flat directory
(including `QuickAddChip` and `HydrationGlass`, which are equally
feature-specific), each with a matching test — hydration Decisions #5
settled this and consistency with 21 working neighbours beats the purity
argument. Feature **compositions** (`onboarding_scaffold`,
`reminder_preview_card`, `calculation_method_sheet`) stay in the feature:
they are assemblies, not catalogue entries.

**13. `13 §14.1` is treated as binding on the visual layer, not as
inspiration.** The onboarding screens are built *from* the game system —
`GamePanel` instead of a plain card, pixel titles, `PixelIcon`
everywhere, Bloop posed for each step's emotional context, solid 4 dp
depth as the press affordance. **No Material Symbols anywhere in
onboarding.** The test `13 §14.1` states is the acceptance test for this
layer: *remove the FLOW wordmark, and the screen should still be
unmistakably a game setup screen rather than a generic wellness form.*
This is why `onboarding_scaffold.dart` and `pixel_icon.dart` are listed
first in their sections — every screen composes through them, and a
screen that reaches for its own `Scaffold` or a Material icon breaks the
system for all eight. It is also why the eight components are in this
plan rather than deferred to a later "styling pass": a styling pass
retrofits, and a retrofit is how the previous attempts ended up as a
conventional wellness app with pixel decorations added on top.

**14. Data layer implementer's notes on forward references.**
The data layer was built before the domain layer per the recommended
dispatch order, so it writes against four types `domain/` has not
declared yet: `UserProfile` / the profile enums
(`lib/features/hydration/domain/models/`), `OnboardingRepository` and
`ReminderPreferences` (`lib/features/onboarding/domain/`). `flutter
analyze` will stay unclean until those land — expected, per this
plan's process. Two shapes were assumed that the plan did not pin down
and the domain implementer should either match or correct:
- `UserProfile` has exactly the thirteen ENT-01 fields including `id`
  (always `1`, not exposed to the write path — the mapper hardcodes
  `id: 1` on the companion regardless of what, if anything, the domain
  model carries for it).
- `ReminderPreferences.activeWeekdays` is a `Set<int>` of ISO weekday
  numbers `1`–`7`. The mapper encodes it ascending
  (`1,2,3,4,5,6,7`-shaped), mirroring the stable-order treatment
  `specialCircumstances` gets. If the domain layer instead models
  weekdays as an enum or a `List<int>`, only
  `onboarding_repository_impl.dart`'s `_encodeWeekdays` needs to change.

**15. `weightKg` is rounded to one decimal a second time, in the mapper,
not only in `weight_notifier.dart`.** The API contract note explicitly
frames this as a pre-write concern ("round to one decimal before
writing"), and the mapper is the last code that runs before the value
reaches the `BETWEEN 25.0 AND 250.0` CHECK. Rounding only in the
notifier would make the guarantee depend on every future caller of
`completeOnboarding` going through that one widget's code path;
rounding again in the mapper makes it depend on nothing.

**16. The `ReminderPreferences` → `ReminderSettingsCompanion` conversion
lives as a private function in `onboarding_repository_impl.dart`, not
in its own `data/models/` file.** The file plan lists exactly one
mapper file (`user_profile_mapper.dart`) and describes only the
`UserProfile` encodings, so a second mapper file would be an addition
the plan didn't ask for. The reminders conversion is a direct field
copy plus one join — proportionate to inline, per SKILL's "do not
create empty layers to complete a pattern."

**17. Domain implementer: the data layer's assumed shapes (Decisions
#14) stand, unchanged.** `UserProfile` has exactly the thirteen ENT-01
fields including `id` (`int`, defaults to `1`, documented as never
actually read by the mapper — it hardcodes `id: 1` on the companion
regardless). `ReminderPreferences.activeWeekdays` is `Set<int>` of ISO
weekday numbers `1`–`7`, matching `ENT-07`'s own typing. Field names
(`enabled`, `startMinuteOfDay`, `endMinuteOfDay`, `intervalMinutes`,
`activeWeekdays`; `displayName`, `age`, `sex`, `weightKg`,
`activityLevel`, `environment`, `specialCircumstances`, `dailyTargetMl`,
`targetSource`, `calculatorMethodId`, `profileCreatedAt`, `updatedAt`)
were checked field-by-field against `user_profile_mapper.dart` and
`onboarding_repository_impl.dart` before writing `user_profile.dart` /
`reminder_preferences.dart` / `onboarding_repository.dart`, so the data
layer needs no changes — `OnboardingRepositoryImpl implements
OnboardingRepository` and `UserProfileMapper`/`_toReminderSettingsCompanion`
compile against these shapes as written.

**18. `OnboardingDraft.reminders` defaults to
`ReminderPreferences.defaults()` rather than staying nullable.** The
file plan's field list calls out only `specialCircumstances` as having
a "spec'd default"; every other field in that list, read literally,
would be nullable — including `reminders`. This implementer chose to
give `reminders` a non-null default instead, because `FR-015`'s seeded
values are already a fully-specified, valid answer, and a nullable
`reminders` would push a null-handling branch (what does
`CompleteOnboarding` write if `ONB-08` was skipped and the field was
never touched?) into the one usecase the plan says should *only*
re-validate and construct. With the default in place, Skip is a single
`copyWith(enabled: false)` on already-valid data, and `isComplete`
needs no special case for it. **Flag for the presentation
implementer:** `reminders_notifier.dart`'s `submit({required bool
enabled})` should read the current `draft.reminders`, `copyWith` just
`enabled`, write that through, then call `CompleteOnboarding` — not
construct a fresh `ReminderPreferences` from scratch.

**19. `SuggestedHydrationTarget` carries two ids —
`calculationMethodId` and `methodId` — because the file plan lists both
by name without disambiguating them, and `08 §6.1`'s own contract has
only one field (`calculationMethod`, described as "human-readable
name") for the two.** Decisions #7 already established that no prose
may appear in the calculator, which rules out `08 §6.1`'s literal
"human-readable name" as a raw string. This implementer split the
plan's two names into two ids: `methodId` is the raw machine id
(`'reference_intake_v1'`, written verbatim to
`user_profiles.calculator_method_id`), and `calculationMethodId` is a
second id for the method's *localized display name* on `OVL-10`, which
`ReferenceIntakeV1` currently sets to the same underlying string as
`methodId`. **Flag for the presentation implementer:**
`calculation_method_sheet.dart` needs an ARB key for
`calculationMethodId == 'reference_intake_v1'`'s display name (e.g. a
"Reference daily intake" title) distinct from the `assumptions[]` /
`disclaimer` id vocabulary below. If this reading is wrong and the plan
meant one field doing double duty, only `hydration_result.dart` and
`reference_intake_v1.dart` need to change — nothing downstream depends
on the two ids actually differing.

**20. The breakdown/assumption/disclaimer id vocabulary
(`ReferenceIntakeV1`) is this implementer's invention, not pinned by
any doc.** `08 §6.1`/Decisions #7 require the calculator to emit ids
instead of prose, but no source names the ids themselves. Chosen:
`BreakdownLine.labelId` ∈ `{'baseline', 'weightAdjustment', 'activity',
'environment', 'totalWaterSubtotal', 'foodWaterDeduction',
'drinkingTargetSubtotal'}` (`'activity'`/`'environment'` carry
`labelArg` = the enum's `.name` for interpolation);
`assumptions` ∈ `{'foodWaterFraction', 'weightAdjustmentClamped',
'resultClamped'}` (the latter two only appear when they actually
happened); `disclaimer` = `'referenceIntakeDisclaimer'`. **The
presentation implementer building `calculation_method_sheet.dart` must
map exactly this vocabulary to `CPY-081`–`CPY-089` ARB keys** — these
strings are the contract between this pass and that one; renaming them
without updating both sides silently breaks `OVL-10`.

**21. `reference_intake_v1_test.dart` and the other four domain/usecase
test files listed in § Tests were not written this pass.** The task
that dispatched this layer scoped it to the domain and calculator
*source* files (13 files: 3 calculator + 3 hydration-shared domain + 7
onboarding domain); the file plan's § Tests bucket is listed separately
and was not named in this invocation. All ten `08 §6.4` boundary rows
were hand-verified against `reference_intake_v1.dart`'s logic during
implementation (see this file's inline comments), but that is not a
substitute for the actual test file. **Flag for whoever picks up
`test/features/hydration/calculator/reference_intake_v1_test.dart`:**
it is still unwritten and is this plan's own acceptance criterion
("All ten rows of `08 §6.4`'s boundary table produce the stated
target").

---

**22. This Core dispatch built only the 8 listed component files —
no test files, no barrel, no export additions.** `§ Tests` lists eight
matching component tests as a separately-scoped bucket (same precedent
as Decisions #21 for the domain layer's usecase tests); this invocation
was scoped to `§ Core`'s file list only. **Flag for whoever picks up
`test/core/design/components/{pixel_icon,game_panel,step_header,
cta_section,brand_mark,mascot_frame,stat_display,target_hero}_test.dart`:**
they are unwritten, and the repo's standing "one test file per
component" rule (Decisions #12, currently 21/21 covered) is not yet
restored to green — it will regress to 21/29 until those eight land.

**23. `StepHeader`'s back chevron is built directly from `FlowFrameBox` +
the new `PixelIcon`, not by composing the existing `FlowBackButton`.**
The dispatch's own reuse list named `StepTrack`, `StepperButton` and
`FlowSlider` as existing components to build on, and pointedly did not
name `FlowBackButton` — while separately calling out `PixelIcon` by name
for this exact chevron. `FlowBackButton` renders the same 48dp/depth-3
recipe already (built before `PixelIcon` existed, so it calls
`SvgPicture.asset` directly instead), which makes the two now
near-duplicates. **Flag for the developer:** either accept the
duplication (it is small — one `FlowFrameBox` + one icon each) or, in a
later pass, refactor `FlowBackButton` to wrap `StepHeader`'s chevron (or
vice versa) so there is one 48dp-chevron-button implementation instead
of two. Not fixed here because `back_button.dart` is not in this
dispatch's file list and touching it would be an unrelated diff.

**24. A pre-existing doc-comment conflict, not introduced by this
pass: `back_button.dart` and `setting_row.dart` both already cite
"CMP-42" for `FlowBackButton`'s chevron, while this workplan assigns
CMP-42 to `PixelIcon`.** Neither file is in this dispatch's file list,
so neither was changed. This plan's own catalogue numbering is treated
as authoritative for the 8 new files (per the explicit dispatch
instructions), but the mismatch means the repo now has two components
both claiming CMP-42 in their doc comments. **Flag for the developer:**
one of the two doc comments is wrong and should be corrected in a
follow-up — likely `back_button.dart`'s and `setting_row.dart`'s stale
references, since this workplan is the more recent, more detailed
source for the catalogue numbering.

**25. `GamePanel`'s three variants pick fill/depth pairs by name, not by
spec'd dp/token values (the file plan gives variant names and the "no
screen picks tokens ad hoc" intent, not the exact per-variant tokens):**
`flat` → `surfacePrimary` fill, depth 0 (no offset — a flush, non-card
block); `deep` → `panelDeep` fill, depth 4, paired with `panelDeepInk`
(fixed white) / `panelDeepAccent` (fixed light aqua) content text per
this component's own doc comment; `milestone` → `achievement` gold
fill, depth 4, paired with `onBrandFill` (the same fixed navy
`PrimaryButton.isMilestone` already uses on this exact fill). Radius is
`FlowRadius.lg` (16dp) throughout — the largest scale step below `xl`,
chosen because every other radius in the scale is already claimed by an
existing component (buttons at `sm`, tiles at `md`) and a panel is
visually the largest surface in this set. `StatDisplay` and `TargetHero`
both consume `GamePanel(variant: .deep)` and its paired ink/accent
colors, rather than reaching for `textPrimary`/`textSecondary` — those
flip with the theme and are not guaranteed legible against `panelDeep`,
which does not flip the same way.

**26. `MascotFrame`'s 88-120dp size bound (`13 §14.1`) and its separate
"4dp per art pixel" illustration rule cannot both hold for the shipped
Bloop assets.** `bloop-steady.svg`'s own art-pixel grid is 44x38 (a
6-unit native grid, same convention as the icon set); at a literal
4dp/pixel scale that renders at 176x152dp, well outside 88-120dp. This
implementation honors the explicit numeric range — it is the one a
screen's fixed layout must fit inside — and lets `BoxFit.contain` scale
each pose down to it. **Flag for the developer:** confirm this reading;
if the two constraints were meant to describe different mascot
instances (e.g. a small onboarding footprint vs. a larger dashboard
one) rather than the same `MascotFrame`, only this file's docs and
default `size` need to change, not its structure.

**27. `BrandMark`'s mark width (default 160dp) and `MascotFrame`'s
particle placement/motion (three fixed `Alignment` offsets, a
`FlowMotion.celebrate`-duration scale+fade loop) are this implementer's
invention — no cited section pins exact numbers for either.** Both are
visual defaults a screen can override (`BrandMark.width`) or are
self-contained decoration with no external contract (`MascotFrame`'s
particle motion curve/positions), so getting them exactly right is a
presentation-layer/visual-QA concern, not a domain one. `wordmark-
lockup.svg` was confirmed (via its own `aria-label`, "FLOW wordmark
with Bloop") to already be a single combined asset — `BrandMark` renders
it as one `SvgPicture.asset` call rather than stacking `app-icon.svg`
and the wordmark separately.

---

**28. This presentation dispatch was a continuation of one cut off
mid-way by an infrastructure rate limit, not by an error in its own
work — real progress already existed on disk and no report had been
written.** The following was already built, and is described here
because no prior report existed to describe it: `onboarding_draft_notifier.dart`,
`widgets/onboarding_scaffold.dart`, `splash/splash_page.dart`,
`welcome/welcome_page.dart`, and the full `basics/` and `weight/` trios
(`{page,notifier,state}.dart`). Every file's own doc comments already
explain its individual design (e.g. `onboarding_scaffold.dart`'s "single
highest-leverage file" reasoning, `weight_notifier.dart`'s
text/slider-sync design) — this and the following two entries capture
what was **not** already explained in a doc comment, found only by
reading the code end to end before adding anything.

**29. The prior dispatch's already-built `welcome_page.dart`,
`basics_page.dart` and `weight_page.dart` referenced roughly 25
`AppLocalizations` getters (`onboardingWelcomeHeadline`,
`onboardingStepLabel`, `onboardingBasicsSexHelper`, `continueButton`,
etc.) that did not exist anywhere in `lib/l10n/app_en.arb` or the
generated `AppLocalizations` class — confirmed by grepping the ARB file
and `app_localizations_en.dart` for `onboarding` before writing anything
and finding zero matches.** This means those three screens could not
have compiled against generated localization output as they stood. This
is not a defect introduced by this dispatch; it is the state the cut-off
left behind (the l10n step of its own work was still pending when the
rate limit hit). This dispatch added every one of those pre-existing
references to the ARB, verbatim to the key names already used in the
already-written `.dart` files, rather than renaming the code to match a
different key scheme — changing the working pages would have been an
unrelated diff for a file this dispatch didn't otherwise need to touch.

**30. `09-content-copy-spec.md`, the document the workplan repeatedly
cites for verbatim `CPY-xxx` wording, does not exist anywhere in this
repository.** Confirmed by grepping the whole tree (`docs/`, `lib/`, the
project root) for `content-copy-spec` and for distinctive strings like
`CPY-070`/`CPY-072` before writing a single ARB value — the only hits
were this workplan's own text and `hydration_result.dart`'s doc comment,
both of which merely *cite* the id, never quote its wording. Every
string this pass added to `app_en.arb` is therefore this implementer's
own construction, not a verified verbatim copy — including `CPY-070`
(`onboardingTargetProfessionalNotice`) and `CPY-072`
(`onboardingTargetHeadline`), which the workplan flags as **binding,
do-not-paraphrase** wording. Both were written to honour `ONB-07`'s
stated constraints (no *must*/*need to*/*required*/*minimum*, no
urgency, no red) as closely as possible without the source text, and
both are called out individually in the ARB's own `@`-description
blocks with a flag for the developer to check against the real spec
once it's available. This is the same situation Decisions #21's domain
implementer and the Core dispatch (#22) were already in for their own
unwritten pieces — treated the same way: done as well as possible,
flagged loudly, not silently guessed past.

**31. `ONB-05`/`ONB-06`'s exact `CPY-xxx` numbering (headlines,
subheads, tile/checkbox labels) is likewise this implementer's
construction, not verified against a numbering authority, for the same
reason as Decisions #30.** Where the workplan's file-plan text names a
specific id against a specific string (`CPY-030`, `CPY-039`, `CPY-042`,
`CPY-045`, `CPY-070`–`CPY-080`, `CPY-081`–`CPY-089`, `CPY-120`–`CPY-128`,
`CPY-028`), the ARB's `@`-description cites that id. Where the workplan
only gives a range without pinning which string gets which number inside
it (e.g. `CPY-060`–`CPY-071` covering `ONB-06`'s headline, subhead, four
tile labels, a section header and four checkbox labels — eleven strings
for a twelve-id range once `CPY-070`/`CPY-071` are accounted for
separately), this implementer chose not to assert a specific number per
string rather than risk a false-precision mapping; those ARB entries
describe the string's screen and purpose instead.

**32. `ONB-07`'s disclaimer is rendered from one ARB key
(`onboardingCalcDisclaimer`), reused verbatim on both `ONB-07` (the
plan's `CPY-076`) and inside `OVL-10` (the plan's `CPY-089`), rather than
two separately-worded strings.** Both surfaces render the same
calculator output field (`SuggestedHydrationTarget.disclaimer`, id
`'referenceIntakeDisclaimer'`) — giving them independently-invented
wording risked the two screens disagreeing on what is meant to be the
same disclaimer. If the real copy spec turns out to give these two
placements genuinely different sentences, only this one ARB key needs
to split into two.

**33. `ONB-08`'s interval bottom sheet and the day-letter/day-name ARB
keys are this implementer's addition, built inline in
`reminders_page.dart` rather than as a separate file.** The file plan
lists only `reminders_page.dart`, `reminders_notifier.dart`,
`reminders_state.dart` and `widgets/reminder_preview_card.dart` for
`ONB-08` — no dedicated interval-sheet or day-toggle-row file — so the
picker sheet is a private method on `RemindersPage` rather than a new
file the plan didn't ask for (per this task's "a file you think is
missing is a planning question, not something to add"). Its rows are
built from `FlowTappable` + `PixelIcon` (`icon-check.svg`), explicitly
**not** `ListTile`/`Icon(Icons.check)`, to hold the line on `13 §14.1`'s
"no Material Symbols anywhere in onboarding" rule even inside an
otherwise-unspecified internal picker. `remindersIntervalOptionsMinutes`
(`30, 60, 90, 120, 180, 240`) lives as a top-level const in
`reminders_notifier.dart`, mirroring `weight_notifier.dart`'s
`weightPrefillKg` precedent for an undocumented-but-necessary constant,
per the workplan's own § Open product questions proposal.

**34. `TargetNotifier`'s `editing` vs `edited` distinction is this
implementer's concrete design for a transition the file plan names but
does not fully specify.** The plan says the notifier "owns the
`suggested → editing → edited` transition" and writes `manualTargetMl`
"only in the `edited` state" — but does not say what, if anything,
distinguishes merely *entering* the editor from actually *changing* the
value inside it. This implementer chose: tapping Adjust moves
`suggested → editing` and shows the calculator's own value in the
editor **without** writing `manualTargetMl` to the shared draft; the
first actual stepper tap or slider change moves `editing → edited` and
writes through. This is what makes a user who taps Adjust and
immediately taps Continue without changing anything come out as
`targetSource == suggested`, matching the acceptance criterion
literally ("even when the adjusted value happens to equal the
suggestion" implies an actual edit occurred, not merely opening the
editor). The CTA follows the same two-way split: `suggested` shows
Accept/Adjust (`CPY-077`/`CPY-078`); `editing`/`edited` both show
Continue/"use suggested amount" (the plan's `CPY-080`) — collapsing the
sub-states in the CTA once either is in play, so the button set does
not flicker between two different button pairs while adjusting.

**35. Two accessibility overrides were added on top of already-shipped
Core components, from the feature side, without modifying those Core
files.** `TargetHero` in viewing mode is wrapped in
`Semantics(label: "Your suggested daily target: N millilitres", child:
ExcludeSemantics(...))` so a screen reader gets one merged node instead
of walking the eyebrow and the pixel value separately (manual QA item
12's literal example). The same pattern wraps each `DayToggle` on
`ONB-08` with its full day name (`"Monday"`, not the visible `"M"`),
mirroring the existing `quickAddChipSemantics` precedent for overriding
a visible-text-derived label. Neither `target_hero.dart` nor
`day_toggle.dart` was touched — both overrides live entirely in the
consuming pages, which is the correct seam per `flutter-ui-kit` SKILL
("a component belongs to the shared kit... otherwise the feature's
`widgets/`") for a need specific to these two screens.

**36. Known, pre-existing localization gaps in already-built files were
found but deliberately not fixed by this dispatch.** `basics_page.dart`
(prior dispatch) renders `ValidationFailure.message` directly as
`FlowTextField.errorText` — and `onboarding_rules.dart` (domain layer,
also already built) constructs those messages as hardcoded English
literals, matching an identical, already-shipped pattern in
`hydration/domain/usecases/log_water.dart`. Separately,
`weight_notifier.dart`/`weight_page.dart` pass the literal English word
`'kilograms'` into `FlowSlider.unitLabel`, and `target_hero.dart` (Core)
hardcodes `'milliliters'` the same way — both become a screen reader's
spoken unit and are not behind `AppLocalizations`. All three are real
instances of CLAUDE.md §9/§21's "no hardcoded user-facing string" rule
being broken, but all three are in files this dispatch was not asked to
change (`onboarding_rules.dart` is domain; `target_hero.dart` is Core;
fixing `basics_page.dart`/`weight_notifier.dart` properly means also
threading a localized message through every `OnboardingRules.validate*`
call site, a bigger change than "finish the presentation layer").
Flagged here instead of silently patched or silently shipped — **the
developer should decide whether this is worth a follow-up pass** before
treating onboarding as fully localized.

**37. No `.g.dart` file exists yet for any onboarding notifier —
`onboarding_draft_notifier.g.dart`, `basics_notifier.g.dart`,
`weight_notifier.g.dart`, `target_notifier.g.dart`,
`reminders_notifier.g.dart` — and none of the ARB additions in this pass
have been compiled into `app_localizations_en.dart` either.** This
session's tool set was Read/Edit/Write/Grep/Glob only — no shell/Bash
tool was available to run `dart run build_runner build
--delete-conflicting-outputs` or `flutter gen-l10n`. Both commands must
be run before `flutter analyze` or any test can pass; until then,
analyze will show missing-part-file and missing-getter errors across
every file this pass and the prior one touched. This is a tooling gap,
not a layering one — distinct from the intentional forward-references
Decisions #14/#17/#21/#22 describe, which resolve once the next *layer*
lands; this resolves once someone with a shell runs two commands.

**38. The eight now-superseded flat onboarding files
(`splash_page.dart`, `welcome_page.dart`, `basics_page.dart`,
`weight_page.dart`, `activity_page.dart`, `environment_page.dart`,
`target_page.dart`, `reminders_page.dart`, all directly under
`presentation/`) could not be deleted, for the same reason as
Decisions #37 — no delete/shell tool was available in this session,
matching the hydration pass's own Decisions #35 precedent exactly.**
`app_router.dart`'s imports were repointed at the new
`presentation/<screen>/` locations, and a repo-wide grep for the eight
old import paths turned up only `app_router.dart` itself (already
fixed), so these eight files are now genuinely dead — nothing imports
them — but they remain, byte-for-byte, wherever the prior dispatch (for
`splash_page.dart`/`welcome_page.dart`) or the original scaffold (for
the other six, which were still their original one-line `Scaffold`
stubs) left them. They were left untouched rather than hollowed out to
avoid an unrelated diff to files outside this dispatch's actual layer
of work. **The developer must delete these eight files manually** —
see the exact list and an `rm` command in the file plan's "Modified (3)
+ deleted (7)" section above.

**39. This dispatch wrote the twelve non-widget test files § Tests names
(the calculator, both hydration-shared/onboarding domain models, both
onboarding usecases, the repository implementation, and all five
presentation notifiers) and deliberately left the eight `CMP-xx`
component tests (`pixel_icon_test` through `target_hero_test`)
unwritten.** The dispatching instruction named the calculator's boundary
table, the shared `keepAlive` draft notifier, `TargetNotifier`'s
editing/edited distinction, the `Stream<T>`-reads/`Future<Result<T>>`-
writes pattern, and the data layer's Drift+SharedPreferences ordering by
name, and did not mention the eight components — the same
separately-scoped-bucket treatment the Core dispatch's own Decisions #22
already established for this exact list. The repo's "one test file per
component" count therefore stays at 21/29 after this pass, not 21/21;
whoever picks up the eight component tests should treat Decisions #22's
flag as still open.

Three real findings from writing these tests, none requiring a
production-code change beyond what was already fixed before this dispatch
started:

- **Every onboarding notifier's generated provider is named
  `<name>Provider`, not `<name>NotifierProvider`** (e.g. `weightProvider`,
  `basicsProvider`, `targetProvider`, `remindersProvider` — confirmed by
  reading each `.g.dart` file's `final ... = ...Provider._();` line
  directly, after the naming bug the dispatching agent flagged as
  already-fixed in `lib/` turned out to still trip up a first draft of
  these tests). `onboardingDraftProvider` is the one exception, because
  its class is literally named `OnboardingDraftNotifier` and Riverpod's
  generator strips only the `Notifier` suffix, not `Draft`.
- **`clockProvider` is unusable un-overridden in a plain
  `ProviderContainer` test.** It reads `AppEnvironment.current`, which
  throws `StateError` unless `AppEnvironment.initialize()` has run (only
  `main()` does that). Any test that reaches `completeOnboardingProvider`
  (directly or via `RemindersNotifier.submit()`) must override
  `clockProvider` with a `FixedClock`, the same way
  `hydration/presentation/home/home_notifier_test.dart` already does —
  this is not new, but it is easy to miss the first time a test exercises
  this particular provider chain from the onboarding side.
- **A hand-written fake standing in for a repository whose *documented
  contract* includes a side effect (here, `OnboardingRepository
  .completeOnboarding` setting `onboardingComplete` on success, per
  `FR-019`) must reproduce that side effect, not just the return value.**
  `reminders_notifier_test.dart`'s "submit invalidates
  onboardingCompleteProvider" test initially used a fake that only
  tracked call count and returned `Ok`, leaving the overridden
  `SharedPreferences` instance untouched — `RemindersNotifier`'s
  `ref.invalidate(onboardingCompleteProvider)` then correctly re-read a
  value that had genuinely never changed, so the test's own fake was
  wrong, not the notifier. Fixed by having `_FakeOnboardingRepository`
  accept the same `SharedPreferences` instance and set the flag on
  success, mirroring the interface's documented behaviour rather than
  only its return type.

None of these three are production defects — the first two are testing-
environment setup requirements that already exist elsewhere in the repo,
and the third was a bug in the test double, caught by re-deriving the
expected value from first principles before trusting a red test.

---

## Gate results

- analyze: not run by this dispatch (out of scope for a test-writing pass; see CLAUDE.md's own gate list for the developer to run before merge)
- tests: `flutter test` — 404/404 passing (265 baseline + 139 new: 12 new onboarding/calculator test files below, plus the pre-existing suite unaffected). The 8 `CMP-xx` component tests remain unwritten (Decisions #39) and are not counted here.
- localization:
- platform:
- security:
- documentation:
- scope: this dispatch touched only `test/features/hydration/calculator/reference_intake_v1_test.dart` and eleven files under `test/features/onboarding/` (new files only; no `lib/` file was modified)
- test coverage of new state code: all five onboarding-specific notifiers (`OnboardingDraftNotifier`, `BasicsNotifier`, `WeightNotifier`, `TargetNotifier`, `RemindersNotifier`) now have a test file; the two onboarding usecases and the repository implementation are covered; the calculator's full `08 §6.4` boundary table plus its rounding/clamp/floor edge cases are covered

---

## Manual QA for the developer

Automated tests cover the boundary tables, the ordering and the
notifiers. These are the things only a person holding a device can
settle.

1. **The whole flow, cold, on a real fresh install.** Delete the app,
   reinstall, and complete onboarding without hurrying. Under two
   minutes (`FLOW-01`'s goal)? Where did you hesitate? That hesitation
   is the design problem, and no test will find it.
2. **`13 §14.1`'s own test.** Screenshot each of the seven screens and
   cover the wordmark. Does it still read as a game setup screen, or as a
   clean white wellness form with a pixel mascot on it? If the latter,
   the visual layer is not done, regardless of what the checkboxes say.
3. **Back, everywhere.** From every step, use the in-app back chevron,
   the Android system back gesture **and** the iOS edge swipe. All three
   must preserve the draft (`FR-018`), including text you were
   mid-way through typing. Back from `ONB-02` should exit the app, not
   land on a blank `/`.
4. **Kill the app mid-flow.** At `ONB-05`, force-quit. Relaunch: you
   should be at `ONB-02` with a clean draft and, critically, **not** at
   `/home`. Then complete the flow and confirm exactly one profile row.
5. **Kill the app between the commit and the pref write.** The hardest
   one — use a debug breakpoint between the two if you can. Relaunch must
   restart onboarding, and completing it a second time must leave one
   row, not two (`FR-019`).
6. **Does `/home` actually work now?** This flow closes the hydration
   feature's documented QA blocker. After completing onboarding, the
   dashboard must show your chosen target and log water — no seeding, no
   `StorageFailure` banner.
7. **`ONB-07` with a special circumstance.** Check "I'm pregnant" on
   `ONB-06`. `CPY-070` must be visible on `ONB-07` **without scrolling**,
   at default text size *and* at 200% (`FR-011`). Read the whole screen
   aloud: does anything on it sound prescriptive? The words *must*,
   *need to*, *required* and *minimum* are forbidden here, and so is any
   red.
8. **`ONB-07` above 3,500 ml.** Adjust to 3,600. `CPY-074` appears, is
   announced, and **Continue still works** (`FR-014`). A caution that
   blocks is a bug.
9. **The number has to feel right.** Put your own real details in and
   look at the suggestion. Does it feel plausible? `01 §12` A1 records
   this as an unvalidated assumption — this is the first moment anyone
   can judge it, and if it feels wrong the calculator is the thing to
   question, not the screen.
10. **200% text scale at 360×640 dp, every screen.** Pixel type falls
    back to Inter above 130% (`13 §14.1`) — check the fallback actually
    fires and nothing clips. The hydration pass shipped a 4 dp
    `RenderFlex` overflow at this exact viewport (its Decisions #44);
    `ONB-04`'s hero + slider and `ONB-08`'s seven day toggles are the
    two most likely repeats.
11. **Keyboard avoidance on `ONB-03` and `ONB-04`.** Focus the last
    field on a short device. The field must scroll into view with
    clearance above the keyboard, the Continue button must remain
    reachable, and the return key must move to the next field.
12. **Screen reader, end to end.** Each `ChoiceCard` on `ONB-05` must
    announce as a radio in a group with its selected state; the `ONB-06`
    checkboxes as real checkboxes; the conditional info cards must be
    announced **when they appear**, not only when focused; `ONB-07`'s
    number must read as "Your suggested daily target: 2 litres, 2000
    millilitres" as one node; the `ONB-04` slider must announce "68
    kilograms" and step by 1.
13. **Reduced motion.** With the OS setting on, Bloop's sparkles must be
    static and nothing should scale in. Motion is decoration here and
    must be fully removable (`10 §7`).
14. **Skip the reminders.** Tap `CPY-120`. Onboarding must complete, and
    `APP-09` must later show reminders off — not on with a silent
    failure (`FR-017`).
15. **Turn reminders on and then look for one.** None will arrive —
    scheduling is the next feature (Decisions #10). Confirm you are
    comfortable shipping that gap, or hold the CTA copy until the
    reminders pass lands.
16. **Double-tap the final CTA, hard.** One profile row. Then repeat with
    the device in airplane mode and with storage nearly full, if you can
    arrange it — the failure path must leave you on `ONB-08` with your
    answers intact and a readable error, never on a half-configured
    `/home`.
