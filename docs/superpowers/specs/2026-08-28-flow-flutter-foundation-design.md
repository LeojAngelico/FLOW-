# FLOW Flutter Foundation — Design Spec

Status: Approved by user (2026-08-28), ready for implementation planning.

## 1. Context

FLOW is a fully offline hydration-tracking app (mascot "Bloop", light gamification:
XP/levels/titles/achievements, local reminders, daily trivia, sharing) with **no
accounts, no backend, no network calls, and no analytics anywhere** — this is an
architectural constraint enforced by the product's own CI gates
(`CI-11`/`CI-12`: no network/analytics dependency, no `INTERNET` Android
permission), not a V1 deferral.

The current repository is a renamed Flutter boilerplate (`oiracam.flow.bloop` /
"FLOW") originally built for a REST-backed, account-based incident-reporting app.
This spec defines the **foundation-only** pass that prepares the project for FLOW
screen development, matching the scope the product's own roadmap
(`12-backlog-roadmap.md`) defines as "Phase 3 — Flutter Foundation" (`EP-01`,
stories `US-001`–`US-008`). It does **not** implement any FLOW feature screens —
only architecture, dependencies, design system, data schema, navigation
skeleton, and a small foundational component set.

Source documentation (primary source of truth for this spec):
`/Users/leojangelicomacario/Downloads/docs/00-README.md` through `13-brand-visual-system.md`,
plus `/Users/leojangelicomacario/Downloads/docs/assets/`.

**Design-token and component verification source:** the Figma file "FLOW —
Onboarding v2" (`fileKey GGCrpp5JI69VK0kLguM40b`,
https://www.figma.com/design/GGCrpp5JI69VK0kLguM40b/) — a "00 Foundations"
page with live Figma-variable color/type/spacing bindings, and a "01
Components" page with built components far beyond the onboarding scope. Where
this file and the written docs disagree, Section 6 and Section 8 below note
the correction and which source won (generally: Figma, since it's the more
current, maintained artifact — its own color swatches are explicitly annotated
as "live bindings, not pasted hex").

## 2. Scope decisions (confirmed with user)

### Removed entirely (from `lib/` and `pubspec.yaml`)
- Packages: `dio`, `flutter_secure_storage`, `geolocator`, `camera`,
  `mobile_scanner`, `google_mlkit_face_detection`, `image_picker`
- Code: `lib/features/auth/`, `lib/core/network/`, `lib/core/storage/`,
  `lib/core/auth/`, `lib/core/qr_scanner/`, `lib/core/face_capture/`,
  `lib/core/signature_pad/`, `lib/core/models/` (avatar, date_created,
  general_response — REST-response helpers with no FLOW equivalent)
- `lib/l10n/app_fil.arb`, `lib/l10n/app_ceb.arb` and their generated delegates

Rationale: none of these apply to an offline, account-less, camera/QR/signature-free
app. Keeping them would misrepresent the architecture and, in the case of `dio`/
`flutter_secure_storage`, would directly violate FLOW's own "no network
dependency" CI gate if left in `pubspec.yaml` even unused.

### Relocated (preserved, not deleted)
- The auth feature + network client (`dio`, `api_client.dart`,
  `auth_interceptor.dart`) + secure-storage usage move to
  `reference/auth-and-network/` at the **repository root**, outside `lib/` and
  outside the Flutter build entirely (not analyzed, not compiled, not part of
  `pubspec.yaml`). Preserved purely as a copyable pattern in case a future,
  currently undocumented phase adds accounts. A short `README.md` in that folder
  explains why it's there and what re-adding it requires (re-adding `dio` +
  `flutter_secure_storage` to `pubspec.yaml`, moving the code back under
  `lib/features/auth/`).

### Kept, re-themed or adapted
- `lib/core/image_viewer/` — kept as-is (per user decision; may be reused for
  achievement/share-card image previews later)
- `lib/core/ui_kit/` — folder *pattern* kept, but token **values** and the
  `CMP-01`–`CMP-15` component implementations are rebuilt wholesale to FLOW's
  design system, not incrementally patched onto the old tokens
- `lib/core/errors/` — kept, adapted: FLOW's `Failure`→copy-key pattern
  (`09-content-copy-spec.md` §1, CPY-190–199) replaces network-specific error
  codes with validation/storage/permission failure categories
- `lib/core/widgets/bottom_navigation/`, `lib/app/router/`, `lib/app/theme/` —
  folders kept, contents rebuilt
- `lib/core/environment/` — kept, `dev`/`prod` flavors only (drop `alpha` — not
  mentioned anywhere in FLOW's docs; trivial to re-add later if wanted)
- `lib/l10n/` infrastructure (ARB-based externalization, ICU plural/placeholder
  support) — kept; `app_en.arb` content will be rewritten to FLOW's copy-spec
  keys in a later phase, not this pass. English-only for V1 per
  `09-content-copy-spec.md`: "English ships at launch; the key structure
  supports localisation later."
- Package identifier `oiracam.flow.bloop` / app name `FLOW` — already correct
  from the prior cleanup pass, no change needed.

## 3. Dependencies

### Add
| Package | Type | Why |
|---|---|---|
| `riverpod_annotation` | dependency | Codegen provider annotations |
| `riverpod_generator` | dev dependency | Codegen provider generation |
| `drift` | dependency | Mandated local database — typed SQL, real migrations, date-range queries |
| `sqlite3_flutter_libs` | dependency | Bundles SQLite engine for drift on mobile |
| `drift_dev` | dev dependency | Drift codegen |
| `shared_preferences` | dependency | `onboardingComplete`, theme, unit system — needed before the DB opens |
| `flutter_local_notifications` | dependency | Local reminder scheduling |
| `timezone` | dependency | DST-safe scheduling, mandatory per `07-technical-architecture.md` |
| `share_plus` | dependency | OS share sheet for achievement cards |
| `path_provider` | dependency | Temp dir for share-card PNGs and export/import JSON |
| `freezed_annotation` | dependency | Immutable model annotations |
| `freezed` | dev dependency | Immutable model codegen (`copyWith`, equality) |
| `json_annotation` | dependency | Export/import serialization annotations |
| `json_serializable` | dev dependency | Export/import serialization codegen |
| `build_runner` | dev dependency | Codegen runner for all of the above |
| `flutter_svg` | dependency | **Not in the docs' package table — flagged gap.** Every brand/illustration asset provided is `.svg`; Flutter's `Image` widget cannot render SVG natively. This is the de facto standard, actively maintained package and the only reasonable way to use the provided assets at all. |

### Remove
`dio`, `flutter_secure_storage`, `geolocator`, `camera`, `mobile_scanner`,
`google_mlkit_face_detection`, `image_picker`

### Keep unchanged
`flutter_riverpod`, `go_router`, `permission_handler`, `intl`, `cupertino_icons`,
`flutter_lints`, `flutter_test`

### Explicitly not added
- Any HTTP client (forbidden by `NFR-01`/`CI-11`)
- `google_fonts` — fetches fonts over the network by default; incompatible with
  FLOW's zero-network-at-runtime architecture. Real Inter and Press Start 2P
  font files are instead fetched once (dev-time asset acquisition, not a
  runtime dependency) and bundled locally.
- `fl_chart` — explicitly rejected in `07-technical-architecture.md` ("`APP-03`
  needs seven horizontal bars. A dependency for that is unjustified.")
- `get_it`/`injectable` — Riverpod already composes dependencies
- `hive`/`isar` — Drift chosen instead, per the docs
- `material_symbols_icons` — Flutter's built-in `Icons.*_rounded` variants are
  visually the same rounded design language and already bundled; not worth a
  new dependency for a stylistic match that's free

### Deferred (not built this pass)
Custom analyzer lints for `CI-04`–`CI-12` (no Flutter in `domain/`, no raw
colors outside `core/design/`, no `DateTime.now()` outside `core/time/clock.dart`,
etc.). Building real `custom_lint` analyzer rules is a nontrivial side-project
and the docs don't specify an implementation. This pass satisfies these rules
*by construction* (correct folder boundaries, a `Clock` abstraction, tokens-only
colors) but does not build enforcement tooling. Flagged as a follow-up.

## 4. Architecture & folder structure

Feature-first layout per `07-technical-architecture.md` §3:

```
lib/
├── core/
│   ├── design/
│   │   ├── tokens/
│   │   │   ├── flow_colors.dart
│   │   │   ├── flow_typography.dart
│   │   │   ├── flow_spacing.dart
│   │   │   ├── flow_radius.dart
│   │   │   ├── flow_elevation.dart
│   │   │   └── flow_motion.dart
│   │   ├── theme/
│   │   │   ├── flow_theme.dart
│   │   │   └── flow_theme_extension.dart
│   │   └── components/            # CMP-01 … CMP-15 (Section 8)
│   ├── time/
│   │   └── clock.dart              # injectable Clock; no raw DateTime.now() elsewhere
│   ├── result/
│   │   └── result.dart             # sealed Result<T>/Failure types
│   ├── database/
│   │   ├── app_database.dart       # Drift schema + migration harness (Section 5)
│   │   └── tables/                 # one file per table
│   ├── ui_kit/                     # legacy folder pattern; superseded pieces
│   │                                # removed as CMP-01–15 replace them
│   ├── image_viewer/                # kept as-is
│   ├── errors/                      # kept, adapted (Section 2)
│   ├── environment/                  # dev/prod flavors
│   └── widgets/bottom_navigation/    # kept, re-themed
├── features/
│   # created only when this pass needs a route target inside them —
│   # placeholder screen only, no domain/data logic (Phase 4+ builds those)
│   ├── onboarding/presentation/      # 8 step screens (placeholders)
│   ├── hydration/presentation/       # home/add/progress placeholders
│   ├── gamification/presentation/    # awards/achievement-detail placeholders
│   ├── reminders/presentation/       # reminder-settings placeholder
│   ├── trivia/presentation/          # trivia placeholder
│   └── settings/presentation/        # profile/settings/about placeholders
├── app/
│   ├── router/                       # rebuilt (Section 7)
│   ├── theme/                        # wiring to core/design
│   └── main_shell.dart               # 4-tab shell, re-themed
├── l10n/                             # kept, app_en.arb only
└── main.dart
```

No `domain/`/`data/` subfolders are pre-created for features with no code yet —
an empty, untracked directory isn't useful scaffolding. `sharing/` and `brand/`
(mentioned in the docs' folder list) are not created in this pass since nothing
in the foundation scope needs a route or screen inside them yet.

## 5. Data layer

### Drift schema (`US-005`) — build now, matching `08-data-model.md` exactly

Tables (all fields, types, and constraints per the data-model doc):

- **`user_profiles`** (singleton, `id=1`): `id`, `displayName` (String?, ≤24
  chars), `age` (int, CHECK 9–120), `sex` (enum: female/male/preferNotToSay),
  `weightKg` (double, CHECK 25.0–250.0), `activityLevel` (enum:
  sedentary/light/moderate/high/athlete), `environment` (enum:
  temperate/warm/hot/veryHot), `specialCircumstances` (comma-joined TEXT of
  enum: pregnancy/breastfeeding/medicalCondition/other), `dailyTargetMl` (int,
  CHECK 500–4000), `targetSource` (enum: suggested/manual),
  `calculatorMethodId` (String), `profileCreatedAt` (UTC epoch millis),
  `updatedAt` (UTC epoch millis)
- **`hydration_entries`**: `id` (UUID PK), `amountMl` (int, 50–2000),
  `occurredAt` (UTC epoch millis), `localDate` (TEXT `YYYY-MM-DD`, immutable
  once set), `source` (enum: quickAdd/custom/imported), `createdAt` (UTC epoch
  millis). Indexes on `localDate`, `occurredAt`.
- **`daily_hydration`** (materialized aggregate, one row/date): `date` (TEXT
  PK), `totalMl` (int, ≥0), `targetMl` (int, 500–4000, snapshotted on first
  entry of day, never rewritten after), `goalCompleted` (bool),
  `goalCompletedAt` (UTC epoch millis, nullable), `entryCount` (int, ≥0),
  `status` (enum: noData/inProgress/complete)
- **`xp_events`** (append-only ledger): `id` (UUID PK), `type` (enum:
  log/goalComplete/streakMilestone/trivia/achievement), `amount` (int, CHECK
  ≥0), `localDate` (TEXT), `occurredAt` (UTC epoch millis), `refId` (String?).
  Unique index on `(type, localDate) WHERE type='goalComplete'`.
- **`achievements`** (16 seeded rows): `key` (String PK), `unlocked` (bool),
  `unlockedAt` (UTC epoch millis, nullable), `progressCurrent` (int, cached).
  Name/description/group/threshold/XP live in a **const Dart catalogue**, not
  the DB.
- **`trivia_progress`**: `itemId` (String PK, matches bundled `trivia.json`),
  `type` (enum: fact/quiz), `seenAt` (nullable), `completed` (bool),
  `answeredCorrectly` (bool?, null for facts), `awardedXp` (bool)
- **`reminder_settings`** (singleton): `enabled` (bool, default true),
  `startMinuteOfDay` (int, default 480), `endMinuteOfDay` (int, default 1320,
  must be > start), `intervalMinutes` (int, default 120, one of
  30/45/60/90/120/180/240), `activeWeekdays` (comma-joined TEXT, default all 7),
  `messageStyle` (enum: friendly/plain/minimal, default friendly), `soundId`
  (String?), `stopWhenGoalMet` (bool, default true, immutable in V1)
- **`progress_meta`**: `id` (INTEGER PK CHECK id=1), `best_streak` (INTEGER,
  default 0) — high-water mark, since `bestStreak` isn't fully derivable after
  a partial data import/merge

Migration harness: `MigrationStrategy` with `onCreate` (creates all tables,
seeds the 16-item achievement catalogue, seeds reminder defaults),
`onUpgrade` (one schema version step at a time, never skipping), `beforeOpen`
(`PRAGMA foreign_keys = ON`). Schema version starts at 1, stored in both Drift
and `SharedPreferences`.

**Not built this pass:** repository interfaces/implementations, use cases, or
any CRUD logic on top of this schema — that's Phase 4 ("Core Hydration") work
per the roadmap. This pass delivers the schema and migration harness only.

### Core abstractions (`US-006`)
- **`Clock`** (`core/time/clock.dart`) — injectable; a `SystemClock` default and
  an overridable clock for the `dev` flavor's "debug clock override" feature
  (mentioned in `07-technical-architecture.md` §15). No other file may call
  `DateTime.now()` directly.
- **`Result<T>`/`Failure`** (`core/result/result.dart`) — sealed-class result
  type for the Repository→UseCase→Notifier boundary. `Failure` subtypes cover
  validation, storage, and permission categories — no network-related cases
  (none apply).
- **`UnitConverter`** — mL↔fl oz (`1 fl oz = 29.5735 ml`) and kg↔lb
  (`1 lb = 0.453592 kg`) conversions, since storage is always metric and
  imperial is presentation-only (`BR-40`/`BR-41`).

### DI/provider graph (`US-007`)
Riverpod codegen (`@riverpod`) provider tree: `Clock`, the Drift `AppDatabase`,
and `SharedPreferences` (resolved asynchronously in `main()` before `runApp`,
overridden into the `ProviderScope`, mirroring how `AppEnvironment.initialize()`
already works today). App must boot to the placeholder home screen with zero
errors and `flutter analyze` clean.

## 6. Design system & theme

Full token set from `06-design-system.md`, implemented as a
`ThemeExtension<FlowTokens>` (never raw literals outside `core/design/`).

### Color tokens
Both light and dark palettes are fully specified in the source doc (dark mode
is a V1 blocker, not an auto-inversion — "deep foundation navy" background,
independently designed). Implement verbatim:

**Brand (theme-independent):** `brand.primary` `#2FB6F0` (text-safe
`#0A6E9E`), `brand.primaryPressed` `#085A82`, `brand.secondary` `#8B6BF2`
(text-safe `#6947C7`), `xp` `#8BD450` (text-safe `#3F7D1E`), `achievement`
`#FFC542` (text-safe `#8A5A00`), `reward` `#FF7A59` (text-safe `#C6431F`),
`pixelWorld.yellow` `#FFE066` (illustration-only), `streak` `#B45309`
(warm — never red).

**Light semantic tokens:** `background.primary` `#FFFFFF`, `surface.primary`
`#F7FAFD`, `surface.tinted` `#E4F5FD`, `border` `#D7DEE6`, `borderStrong`
`#AEBBC8`, `text.primary` `#101A2E`, `text.secondary` `#4A5763`,
`text.disabled` `#6B7885`, `onPrimary` `#FFFFFF` (⚠ fails WCAG 1.4.3 on bright
fills — see button rule below), `trackSubtle` `#DCE6EF`, `success` `#147A52`
(surface `#E4F5EE`), `streak` surface `#FDF1E3` (text `#8A4B00`), `error`
`#C22A2E` (surface `#FCEBEA`), `info` `#0A6E9E` (surface `#E6F2FB`), `warning`
`#A85A08` (surface `#FDF8EC`), `scrim` `#101A2E` @ 60%.

**Dark semantic tokens:** `background.primary` `#101A33`, `surface.primary`
`#182347`, `surface.tinted` `#1C2B57`, `border` `#2A3A66`, `borderStrong`
`#3D4F8A`, `text.primary` `#EAF2FF`, `text.secondary` `#A9B8D6`,
`text.disabled` `#8593A1`, `brand.primary` `#2FB6F0` (7.45:1, AAA),
`brand.secondary` `#A488FF`, `xp` `#8BD450`, `achievement` `#FFC542`, `reward`
`#FF7A59`, `onPrimary` `#08243A`, `trackSubtle` `#22315C`, `success` `#2FBE79`,
`streak` `#F5A15C`, `error` `#FF6B6B`, `warning` `#FFA940`, `scrim` `#000000` @
70%.

**Game-surface/frame tokens (§2.5, used by pixel-framed components).**
**Correction from Figma verification:** the written doc presented these as a
single theme-independent table, but the actual Figma variable bindings show
`canvas.game`, `panel.deep`, and `trackDark` are genuinely theme-dependent —
confirmed by inspecting the file's bound variables directly, not just its
light-mode swatches:

| Token | Light | Dark |
|---|---|---|
| `canvas.game` | `#E4F5FD` | `#101A33` (= dark `background.primary`) |
| `panel.deep` | `#085A82` | `#06405E` |
| `panel.deepAccent` | `#7FDBFA` | `#7FDBFA` (same) |
| `trackDark` | `#143A52` | `#0C2436` |

Theme-independent (confirmed unchanged across both modes in Figma):
`panel.deepInk` `#FFFFFF`, `frame.ink` `#0B1E36`, `frame.depth` `#0A3E5C`
(never blurred), `frame.bevel` `#5FCBF5` @ 35%, `particle` `#7FDBFA` @ 30%,
`brand.primaryActive` `#1C9AD1`.

**Gradients (exactly 3):** `gradient.hero` (160°, `brand.primary` →
`brand.primaryPressed`), `gradient.share` (180°, `brand.primary` → `#083A5E`),
`gradient.tsunami` (135°, `achievement` → `brand.secondary`, used in exactly 2
places: Level 99 badge and Tsunami-rarity trophies/badges).

**Color rule (enforced by construction, not lint, this pass):** every vivid
brand hue is fill/icon-only; text/small icons on light surfaces use the
text-safe variant. Bright-fill controls (primary CTA, selected segment,
milestone CTA) use `text.primary` navy labels, not `onPrimary` white, because
white-on-`brand.primary` fails WCAG 1.4.3 (2.32:1).

**Gaps filled with a judgment call (flag for design confirmation):**
1. `gradient.water` (hydration-glass fill) is referenced but never defined
   anywhere in the source doc. **Default:** mirror `gradient.hero` verbatim.
2. `color.surfaceAlt` (dark-mode elevation 2/3, one component's de-emphasized
   state) is never defined in either palette table. **Default:** dark
   `#202F5E` (one step lighter than `surface.tinted`); light `#EEF2F6` (a
   neutral step above `surface.tinted`, since light elevation otherwise uses
   shadows, not surface steps).
3. `CMP-04 QuickAddChip`'s spec uses stale pre-rename token names not present
   in the current palette. **Mapping:** `blue.100` → `surface.tinted`;
   `color.primary` (as a text/label color) → the brand-primary text-safe
   variant (`#0A6E9E` light / raw `brand.primary` dark, consistent with rule
   4); `color.textSecondary` → `text.secondary`.

### Typography
Font families: **Inter** (variable, real UI copy; system fallback SF Pro/
Roboto) and **Press Start 2P** (pixel-display accent, tightly scoped — never
body copy, never button labels, never the sole rendering of actionable info,
max 3 lines per the v3.1 changelog correction — the table's "max two lines" is
stale, three lines is authoritative). Both fetched as real, openly-licensed
(SIL OFL) `.ttf` files and bundled under `assets/fonts/`.

Full type scale (size/line-height px, weight, tracking px, font):

| Token | Size/Line | Weight | Tracking | Font |
|---|---|---|---|---|
| `numericHero` | 56/60 | 700 | −1.5 | Inter, tabular |
| `numericL` | 28/32 | 700 | −0.5 | Inter, tabular |
| `pixelDisplay` | 20/28 | — | 0 | Press Start 2P |
| `pixelHero` | 40/44 | — | 0 | Press Start 2P |
| `pixelTitle` | 20/28 | — | 0 | Press Start 2P (max 3 lines; falls back to `headline` above 130% text scale) |
| `pixelUnit` | 20/24 | — | 0 | Press Start 2P |
| `labelGame` | 12/16 | 700 | +1.2 | Inter, uppercase |
| `buttonGame` | 16/20 | 700 | +1.2 | Inter, uppercase |
| `displayL` | 40/48 | 700 | −1.0 | Inter |
| `displayM` | 32/40 | 700 | −0.5 | Inter |
| `headline` | 24/32 | 600 | −0.2 | Inter |
| `titleL` | 20/28 | 600 | 0 | Inter |
| `titleM` | 17/24 | 600 | 0 | Inter |
| `bodyL` | 16/24 | 400 | 0 | Inter |
| `bodyM` | 14/20 | 400 | 0 | Inter |
| `label` | 13/16 | 600 | +0.4 | Inter |
| `caption` | 12/16 | 400 | +0.2 | Inter |
| `button` | 16/20 | 600 | +0.2 | Inter |

Rules: numerals use tabular figures wherever a value updates in place; nothing
ships smaller than 12sp (`caption`), body minimum 14sp; text scales to 200%
without clipping (layouts reflow); max 68 chars/line body copy; max 3 type
levels visible per card.

### Spacing, radius, elevation, motion
- **Spacing** (4dp base): `space.2/4/8/12/16/20/24/32/40/48/64`.
- **Radius:** `sm` 8 (buttons, chip-shells, game panels), `md` 12 (inputs,
  cards, tiles), `lg` 16 (cards, sheets), `xl` 24 (modals/sheet top corners).
  **Correction from Figma verification:** the written doc lists a `pill` (999)
  radius reserved for `QuickAddChip` — but the actual built `CMP-04
  QuickAddChip` in Figma uses a **10px radius**, not a pill. `radius.pill`
  appears to be unused anywhere in the current design. I'm keeping the token
  defined (harmless, and easy to use if a future component needs a true pill)
  but building `QuickAddChip` with a dedicated 10px radius rather than
  `radius.pill`, matching what's actually in the file.
- **Elevation:** light uses box-shadows (`elevation.1/2/3`, escalating blur/
  opacity); dark uses surface-color steps instead of shadow (near-invisible on
  dark backgrounds). Modals use `elevation.3`, cards use `elevation.1`, never
  exceed `elevation.3`.
- **Motion:** `instant` 100ms/easeOut (tap feedback), `fast` 180ms/
  easeOutCubic (state changes), `base` 280ms/easeInOutCubic (sheet/card
  expand), `slow` 450ms/easeOutCubic (ring/glass progress fill), `celebrate`
  650ms/easeOutBack, overshoot ≤1.05 (overlay entrances), `page` 300ms/
  platform default (route transitions). Every animation interruptible, nothing
  exceeds 650ms, no looping/idle animation ever. Reduced-motion: instant change
  or ≤120ms cross-fade, wave/fill animations disabled entirely — read once from
  a `reduceMotionProvider` (`MediaQuery.disableAnimations`), consumed by every
  animated component. This provider is created in this pass even though no
  animated component exists yet, since the docs treat it as a foundational,
  cross-cutting requirement (`10-accessibility.md`).

### Icons
Rounded outline, 2dp stroke, 24×24 grid, sizes 16/20/24/32/40/80/96dp. Use
Flutter's built-in `Icons.*_rounded` variants (visually the same rounded
language as "Material Symbols Rounded") instead of adding a new package.
Product chrome never uses emoji, only icons.

## 7. Navigation foundation

Built from `03-information-architecture.md`'s route table exactly.

**Redirect gate** (`04-user-flows.md` §4.1): resolved once as go_router's
global `redirect`.
| Condition | Redirect to |
|---|---|
| Drift database fails to open | `/recovery` |
| `onboardingComplete == false` and location not under `/onboarding` | `/onboarding/welcome` |
| `onboardingComplete == true` and location under `/onboarding` | `/home` |
| Otherwise | no redirect |

`onboardingComplete` is read from `SharedPreferences` before `runApp`. The
DB-open-check is a real check (not stubbed) since the Drift schema is already
part of this pass.

**Routes** (every one gets a minimal placeholder `Scaffold` with a title —
no real UI):

Onboarding (no tab bar): `/` (splash, redirect-only, never a back-target),
`/onboarding/welcome`, `/onboarding/basics`, `/onboarding/weight`,
`/onboarding/activity`, `/onboarding/environment`, `/onboarding/target`,
`/onboarding/reminders`.

4-tab shell (`StatefulShellRoute.indexedStack`, reusing the existing shell
pattern, re-themed): `/home` (Home), `/progress` (Progress), `/awards`
(Awards), `/profile` (Profile).

Pushed screens: `/home/add`, `/home/trivia`, `/progress/day/:date` (see flag
below), `/awards/:achievementId`, `/profile/target`, `/profile/reminders`,
`/profile/settings`, `/profile/settings/about`.

Error: `/recovery`.

**Explicitly out of scope this pass:** all `OVL-*` overlays (modals/bottom
sheets/dialogs/toasts) — these are imperative presentations built inside the
feature that needs them (Phase 4/5/8), not routes. Two flagged exceptions:
- `OVL-15` "About FLOW" *is* built as a real route (`/profile/settings/about`)
  despite its `OVL` prefix — the doc itself calls it a "pushed page."
- `OVL-04` "Share Preview" is reachable from two different parents
  (`/awards/:id` and a trophy-unlock overlay) and the docs never resolve
  whether it needs its own route. Left unbuilt; flagged for whoever builds
  Sharing (Phase 8) to decide.
- `/progress/day/:date` is marked "SHOULD" (optional) in the IA table but
  treated as normal/required in the `FLOW-08` user-flow diagram. Included as a
  placeholder route since it's cheap to stub now and avoids re-plumbing later;
  the doc conflict itself is not resolved by this spec.

## 8. Component scope — `CMP-01` through `CMP-15`, verified against Figma

Matches the roadmap's own `US-003` foundation scope (not the full component
catalogue — the actual Figma file's "01 Components" page turns out to contain
far more than 15 components, including a near-complete gamification/progress
set; all of that is Phase 5+ work and stays out of scope here). Every spec
below was pulled directly from the Figma file
(`GGCrpp5JI69VK0kLguM40b`, "FLOW — Onboarding v2"), not just the written docs
— several details below correct or sharpen what the wireframes/design-system
docs said. Each component gets a widget test per documented state.

A cross-cutting implementation note: nearly every component below shares the
same "2dp `frame.ink` border, optional `frame.depth` offset, optional
`frame.bevel` inner highlight" recipe. Worth building as one shared decoration
helper in `core/design/components/` rather than duplicating it 12 times.

| ID | Component | Verified spec |
|---|---|---|
| `CMP-01` | `PrimaryButton` | 56dp height (60dp incl. 4dp `frame.depth` offset), `radius.sm`, full frame recipe (2dp `frame.ink` stroke + 4dp solid `frame.depth` drop, never blurred + 2dp `frame.bevel` inner top). Fill `brand.primary` (pressed: `brand.primaryActive`). Label `type.buttonGame` in `text.primary` navy (7.50:1) — confirmed never `onPrimary` white. **Has an optional trailing icon slot** (e.g. `icon-arrow-right`) shown in Default/Pressed, hidden in Disabled — the written spec didn't mention this. States: Default/Pressed/Disabled; milestone variant swaps fill to `achievement`. |
| `CMP-02` | `SecondaryButton` | 52dp tall — deliberately 4dp shorter than Primary's 60dp footprint. Outline only, no fill, no depth. Border: Default `frame.ink`, Pressed `brand.primary`, Disabled `surface.primary` (near-invisible). Label `type.buttonGame`: Default/Pressed `text.primary`, Disabled `text.secondary`. |
| `CMP-03` | `TextButton` | 48dp tall **regardless of label length** (real hit target, not glyph bounds) — required explicitly for the Skip control. Label color is `brand.primaryTextSafe` (`#0A6E9E`), never raw `brand.primary` (2.32:1 contrast failure). Optional leading pixel icon. States: Default/Pressed/Disabled/NoIcon (Skip uses NoIcon). |
| `CMP-04` | `QuickAddChip` | 56dp tall, **10px radius** (not `radius.pill` — see Section 6 correction), leading droplet icon + amount label. Selected: `brand.primary` fill + 3dp `frame.ink` border + navy label (7.50:1) — three-cue selection, not color alone. |
| `CMP-05` | `SegmentedChoice` | Two real variants, both fill-selected-segment + 2dp frame + inner bevel + pixel check icon: **`/Unit`** (kg/lb) — 56dp shell, 4dp padding, **48dp segments** (Figma's own annotation notes a prior 40dp-segment build failed the 48×48 touch minimum — already fixed). **`/Sex`** (female/male/prefer-not-to-say) — 64dp shell, 56dp segments, with label wrapping enabled on every segment (a "WRAP FIX" annotation in the file notes "prefer not to say" previously clipped in a single line). |
| `CMP-06` | `ChoiceCard` | Min-height 76dp. Leading element is a **pixel "bar-meter"** (1–5 vertical bars filled, matching the activity-level count) — not a generic icon; rebuilt per instance. Selected: `surface.tinted` fill + **3dp** frame (thicker than the default 2dp, not just recolored) + trailing 24dp check-badge circle (`brand.primary` fill, `frame.ink` border, check icon). Radio-group semantics. |
| `CMP-07` | `IconChoiceTile` | **104dp tall** (the written doc said "min 96dp" — Figma's own note confirms 96dp is the minimum but it's actually built at 104dp). 2×2 grid tile. Leading pixel thermometer icon whose fill height *and* color both shift with the environment level (aqua→gold→orange→coral) — two channels, not one. Same selected treatment as `CMP-06` (tinted fill + 3dp frame + check badge). |
| `CMP-08` | `PillarRow` | Not a stateful wrapper — it's a single static "Pillar" card (76dp, `radius.md`, 2dp frame border, `surface.primary` fill, 28dp leading icon + title + description, no selection state) reused 3× in a column on the welcome screen. Build one `Pillar` widget, not a `PillarRow` with internal variants. |
| — | ~~`CMP-09 StepHeader`~~ **does not exist as one component.** Replaced by two real, separately-numbered components (build both, compose them where the wireframe doc described "StepHeader") | **`CMP-42 BackButton`**: 48×48dp touch target, `surface.primary` fill, 2dp `frame.ink` border, **3dp** depth (shallower than a primary button's 4dp, so it reads as secondary), `radius.sm`, pixel chevron-left icon (not a Material icon — onboarding uses no Material Symbols at all, per the file's own note). **`CMP-44 StepTrack`**: a 5-node horizontal track for ONB-03–07. Three node states, each with a *shape* cue as well as color (never color alone): done = 14dp square with a light notch; current = 22dp square with a white core (deliberately larger so "you are here" survives greyscale); upcoming = 14dp square on `trackSubtle`. Connectors fill remaining width. Pairs with a plain "Step N of 5" text label in `type.labelGame` — not baked into the component. |
| `CMP-10` | `TextField` | `radius.sm`, 2dp border, **no depth offset** (inputs aren't tappable buttons, so no press affordance). States: Default (`borderStrong`), Focused (`brand.primary` stroke), Error (`color.error` stroke — error message rendered separately below in `type.caption` + `color.error`, never color alone). |
| `CMP-11` | `Slider` | Range 25–250kg (55–550lb), **step 0.5kg** (the written spec just said "step increments" — Figma's note gives the exact value). 12dp tall track (`trackDark` rest / `brand.primary` filled), pixel handle 24×28dp with a 48dp hit area. The numeric field stays the accessible primary control — the slider is an enhancement exposing `Semantics(value: "68 kilograms")` stepping by 1 for screen readers. |
| `CMP-12` | `CheckRow` | 48dp tall (full-row hit target), true checkbox semantics. Checked: `brand.primary` fill + pixel check icon + 2dp frame — three cues again, not color alone. Box is 24dp, `radius` 5. |
| `CMP-13` | `InfoCard` | **Only two tone kinds — `Info` and `Caution`** (the written design-system summary said info/warning/error; Figma has exactly two). Info: `infoSurface` background, `info` text. Caution: intended as `warningSurface` background with `warning` text (matching Info's own tint-background pattern) — **flagging a real bug found in the Figma file itself:** the actual exported Caution variant has its text color set to the same value as its background fill (`warning` on `warning`), making the caution message invisible. I'm implementing the evidently-intended tinted version, not reproducing the bug, but this is worth reporting back to whoever owns the Figma file. |
| `CMP-14` | `SettingRow` | 56dp row, `radius.sm`, 2dp `frame.ink` border + `surface.primary` fill (the written doc undersold this as a plain chevron row — it actually carries the full pixel-frame treatment). Value text in `text.secondary` keeps the label dominant. The chevron is the **same pixel chevron-left asset as `CMP-42 BackButton`, just rotated 180°** — one icon file, not two. |
| `CMP-15` | `DayToggle` | 40dp circle (`radius` 20), single-letter day label in `type.labelGame`. On: `brand.primary` fill + 2dp `frame.ink` border + navy label. |

**Icon sourcing correction:** I'd originally planned to use Flutter's built-in
`Icons.*_rounded` as a stand-in for "Material Symbols Rounded" everywhere.
Figma's own component notes are explicit that **onboarding uses no Material
Symbols at all** — every onboarding icon (chevron, check, arrow, info,
droplet, thermometer, etc.) is one of the custom pixel-art SVGs already
bundled in `assets/icons/onboarding/`, rendered via `flutter_svg`. Flutter's
built-in rounded icons remain a reasonable substitute only for generic,
non-onboarding chrome that isn't covered by a bundled asset (nothing in this
foundation pass needs that yet).

Everything past this list (achievement tiles, `HydrationGlass`, XP bars, day
bars, `RarityBadge`, progress/stats cards, etc. — all of which already exist,
fully designed, on the Figma file's Components page) is deferred to the phase
that builds the screens using them.

## 9. Explicitly out of scope for this pass

- Any FLOW feature screen UI beyond placeholder route targets
- Repository/use-case implementations on top of the Drift schema
- The hydration target calculator (isolated, zero-dependency module — Phase 4)
- XP/level/streak/achievement business logic (Phase 5, explicitly designed as a
  removable seam per `TC-090`)
- Reminder scheduling logic (Phase 6)
- Trivia content/logic (Phase 7)
- Sharing/share-card generation (Phase 8)
- `CMP-16` and beyond in the component catalogue
- Custom `custom_lint` analyzer rules for `CI-04`–`CI-12` (flagged as a
  follow-up, not blocking)
- Rewriting `app_en.arb` to FLOW's actual copy-spec keys/strings (kept as
  infrastructure only this pass — content is a separate, large effort)

## 10. Known documentation gaps/conflicts (inherited from the doc set, not resolved here)

These are pre-existing issues in the source documentation, surfaced during
research, not something this pass fixes:
- Doc status mismatch: README says "Pre-development," PRD says "Approved for
  build."
- Achievement/Trophy/Badge vocabulary reversal between doc versions — worth a
  scan of `09`/`13` for stale terminology when copy is written.
- `FR-033` reads as if XP stops at 100% completion; `BR-07`'s 120% cap is the
  actual source of truth (Phase 5 concern, not this pass).
- `FR-014` allows a manual target as low as 500ml, below the calculator's own
  1,000/1,200ml floor — intentional per the doc, flagged for product awareness.
- Title-band rebalancing (`BR-09`) is explicitly marked unvalidated/needs
  playtesting in the source doc (Phase 5 concern).
- `13-brand-visual-system.md`'s onboarding-icon inventory (§11) is stale
  relative to what's actually on disk in `assets/icons/onboarding/` — 19 of the
  25 files on disk aren't in the doc's table, and several files the doc lists
  as produced don't exist. Needs reconciling before those assets are wired up
  (Phase 4).
- `bloop-resting-tight.svg` is referenced by convention (empty-state layout
  usage) but doesn't exist on disk — needed before empty states are built
  (Phase 4/9).
- `level-badge.svg`/`level-badge-max.svg` exist on disk but the doc marks the
  "Level" icon as not-yet-produced — likely just a stale doc, but worth a
  quick confirmation before Phase 5.
- A `§14.2` mascot-behavior change referenced in `13`'s changelog doesn't
  actually exist in the document body — flagged, not actionable without the
  missing section.

**New, found during the Figma verification pass (Section 8):**
- `CMP-13 InfoCard`'s "Caution" variant has matching text and background
  colors in the actual Figma export (`warning` on `warning`), making the
  message invisible — a real authoring bug in the file, not a doc/code gap.
  Implementing the evidently-intended tinted version instead; worth reporting
  to whoever owns the Figma file so the source gets fixed too.
- The written docs describe `CMP-09 "StepHeader"` as one component; it doesn't
  exist in Figma at all — the actual file has two separately-numbered
  components (`CMP-42 BackButton`, `CMP-44 StepTrack`) plus a plain text label,
  composed together. Not a conflict to resolve, just a docs-vs-file mismatch
  worth knowing about if `06`/`05` get updated later.
- `radius.pill` (999) is defined as a token and documented as reserved for
  `QuickAddChip`, but the actual built chip uses a 10px radius — `radius.pill`
  appears to be currently unused anywhere in the real design.

## 11. Validation criteria for this pass

Mirrors the roadmap's own Phase 3 exit criteria: "Project, theme, routing,
storage, state, core components running."

- `flutter pub get` succeeds with the new dependency set
- `flutter analyze` clean (no new warnings/errors introduced)
- `dart format .` clean
- App boots (`flutter run --flavor dev`) to the placeholder `/home` screen
  with no errors, through the real redirect gate
- Every documented route in Section 7 is reachable and renders its placeholder
  without crashing
- Light and dark themes both render without contrast/token errors
- Drift database opens, migrates from empty to schema v1, and seeds the
  achievement catalogue + reminder defaults without error
- Each of `CMP-01`–`CMP-15` has a passing widget test per documented state
- No `dio`, `flutter_secure_storage`, `geolocator`, `camera`,
  `mobile_scanner`, or `google_mlkit_face_detection` reference remains in
  `lib/` or `pubspec.yaml`
- `reference/auth-and-network/` exists at the repo root, is excluded from
  `flutter analyze`/the build, and is not referenced from `lib/`
- Package identifier remains `oiracam.flow.bloop`, app name remains `FLOW`
