# Project Map

Generated facts about this repository. See
`.claude/skills/flutter-architecture-map/SKILL.md` for the directory
contract this inventories against. Regenerate with `/sync-map` — do
not hand-edit.

## Identity

| | |
|---|---|
| Package name | `flow` |
| Description | "FLOW mobile application." (`pubspec.yaml`) |
| Version | `1.0.0+1` |

**Flavors** — `dev`, `alpha`, `prod` (Android product flavors, `android/app/build.gradle.kts`; iOS schemes `dev.xcscheme`, `alpha.xcscheme`, `prod.xcscheme` + matching `ios/Flutter/Flavors/*.xcconfig`).

| Flavor | Android applicationId suffix | iOS bundle ID suffix |
|---|---|---|
| dev | `.dev` | `.dev` |
| alpha | `.alpha` | `.alpha` |
| prod | *(none)* | *(none)* |

Base Android `applicationId` / iOS `PRODUCT_BUNDLE_IDENTIFIER`: `oiracam.flow.bloop`.

## Features

Seven directories under `lib/features/`, each with `presentation/` only — no feature currently has `data/` or `domain/` anywhere in the repo, and no feature has a `widgets/` subdirectory. Every screen below is a stub (`Scaffold`/`StatelessWidget` with an empty/placeholder body; no Notifier, no business logic wired in yet).

| Feature | Screens |
|---|---|
| `gamification` | `awards_page`, `achievement_detail_page` |
| `home` | `home_page` — **dead code**: declares its own `HomePage`, but nothing imports it (the router's `/home` route uses `hydration`'s `HomePage` instead); only other reference in the repo is `docs/guide/ui-kit.md` |
| `hydration` | `home_page`, `add_water_page`, `progress_page`, `day_detail_page`, `target_settings_page` |
| `onboarding` | `splash_page`, `welcome_page`, `basics_page`, `weight_page`, `activity_page`, `environment_page`, `target_page`, `reminders_page`, `recovery_page` |
| `reminders` | `reminder_settings_page` |
| `settings` | `profile_page`, `general_settings_page`, `about_page` |
| `trivia` | `trivia_page` |

There is no `lib/features/profile/` — `settings` owns `profile_page`.

## Routes

From `lib/app/router/app_router.dart` (`GoRouter`, `initialLocation: '/'`):

| Path | Screen |
|---|---|
| `/` | `SplashPage` |
| `/onboarding/welcome` | `WelcomePage` |
| `/onboarding/basics` | `BasicsPage` |
| `/onboarding/weight` | `WeightPage` |
| `/onboarding/activity` | `ActivityPage` |
| `/onboarding/environment` | `EnvironmentPage` |
| `/onboarding/target` | `TargetPage` |
| `/onboarding/reminders` | `RemindersPage` |
| `/home` | `HomePage` (`hydration`; shell branch) |
| `/progress` | `ProgressPage` (shell branch) |
| `/awards` | `AwardsPage` (shell branch) |
| `/profile` | `ProfilePage` (`settings`; shell branch) |
| `/home/add` | `AddWaterPage` |
| `/home/trivia` | `TriviaPage` |
| `/progress/day/:date` | `DayDetailPage` (`date` path param) |
| `/awards/:achievementId` | `AchievementDetailPage` (`achievementId` path param) |
| `/profile/target` | `TargetSettingsPage` |
| `/profile/reminders` | `ReminderSettingsPage` |
| `/profile/settings` | `GeneralSettingsPage` |
| `/profile/settings/about` | `AboutPage` |
| `/recovery` | `RecoveryPage` |

`/home`, `/progress`, `/awards`, `/profile` are grouped under a `StatefulShellRoute.indexedStack` (`MainShell`, `lib/app/main_shell.dart`) — a 4-tab bottom nav (`FlowBottomNav`, `lib/app/flow_bottom_nav.dart`).

Redirect logic (`lib/app/router/app_redirect.dart`, pure function `resolveRedirect`): `!databaseHealthy` → `/recovery`; `!onboardingComplete` and not under `/onboarding` → `/onboarding/welcome`; `onboardingComplete` and (under `/onboarding` or at `/`) → `/home`.

## UI Kit Catalog

The app's live component library is `lib/core/design/components/` — a flat directory, no category subdirectories, no barrel file (each component is imported directly). Token files and private (`_`-prefixed) helper classes are excluded.

| File | Public class |
|---|---|
| `back_button.dart` | `FlowBackButton` |
| `check_row.dart` | `CheckRow` |
| `choice_card.dart` | `ChoiceCard` |
| `day_toggle.dart` | `DayToggle` |
| `flow_frame_box.dart` | `FlowFrameBox` |
| `flow_slider.dart` | `FlowSlider` |
| `flow_text_button.dart` | `FlowTextButton` |
| `flow_text_field.dart` | `FlowTextField` |
| `icon_choice_tile.dart` | `IconChoiceTile` |
| `info_card.dart` | `InfoCard` (+ `enum InfoCardKind`) |
| `pillar.dart` | `Pillar` |
| `primary_button.dart` | `PrimaryButton` |
| `quick_add_chip.dart` | `QuickAddChip` |
| `secondary_button.dart` | `SecondaryButton` |
| `segmented_choice.dart` | `SegmentedChoice<T>` |
| `setting_row.dart` | `SettingRow` |
| `step_track.dart` | `StepTrack` |

17 components, one class per file. None of these components are imported by any feature page yet (all feature screens are still unstyled `Scaffold`/`StatelessWidget` stubs); only `flow_theme.dart` (colors/typography) is wired into `app.dart`.

`lib/core/ui_kit/` (the previously-documented second, dead component library) no longer exists — removed in commit `027452b`.

## Design Tokens

Live tokens, `lib/core/design/tokens/` (consumed by `FlowTheme` in `lib/core/design/theme/flow_theme.dart`, wired into `MaterialApp.router` in `lib/app/app.dart`):

| Class | Covers |
|---|---|
| `FlowColors` (`ThemeExtension`) | Brand/role colors, `light`/`dark` variants: brand primary/secondary, xp/achievement/reward/streak accents, background/surface/border/text roles, success/error/warning/info + their surface tints, and a "pixel game" panel/frame/particle palette |
| `FlowTypography` (`ThemeExtension`) | Type scale in two families (`Inter`, `Press Start 2P`): numeric hero/large, pixel display/hero/title/unit, game label/button, display L/M, headline, title L/M, body L/M, label, caption, button |
| `FlowSpacing` | 4dp-base scale: `xs2`(2) `xs`(4) `sm`(8) `smMd`(12) `md`(16) `mdLg`(20) `lg`(24) `xl3`(32) `xl4`(40) `xl5`(48) `xl6`(64) |
| `FlowRadius` | Corner radii: `sm`(8) `md`(12) `lg`(16) `xl`(24) `pill`(999, currently unused) `quickAddChip`(10) `navBar`(32, the floating tab bar) |
| `FlowElevation` | Light-mode shadow levels 1–3 (`BoxShadow` lists); dark mode uses surface-color steps instead, handled in `FlowTheme` directly |
| `FlowMotion` | Durations `instant`(100ms) `fast`(180ms) `base`(280ms) `slow`(450ms) `celebrate`(650ms) `page`(300ms) + matching curves |

`lib/core/ui_kit/tokens/` (the previously-documented second, dead token set — `AppColors`/`AppSpacing`/`AppRadius`/`AppSizing`/`AppMotion`) no longer exists — removed in commit `027452b`.

## Network Layer

**None.** `pubspec.yaml` has no HTTP client dependency (no `dio`, no `http`); FLOW has no backend. `lib/core/result/failure.dart` says so explicitly: *"FLOW has no backend, so there are deliberately no network-related cases here."*

- **Local error/result convention** (`lib/core/result/`): `sealed class Result<T>` (`Ok<T>` / `Err<T>`) and `sealed class Failure` with `ValidationFailure`, `StorageFailure`, `PermissionFailure`, `UnknownFailure` — intended for the Repository → UseCase → Notifier boundary described in the skill, but not yet consumed anywhere (no feature has reached that layer).
- **Persistence**: local only — Drift/SQLite (`lib/core/database/`) for structured data, `shared_preferences` for flags (e.g. onboarding-complete). No credential/token storage exists (no auth in this app).

**Dead code, still present** (not touched by commit `027452b`, unlike `core/ui_kit/`): `lib/core/errors/` (`Failure`/`NetworkFailure`/`ServerFailure`/`UnauthorizedFailure`/`AuthenticationFailure`/`ErrorCodes`/`ValidationFailure`), `lib/core/localization/error_localizer.dart` (`ErrorLocalizer`), and `lib/core/constants/app_constants.dart` (login/register/logout/refresh-token REST endpoints, a Dio-interceptor flag set) are a second, unreferenced error/network scaffold. Confirmed zero imports from anywhere else in `lib/` or `test/` — these three only reference each other. Leftover from the original (non-FLOW) boilerplate.

## State

Riverpod `Notifier<State>` classes that exist in the whole app, generated via `riverpod_annotation`:

| Notifier | State owned | Location |
|---|---|---|
| `ReduceMotion` | `bool` (defaults `false`) | `lib/core/design/theme/reduce_motion_provider.dart` |
| `ClockOverride` | `DateTime?` (defaults `null`; only consulted in the dev flavor) | `lib/core/time/clock_provider.dart` |

No feature under `lib/features/` currently has a `<screen>_notifier.dart` / `<screen>_state.dart` pair — every feature screen is a `StatelessWidget` stub with no state management wired in yet.

`RouterRefreshNotifier` (`lib/app/router/router_refresh_notifier.dart`) — plain `ChangeNotifier`, not a Riverpod `Notifier`; not currently referenced by `app_router.dart`'s `GoRouter` construction (no `refreshListenable:` argument is passed).

`AppDatabase extends _$AppDatabase` (`lib/core/database/app_database.dart`) is Drift-generated table/query code, not a Riverpod Notifier — excluded from the table above.

## Providers

No feature has reached the `data/` / `domain/` layers, so the skill's two-file `data/providers/` → `domain/providers/` wiring (§ Provider wiring) does not exist anywhere yet — there is nothing to quote a repository-to-usecase example from.

What exists instead is a set of standalone `@riverpod`/`@Riverpod(keepAlive: true)` providers under `lib/core/`, several of which are deliberately left unimplemented at declaration time and overridden once in `main.dart` before `runApp`:

```dart
// lib/core/database/database_provider.dart
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  throw UnimplementedError(
    'appDatabaseProvider must be overridden in main() before runApp.',
  );
}
```

```dart
// lib/main.dart
runApp(
  ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      appDatabaseProvider.overrideWithValue(database),
      databaseHealthyProvider.overrideWithValue(databaseIsHealthy),
    ],
    child: const App(),
  ),
);
```

Other core providers: `sharedPreferencesProvider` (`core/preferences/shared_preferences_provider.dart`), `onboardingCompleteProvider` (`core/preferences/onboarding_provider.dart`, reads `sharedPreferencesProvider`), `reduceMotionProvider` (see § State), `clockProvider`/`clockOverrideProvider` (`core/time/clock_provider.dart`), `appRouterProvider` (`app/router/app_router.dart`, reads `databaseHealthyProvider` and `onboardingCompleteProvider` in its redirect callback).

## Localization

- **Locales**: `en` only — `lib/l10n/app_en.arb` (`@@locale: "en"`) is the only `.arb` file in the repo.
- **ARB directory**: `lib/l10n/` (`l10n.yaml`: `arb-dir: lib/l10n`, `template-arb-file: app_en.arb`).
- **Generated output class**: `AppLocalizations`, written to `lib/l10n/generated/app_localizations.dart` (`l10n.yaml`: `output-dir: lib/l10n/generated`, `output-class: AppLocalizations`).
- **Regeneration command**: `flutter gen-l10n` (also runs automatically on `flutter pub get`/`flutter run` since `pubspec.yaml` sets `flutter: generate: true`).
- Wired into `MaterialApp.router` in `lib/app/app.dart` via `AppLocalizations.localizationsDelegates` / `AppLocalizations.supportedLocales`.

## Platform

**Packages using native capabilities** (from `pubspec.yaml`), by actual wiring status:

| Package | Status |
|---|---|
| `shared_preferences` | wired — `lib/main.dart`, `core/preferences/shared_preferences_provider.dart` |
| `path_provider` | wired — `core/database/app_database.dart` (locates the Drift `flow.db` file) |
| `sqlite3_flutter_libs` | wired transitively — bundles native SQLite for `drift`, no direct Dart import needed |
| `permission_handler` | declared, zero references anywhere in `lib/` — not wired into the live app (`core/utils/app_camera_permission.dart`, its previous only caller, was removed in commit `027452b`) |
| `flutter_local_notifications` | declared, zero references in `lib/` — not yet integrated |
| `timezone` | declared, zero references in `lib/` — not yet integrated |
| `share_plus` | declared, zero references in `lib/` — not yet integrated |

**Android** (`android/app/src/main/AndroidManifest.xml`):
- `CAMERA`
- `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`
- `uses-feature android.hardware.camera` — `required="false"`

**iOS** (`ios/Runner/Info.plist`):
- `NSLocationWhenInUseUsageDescription` — "This app uses your location to provide location-based features."
- `NSPhotoLibraryUsageDescription` — "This app needs access to your photos to attach images."
- `NSCameraUsageDescription` — "This app uses the camera to take photos and to scan QR codes."

None of the current `pubspec.yaml` dependencies require camera, location, or photo-library access (no `camera`, `geolocator`, `image_picker`, or `mobile_scanner` package is declared) and no permission is requested anywhere in `lib/` (`permission_handler` is unreferenced, see above) — these manifest/`Info.plist` entries, and their comments referencing a "Core QR Scanner" that does not exist in this repo, appear to be leftover from the original boilerplate. The Android manifest comment and the iOS usage strings were not touched by commit `027452b` and remain stale.

## Test Coverage

**Notifiers** — 2 total, 2 tested:
`ReduceMotion` (`test/core/design/theme/reduce_motion_provider_test.dart`), `ClockOverride` (`test/core/time/clock_test.dart`). No feature-level Notifiers exist (see § State).

**UseCases** — 0 total. No `domain/usecases/` directory exists anywhere in `lib/features/`.

**Repository implementations** — 0 total. No `data/repositories/` directory exists anywhere in `lib/features/`.

**Domain models** — 0 total. No `domain/models/` directory exists anywhere in `lib/features/`.

**UI components** — 17 total (`lib/core/design/components/`), 17 tested (one test file per component under `test/core/design/components/`): `back_button`, `check_row`, `choice_card`, `day_toggle`, `flow_frame_box`, `flow_slider`, `flow_text_button`, `flow_text_field`, `icon_choice_tile`, `info_card`, `pillar`, `primary_button`, `quick_add_chip`, `secondary_button`, `segmented_choice`, `setting_row`, `step_track`. 0 untested.

The dead `core/ui_kit/` component files and their tests no longer exist — `test/` has zero remaining references to `ui_kit`.

## Generated

Generated 2026-09-04 from commit `027452b`.
