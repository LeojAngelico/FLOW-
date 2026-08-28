# Instructions

This is the primary developer guide for this Flutter boilerplate — an
Incident Reporting app built as a reference implementation of a
reusable MVVM + Riverpod architecture and a themeable **Core UI Kit**.

If you're new here: this document tells you what the project is, how
it's put together, where to put new code, how to use the Core UI Kit,
and how to build/run every environment. The codebase is the source of
truth — if anything here ever drifts from what the code actually
does, trust the code and fix this document (see
["Keeping This Document Updated"](#keeping-this-document-updated)).

## I Need To...

| I need to...                        | See |
|--------------------------------------|-----|
| Add a new screen                     | [Development Workflows](#development-workflows) |
| Add a whole feature                  | [Architecture](#architecture), [Development Workflows](#development-workflows) |
| Add an API endpoint                  | [Networking & API Layer](#networking--api-layer) |
| Use a button, dialog, snackbar, etc. | [Core UI Kit](#core-ui-kit) |
| See the Core UI Kit live             | [UI Playground](#ui-playground) |
| Scan a QR code / barcode             | [Core QR Scanner](#core-qr-scanner) |
| Capture a photo of a face            | [Face Capture Core](#face-capture-core) |
| Show an image fullscreen             | [Image Viewer Core](#image-viewer-core) |
| Capture a handwritten signature      | [Signature Pad Core](#signature-pad-core) |
| Add a new reusable component         | [Core UI Kit](#core-ui-kit), [Development Workflows](#development-workflows) |
| Add a route                          | [Navigation & Routing](#navigation--routing) |
| Add a new flavor/environment         | [Environments & Flavors](#environments--flavors) |
| Build an Android APK                 | [Android Builds](#android-builds) |
| Build an Android App Bundle (AAB)    | [Android Builds](#android-builds) |
| Build for iOS                        | [iOS Builds](#ios-builds) |
| Change app branding/name per flavor  | [Environments & Flavors](#environments--flavors) |
| Handle API/network errors            | [Error Handling](#error-handling) |
| Handle loading/empty/error states    | [Loading, Empty & Error States](#loading-empty--error-states) |
| Add form validation                  | [Forms & Validation](#forms--validation) |
| Add local storage                    | [Local Storage](#local-storage) |
| Change the theme/design tokens       | [Theme & Design Tokens](#theme--design-tokens) |
| Write or run tests                   | [Testing](#testing) |
| Fix a build problem                  | [Troubleshooting](#troubleshooting) |
| Start a **new project** from this boilerplate | [Starting a New Project From This Boilerplate](#starting-a-new-project-from-this-boilerplate) |

## Project Overview

| | |
|---|---|
| **App** | Incident Reporting — report, list, view, edit, and delete incidents |
| **Flutter** | 3.44.7 (stable) |
| **Dart SDK** | `^3.12.2` |
| **State management** | Riverpod (`flutter_riverpod: ^3.4.2`) — `Notifier`/`NotifierProvider`, no `StateNotifier`/`ChangeNotifier` |
| **Navigation** | `go_router: ^17.5.0` |
| **Networking** | `dio: ^5.11.0` |
| **Local storage** | `flutter_secure_storage: ^11.0.0` (used for both the auth token and the locale preference) |
| **Localization** | `flutter_localizations` + generated `AppLocalizations` — English, Filipino (`fil`), Cebuano (`ceb`) |
| **Design system** | A custom, hand-built **Core UI Kit** under `lib/core/ui_kit/` — no third-party design-system package |
| **QR/barcode scanning** | `mobile_scanner: ^7.4.0` — wrapped by the [Core QR Scanner](#core-qr-scanner) |
| **Face detection** | `google_mlkit_face_detection: ^0.15.1` + `camera: ^0.12.0` — wrapped by the [Face Capture Core](#face-capture-core). On-device detection only; **not** facial recognition |
| **Image viewing** | No package — the [Image Viewer Core](#image-viewer-core) is built on Flutter's own `InteractiveViewer` and `PageView` |
| **Signature capture** | No package — the [Signature Pad Core](#signature-pad-core) draws with `CustomPainter` and exports through `PictureRecorder` |
| **Runtime permissions** | `permission_handler: ^13.0.1` — wrapped per capability in `core/utils/` (camera today); `geolocator` still handles its own location permission |

## Starting a New Project From This Boilerplate

**If you just cloned/copied this repository to start a brand-new
app, stop before writing any feature code.** This repo is still
carrying the *Incident Reporting* boilerplate's own identity — its
package name, application/bundle IDs, app name, and branding. Ship
those unchanged and you'll end up with an app that installs as
"flutter_incident_reporting" / `com.example.flutter_incident_reporting`,
which is almost never what you want for a real project, and can
silently collide with this boilerplate (or another project generated
from it) on the same device or in the same app store account.

**Recommended order:**

1. Rename the Flutter/Dart project identity
2. Configure the Android identity (namespace, applicationId, Kotlin package)
3. Configure the iOS identity (Bundle Identifier)
4. Re-check the `dev`/`alpha`/`prod` flavor identifiers
5. Configure environment/API settings for each flavor
6. Replace branding (app name, icons, splash, theme)
7. Verify every flavor builds and runs
8. Run `flutter analyze` and `flutter test`
9. Search the repo for leftover boilerplate identifiers
10. **Only then** start adding project-specific features

### Terminology — these are five different things

A rename touches several independent identifiers. Changing one does
**not** change the others — treat them separately:

| Concept | What it actually controls | Where it lives here | Current value |
|---|---|---|---|
| Flutter/Dart project name | The Dart package name, used in `import 'package:<name>/...'` | `pubspec.yaml` → `name:` | `flutter_incident_reporting` |
| Android `namespace` | Where generated Android resource (`R`) classes live; **dictates the required Kotlin package/directory path** | `android/app/build.gradle.kts` → `android.namespace` | `com.example.flutter_incident_reporting` |
| Android `applicationId` | The actual installed package name — what Google Play and the device see. Can differ from `namespace`, but this boilerplate keeps them the same for clarity | `android/app/build.gradle.kts` → `android.defaultConfig.applicationId` | `com.example.flutter_incident_reporting` (plus a per-flavor suffix — see below) |
| iOS Bundle Identifier | The installed app identity on iOS / App Store Connect | Xcode build settings (`PRODUCT_BUNDLE_IDENTIFIER`), via `ios/Flutter/Flavors/*.xcconfig` in this project | `com.example.flutterIncidentReporting` (plus a per-flavor suffix) |
| App display name | What the user sees under the home-screen icon | Android: generated `app_name` string resource; iOS: `CFBundleDisplayName` | "Incident Reporting Dev" / "Incident Reporting Alpha" / "Incident Reporting" |

Note the **Android/iOS casing already differs on purpose** in this
boilerplate — `flutter_incident_reporting` (snake_case) vs.
`flutterIncidentReporting` (camelCase). That's how the Flutter
template generated them originally; they don't need to match
character-for-character, only represent the same app conceptually.
Pick one convention for your new project and use it consistently on
both platforms — don't feel obligated to preserve the mismatch.

### Step 1 — Rename the Flutter/Dart project

1. `pubspec.yaml` → change `name: flutter_incident_reporting` to your
   new project name (lowercase, `snake_case`, no spaces — standard
   Dart package naming).
2. Update the **two** places that import via the old package name
   (search, don't guess — there may be more by the time you read this):
   ```bash
   grep -rn "package:flutter_incident_reporting" lib/ test/
   ```
   As of this writing, that's `lib/features/incident/data/datasources/incident_remote_data_source.dart`
   and `test/widget_test.dart`. Change each to
   `package:<your_new_name>/...`.
3. Run `flutter pub get` afterward — a stale `.dart_tool/` can leave
   the old package name cached.

### Step 2 — Configure the Android identity

All three of these should change **together** — changing only
`applicationId` and leaving `namespace`/the Kotlin package pointed at
the old name is legal to Gradle but confusing to maintain.

1. **`android/app/build.gradle.kts`**:
   ```kotlin
   android {
     namespace = "com.yourcompany.yourapp"       // was: com.example.flutter_incident_reporting
     defaultConfig {
       applicationId = "com.yourcompany.yourapp" // was: com.example.flutter_incident_reporting
     }
   }
   ```
2. **Move the Kotlin source to match the new `namespace`** — the
   package declaration inside the file must match the directory path:
   ```bash
   # from android/app/src/main/kotlin/
   mkdir -p com/yourcompany/yourapp
   git mv com/example/flutter_incident_reporting/MainActivity.kt com/yourcompany/yourapp/MainActivity.kt   # or `mv` if not using git
   ```
   Then edit `MainActivity.kt`'s first line:
   ```kotlin
   package com.yourcompany.yourapp
   ```
   Remove the now-empty `com/example/` directory afterward.
3. Leave `android/app/build.gradle.kts`'s `productFlavors` block
   structure alone for now — the `applicationIdSuffix`/`resValue`
   lines automatically pick up your new base `applicationId` (Step 4
   below covers the *values* inside them).

### Step 3 — Configure the iOS identity

The bundle identifier lives in the flavor xcconfig files this
boilerplate already uses (`ios/Flutter/Flavors/`), **not** hardcoded
directly in `project.pbxproj` for the base value — only the
`$(FLUTTER_TARGET_BUNDLE_ID_SUFFIX)`-templated pattern is in
`project.pbxproj`.

1. Open `ios/Runner.xcodeproj` in Xcode → **Runner** target →
   **Signing & Capabilities** (or **Build Settings**) → find
   `Product Bundle Identifier` for the base `Debug`/`Release`/
   `Profile` configurations, and change it from
   `com.example.flutterIncidentReporting` to
   `com.yourcompany.yourapp`.
2. **Do the same for the `Debug-dev`/`Release-dev`/`Profile-dev` (and
   `-alpha`/`-prod`) configurations** — these were added by this
   boilerplate's flavor setup and currently read
   `com.example.flutterIncidentReporting$(FLUTTER_TARGET_BUNDLE_ID_SUFFIX)`.
   If you'd rather script this than click through 12 configurations
   in Xcode, use the same approach used to create them — the
   [`xcodeproj` Ruby gem](https://github.com/CocoaPods/Xcodeproj)
   (`gem install xcodeproj`) — and verify afterward with
   `xcodebuild -list -project ios/Runner.xcodeproj`. **Always back up
   `ios/` before scripting a `project.pbxproj` edit** — a bad edit can
   silently corrupt the project file.
3. You do **not** need to touch `Info.plist` — its
   `CFBundleIdentifier` already reads `$(PRODUCT_BUNDLE_IDENTIFIER)`,
   so it follows whatever you set in Step 1/2 automatically.

### Step 4 — Re-check the flavor identifiers

The `dev`/`alpha`/`prod` suffix *pattern* doesn't need to change —
only the base identifier underneath it (which you just changed in
Steps 2–3). After the rename, the pattern should read:

| Flavor | Android `applicationId` | iOS Bundle Identifier |
|---|---|---|
| `dev` | `com.yourcompany.yourapp.dev` | `com.yourcompany.yourapp.dev` |
| `alpha` | `com.yourcompany.yourapp.alpha` | `com.yourcompany.yourapp.alpha` |
| `prod` | `com.yourcompany.yourapp` | `com.yourcompany.yourapp` |

Use your **real** organization's reverse-domain identifier for
`com.yourcompany.yourapp` — not the placeholder above, and not
`com.example.*`, which Google Play and Apple both reject at
publish time anyway. Keep the three suffixes **distinct** — that's
what lets `dev`/`alpha`/`prod` be installed on one device
simultaneously; don't collapse them to save typing.

Flavor *names* (`dev`/`alpha`/`prod`) themselves should stay identical
across Android, iOS, and Dart (`AppFlavor` in `app_environment.dart`)
— Flutter matches `--flavor <x>` to the Android product flavor and
the iOS scheme/configuration by that exact string, so renaming one
without the others breaks `--flavor` resolution on that platform. See
[Environments & Flavors](#environments--flavors) and
[Build Matrix](#build-matrix) for the full `devDebug`/.../`prodRelease`
combination table — that structure doesn't change for a new project,
only the identifiers underneath it.

### Step 5 — Configure environment/API settings

Separate task from renaming the app identity — see
[Environments & Flavors](#environments--flavors) for the full
mechanism. For a new project:

- Replace all three `apiBaseUrl` values in
  `lib/core/environment/app_environment.dart`'s `_configFor` — this
  boilerplate's `dev` URL (`https://androidtest.ziademo.com`) is
  *this* project's test API and almost certainly wrong for yours; the
  `alpha`/`prod` placeholders (`https://...TODO-CONFIGURE...`) were
  never real to begin with.
- Update `appDisplayName` in the same file to match whatever you set
  in [Step 6](#step-6--replace-branding) below, so the in-app title
  and the installed app name agree.
- Leave `logLevel`/`enableUiPlayground` logic alone unless your new
  project's QA process genuinely needs different rules — the
  dev/verbose, alpha/moderate, prod/none split is a reasonable
  default for most apps.
- **Never** hardcode a real API secret/key into `app_environment.dart`
  or anywhere else in Dart source — it ships inside the compiled app
  and is trivially extractable. See [Security](#security).

### Step 6 — Replace branding

| What | Android | iOS | Notes |
|---|---|---|---|
| App display name | `resValue("string", "app_name", "...")` per flavor in `android/app/build.gradle.kts` | `APP_DISPLAY_NAME` per flavor in `ios/Flutter/Flavors/*.xcconfig` | Already flavor-aware in this boilerplate — just change the string values |
| App icon | `android/app/src/main/res/mipmap-*/ic_launcher.png` (currently the default Flutter icon, unmodified) | `ios/Runner/Assets.xcassets/AppIcon.appiconset/` (also still the default) | No `flutter_launcher_icons`-style generator is set up — icons are replaced manually today, or you can add that package yourself |
| Splash/launch screen | `android/app/src/main/res/drawable{,-v21}/launch_background.xml` + `styles.xml` (`LaunchTheme`) | `ios/Runner/Base.lproj/LaunchScreen.storyboard` + `Assets.xcassets/LaunchImage.imageset/` | Native launch screens, shown before the Flutter engine draws its first frame — separate from this app's own `SplashPage` Dart widget (`lib/features/auth/presentation/splash/splash_page.dart`), which only runs *after* that |
| Theme colors | — | — | `lib/app/theme/app_theme.dart` → `AppTheme.light`'s `ColorScheme.fromSeed(seedColor: ...)`. See [Theme & Design Tokens](#theme--design-tokens) |
| Environment ribbon colors | — | — | `lib/app/app.dart` — currently blue (`dev`) / deep orange (`alpha`); cosmetic, change freely |

**The point of doing this through the theme, not through
`ui_kit/`:** every Core UI Kit component already reads its colors
from `Theme.of(context).colorScheme`. Changing `AppTheme.light`'s seed
color re-skins the entire app — buttons, cards, badges, dialogs — with
zero changes to any file under `core/ui_kit/`. That's the whole point
of the kit: **same Core UI Kit + new branding = a new-looking app**,
without touching or forking a single component.

### Step 7 — Verify every flavor

```bash
flutter run --flavor dev
flutter run --flavor alpha
flutter run --flavor prod

flutter build apk --flavor dev --debug
flutter build apk --flavor alpha --debug
flutter build apk --flavor prod --debug

flutter build ios --flavor dev --debug --simulator
flutter build ios --flavor alpha --debug --simulator
flutter build ios --flavor prod --debug --simulator
```

> **On an Apple Silicon Mac the `--simulator` builds will fail.** ML
> Kit ships no `arm64` simulator slice, so use a physical device there
> — see [Face Capture Core](#face-capture-core). On an Intel Mac
> (x86_64 simulators) they work.

Confirm on-device/simulator for at least one flavor: the app name
under the icon, the API calls hitting the URL you configured in Step
5, and (for `dev`/`alpha`) the environment ribbon showing the
renamed values, not the old ones.

### Step 8 — Run analyze and tests

```bash
flutter analyze
flutter test
```

`flutter analyze` should come back clean (this boilerplate's own
baseline is a handful of pre-existing `info`-level lints and two
unused imports — see [Code Quality](#code-quality); your rename
shouldn't add anything beyond that). `flutter test` will still fail
on `test/widget_test.dart` regardless of the rename — that's a known,
pre-existing, unrelated issue (see [Testing](#testing)), not something
your renaming broke.

### Verify no boilerplate identifiers remain

Before writing feature code, search the repo for anything you might
have missed:

```bash
grep -rn "flutter_incident_reporting" . \
  --include="*.dart" --include="*.kts" --include="*.gradle" \
  --include="*.plist" --include="*.pbxproj" --include="*.xcconfig" \
  --include="*.xml" --include="*.yaml" \
  --exclude-dir=build --exclude-dir=.dart_tool

grep -rn "flutterIncidentReporting\|com.example" . \
  --include="*.pbxproj" --include="*.xcconfig" --include="*.kts" \
  --exclude-dir=build --exclude-dir=.dart_tool

grep -rn "Incident Reporting" . \
  --include="*.dart" --include="*.arb" --include="*.plist" --include="*.kts" \
  --exclude-dir=build --exclude-dir=.dart_tool
```

The last one will also catch this app's own localized brand strings
in `lib/l10n/app_en.arb`/`app_fil.arb`/`app_ceb.arb`
(`appTitle`, shown on the login screen) — update those too if you're
keeping this as a real "Incident Reporting"-style app under a new
identity, or replace them with your new app's name if not.

Any hit outside `build/`/`.dart_tool/` (which regenerate anyway) is
something you decided to keep or something you missed — make that a
deliberate choice, not an accident.

### Before Adding Features — checklist

- [ ] Renamed the Flutter/Dart project (`pubspec.yaml` + the 2 package-qualified imports)
- [ ] Changed Android `namespace`
- [ ] Changed Android `applicationId`
- [ ] Moved the Kotlin source directory + updated `MainActivity.kt`'s `package` declaration to match
- [ ] Changed the iOS Bundle Identifier (base `Debug`/`Release`/`Profile` **and** all 9 `-dev`/`-alpha`/`-prod` configurations)
- [ ] Confirmed `dev`/`alpha`/`prod` application/bundle ID suffixes are still distinct on both platforms
- [ ] Replaced all three `apiBaseUrl` values in `app_environment.dart`
- [ ] Updated `appDisplayName` per flavor (Dart, Android `resValue`, iOS xcconfig)
- [ ] Replaced app icons (Android mipmaps + iOS `AppIcon.appiconset`) if keeping the default Flutter icon isn't acceptable for your project
- [ ] Replaced the native splash/launch screen assets if applicable
- [ ] Updated `AppTheme.light`'s seed color / theme if the new project needs different branding
- [ ] Ran `flutter run --flavor dev` / `alpha` / `prod` and confirmed each installs and shows the right name
- [ ] Ran `flutter build apk --flavor <x> --debug` for all three flavors
- [ ] Ran `flutter build ios --flavor <x> --debug --simulator` for all three flavors
- [ ] Ran `flutter analyze` — no new issues beyond the pre-existing baseline
- [ ] Ran `flutter test`
- [ ] Searched the repo for leftover `flutter_incident_reporting` / `flutterIncidentReporting` / `com.example` / "Incident Reporting" references and resolved every hit deliberately

### Troubleshooting a rename

**Android build fails with "package does not match namespace" (or
similar)** — the Kotlin file's `package` declaration, its directory
path, and `android.namespace` in `build.gradle.kts` must all agree
exactly. Fix whichever one you missed in
[Step 2](#step-2--configure-the-android-identity).

**Gradle can't find `MainActivity`** — same root cause as above,
usually from moving the file without updating the `package` line
inside it (or vice versa).

**`applicationId` changed but the app still installs under the old
package** — uninstall the old build from the device/emulator first;
Android won't silently migrate an installed app to a new package ID,
it just tries to install a second, separate app.

**iOS build fails with a bundle identifier mismatch, or a scheme
seems to still use the old ID** — you likely updated the base
`Debug`/`Release`/`Profile` configurations but missed one of the 9
flavor-specific ones (`Debug-dev`, `Release-alpha`, etc.) — see
[Step 3](#step-3--configure-the-ios-identity). Run
`xcodebuild -list -project ios/Runner.xcodeproj` and check every
configuration, not just the one you're actively testing.

**Xcode scheme can't find its build configuration** — a scheme
(`dev`/`alpha`/`prod`) references a configuration name directly
(`Debug-dev`, etc.); if you renamed a configuration instead of just
its `PRODUCT_BUNDLE_IDENTIFIER`, update the scheme's `.xcscheme` XML
under `ios/Runner.xcodeproj/xcshareddata/xcschemes/` to match.

**Dart build fails with "target of URI doesn't exist:
package:old_name/..."** — you changed `pubspec.yaml`'s `name:` but
missed one of the package-qualified imports from
[Step 1](#step-1--rename-the-flutterdart-project) — re-run the
`grep` from that step; it's authoritative, not this list.

**App still shows the old name on the home screen** — confirm you
changed the `resValue`/`APP_DISPLAY_NAME` values (Step 6), then fully
uninstall and reinstall — Android/iOS both cache the launcher label
and won't always refresh it on a simple reinstall over an existing app
with the same package/bundle ID.

**`dev`/`alpha`/`prod` install over each other** — their
application/bundle IDs aren't actually distinct; re-check
[Step 4](#step-4--re-check-the-flavor-identifiers) — a common mistake
is updating the base ID but leaving a leftover flavor `applicationIdSuffix`/
xcconfig value pointing at the *old* base, which can accidentally
collide with another flavor.

**Wrong API environment after renaming** — confirm you edited
`AppEnvironment._configFor` (Step 5) and not some other
now-unreachable copy of a URL — this boilerplate has exactly one
source of truth for `apiBaseUrl`; there's nowhere else it should live.

**`--flavor <x>` not recognized** — the flavor name you passed doesn't
match a `productFlavors` entry (Android), an Xcode scheme (iOS), or a
case in `AppFlavor`/`_resolveFlavor` (Dart) — see
[Step 4](#step-4--re-check-the-flavor-identifiers). Flavor names are
case-sensitive.

**Build works for one flavor but not another** — almost always a
config that got updated for one flavor and forgotten for the others
(a classic case: fixing `Debug-dev`'s bundle ID but not
`Release-dev`/`Profile-dev`). Check the *entire* Build Matrix
([Build Matrix](#build-matrix)), not just the variant that's failing.

## Architecture

Strict layered MVVM + Clean Architecture. Dependency direction is
one-way:

```
Presentation (Widgets)
        ↓
ViewModel / Notifier (Riverpod)
        ↓
UseCase
        ↓
Repository (interface in domain/, implementation in data/)
        ↓
DataSource (remote or local)
```

- **Widgets** render state and forward user actions — no business
  logic, no direct API/repository calls.
- **Notifiers** (e.g. `LoginNotifier`, `IncidentListNotifier`) hold
  presentation state and call UseCases. One `Notifier` + one
  `State` class per screen/flow.
- **UseCases** are thin, single-purpose operations
  (`GetIncidentsUseCase`, `CreateIncidentUseCase`, ...) that call a
  Repository. They don't contain HTTP/storage details.
- **Repositories** are an interface in `domain/repositories/` plus an
  implementation in `data/repositories/` that maps technical errors
  (`DioException`, etc.) into domain `Failure`s.
- **DataSources** (`data/datasources/`) are the only layer that talks
  to Dio/`ApiClient` directly.

Every feature under `lib/features/<feature>/` follows this same
`domain/` + `data/` + `presentation/` split — see `incident/` for the
most complete example (list, create, edit, details all present).

## Project Structure

```
lib/
├── main.dart                     # AppEnvironment.initialize() → runApp
├── app/
│   ├── app.dart                  # MaterialApp.router, theme, locale, env banner
│   ├── main_shell.dart           # Bottom-nav shell (Home/Incidents/Profile/[UI Kit])
│   ├── locale/                   # Locale notifier + Cebuano fallback delegates
│   ├── router/                   # go_router config (app_router.dart)
│   └── theme/                    # AppTheme (single light theme)
├── core/                         # Generic — no feature-specific knowledge allowed
│   ├── auth/                     # Auth session manager/providers (cross-feature)
│   ├── constants/                # AppConstants (endpoint paths, storage keys)
│   ├── environment/               # AppEnvironment — flavor/env config (see below)
│   ├── errors/                   # Failure, ErrorCodes, ErrorMapper, ValidationFailure
│   ├── localization/              # ErrorLocalizer (maps ErrorCodes → localized text)
│   ├── models/                   # Cross-feature value objects (Avatar, DateCreated, ...)
│   ├── face_capture/             # ★ Face Capture Core — AppFaceCapture.capture(context)
│   ├── image_viewer/             # ★ Image Viewer Core — AppImageViewer.show(context, image)
│   ├── network/                  # Dio setup, interceptors, ApiClient
│   ├── qr_scanner/               # ★ Core QR Scanner — AppQrScanner.scan(context)
│   ├── signature_pad/            # ★ Signature Pad Core — AppSignaturePad.show(context)
│   ├── storage/                  # SecureStorageService
│   ├── ui_kit/                   # ★ The Core UI Kit — see below
│   ├── utils/                    # Platform-wrapping helpers (image picker, location, camera permission, date picker)
│   └── widgets/                  # Shared widgets: bottom nav, CameraPermissionView
├── features/
│   ├── auth/                     # login, registration, profile, session
│   │   ├── data/                 # datasources, models, repositories, providers
│   │   ├── domain/                # models, repository interface, usecases
│   │   └── presentation/          # login/, registration/, profile/, session/, splash/
│   ├── home/                     # dashboard (presentation only — reuses incident feature's data)
│   │   └── presentation/
│   └── incident/                 # list, create, edit, details
│       ├── data/
│       ├── domain/
│       └── presentation/
│           └── widgets/          # IncidentCard — feature-specific, not in core/
└── l10n/
    ├── app_en.arb                # ★ Edit these: the translation sources
    ├── app_fil.arb
    ├── app_ceb.arb
    └── generated/                # Generated AppLocalizations — do not hand-edit
```

> **Empty folders you will see in an IDE.** `core/navigation/`,
> `features/profile/{data,domain,presentation}/` and
> `features/auth/presentation/{screens,widgets}/` exist on disk but
> contain no Dart files — leftovers from earlier scaffolding. They are
> deliberately listed here as *empty* rather than omitted, so nobody
> goes looking for code in them. Note that profile lives under
> `features/auth/presentation/profile/`, **not** in `features/profile/`.

> **Note on `core/widgets/`**: two things live here for different
> reasons. `AppBottomNavigation` predates the Core UI Kit and hasn't
> been migrated into `core/ui_kit/` yet. `CameraPermissionView` is the
> shared "camera access needed" state used by *both* camera
> capabilities (QR scanner and face capture) — it's deliberately not in
> `core/ui_kit/`, because it carries camera-specific copy and depends
> on `AppCameraPermission`, while the UI Kit stays purely
> presentational. New generic *components* still belong in
> `core/ui_kit/`.

## Core UI Kit

**Location:** `lib/core/ui_kit/`. Import everything with one line:

```dart
import 'package:flutter_incident_reporting/core/ui_kit/ui_kit.dart';
```

(or the relative path from inside `lib/`, matching however the rest
of the file already imports things).

### Purpose

A small, theme-driven component library built for this app and meant
to carry over to future projects. It exists so that:

- Every button/dialog/snackbar/card in the app looks and behaves the
  same way, driven by one theme (`AppTheme`) and one set of design
  tokens.
- Changing the theme's `ColorScheme` updates every component
  automatically — nothing in `ui_kit/` hardcodes a color, aside from
  one deliberate, documented exception (`AppColors`, see below).
- New screens have obvious, pre-built pieces to reach for instead of
  hand-rolling `Card`/`CircularProgressIndicator`/`AlertDialog` again.

### Design principles

- **Composition over specialization.** One `AppButton` with a
  `variant` enum, not `PrimaryButton`/`DangerButton`/`SmallButton`
  classes. Same for `AppDialog` (generic shell) vs
  `AppConfirmationDialog` (built on top of it).
- **Escape hatches, not exhaustive props.** Components expose the
  commonly-needed properties directly (`label`, `icon`, `isLoading`,
  ...) and accept a raw override for anything else (`AppButton.style`
  merges onto the base `ButtonStyle`; `AppTextField.decoration`
  replaces the built-in `InputDecoration` entirely when provided).
- **Theme-driven, not hardcoded.** Every color comes from
  `Theme.of(context).colorScheme`; every spacing/radius/size value
  comes from the token classes below — never a raw number typed
  inline in a component.

### Core vs. Feature responsibility

| | Belongs in `core/ui_kit/` | Belongs in `features/<x>/presentation/widgets/` |
|---|---|---|
| Knows about | Nothing feature-specific | `Incident`, `User`, or other domain models |
| Example | `AppCard`, `AppBadge`, `AppButton` | `IncidentCard` (renders an `Incident`) |
| Rule | Generic, reusable in *any* app | Specific to *this* app's data |

**Do not** put feature-specific widgets in `core/` (e.g. an
`IncidentCard` must never live in `ui_kit/`), and **do not** duplicate
a Core component inside a feature folder just to tweak one visual
detail — extend the Core component instead (add a prop, or use its
existing escape hatch).

### Design tokens (`core/ui_kit/tokens/`)

| Class | Values | Use for |
|---|---|---|
| `AppSpacing` | `xs`(4) `sm`(8) `md`(12) `lg`(16) `xl`(24) `xxl`(32) | Padding, gaps, `SizedBox` sizes |
| `AppRadius` | `sm`(8) `md`(12) `lg`(16) `pill`(999) + `*All` `BorderRadius` variants | Corner radii |
| `AppSizing` | `minTouchTarget`(48) `buttonHeight`(52) `buttonHeightCompact`(40) `iconSm/Md/Lg` `avatarSm/Md/Lg` | Component dimensions |
| `AppMotion` | `fast`(150ms) `medium`(250ms) `slow`(400ms) | Animation durations |
| `AppColors` | `warning`/`onWarning`/`warningContainer`/`onWarningContainer` | **The one deliberate exception** — Material 3's `ColorScheme` has no "warning" role, so this fills that specific gap. Everything else must come from `Theme.of(context).colorScheme`. |

### Component catalog

**Buttons** (`buttons/`)

- **`AppButton`** — the only button in the kit. `isLoading` handles
  the loading state (no separate "loading button" class exists).
  ```dart
  AppButton(
    label: 'Save',
    icon: Icons.check,                          // optional
    variant: AppButtonVariant.primary,           // primary | secondary | outlined | text | destructive
    isLoading: state.isSubmitting,
    onPressed: state.isSubmitting ? null : save,
  )
  ```

**Inputs** (`inputs/`)

- **`AppTextField`** — label/hint/error/icons covered directly; pass
  `decoration` for anything else.
  ```dart
  AppTextField(
    controller: emailController,
    label: 'Email',
    prefixIcon: Icons.email_outlined,
    errorText: fieldError,
    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
  )
  ```
- **`AppPasswordField`** — `AppTextField` + a built-in obscure-text
  toggle. `label` is required (no default), everything else mirrors
  `AppTextField`.

There is no `AppSearchField` or `AppDropdown` — nothing in the app
currently needs search or a select field. Don't add one speculatively;
add it when a real screen needs it.

**Surfaces** (`surfaces/`)

- **`AppCard`** — `Card` + `InkWell` + consistent padding, in one call.
  ```dart
  AppCard(
    onTap: () => context.push('/incidents/$id'),
    child: Text('Tap me'),
  )
  ```
- **`AppAvatar`** — image with initials fallback (also falls back on
  a broken image load, not just a missing URL).
  ```dart
  AppAvatar(imageUrl: user.avatar.fullPath, initials: 'JD', size: 64)
  ```
- **`AppBottomSheet.showActions(...)`** — a generic action sheet
  (title + tappable rows), used for things like a photo-source picker.
  ```dart
  AppBottomSheet.showActions(
    context,
    title: 'Photo Evidence',
    actions: [
      AppBottomSheetAction(icon: Icons.photo_camera_outlined, label: 'Take Photo', onTap: pickFromCamera),
      AppBottomSheetAction(icon: Icons.photo_library_outlined, label: 'Choose from Gallery', onTap: pickFromGallery),
    ],
  )
  ```

**Indicators** (`indicators/`)

- **`AppBadge`** — small status pill. `variant`:
  `neutral | info | success | warning | error`.
- **`AppChip`** — selectable `FilterChip` wrapper (`label`, `selected`,
  `onSelected`, optional `icon`).
- **`AppEnvironmentBadge`** — generic diagonal corner ribbon (wraps
  Flutter's built-in `Banner`); used by `app.dart` to show the
  dev/alpha environment indicator (see
  [Environments & Flavors](#environments--flavors)). Not used inside
  any feature screen.

**Feedback** (`feedback/`)

- **`AppSnackbar`** — `.success()` / `.error()` / `.warning()` /
  `.info()`, each `(context, {required message})`.
- **`AppLoadingIndicator`** — sizeable spinner (`small`/`medium`/
  `large`) with an optional label underneath. Replaces bare
  `CircularProgressIndicator()`.
- **`AppEmptyState`** — icon + title + optional message/action button,
  for "nothing here yet" screens.
- **`AppErrorState`** — icon + message + optional "Retry" button
  (`retryLabel` defaults to the English string `'Retry'` — pass a
  localized string explicitly at call sites, as every screen
  currently does via `AppLocalizations`).

**Dialogs** (`dialogs/`)

- **`AppDialog`** — the generic shell (`title`, optional `icon`,
  `content: Widget?`, `actions: List<Widget>`). Build custom dialogs
  on top of this rather than a raw `AlertDialog`.
- **`AppConfirmationDialog.show(...)`** — yes/no confirmation built on
  `AppDialog`. Set `isDestructive: true` for delete/logout-style
  actions (uses `AppButtonVariant.destructive` for the confirm button
  and a warning icon by default).
  ```dart
  AppConfirmationDialog.show(
    context,
    title: 'Delete Incident',
    message: 'Are you sure? This cannot be undone.',
    isDestructive: true,
    confirmLabel: 'Delete',
    onConfirm: () => notifier.delete(),
  )
  ```
- **`AppLoadingDialog.show(context, {message})` / `.hide(context)`** —
  a non-dismissible blocking dialog for short must-wait operations
  (e.g. logging out). **Prefer `AppButton.isLoading` for form
  submissions** — a blocking dialog is the right call only when there's
  no button to attach the loading state to.

There is no `AppDatePicker`/`AppTimePicker`/`AppDateRangePicker`
**inside `ui_kit/`**. A small `AppDatePicker` utility (wrapping
`showDatePicker`) exists at `lib/core/utils/app_date_picker.dart`, but
it is currently **unused by any screen** — the incident form's date is
auto-captured, not user-editable. Don't assume it's wired into a
screen; if you need a date picker, this utility is the starting point.

### Utilities vs. components (`core/utils/`)

Distinct from `core/ui_kit/`: these are static helper functions
wrapping a platform API, not styled widgets.

| File | Provides |
|---|---|
| `app_image_picker.dart` | `AppImagePicker.pickFromCamera()` / `.pickFromGallery()` (wraps `image_picker`) |
| `app_location.dart` | `AppLocation.getCurrentLocation()` (wraps `geolocator`, throws `LocationServiceDisabledException`/`PermissionDeniedException`) |
| `app_camera_permission.dart` | `AppCameraPermission.check()` / `.request()` / `.openSettings()` (wraps `permission_handler`, returns `CameraPermissionStatus`) |
| `app_date_picker.dart` | `AppDatePicker.pickDate(...)` (wraps `showDatePicker`) — unused today, see above |

## UI Playground

**What it is:** a debug-only screen (`lib/core/ui_kit/playground/ui_playground_page.dart`)
that demos the Core UI Kit components and their states — living visual
documentation, not a testing tool.

The one component with no section is `AppEnvironmentBadge`: it wraps
the whole app rather than sitting in a list, and it is already visible
in every dev/alpha build as the corner ribbon, so a Playground entry
would show nothing new.

**How to reach it:** it's the last tab of the bottom navigation,
labeled "UI Kit" (only present when enabled), or directly via the
`/ui-playground` route (`lib/app/router/app_router.dart`).

**Visibility:** gated by `AppEnvironment.current.enableUiPlayground`,
**not** a plain `kDebugMode` check — see
[Environments & Flavors](#environments--flavors) for the exact rule
per flavor/build-mode combination. It is **never** available in the
`prod` flavor, in debug or release.

**Beyond the UI Kit:** four sections near the bottom demo the
[Core QR Scanner](#core-qr-scanner), the
[Signature Pad Core](#signature-pad-core), the
[Image Viewer Core](#image-viewer-core) and the
[Face Capture Core](#face-capture-core) — none of them is a UI Kit
component, but the Playground is the fastest way to try them on a
device and the reference example of how to call them from a screen.
(`AppLoadingDialog` currently sits after them, so they are not literally
the last sections in the file.) The
face capture section also renders the real `FaceCaptureReviewView`,
wired to whatever has been captured, so the review step can be tried
without building a feature around it.

**When you add a new Core UI Kit component:** add a matching
`_Section(...)` block to `ui_playground_page.dart` showing its name,
one-line purpose, and its interesting states (variants, loading,
disabled, error, etc.) — mirror the existing sections' style. This
keeps the Playground trustworthy as documentation; a component that
exists in `ui_kit/` but isn't in the Playground is easy to forget.

## Core QR Scanner

**What it does:** opens a full-screen scanner, waits for the user to
frame a code, and returns the **raw string** that code contained — or
`null` if the user backed out. That's the whole contract. It does not
validate, parse, navigate, or call an API; the calling feature owns all
of that.

**Where it lives:** `lib/core/qr_scanner/`.

```
lib/core/qr_scanner/
├── qr_scanner.dart                        # barrel — import this
├── app_qr_scanner.dart                    # AppQrScanner.scan(context) + routePath
├── qr_scanner_config.dart                 # QrScannerConfig, QrScanFormat
├── qr_scan_session.dart                   # one-result-per-visit guard
├── qr_scanner_page.dart                   # the screen (camera + permission + error states)
└── widgets/
    └── qr_scanner_overlay.dart            # scrim, corner markers, instructions
```

The "camera access needed" state lives in
`core/widgets/camera_permission_view.dart`, shared with the
[Face Capture Core](#face-capture-core).

Camera permission itself lives in
`lib/core/utils/app_camera_permission.dart`, next to the other
platform wrappers, so any future feature that needs the camera can
reuse it instead of copying permission logic.

### How to call it

```dart
import 'package:flutter_incident_reporting/core/qr_scanner/qr_scanner.dart';

final result = await AppQrScanner.scan(context);

if (result != null) {
  // Handle scanned value
}
```

The full shape, as used in the Playground:

```dart
Future<void> _scanQrCode() async {
  final result = await AppQrScanner.scan(context);

  if (!mounted) {
    return;
  }

  if (result == null) {
    // Cancelled — nothing to do.
    return;
  }

  setState(() => _scannedValue = result);
}
```

### What it returns

| The code contains | You get back |
|---|---|
| `https://example.com/user/12345` | `"https://example.com/user/12345"` |
| `USER-12345` | `"USER-12345"` |
| Nothing readable / user closed the scanner | `null` |

The value is passed through untouched — no trimming, no parsing, no
casing changes. Codes with no text payload (binary-only barcodes) are
ignored rather than returned as an empty string.

**One result per visit.** A camera reports the same code many times a
second; `QrScanSession` accepts the first usable value and rejects
everything after it, then the scanner stops the camera and pops once.
You will never get a duplicate callback.

### Cancellation

Every exit that isn't a successful scan returns `null`: the ✕ button,
the Android back gesture, and the close button on the permission and
error screens. There is no separate "cancelled" result type to handle.

```dart
final result = await AppQrScanner.scan(context);

if (result == null) {
  // User cancelled the scanner
  return;
}
```

### Camera permission

The scanner resolves the permission **before** starting the camera, so
the user never stares at a blank preview. `AppCameraPermission` maps
`permission_handler`'s statuses onto four cases:

| State | What the user sees |
|---|---|
| Granted | The camera preview and scan frame |
| Not yet requested | The OS permission dialog, then the preview |
| Denied (can ask again) | "Camera access needed" + **Allow camera access**, which re-shows the OS dialog |
| Permanently denied / restricted | "Camera access needed" + **Open Settings** — no pointless second prompt |

Coming back from the Settings app re-checks the permission
automatically (on `AppLifecycleState.resumed`), so granting access
there drops the user straight into the scanner.

Note the platform difference the scanner already accounts for: **iOS
shows the camera prompt only once**, so a denial there is always
permanent and only Settings can undo it. On Android a first denial can
be re-prompted; "Don't ask again" moves it to the Settings-only case.

### Android setup

Already done in this repo — nothing to add for a new feature:

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" android:required="false" />
```

`mobile_scanner` merges the `CAMERA` permission from its own manifest
too; it is declared here as well so the app's own requirements are
readable in one place. The hardware feature is deliberately
`required="false"` so the app stays installable on camera-less devices
— the scanner then reports "scanning is not supported on this device"
instead of crashing.

`minSdk` comes from `flutter.minSdkVersion`; `mobile_scanner` needs
API 21+ (ML Kit), which the Flutter default already satisfies.

### iOS setup

One usage description, deliberately generic because the camera is
shared between the scanner and photo capture:

```xml
<!-- ios/Runner/Info.plist -->
<key>NSCameraUsageDescription</key>
<string>This app uses the camera to take photos and to scan QR codes.</string>
```

Keep it generic when you reuse this boilerplate — don't write
"Scan incident QR code": the scanner is a shared capability, and the
string is shown for every camera use in the app.

Minimum deployment target: `mobile_scanner` requires iOS 12.0, and the
project is on 13.0, so nothing to change.

**Optional, before shipping to the App Store:** `permission_handler`
compiles *every* permission handler into the iOS binary by default,
which can draw "missing purpose string" warnings for permissions this
app never asks for. To compile in only what's used, add this to
`ios/Podfile` (the file is generated on the first iOS build):

```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)

    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_CAMERA=1',
        'PERMISSION_LOCATION=1',
        'PERMISSION_PHOTOS=1',
      ]
    end
  end
end
```

Everything not listed is then compiled out. This is a store-submission
nicety, not a requirement for the scanner to work in development.

### Customizing

Pass a `QrScannerConfig` for per-call changes:

```dart
final result = await AppQrScanner.scan(
  context,
  config: const QrScannerConfig(
    title: 'Scan asset tag',
    instruction: 'Line up the tag inside the frame',
    formats: {QrScanFormat.code128, QrScanFormat.qrCode},
    showTorchButton: false,
    frameSizeFactor: 0.6,
  ),
);
```

| Option | Default | Notes |
|---|---|---|
| `title` | localized "Scan QR code" | Also used as the app-bar title on the permission/error screens |
| `instruction` | localized "Place the markers around the QR code..." | |
| `formats` | `{QrScanFormat.qrCode}` | QR only by default, so a stray barcode in frame can't end the session. Empty set = every supported format |
| `showTorchButton` | `true` | The button hides itself anyway when the device reports no torch |
| `frameSizeFactor` | `0.72` | Fraction of the shorter side; also drives the scan window, so only what's inside the frame is decoded |

Anything deeper is a code change, not another constructor argument:

- **Colors** come from `AppTheme` — the success flash uses
  `colorScheme.primary`, and the permission/error screens are plain
  themed surfaces. The only fixed colors are the scrim, the corner
  markers, and the camera background, in `qr_scanner_overlay.dart` /
  `qr_scanner_page.dart`, because they sit on top of a live camera
  image where a light theme's `onSurface` would be invisible.
- **Frame shape / animation** — `_ScanFramePainter` in
  `qr_scanner_overlay.dart` is a single `CustomPainter`.
- **Copy** — the localized strings are the `qrScanner*` keys in
  `lib/l10n/app_*.arb`; scanner errors go through `ErrorCodes` +
  `ErrorLocalizer` like every other error in the app.

### Adding scanner-related behavior without coupling it to a feature

The rule that keeps this reusable: **the scanner returns a string, the
feature decides what it means.** Anything that knows about incidents,
users, inventory, or an API belongs in that feature's Notifier/UseCase,
reading the `String` the scanner handed back.

```dart
// In a feature Notifier — not in core/qr_scanner/.
Future<void> onCodeScanned(String rawValue) async {
  final incidentId = int.tryParse(rawValue);

  if (incidentId == null) {
    state = state.copyWith(errorMessage: ErrorCodes.invalidInput);
    return;
  }

  await _loadIncident(incidentId);
}
```

Treat the scanned value as **untrusted input**: anyone can print a QR
code. Never auto-open a scanned URL, auto-authenticate a scanned
token, or send a scanned value to an endpoint without validating it
first — the same care as a text field the user typed into.

If a *generic* scanner improvement is needed (a different overlay,
gallery import, multi-scan mode), extend `core/qr_scanner/`; if it only
makes sense for one feature, keep it in that feature.

### Camera lifecycle

Handled by `QrScannerPage`, and worth knowing about before changing it:

- The camera starts only after the permission resolves to granted.
- Leaving the app releases the camera (`AppLifecycleState.inactive` →
  `stop()`); returning restarts it.
- A successful scan stops the camera *before* popping, so the calling
  screen never regains focus with the camera still running.
- `dispose()` disposes the controller — the scanner owns it, so
  `MobileScanner` won't do it for us.
- The scan frame is measured from `MediaQuery.sizeOf`, not a
  `LayoutBuilder`, so the camera starting up can't trigger a rebuild
  during the layout phase.

### Tests

`test/core/qr_scanner/` — `QrScanSession` (raw value passthrough,
duplicate suppression), the scan-frame geometry, and widget tests for
`QrScannerPage` that fake both platform channels: a granted scan
returns the exact value and pops once, cancelling returns `null`, and a
blocked permission offers Settings without ever starting the camera.

## Face Capture Core

**What it does:** opens a full-screen camera, guides the user into a
requested pose, and **takes the photo by itself** once the face is
framed, turned the right way, optionally smiling, and held steady. It
returns the photo. That's the whole contract.

### Face detection, not face recognition

This distinction matters legally as much as technically, so it is
worth stating plainly. The capability:

- runs **entirely on the device** (Google ML Kit's bundled face model);
- answers only "is there one face, where is it, which way is it
  turned, is it smiling?";
- **never** identifies anyone, matches a face against a database,
  computes a face template, uploads a frame, or authenticates a user;
- keeps nothing — the only artefact is one photo in the app's temp
  directory, handed to the caller.

If a project needs identity *matching*, that is a backend concern and a
different feature. Do not add it here.

**Where it lives:** `lib/core/face_capture/`.

```
lib/core/face_capture/
├── face_capture.dart                       # barrel — import this
├── app_face_capture.dart                   # AppFaceCapture.capture(context) + routePath
├── face_capture_config.dart                # FaceCaptureConfig, FaceOrientation, FaceCaptureCamera
├── face_capture_result.dart                # FaceCaptureResult
├── face_capture_page.dart                  # the screen: camera, lifecycle, auto-capture
├── face_capture_localizer.dart             # detection enums → localized copy
├── detection/                              # the pure, testable core
│   ├── face_sample.dart                    # one frame, normalized, ML-free
│   ├── face_surface_projection.dart        # image space → what the user sees
│   ├── face_capture_evaluator.dart         # the rules and the score
│   ├── face_capture_assessment.dart        # checks, guidance, readiness band
│   ├── face_capture_thresholds.dart        # the numbers, with their reasoning
│   ├── face_capture_geometry.dart          # where the guide circle sits
│   ├── face_stability_tracker.dart         # how long conditions have held
│   └── face_capture_detector.dart          # the only ML Kit-aware file
├── review/
│   ├── face_capture_review_view.dart       # the light review step
│   └── face_capture_review_slot.dart       # one capture position
└── widgets/                                # ring, sweep, readiness, guidance, status panel
```

Everything under `detection/` except `face_capture_detector.dart` is
plain Dart with no camera, no ML types and no `BuildContext` — which is
why the readiness model can be unit tested instead of demonstrated by
waving at a phone.

> **The one platform trap worth knowing about.** Android and iOS report
> face coordinates in *different* spaces, and getting this wrong makes
> the readiness score stall in a way that looks like a scoring bug:
>
> - **Android** streams the sensor's native landscape buffer. ML Kit
>   receives the rotation, rotates the frame itself, and reports
>   coordinates in that upright frame — so a quarter turn swaps the
>   frame's width and height.
> - **iOS** streams a frame that is *already* upright, because
>   `camera_avfoundation` applies `videoOrientation` to the video data
>   output. `google_mlkit_commons` also ignores the rotation metadata on
>   iOS (it builds a `UIImage` with `.up` orientation), which is
>   consistent with that. Swapping the dimensions there scales every
>   measurement by the frame's aspect ratio: the face reads as "too
>   close" and off-centre wherever the user puts it, and the score
>   cannot pass ~50%.
>
> `FaceCaptureDetector.uprightImageSize` is the single place this is
> decided, and `face_capture_detector_test.dart` pins both platforms.

### How to call it

```dart
import 'package:flutter_incident_reporting/core/face_capture/face_capture.dart';

final result = await AppFaceCapture.capture(context);

if (result != null) {
  // result.imagePath is a temp file — copy it or discard it.
}
```

With a configuration:

```dart
final result = await AppFaceCapture.capture(
  context,
  config: const FaceCaptureConfig(
    orientation: FaceOrientation.left,
    smileRequired: true,
    camera: FaceCaptureCamera.front,
  ),
);
```

The `config:` shape matches `AppQrScanner.scan` on purpose — both Core
capabilities are configured the same way.

### What it returns

`FaceCaptureResult` carries `imagePath`, the `orientation` that was
requested, the `camera` actually used, and `capturedAt`. Nothing else —
no landmarks, no probabilities, no template.

Cancelling returns `null`: the back button, the Android back gesture,
and the close button on the permission and error screens all do.

`imagePath` is a **temporary** file. The Core capability never moves,
copies, uploads or deletes it. Treat it as sensitive: copy it somewhere
the feature controls, or drop it, as soon as you're done.

### Supported poses

| `FaceOrientation` | What the user is asked to do |
|---|---|
| `front` | Look straight at the camera |
| `left` | Turn their head to **their own** left |
| `right` | Turn their head to their own right |

Left and right are from the *user's* point of view — the way you'd say
it out loud. A turn only has to be a natural glance, and there is no
upper bound: turning further keeps passing.

**Two signals decide a turn, because one is not enough.** ML Kit's yaw
angle is precise near the front but *saturates* on a real profile: a
head turned far enough to show an ear was measured on an iPhone at
**10.1°**, which is inside the front tolerance. Relying on the angle
alone therefore both refused genuine profiles and would have accepted
one as a "front" capture.

So orientation is judged as:

- **Direction** from the sign of the yaw, which stays trustworthy long
  after its magnitude does (a 4° lean is enough to say which side).
- **Distance** from the yaw magnitude (≥ 15°) *or* how far the nose has
  moved from the middle of the face box (≥ 0.14 of its width). The nose
  keeps travelling all the way round, so it covers exactly where the
  angle gives up.
- **Front** requires the yaw within ±14° *and* the nose still centred,
  so a profile with a collapsed angle can't pass as a front view.

**Which side the head turned depends on whether the frame is
mirrored.** This is the difference between "turn left" working and
doing precisely the opposite, so it is worth stating exactly.

ML Kit reports `headEulerAngleY` as positive when the face turns toward
the right-hand side of the image. A subject facing the camera has their
own left on the image's right, so in an **unmirrored** frame a positive
angle already means "turned to their own left" — the documented
behaviour, and what Android reports.

But `camera_avfoundation` sets `connection.isVideoMirrored = true` for
the front camera, so on **iOS the front-camera buffer is a mirror
image** and the same head turn arrives negated. Android's CameraX
mirrors nothing. Measured: a turn to the user's own left reads about
**-29°** on an iPhone front camera and **+29°** on an Android one.

`FaceCaptureDetector.yawSignForUserLeft` therefore derives the sign per
frame from platform *and* lens direction rather than hard-coding it —
which also gets the iOS **rear** camera right, since that frame is not
mirrored either. Everything downstream can rely on "positive means the
user's own left".

**Head pose needs landmarks or classification switched on.** On iOS ML
Kit only reports `headEulerAngleY` when one of those modes is active
(`MLKFace.hasHeadEulerAngleY` is otherwise false and the plugin sends
null), so `FaceCaptureDetector` enables both unconditionally. With them
off, a null yaw made every *front* capture pass without checking the
pose at all, while `left` and `right` could never pass — the failure
looked like "turning is not detected" and hid behind a front capture
that appeared to work.

**A profile is framed differently from a front view**, and is judged
that way. A turned head hides a cheek, so ML Kit's box is narrower and
sits off-centre. `FaceCaptureThresholds` therefore carries separate
`profileMinWidthFraction` (0.24 vs 0.30) and `profileMaxCenterOffsetX`
(0.18 vs 0.12) — otherwise a profile fails on *framing* for doing
exactly what it was asked to do.

### Smile detection

`smileRequired: false` is the default. With `smileRequired: true`,
readiness cannot reach 100% until ML Kit reports a smile probability of
at least 0.55, and the instruction "Give us a smile" appears once
framing and pose are already right.

**A smile requirement applies to a front capture only.** ML Kit reads a
smile from a mouth it can barely see once the head is turned, so
requiring one on a `left` or `right` capture would gate the photo on a
meaningless number. The flag is honoured where it can be and ignored
where it cannot: a profile capture shows "Smile — N/A" in the status
panel rather than leaving the user waiting on something that will never
pass.

### Readiness, and why it isn't a timer

Each rule carries a weight; the score is the share of active weight
currently passing:

```
score = round(100 * passedWeight / activeWeight)
```

| Rule | Weight |
|---|---|
| exactly one face | 2 |
| face centred on the guide | 2 |
| face at a usable distance | 2 |
| head at the requested orientation | 3 |
| smile — only when `smileRequired` | 2 |

Holding still is deliberately **not** one of the weights. It is a
separate gate that runs *after* the score reaches 100, which splits the
experience into two honest halves:

```
requirements  ->  100%  ->  hold 3, 2, 1  ->  capture
```

- **100% means every requirement is satisfied**, in this frame, right
  now. The weights are whole numbers and nothing is graded, so
  `score == 100` is exactly equivalent to "all conditions pass" — there
  is no rounding by which one could be true without the other.
- **Then the countdown proves the user can hold it.** Reaching 100% is
  not a capture: `isReady` — the only thing that fires the shutter —
  additionally requires the hold period to have elapsed with those
  conditions unbroken. Break the pose and the score drops back below
  100, the countdown disappears, and the hold starts over.
- **No face means 0%.** A frame with no face, or with more than one,
  can't meaningfully satisfy anything else, so the score is gated to
  zero and the ring empties.

Partial scores are real measurements, not animation. A face that is
framed and centred but turned too far to count as "front" reads 67%
(6 of 9 weight); add a smile requirement it isn't meeting and an
otherwise correct pose reads 82% (9 of 11).

Multiple faces are never resolved by picking one: the score stays at 0
and the user is told to make sure only one face is visible.

### Stability

`holdDuration` defaults to **3 seconds**, and those seconds are shown:
the moment the score hits 100%, a countdown badge appears next to "Hold
still..." and ticks 3, 2, 1. It never appears before then — the number
is a promise that everything else already passed, so seeing it means
the only thing left to do is keep still. The count is rounded *up*, so
it starts at 3 rather than 2, and it reaches 0 only when the capture
actually fires.

Failures **decay** the accumulated time at 2.5× rather than zeroing it,
so one noisy frame costs a little progress instead of restarting the
hold, while genuinely losing the face empties it quickly.
`FaceStabilityTracker` takes the frame timestamp as a parameter rather
than reading the clock, which is what makes this testable.

Shortening `holdDuration` shortens the countdown with it — the badge is
derived from the same progress value as the score, so the two can never
disagree. Below one second the badge simply shows 1.

### The scanner screen

Dark, immersive, and built around the face: a full-bleed preview, a
circular window cut out of a dimmed overlay so the face stays
unobstructed and bright, and the readiness ring just outside it. The
percentage sits above the window, the instruction below it, and a
compact status panel along the bottom.

The guide circle comes from `FaceCaptureGeometry` — the *same* constants
the position rule is measured against. That is deliberate: if the ring
and the rule disagreed, the scanner would ask people to move a face
that already looks centred.

Instructions are chosen from whichever rule is blocking progress, in
the order a user would fix them: find a face → only one face →
distance → centring → pose → smile. Once nothing is blocking, the pose
instruction stays up and "Hold still…" is added underneath, rather than
throwing a new instruction at someone who is already doing it right.
No instruction mentions yaw, probabilities, or anything else from
inside the detector.

A faint band of light sweeps the window while detecting. It stops once
ready and honours the platform's reduce-motion setting.

### Camera selection

`FaceCaptureCamera.front` (default) or `.rear`. If the device doesn't
have the requested one, capture carries on with what it does have and
`FaceCaptureResult.camera` reports what was actually used. The switch
button appears only when the device really has more than one camera and
`allowCameraSwitch` is left on; switching tears the old camera down,
resets detection and readiness, and is guarded against double taps.

### Camera permission

Identical handling to the [Core QR Scanner](#core-qr-scanner) — the
same `AppCameraPermission` wrapper and the same shared
`CameraPermissionView`, so there is exactly one implementation of the
four permission states in the project. Permission is resolved *before*
the camera starts, so the user never sees a dead preview, and returning
from the Settings app re-checks it automatically.

### Camera lifecycle

- The camera starts only after permission resolves to granted.
- Leaving the app releases it (`AppLifecycleState.inactive`);
  returning restarts it.
- A successful capture stops the stream *before* the photo is taken and
  before the route pops, so the calling screen never regains focus with
  the camera still running.
- `dispose()` releases the camera and closes the ML Kit detector.
- Detection is throttled to ~9 frames per second and skips any frame
  arriving while the previous one is still being processed, so a 30fps
  camera can't queue work faster than ML Kit finishes it.
- The screen only repaints when something the user can see changed —
  most frames are visually identical to the one before.

### The review step

`FaceCaptureReviewView` is the light, image-focused review UI: slot per
pose, completion state, tips card, primary and secondary actions.

It is a **body widget, not a page** — the calling feature supplies the
`Scaffold` and app bar, because only it knows whether the screen is
called "Verify Account" or "Employee Check-In".

```dart
Scaffold(
  appBar: AppBar(title: const Text('Verify Account')),
  body: FaceCaptureReviewView(
    slots: [
      FaceCaptureReviewSlot(
        orientation: FaceOrientation.left,
        imagePath: captures[FaceOrientation.left],
      ),
      FaceCaptureReviewSlot(
        orientation: FaceOrientation.front,
        imagePath: captures[FaceOrientation.front],
      ),
      const FaceCaptureReviewSlot(
        orientation: FaceOrientation.right,
        isRequired: false,
      ),
    ],
    onSlotTapped: _capture,          // capture or retake that pose
    onContinue: canSubmit ? _submit : null,
  ),
)
```

Slots render empty (placeholder + "Required"/"Optional") or completed
(photo + check badge + "Completed"), and a missing temp file falls back
to the placeholder rather than breaking the screen.
`FaceCaptureReviewView.allRequiredCompleted(slots)` is the usual
condition for enabling `onContinue`.

### Keeping features out of Core, and Core out of features

The split that makes this reusable:

| | Owns |
|---|---|
| **Face Capture Core** | camera, detection, orientation, smile, readiness, auto-capture, returning a photo |
| **Review step** | showing captured photos, completion state, retake and continue affordances |
| **Your feature** | which poses are required, the order, uploading, API calls, validation, storage |

One call captures one pose. A left → front → right → review → submit
workflow is composed by the feature, looping over the poses it wants —
the Core capability deliberately has no concept of a sequence, so the
next project can ask for something different.

```dart
// In a feature Notifier — not in core/face_capture/.
Future<void> onFaceCaptured(FaceCaptureResult result) async {
  final stored = await _copyToFeatureStorage(result.imagePath);

  state = state.copyWith(
    captures: {...state.captures, result.orientation: stored},
  );
}
```

### Customizing

`FaceCaptureConfig` exposes `orientation`, `smileRequired`, `camera`,
`allowCameraSwitch`, `title` and `holdDuration` — the options that are
realistically useful across projects. Detection thresholds are
deliberately *not* part of the public API; they live with their
reasoning in `face_capture_thresholds.dart`, and tuning them is a
one-file job.

Colours follow the theme: the ring and readiness label use
`colorScheme.primary` while detecting and `colorScheme.tertiary` once
ready (the same role `AppSnackbar.success` uses for success in this
design system). The only fixed colours are the scrim, the guide
brackets and the camera background, because they sit on top of a live
camera image where a light theme's `onSurface` would be invisible.
Copy comes from the `faceCapture*` keys in `lib/l10n/app_*.arb`.

### Privacy and security

- On-device only. No frame leaves the phone, and there is no network
  code anywhere in `core/face_capture/`.
- Nothing is logged about detection: no frames, no probabilities, no
  paths. `FaceCaptureResult.toString()` deliberately omits the image
  path, since a result may end up in a log line.
- The captured photo is a temp file, and the feature that asked for it
  owns its lifetime. Do not add persistence to Core.
- A face photo is sensitive personal data in most jurisdictions.
  Whatever a feature does with it — upload, store, display — deserves
  the same care as a password field, plus a look at local privacy law.

### Testing

`test/core/face_capture/` — 87 tests, and the split tells you what is
testable without hardware:

- **`face_capture_evaluator_test.dart`** — the readiness model: exact
  scores, the no-face gate, front/left/right not being interchangeable,
  smile-required vs not, guidance priority, status rows, readiness
  bands, that 100% is exactly "all requirements pass", and the
  3-2-1 countdown.
- **`face_stability_tracker_test.dart`** — hold accumulation, decay on
  a dropped frame, reset, and a clock that jumps backwards.
- **`face_surface_projection_test.dart`** — the `BoxFit.cover` mapping,
  including mirroring and both crop directions.
- **`face_capture_review_view_test.dart`** — slot states, actions, and
  a missing image file.
- **`face_capture_localizer_test.dart`** — every enum resolves in all
  three locales, and no instruction leaks detector jargon.
- **`face_capture_detector_test.dart`** — the Android/iOS coordinate
  space difference described above, and the per-platform image format.
- **`face_capture_widgets_test.dart`** — the guide geometry, and that
  the ring, readiness, guidance and status panel all lay out on a tall
  *and* a small phone, in the longest locale, without overflowing.
- **`face_capture_page_test.dart`** — the permission paths that gate the
  camera, plus cancellation returning null.

**The debug overlay.** In dev and alpha builds (anything where
`AppEnvironment.current.enableUiPlayground` is true — never prod) the
scanner shows the raw detection signals under the guide: face count,
yaw, face width fraction, centre, smile probability and hold progress.
It exists because this feature depends on numbers nobody can see, and
"what did the detector actually report?" is otherwise a
build-and-retest cycle per guess. A dash in the yaw row means ML Kit
reported no head pose at all — which is the difference between "the
user is not turning far enough" and "left/right cannot work on this
device".

**iOS simulators and Apple Silicon.** Google ships ML Kit's frameworks
without an `arm64` *simulator* slice, so `flutter build` prints:

```
The following target(s) do not support arm64 architecture, which is a
requirement for Apple Silicon iOS 26+ simulators: GoogleMLKit, MLImage,
MLKitCommon, MLKitFaceDetection, MLKitVision
```

On an **Intel** Mac (x86_64 simulators) this is harmless — simulators
keep working. On an **Apple Silicon** Mac the app cannot run on an iOS
simulator at all once this dependency is present; development there has
to happen on a physical device. Worth knowing before this boilerplate
moves to a new machine, since it affects the whole app, not just the
face capture screen.

**What needs a physical device.** The live camera and ML Kit are
platform code and cannot run in a widget test — and emulators are not
much better, since a simulated camera has no real face to detect. Check
these by hand on an Android device and an iPhone:

1. Head pose: front, left, right — **on both platforms**, since the
   yaw sign depends on front-camera mirroring, which differs between
   them (see above). Also check the debug overlay shows a real yaw
   rather than a dash, and test the rear camera if a project uses it. ML Kit's yaw sign is interpreted in one place,
   `_yawSignForUserLeft` in `face_capture_detector.dart`; if a device
   reports it the other way round, flipping that constant to `-1` fixes
   left and right everywhere.
2. The guide circle lining up with where a centred face actually
   appears (this is the `BoxFit.cover` projection doing its job).
3. Smile detection with `smileRequired: true`.
4. Auto-capture firing once, and the photo being right-side-up.
5. Front-camera mirroring in the *captured file*, which differs by
   platform — decide per project whether to flip it, and do that in the
   feature, not in Core.
6. Camera switching, backgrounding mid-capture, and revoking the
   camera permission in Settings while the scanner is open.

## Image Viewer Core

**What it does:** opens an immersive, zoomable viewer for one image or
a swipeable gallery, and returns when the user closes it. No result, no
business logic — it is handed images and shows them.

**Where it lives:** `lib/core/image_viewer/`.

```
lib/core/image_viewer/
├── image_viewer.dart              # barrel — import this
├── app_image_viewer.dart          # AppImageViewer.show / .showGallery + routePath
├── app_image_source.dart          # AppImageSource — where an image comes from
├── image_viewer_config.dart       # AppImageViewerConfig, AppImageViewerAction
├── image_viewer_page.dart         # the page: paging, counter, top bar
└── widgets/
    ├── zoomable_image.dart        # InteractiveViewer + double-tap + load/error
    └── image_viewer_counter.dart  # the "2 / 5" pill
```

### No package, on purpose

`photo_view` is the usual answer here, and it was considered and
rejected: its last release is **April 2024** with a `flutter: >=1.6.0`
constraint, which is not something to put under a boilerplate that just
moved to Flutter 3.44.

What replaces it is first-party and already in the SDK:

| Need | Used |
|---|---|
| Pinch zoom, pan, momentum, edge boundaries | `InteractiveViewer` |
| Swiping between images, lazily | `PageView.builder` |
| Network caching | Flutter's own `ImageCache` — no second caching layer |
| Double-tap zoom | ~20 lines of standard `TransformationController` work |

Only the last one is code we own, and it is framework-idiomatic rather
than gesture maths.

### How to call it

```dart
import 'package:flutter_incident_reporting/core/image_viewer/image_viewer.dart';

// One image.
await AppImageViewer.show(
  context,
  AppImageSource.network(incident.image.fullPath),
);

// A gallery, opened on the third photo.
await AppImageViewer.showGallery(
  context,
  photos.map(AppImageSource.network).toList(),
  initialIndex: 2,
);
```

A real-world shape — an incident photo the user taps, with a Hero
transition from the thumbnail:

```dart
// The thumbnail in the list.
Hero(
  tag: 'incident-${incident.articleId}',
  child: Image.network(incident.image.thumbPath, fit: BoxFit.cover),
)

// The tap handler.
void _viewPhoto(Incident incident) {
  AppImageViewer.show(
    context,
    AppImageSource.network(
      incident.image.fullPath,
      semanticLabel: incident.name,
      heroTag: 'incident-${incident.articleId}',
    ),
  );
}
```

The `heroTag` is optional and the viewer works without it — nothing
needs a Hero configured.

### Where images come from

`AppImageSource` is a thin wrapper over Flutter's `ImageProvider`
rather than a new image model. The project's `Avatar` is an API DTO
(paths a server returned), not something a widget can render, so a
parallel abstraction would just mean converting between three things
instead of two.

| Factory | For |
|---|---|
| `AppImageSource.network(url, headers: ...)` | A remote image; `headers` covers authenticated endpoints |
| `AppImageSource.file(path)` | A file on the device — e.g. a `FaceCaptureResult.imagePath` |
| `AppImageSource.memory(bytes)` | Bytes already in memory |
| `AppImageSource.asset(name)` | A bundled asset |
| `AppImageSource.provider(anyImageProvider)` | The escape hatch — a project that later adds a caching package passes its provider straight through |

Each carries an optional `semanticLabel` (announced instead of the
image) and `heroTag`.

### Zoom, pan and paging

- **Pinch** to zoom, up to 5×.
- **Double tap** to zoom to 2.5× *on the tapped point*, and again to
  return to fit. Zooming on the centre instead of the tap would move
  the detail the user was aiming at, so the tap position is used.
- **Pan** when zoomed, bounded by `InteractiveViewer` so a zoomed image
  cannot be flung into empty space.
- **Paging is suspended while zoomed.** This is the one interaction
  that has to be arbitrated: at rest a horizontal drag turns the page,
  and while magnified the same drag pans the image. `ZoomableImage`
  reports its zoom state up, and the gallery swaps `PageScrollPhysics`
  for `NeverScrollableScrollPhysics`.
- **Changing page clears the zoom**, so returning to an image never
  lands on leftover magnification.

### Counter, controls and actions

The counter appears only when there is more than one image — "1 / 1" is
noise. It reads "2 / 5" and announces "Image 2 of 5".

The top bar holds a close button (left), an optional title, and any
actions the caller supplied. System back closes the viewer regardless,
because it is a route rather than a bespoke overlay.

**No share, save or delete button ships with it.** Each needs a package
and a policy decision (where does a download go? what does deleting
mean?), which makes them feature concerns. Callers pass the actions
they want:

```dart
AppImageViewer.showGallery(
  context,
  images,
  config: AppImageViewerConfig(
    title: 'Evidence photos',
    actions: [
      AppImageViewerAction(
        icon: Icons.delete_outline,
        label: 'Delete photo',            // tooltip *and* screen-reader label
        onPressed: (index, image) => _confirmDelete(index),
      ),
    ],
  ),
);
```

### Loading and error states

While an image decodes: `AppLoadingIndicator` on the viewer's surface,
never a blank black screen. `frameBuilder` is used rather than
`Image.network`'s `loadingBuilder` so files, bytes and assets get the
same treatment.

On failure: `AppErrorState` with "Unable to load image." and a Retry
that evicts the cached failure and genuinely re-fetches. No exception
text is shown. Since `AppErrorState` takes its colours from the app's
*light* theme, it is wrapped in a dark scheme derived from the app's own
`colorScheme.primary` — the component and the brand colour are reused
rather than forked.

### Customization

`AppImageViewerConfig` exposes `showCounter`, `showCloseButton`,
`title`, `actions` and `backgroundColor`. Gesture behaviour is
deliberately *not* configurable: zoom limits and double-tap scale
should feel the same everywhere in an app.

The background is black by default even though the app's theme is
light. An image viewer is an immersive surface, and a light background
changes how the image itself reads.

### Accessibility

Images announce their `semanticLabel` (falling back to a localized
"Image"). The close button and every action carry a tooltip that
doubles as the screen-reader label, so nothing is icon-only. The
counter is announced as "Image 2 of 5" rather than "2 / 5". Controls
are `IconButton`s, which already meet the minimum touch target, and
they sit inside `SafeArea` so notches, Dynamic Island and system bars
never cover them.

### Performance

`PageView.builder` keeps only the visible page and its neighbours
alive, so a twenty-image gallery never decodes twenty full-resolution
images. `BoxFit.contain` preserves aspect ratio and never upscales a
small image past its own resolution. Network caching is Flutter's
`ImageCache`; no second caching layer was added.

### Edge cases

| Case | Behaviour |
|---|---|
| Empty list | Nothing opens. Asserts in debug (almost always a caller that forgot to check); a silent no-op in release. `AppImageViewer.canShow(images)` is there for callers that would rather hide the affordance |
| Out-of-range `initialIndex` | Clamped, in both directions |
| Page built directly with no images | Renders the bar and nothing else — no crash. `clamp(0, -1)` is itself an error, which is what made this worth a test |
| Image fails to load | Error state with retry, per image; the rest of the gallery keeps working |
| Viewer closed mid-load | Controllers and listeners are disposed with the page |

### What was left out

**Swipe-down-to-dismiss** is not implemented. `InteractiveViewer`
installs its own pan recognizer, so a competing vertical drag detector
means two gesture arenas fighting over the same drag — and the failure
mode is a viewer that sometimes dismisses when the user meant to pan.
The spec for this component called the gesture optional and stability
not; close button and system back are always available. If it is added
later, the honest way is a custom gesture arbitration, not a
`GestureDetector` wrapped around the viewer.

### Testing

`test/core/image_viewer/` — 24 tests covering single vs gallery,
initial-index clamping, swiping, the counter, double-tap zoom and that
it suspends paging, the load-failure state, the empty list, a
directly-built empty page, config flags, caller actions and the
accessibility labels.

One harness note worth copying: these tests use bounded `pump` calls
rather than `pumpAndSettle`, because the loading indicator is a
continuous animation and nothing ever "settles" while an image is
decoding.

## Signature Pad Core

**What it does:** shows a full-screen pad, lets the user sign with a
finger or stylus, and returns the signature as a PNG.

> **The exported signature is a PNG with a transparent background and
> contains only the signature strokes, not the Signature Pad UI.** No
> border, no dashed frame, no instruction text, no buttons, no
> background fill, no shadows.

That is guaranteed by construction rather than by inspection: the
export paints the *same* `SignaturePainter` used on screen onto a
fresh, empty canvas. The painter draws strokes and nothing else — the
frame, the hint and the buttons are separate widgets it has no access
to — so there is no path by which pad chrome could reach the image.
Nothing paints a background, so every pixel the pen missed stays fully
transparent.

**Where it lives:** `lib/core/signature_pad/`.

```
lib/core/signature_pad/
├── signature_pad.dart              # barrel — import this
├── app_signature_pad.dart          # AppSignaturePad.show + routePath
├── signature_pad_config.dart       # SignaturePadConfig
├── signature_pad_controller.dart   # strokes, validation, PNG export
├── signature_pad_page.dart         # the screen
├── signature_result.dart           # SignatureResult
├── signature_stroke.dart           # one pen-down-to-pen-up mark
└── widgets/
    ├── signature_canvas.dart       # dashed frame, hint, touch handling
    └── signature_painter.dart      # paints strokes — and nothing else
```

### No package, on purpose

The `signature` package is well maintained (6.4.0, mid-2026) and was a
real option — this is not a stale-dependency rejection. Two things
decided it:

- It pulls in **`flutter_svg`** transitively for an export format this
  boilerplate doesn't need.
- Its export model is *full canvas + `exportBackgroundColor`*, whereas
  the requirement here is cropping to the stroke bounds without
  clipping. Doing that properly needs the stroke points, and owning
  them is also what lets one painter serve both the screen and the
  export.

The underlying mechanism (`PictureRecorder` → `Picture.toImage` →
`ImageByteFormat.png`) is identical either way, so the package would
have added a dependency without removing any of the work.

### How to call it

```dart
import 'package:flutter_incident_reporting/core/signature_pad/signature_pad.dart';

final result = await AppSignaturePad.show(context);

if (result == null) {
  return; // Cancelled.
}

// A transparent PNG, ready to upload or embed.
await _uploadSignature(result.bytes);
```

`SignatureResult` carries `bytes` (the PNG), plus `width` and `height`
in pixels. Its `toString()` deliberately omits the bytes — a signature
is not something to drop into a log line.

### Drawing

Touch is handled by a `Listener` rather than a `GestureDetector`, so
points arrive without waiting for the gesture arena to resolve and the
first millimetre of a stroke isn't lost. A stylus reports through the
same path as a finger.

Strokes are smoothed with **midpoint quadratic curves**: each raw touch
sample becomes the control point of a curve ending at the midpoint of
the next segment. Straight lines between samples look faceted when the
finger moves fast, because the samples arrive far apart. Round caps and
joins finish it, so a line reads as ink rather than as segments.

### Is it signed yet?

The pad does *not* ask "has the canvas been touched?". It measures
**total ink travel** and requires at least
`SignaturePadController.minimumInkLength` (20 logical pixels) before
Complete is enabled. A tap or a twitch produces almost no travel; even
initials produce far more.

This gives the two buttons genuinely different conditions, which is
what the design implies:

| Pad state | Clear | Complete |
|---|---|---|
| Untouched | disabled | disabled |
| A stray tap or twitch | **enabled** — there's a mark worth removing | disabled |
| A signature | enabled | enabled |

### Clear

Removes every stroke immediately, resets the state, disables Complete
and brings the empty-state hint back. **No confirmation** — clearing is
repeatable and reversible, so a dialog would only be in the way.

### Complete

Validates that a signature exists, exports it, and pops with the
result. A `null` export (which the disabled button should already have
prevented) leaves the pad open rather than closing with nothing.

### Cancellation

The ✕ button, Android back and the iOS swipe all return `null`. With a
signature on the pad they first ask "Discard signature?" via the
existing `AppConfirmationDialog`, because a signature is user *work*
and losing it to a misplaced tap is the kind of thing people notice.
Set `confirmDiscard: false` for a pad that closes immediately.

All three routes go through the same guard: `PopScope.canPop` is
recomputed whenever the signature state changes, so the back gesture
can't skip a confirmation the button would have shown.

### Cropping

On by default. A signature drawn in the corner of a tall canvas would
otherwise export as mostly empty space, which is awkward to composite
into a document.

The crop is **analytic, not pixel-scanned**: bounds come from the
stroke geometry, already inflated by half the pen width so an end cap
can never be clipped, then inflated again by `cropPadding` (12 logical
pixels by default). Exact, cheap, and impossible to clip a stroke.

```
signing area                    exported PNG
┌──────────────────────────┐    ┌────────────────┐
│                          │    │  signature     │  ← bounds + padding
│      signature           │ →  └────────────────┘     transparent
│                          │
└──────────────────────────┘
```

`cropToSignature: false` keeps the full signing area instead — still
transparent, just uncropped.

### Resolution

`exportPixelRatio` defaults to **3×** and is fixed rather than read
from the device, so the same signature exports at the same quality on
every phone. Three times a full-width signing area is comfortably
enough for API upload, PDF embedding and print.

PNG is the only output format. JPEG cannot carry transparency, so the
format is part of the contract rather than an implementation detail —
there is a test asserting the PNG magic number.

### Customization

`SignaturePadConfig` exposes `title`, `hint` (empty string hides it),
`strokeColor`, `strokeWidth`, `exportPixelRatio`, `cropToSignature`,
`cropPadding`, `confirmDiscard`, `clearLabel` and `completeLabel`.
Stroke caps, joins and smoothing are deliberately not configurable — a
signature should look the same everywhere in an app.

### Presentation and layout

A full-screen route, for the same reason as the scanner and face
capture: a signature needs every pixel the device has, and a route
gives correct system-back behaviour for free. The signing area takes
all the space left after the title and buttons, inside a `SafeArea`, so
notches, Dynamic Island and navigation bars never overlap it and small
phones still get a usable canvas. No dimension is hardcoded.

### Accessibility

The close button carries a tooltip that doubles as its screen-reader
label. Clear and Complete are `AppButton`s, which already announce
their labels and meet the minimum touch target. The signing area is
labelled "Signature drawing area" with `excludeSemantics`, so it
describes itself without swallowing the touch events that draw.

### Privacy

The Core capability never uploads, stores, persists or logs a
signature — it hands back bytes and forgets them. Treat those bytes as
sensitive user data: the calling feature owns the whole lifecycle, and
`SignatureResult.toString()` is deliberately byte-free so an
accidental log line cannot leak one.

### Testing

`test/core/signature_pad/` — 34 tests, in three groups:

- **`signature_export_test.dart`** — the important one. It decodes the
  exported PNG and asserts the corner pixels have **alpha 0** while the
  ink is opaque, that the bytes start with the PNG magic number, that
  cropping shrinks the output to the stroke bounds (and `crop: false`
  doesn't), that a stroke drawn hard against the edge isn't clipped,
  that `exportPixelRatio` scales the output, and that an empty pad and
  a stray tap both export nothing.
- **`signature_pad_controller_test.dart`** — the ink-length threshold,
  accumulation across strokes, clear, notification behaviour, bounds
  including pen width, and that the exposed stroke list is
  unmodifiable.
- **`signature_pad_page_test.dart`** — button states, drawing, clear,
  completing (returns a non-empty PNG and closes), all three
  cancellation routes including the discard confirmation, custom copy,
  and the accessibility labels.

**What needs a device.** Stroke feel is the one thing tests can't
judge: whether the line keeps up with a fast signature, and whether a
stylus behaves like a finger. Worth signing a few times on both an
Android phone and an iPhone.

## Real-World Usage — Core UI Kit in Production Screens

The Playground shows components in isolation; these screens show them
doing real work. Only components actually used are listed below.

| Screen | File | Components used |
|---|---|---|
| Login | `features/auth/presentation/login/login_page.dart` | `AppTextField`, `AppPasswordField`, `AppButton` (primary + text variant), `AppSnackbar` |
| Registration | `features/auth/presentation/registration/registration_page.dart` | `AppTextField`, `AppPasswordField`, `AppButton`, `AppSnackbar.error` |
| Home (dashboard) | `features/home/presentation/home_page.dart` | `AppCard`, `AppButton`, `AppLoadingIndicator`, `AppEmptyState`, `AppErrorState`, `IncidentCard` |
| Incident list | `features/incident/presentation/incident_page.dart` | `AppLoadingIndicator`, `AppEmptyState`, `AppErrorState`, `IncidentCard` (all 3 layouts) |
| Create/Edit incident | `.../create_incident_page.dart`, `.../edit_incident_page.dart` | `AppTextField`, `AppBottomSheet`, `AppButton`, `AppSnackbar` |
| Incident details | `.../incident_details_page.dart` | `AppLoadingIndicator`, `AppErrorState`, `AppConfirmationDialog`, `AppSnackbar` |
| Profile | `features/auth/presentation/profile/profile_page.dart` | `AppAvatar`, `AppCard`, `AppButton`, `AppLoadingIndicator`, `AppEmptyState`, `AppErrorState`, `AppConfirmationDialog`, `AppLoadingDialog`, `AppDialog` (language picker) |
| App shell | `app/main_shell.dart` | `AppBottomNavigation` (from `core/widgets/`, not the UI Kit — see [Project Structure](#project-structure)) |
| App root | `app/app.dart` | `AppEnvironmentBadge` (the dev/alpha corner ribbon) |

`IncidentCard` (`features/incident/presentation/widgets/incident_card.dart`)
is the one feature-specific component of note: it renders an
`Incident` in one of three layouts (`horizontal` / `list` / `grid`),
built on top of `AppCard`. It replaced four separate hand-rolled card
implementations that used to exist across the home and incident-list
screens — a good example of "generic → Core, feature-specific →
feature" in practice.

`AppBadge`/`AppChip` are **not** currently used on any incident card —
the `Incident` model has no status/severity field to badge (only
`articleId`, `name`, `description`, `dateCreated`, `image`), and
inventing one just for a visual would mean fabricating data the API
doesn't provide. If a real status/severity field is added later,
that's the natural place to reach for `AppBadge`.

## Theme & Design Tokens

Single light theme: `lib/app/theme/app_theme.dart` → `AppTheme.light`,
wired into `MaterialApp.router(theme: ...)` in `app.dart`. Material 3,
`ColorScheme.fromSeed(seedColor: Colors.blue)`. **No dark theme exists
yet** — adding one means adding `AppTheme.dark` and wiring
`darkTheme:`/`themeMode:` into `MaterialApp.router`; nothing in
`ui_kit/` needs to change first, since every component already reads
colors from `Theme.of(context).colorScheme` rather than hardcoding
light-mode assumptions.

To reskin the whole app (new brand color, different seed), change
`AppTheme.light` — every `ui_kit/` component updates automatically.
Don't hardcode a color in a screen "just this once"; if the design
truly needs a new semantic color the theme doesn't have, follow the
`AppColors.warning` pattern (a small, explicitly-documented exception)
rather than a raw `Color(0xFF...)` inline.

## Navigation & Routing

`go_router`, configured in `lib/app/router/app_router.dart`.

**Routes:**

| Path | Screen | Notes |
|---|---|---|
| `/splash` | `SplashPage` | Initial route; waits on session + locale init |
| `/login` | `LoginPage` | Accepts `?message=` query param (shown as a success snackbar) |
| `/registration` | `RegistrationPage` | |
| `/incidents/create` | `CreateIncidentPage` | Pushed, not a tab |
| `/incidents/:id` | `IncidentDetailsPage` | Must stay registered *after* `/incidents/create` — `go_router` matches in order and `:id` would otherwise swallow `create` |
| `/incidents/:id/edit` | `EditIncidentPage` | Takes the `Incident` via `state.extra` |
| `/ui-playground` | `UiPlaygroundPage` | Only registered when `AppEnvironment.current.enableUiPlayground` |
| `/qr-scanner` | `QrScannerPage` | Pushed by `AppQrScanner.scan(context)`; takes an optional `QrScannerConfig` via `state.extra` and pops a `String?` |
| `/face-capture` | `FaceCapturePage` | Pushed by `AppFaceCapture.capture(context)`; takes an optional `FaceCaptureConfig` via `state.extra` and pops a `FaceCaptureResult?` |
| `/image-viewer` | `ImageViewerPage` | Pushed by `AppImageViewer.show` / `.showGallery`; takes `AppImageViewerArgs` via `state.extra` and returns nothing |
| `/signature-pad` | `SignaturePadPage` | Pushed by `AppSignaturePad.show(context)`; takes an optional `SignaturePadConfig` via `state.extra` and pops a `SignatureResult?` |
| `/home`, `/incidents`, `/profile` | `HomePage`, `IncidentPage`, `ProfilePage` | The three `StatefulShellBranch`es inside `MainShell`'s bottom nav |

**Auth redirect logic** lives in the router's top-level `redirect:`
callback, driven by `authSessionNotifierProvider`
(`AuthSessionStatus.checking/authenticated/unauthenticated`) — not
scattered per-screen `if (!loggedIn)` checks.

**Adding a route:** add a `GoRoute` inside `app_router.dart`'s
`routes:` list (top-level for a full-screen push, or inside one of the
`StatefulShellBranch`es for a new bottom-nav tab). Keep path-parameter
routes (`:id`) registered after any static sibling route they could
otherwise shadow.

## State Management

Riverpod `Notifier`/`NotifierProvider` throughout — no
`StateNotifier`, no `ChangeNotifier`, no `provider` package.

Convention, per screen/flow:

```
feature_x_state.dart      // immutable state class, `copyWith`, optional `clearX` flags for nullable fields
feature_x_notifier.dart   // extends Notifier<FeatureXState>, build() wires UseCases via ref.read
```

- `build()` reads dependencies (`ref.read(someUseCaseProvider)`) and
  returns the initial state — it does not perform async work itself.
- Screens trigger the first load from `initState()` via
  `Future.microtask(() => ref.read(...notifier).loadX())`, not inside
  `build()`.
- Side effects that need `BuildContext` (navigation, snackbars) are
  handled via `ref.listen` in the widget's `build()` method, not
  inside the Notifier.
- `autoDispose` is used where state must not leak between screens
  (`editIncidentNotifierProvider`, `incidentDetailsNotifierProvider`).

See `IncidentListNotifier` (`features/incident/presentation/incident_list_notifier.dart`)
as the reference example — pagination, refresh, and error handling all
follow this shape.

## Networking & API Layer

- **`ApiClient`** (`core/network/api_client.dart`) — thin wrapper over
  a single shared `Dio` instance (`get`/`post`/`put`/`delete`).
- **`dioProvider`** (`core/network/network_providers.dart`) builds that
  `Dio` instance: base URL from `AppEnvironment.current.apiBaseUrl`
  (see [Environments & Flavors](#environments--flavors)), a
  `RedactedLogInterceptor` sized to the environment's log level, and
  `AuthInterceptor`.
- **`AuthInterceptor`** (`core/network/auth_interceptor.dart`) attaches
  the `Authorization: Bearer <token>` header, and on a `401` performs
  a queued token refresh + retry of the original request (a separate
  internal `Dio` instance is used for the refresh call itself, to
  avoid a refresh-triggers-refresh loop).
- **Per-feature DataSources** (e.g. `incident_remote_data_source.dart`)
  are the only place that calls `ApiClient` directly and parses raw
  JSON into DTOs (`data/models/`, `data/responses/`).

**Adding an endpoint:** add the path to `AppConstants`
(`core/constants/app_constants.dart`), a method on the relevant
`*RemoteDataSource`, a Repository method (interface in `domain/`,
implementation in `data/`), a UseCase if it represents a distinct
app-level operation, and wire it into a Notifier. Confirm the actual
request/response contract before writing the DataSource method — don't
invent field names or a shape the backend doesn't return.

## Authentication & Session

- **`AuthSessionNotifier`** (`features/auth/presentation/session/`)
  is the single source of truth for "is the user logged in" —
  `AuthSessionStatus.checking / authenticated / unauthenticated`. The
  router's redirect logic watches this, not individual screens.
- **`AuthSessionManager`** (`core/auth/`) bridges the network layer
  (which needs to know about session expiry) and the session Notifier.
- The access token lives in `flutter_secure_storage`
  (`SecureStorageService.saveAccessToken`/`getAccessToken`/
  `clearTokens`), never in `SharedPreferences` or plain memory-only
  state.

## Local Storage

**`SecureStorageService`** (`core/storage/secure_storage_service.dart`),
backed by `flutter_secure_storage`, is the one storage abstraction in
the app — used today for the access token and the locale preference
(`saveLocaleCode`/`getLocaleCode`). Add new methods here rather than
creating a second storage service, unless what you're storing
genuinely doesn't belong in secure storage (e.g. large cached data) —
in that case, add a sibling service under `core/storage/`, not inline
`SharedPreferences` calls scattered through features.

## Error Handling

Three pieces work together:

1. **`Failure`** (`core/errors/failure.dart`) — the domain-level error
   type (`NetworkFailure`, `ServerFailure`, `UnauthorizedFailure`,
   `UnknownFailure`, `ValidationFailure` with per-field errors). Its
   `message` is either a stable code from **`ErrorCodes`**
   (`core/errors/error_codes.dart`, e.g. `ErrorCodes.network`) or, for
   `ValidationFailure`, raw text returned directly by the backend.
2. **`ErrorMapper`** (`core/errors/error_mapper.dart`) — turns a
   `DioException`/HTTP status code into the right `Failure` subtype.
3. **`ErrorLocalizer`** (`core/localization/error_localizer.dart`) —
   resolves an `ErrorCodes` value into localized, user-facing text at
   the point of display (`ErrorLocalizer.resolve(context, message)`).
   Unrecognized codes (i.e. real backend-provided text) pass through
   unchanged.

**Why the indirection:** `Failure`/`ErrorMapper` live in `core/errors/`
(data/domain layers) and must not own presentation-language text —
only the widget displaying the error, which has a `BuildContext` for
localization, calls `ErrorLocalizer.resolve`.

**Adding a new failure case:** add a code to `ErrorCodes`, produce it
from `ErrorMapper` (or a Notifier's own validation), add the localized
string to `lib/l10n/app_en.arb` (+ `app_fil.arb`/`app_ceb.arb`), and
add a `case` to `ErrorLocalizer.resolve`.

## Loading, Empty & Error States

Every screen that loads data follows the same three-way branch, using
Core UI Kit components — do not reintroduce a bare
`CircularProgressIndicator()` or a custom `Column` for these:

```dart
if (state.isLoading && state.items.isEmpty) {
  return const AppLoadingIndicator();
}

if (state.errorMessage != null && state.items.isEmpty) {
  return AppErrorState(
    message: ErrorLocalizer.resolve(context, state.errorMessage!),
    retryLabel: loc.retry,
    onRetry: () => notifier.loadInitial(),
  );
}

if (state.items.isEmpty) {
  return AppEmptyState(icon: Icons.inbox_outlined, title: loc.noItemsFound);
}
```

See `incident_page.dart` or `home_page.dart` for the full pattern,
including pull-to-refresh (`RefreshIndicator`) wrapping the success
case.

## Forms & Validation

- **Client-side field validation** (e.g. login email/password
  required) uses `AppTextField`/`AppPasswordField`'s `validator`
  inside a `Form` + `GlobalKey<FormState>` (see `login_page.dart`).
- **Server-side field validation** (e.g. registration field errors)
  comes back as `ValidationFailure.fieldErrors` (a
  `Map<String, List<String>>`) and is shown via each field's
  `errorText` — never re-typed as a client-side rule guessing at the
  backend's actual validation.
- **Notifier-level validation** (e.g. "a photo is required" in
  `CreateIncidentNotifier`) stores an `ErrorCodes` value in
  `fieldErrors`, resolved to text via `ErrorLocalizer` at the display
  site — same reasoning as [Error Handling](#error-handling).

## Localization

`flutter_localizations` + generated `AppLocalizations`
(`lib/l10n/generated/`, driven by `lib/l10n/app_en.arb` /
`app_fil.arb` / `app_ceb.arb` and `l10n.yaml`). Supported locales:
English, Filipino (`fil`), Cebuano (`ceb`) — switchable in-app from
Profile → Language.

**Adding a string:** add the key to `app_en.arb` (with a
`@description` if the meaning isn't obvious from the key), then the
Filipino and Cebuano translations to the other two `.arb` files, then
run `flutter gen-l10n` (or `flutter pub get`, which triggers it) to
regenerate `lib/l10n/generated/`. Never hand-edit files under
`generated/`.

**Known caveat:** Cebuano isn't a locale Flutter's built-in
`MaterialLocalizations`/`CupertinoLocalizations` support. Two fallback
delegates (`lib/app/locale/unsupported_locale_fallback_delegates.dart`)
make built-in widget chrome (e.g. date-picker buttons) fall back to
English when the locale is `ceb`, while this app's own text still
displays real Cebuano.

## Environments & Flavors

Three flavors — `dev`, `alpha`, `prod` — each buildable debug or
release, for six variants: `devDebug`, `devRelease`, `alphaDebug`,
`alphaRelease`, `prodDebug`, `prodRelease`.

| Flavor | Purpose | API | Logging | UI Playground |
|---|---|---|---|---|
| `dev` | Local development | Dev/test API (already live) | Verbose | Debug builds only |
| `alpha` | Internal testing / QA / UAT | Alpha API (**not configured yet — see below**) | Moderate | Always enabled |
| `prod` | Production users | Production API (**not configured yet — see below**) | Minimal (none) | Always disabled |

`dev`/`alpha` builds show a small "DEVELOPMENT"/"ALPHA" corner ribbon
(`AppEnvironmentBadge`, wired in `app.dart`) so they're never mistaken
for `prod`. `prod` never shows this, in debug or release.

### Single source of truth

`lib/core/environment/app_environment.dart` — reads Flutter's built-in
`appFlavor` constant (`package:flutter/services.dart`, automatically
populated from the native `--flavor` value — no `--dart-define` or
separate `main_dev.dart`-style entry points needed) plus `kDebugMode`,
and resolves everything environment-dependent into one
`AppEnvironment.current`:

- `apiBaseUrl`
- `appDisplayName`
- `logLevel` (`verbose` / `moderate` / `minimal`)
- `enableUiPlayground`

`AppEnvironment.initialize()` runs once, at the very top of `main()`
(`lib/main.dart`), before anything else reads `AppEnvironment.current`.
**Never** scatter `if (flavor == ...)` checks elsewhere — add a new
field to `AppEnvironment` instead.

If no `--flavor` is passed at all (e.g. plain `flutter run`), the app
defaults to `dev`.

**API URLs — action required.** Only the `dev` URL is real
(`https://androidtest.ziademo.com` — the one API URL that existed
anywhere in this codebase before flavors were added). The `alpha` and
`prod` URLs in `app_environment.dart` are deliberately obvious
placeholders (`https://alpha-api.TODO-CONFIGURE.example.com`,
`https://api.TODO-CONFIGURE.example.com`), not invented real
endpoints. Replace both in `AppEnvironment._configFor` once those
environments' real API base URLs are known.

### Logging

`RedactedLogInterceptor` (`core/network/redacted_log_interceptor.dart`)
replaces Dio's stock `LogInterceptor` and scales with
`AppEnvironment.current.logLevel`:

- **verbose** (`dev`): full request/response logging, headers and body
- **moderate** (`alpha`): method/URL/status only
- **minimal** (`prod`): no HTTP logging interceptor at all

It also **redacts** any field whose key contains `authorization`,
`token`, or `password` (case-insensitive) before printing, in every
environment including `dev` — fixing a real prior issue where the raw
JWT bearer token was printed to the console verbatim.

## Android Builds

Configured in `android/app/build.gradle.kts` via a single
`environment` flavor dimension.

| Flavor | Application ID | App name |
|---|---|---|
| `dev` | `com.example.flutter_incident_reporting.dev` | Incident Reporting Dev |
| `alpha` | `com.example.flutter_incident_reporting.alpha` | Incident Reporting Alpha |
| `prod` | `com.example.flutter_incident_reporting` | Incident Reporting |

Distinct application IDs mean all three can be installed on one
device simultaneously. App name is generated per flavor via Gradle's
`resValue("string", "app_name", ...)`, referenced from
`AndroidManifest.xml` as `android:label="@string/app_name"`.

```bash
flutter run --flavor dev
flutter run --flavor alpha
flutter run --flavor prod

flutter build apk --flavor dev --debug
flutter build apk --flavor dev --release
flutter build apk --flavor alpha --debug
flutter build apk --flavor alpha --release
flutter build apk --flavor prod --debug
flutter build apk --flavor prod --release

flutter build appbundle --flavor prod --release   # use this for Google Play, not the APK
```

> **`--flavor` is not optional on Android.** With product flavors
> declared there is no unflavored variant, so omitting it fails with
> the misleading *"Gradle build failed to produce an .apk file"* — the
> Gradle build actually succeeded, it just wrote `app-dev-debug.apk`,
> `app-alpha-debug.apk` and `app-prod-debug.apk` rather than the
> `app-debug.apk` the tool went looking for. See
> [Troubleshooting](#troubleshooting).

All six APK variants above, plus the `prod` AAB, have been built and
verified successfully.

> The base application ID (`com.example.flutter_incident_reporting`)
> is still the Flutter template placeholder (`build.gradle.kts` has a
> `TODO` marking this). Rename `applicationId` and `namespace` to your
> real organization's ID before shipping — the flavor suffixes carry
> over automatically.

**Signing:** release builds currently sign with the **debug** keystore
(unchanged from the project's pre-flavor behavior), so
`flutter build apk --release --flavor <x>` keeps working out of the box
locally. (Without `--flavor` it fails for an unrelated reason — see the
note above.)
To use real signing:

1. `keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
2. Create `android/key.properties` (already git-ignored — **never
   commit this file or the keystore**):
   ```properties
   storePassword=<store password>
   keyPassword=<key password>
   keyAlias=upload
   storeFile=/absolute/path/to/upload-keystore.jks
   ```
3. `build.gradle.kts` detects the file automatically and switches
   release builds to real signing — no Gradle changes needed.

For CI/CD, write `key.properties` from encrypted secrets at build
time rather than committing it.

## iOS Builds

Three shared Xcode schemes — `dev`, `alpha`, `prod` — under
`ios/Runner.xcodeproj/xcshareddata/xcschemes/`, alongside the original
`Runner` scheme (untouched). Each scheme's Run/Profile/Archive actions
point at a matching build configuration (`Debug-dev`/`Release-dev`/
`Profile-dev`, and equivalently for `alpha`/`prod` — 9 new
configurations total, alongside the original `Debug`/`Release`/
`Profile`).

| Flavor | Bundle identifier | Display name |
|---|---|---|
| `dev` | `com.example.flutterIncidentReporting.dev` | Incident Reporting Dev |
| `alpha` | `com.example.flutterIncidentReporting.alpha` | Incident Reporting Alpha |
| `prod` | `com.example.flutterIncidentReporting` | Incident Reporting |

Driven by `.xcconfig` files under `ios/Flutter/Flavors/`:
`Dev.xcconfig`/`Alpha.xcconfig`/`Prod.xcconfig` define
`FLUTTER_TARGET_BUNDLE_ID_SUFFIX` and `APP_DISPLAY_NAME`; the 9
per-build-type files (e.g. `Debug-dev.xcconfig`) each `#include` the
existing base config plus the relevant flavor file.
`Info.plist`'s `CFBundleDisplayName` reads `$(APP_DISPLAY_NAME)`.

**CocoaPods and SPM, side by side.** The project was Swift Package
Manager only until the [Face Capture Core](#face-capture-core) arrived:
ML Kit's iOS SDK ships as a CocoaPods pod with no SPM support, so
`ios/Podfile` now exists and Flutter runs both resolvers. Two
consequences:

- **`ios/Podfile` maps every build configuration**, including the nine
  flavor ones. Add a line there whenever you add a flavor, or CocoaPods
  cannot tell a flavored Release from a Debug.
- **`IPHONEOS_DEPLOYMENT_TARGET` is 15.5** (raised from 13.0), because
  that is ML Kit's minimum. This drops iOS 13 and 14 devices. If a
  project must support them, it cannot use the Face Capture Core as it
  stands — removing `google_mlkit_face_detection` and lowering the
  target back to 13.0 is the trade-off. The `platform :ios` line in the
  Podfile and the Xcode setting must stay in step.

The Podfile's `post_install` also restricts `permission_handler` to the
permissions this app actually uses (camera, location, photos), so App
Store review doesn't ask about purpose strings for permissions that are
never requested.

**The `RunnerTests` configuration gap.** Adding CocoaPods exposed a
latent problem in the flavor setup: the project and the `Runner` target
each had all 12 build configurations, but `RunnerTests` still had only
the original three (`Debug`/`Release`/`Profile`). Nothing noticed under
SPM, but `pod install` inspects every configuration of every integrated
target and failed outright:

```
[!] There may only be up to 1 unique SWIFT_VERSION per target.
    Found target(s) with multiple Swift versions:
    RunnerTests: Swift
    RunnerTests: Swift 5.0
```

`RunnerTests` now has all 12 configurations, mirroring `Runner`. **When
you add a flavor, add its three configurations to `RunnerTests` too**,
not just to `Runner` — or `pod install` breaks again with that error.

**Two warnings during `pod install` that are expected.** Neither one
breaks the build; both device builds (plain and `--flavor dev`) were
verified after this change.

1. *"plugins do not support Swift Package Manager: google_mlkit_commons,
   google_mlkit_face_detection"* — correct, that is why the Podfile
   exists. Informational.
2. *"CocoaPods did not set the base configuration of your project
   because your project already has a custom config set"*, repeated per
   flavor configuration. Expected: the flavor `.xcconfig` files are
   already the base configurations. The Pods settings still arrive,
   because every flavor config `#include`s `../Debug.xcconfig` or
   `../Release.xcconfig`, and those carry Flutter's
   `#include? "Pods/Target Support Files/Pods-Runner/..."` line. All 12
   generated `Pods-Runner.*.xcconfig` files are byte-identical (every
   per-configuration value is expressed through `$(CONFIGURATION)`), so
   inheriting the base variant is equivalent. If a future pod ever
   generates genuinely different settings per configuration, add an
   explicit `#include?` of the matching `Pods-Runner.<config>.xcconfig`
   to each flavor `.xcconfig`.

```bash
flutter run --flavor dev
flutter run --flavor alpha
flutter run --flavor prod

flutter build ios --flavor dev --debug --simulator
flutter build ios --flavor alpha --debug --simulator
flutter build ios --flavor prod --debug --simulator

flutter build ios --flavor dev --release --no-codesign     # verifies the build without a signing team
flutter build ios --flavor alpha --release --no-codesign
flutter build ios --flavor prod --release --no-codesign
```

On an Apple Silicon Mac the `--simulator` lines will fail — ML Kit has
no `arm64` simulator slice, so develop on a device there (see
[Face Capture Core](#face-capture-core)). On Intel they build normally.

All six variants above have been built and verified (simulator debug
×3, unsigned device release ×3) with correct, distinct bundle
identifiers and display names.

> The base bundle ID (`com.example.flutterIncidentReporting`) is also
> still the Flutter template placeholder — rename it in Xcode (Runner
> target → Signing & Capabilities) before shipping.

**Signing (Apple Developer configuration, not code):**

1. Open `ios/Runner.xcodeproj` → **Runner** target → **Signing &
   Capabilities** → select your Apple Developer **Team** (per
   configuration, if `dev`/`alpha`/`prod` need different provisioning).
2. For `alpha`/`prod` TestFlight/App Store distribution, register the
   corresponding bundle IDs in the Apple Developer portal and create
   matching provisioning profiles if not using fully Automatic
   signing.

None of this requires code changes — it's one-time Apple Developer
account configuration per environment.

## Build Matrix

| Environment | Debug | Release | Profile (iOS) | Purpose |
|---|---|---|---|---|
| `dev` | `devDebug` | `devRelease` | `Profile-dev` | Development |
| `alpha` | `alphaDebug` | `alphaRelease` | `Profile-alpha` | QA / UAT |
| `prod` | `prodDebug` | `prodRelease` | `Profile-prod` | Production |

Android doesn't have a separate "Profile" build type in
`productFlavors` — Flutter's `flutter run --profile --flavor <x>` uses
the flavor's `release` build type with profiling enabled, so there's
no extra Android row to document beyond Debug/Release.

## Debug Tools

| Tool | What it is | Available in |
|---|---|---|
| UI Playground | Component showcase (see above) | `devDebug`, `alphaDebug`, `alphaRelease` — never `prod` |
| Verbose HTTP logging | Full request/response logging via `RedactedLogInterceptor` | `dev` only |
| Environment ribbon | Corner banner showing "DEVELOPMENT"/"ALPHA" | `dev`, `alpha` (debug and release) — never `prod` |

**Developer tooling** (UI Playground, verbose logs) exists purely to
help build/debug the app and must never reach real users — that's why
everything above is gated through `AppEnvironment`, not a screen-level
`if (kDebugMode)` that a flavor could accidentally bypass.
**Internal QA tooling** (the environment ribbon, moderate logging, the
Playground in `alpha`) is intentionally available in `alpha` release
builds too, since QA needs to test release-mode behavior.
**Production functionality** is everything else — it must work
identically regardless of which of the above tools happen to be
compiled in.

## Development Workflows

**Add a new feature** — create
`lib/features/<name>/{data,domain,presentation}/`, following the
`incident/` feature as a template. Start with the domain model +
repository interface, then the data-layer implementation, then
UseCases, then the Notifier + screen.

**Add a new screen to an existing feature** — add
`<name>_page.dart` under the feature's `presentation/`, a matching
`<name>_notifier.dart` + `<name>_state.dart` if it needs its own
state, and register a `GoRoute` in `app_router.dart`
([Navigation & Routing](#navigation--routing)).

**Add a new API endpoint** — see
[Networking & API Layer](#networking--api-layer).

**Add a model** — domain model in `features/<x>/domain/models/`
(plain Dart, no JSON knowledge); if the API's JSON shape differs from
the domain model, add a corresponding DTO in `features/<x>/data/models/`
with `fromJson`/`toDomain()`.

**Add a Repository** — interface in `domain/repositories/`,
implementation in `data/repositories/`, registered as a Riverpod
`Provider` in `domain/providers/` (interface) wired to the
implementation via `data/providers/`.

**Add a UseCase** — a single class with one `execute(...)` method in
`domain/usecases/`, taking the Repository as a constructor dependency,
registered as a `Provider` alongside the others in
`domain/providers/`.

**Add a Riverpod provider/Notifier** — see
[State Management](#state-management).

**Use a Core UI component** — see
[Core UI Kit](#core-ui-kit); import `core/ui_kit/ui_kit.dart`.

**Create a new Core UI component** — decide Core vs. Feature first
([Core vs. Feature responsibility](#core-vs-feature-responsibility)).
For Core: add the file under the right `core/ui_kit/<category>/`
subfolder, export it from `ui_kit.dart`, use only
`Theme.of(context)`/token classes for styling, and add a Playground
section (next workflow).

**Add a UI Playground example** — see
[UI Playground](#ui-playground).

**Add form validation** — see [Forms & Validation](#forms--validation).

**Handle loading/empty/error state** — see
[Loading, Empty & Error States](#loading-empty--error-states).

**Add local storage** — see [Local Storage](#local-storage).

**Modify the theme** — edit `AppTheme.light`
(`lib/app/theme/app_theme.dart`); every `ui_kit/` component picks up
the change automatically since none of them hardcode colors.

**Add a new flavor/environment** — add a case to `AppFlavor` and
`AppEnvironment._configFor` (Dart), a `productFlavors { create(...) }`
block in `android/app/build.gradle.kts` (Android), and a new
xcconfig/scheme pair mirroring the existing `dev`/`alpha`/`prod` ones
(iOS) — see [Environments & Flavors](#environments--flavors),
[Android Builds](#android-builds), [iOS Builds](#ios-builds).

**Build an APK / AAB / iOS app** — see
[Android Builds](#android-builds) / [iOS Builds](#ios-builds).

## Testing

**Current state:** **163 passing tests** live under `test/core/`, one
per Core capability, plus one failing leftover from the Flutter
template:

- `test/core/signature_pad/` — real coverage for the
  [Signature Pad Core](#signature-pad-core): 34 passing tests,
  including one that decodes the exported PNG and asserts its corner
  pixels are fully transparent.
- `test/core/image_viewer/` — real coverage for the
  [Image Viewer Core](#image-viewer-core): 24 passing tests, all pure
  widget tests (no camera, no network — images come from bytes).
- `test/core/face_capture/` — real coverage for the
  [Face Capture Core](#face-capture-core): 87 passing tests, most of
  them pure unit tests over the readiness model, the stability tracker
  and the camera-to-screen projection. See that section for what needs
  a physical device instead.
- `test/core/qr_scanner/` — real coverage for the
  [Core QR Scanner](#core-qr-scanner): 18 passing unit and widget
  tests. They're also the reference for how to test a
  platform-channel-backed capability here: the scanner platform is
  faked by subclassing `MobileScannerPlatform`, and
  `permission_handler` is faked with
  `setMockMethodCallHandler` — no extra dev dependency needed.
- `test/widget_test.dart` — the **unmodified default Flutter
  counter-app template** (its own `pumpWidget(const App())` call is
  commented out), which does not test this app at all. `flutter test`
  fails on this one file; that failure is pre-existing and unrelated
  to any feature work.

**Running tests:**

```bash
flutter test
```

**What to add, and where, as real coverage is built up:**

- **Unit tests** for UseCases/Repositories/`ErrorMapper` — pure Dart,
  no widget dependencies, under `test/` mirroring the `lib/` path
  (e.g. `test/features/incident/domain/usecases/...`).
- **Notifier tests** — construct the Notifier with mocked UseCases via
  `ProviderContainer`/`ProviderScope` overrides; assert on emitted
  `State` values.
- **Widget tests** for Core UI Kit components — these are the easiest
  high-value tests to add first, since they're pure, stateless (mostly)
  widgets with no Riverpod/network dependencies.
- **Widget tests** for core capabilities — see
  `test/core/qr_scanner/qr_scanner_page_test.dart` for the pattern
  (fake the platform interface, drive the real public entry point).
- **Keep platform-dependent logic in pure classes** where you can. The
  face capture readiness model is the worked example: the rules, the
  scoring and the geometry are plain Dart with no camera in sight, so
  they are covered by fast unit tests, and only the thin ML Kit bridge
  needs a device.
- **Integration tests** — none exist yet; would live under
  `integration_test/` if added (standard `flutter_driver`/
  `integration_test` package location, not yet a dependency of this
  project).

## Code Quality

- **Static analysis:** `flutter analyze` — must report the same
  pre-existing baseline (a handful of `info`-level lints, two unused
  imports) and **zero new errors/warnings** before you're done. Fix
  anything you introduce; don't suppress lints with `// ignore:`
  unless there's no reasonable fix.
- **Linting:** `flutter_lints: ^6.0.0` via `analysis_options.yaml`
  (default ruleset, not customized).
- **Formatting:** standard `dart format` — no custom formatter config.
- **`const` usage:** used consistently where the analyzer would flag
  its absence; don't remove it to "simplify" a diff.
- **Reuse before creating:** search `core/ui_kit/` and the relevant
  feature's existing widgets before writing a new one — see
  [Core UI Kit](#core-ui-kit) and
  [Common Architecture Mistakes](#common-architecture-mistakes).
- **Architecture boundaries:** enforced by convention, not tooling —
  there's no lint rule blocking a `core/` file from importing a
  feature; it's on you to keep the dependency direction correct (see
  [Architecture](#architecture)).

## Common Architecture Mistakes

**DO NOT:**

- Put API calls or business logic directly in a widget — that belongs
  in a UseCase/Repository, coordinated by a Notifier.
- Put feature-specific code inside `core/` (an `IncidentCard`,
  anything that imports a domain model, belongs in the feature).
- Duplicate a Core UI Kit component inside a feature to tweak one
  visual detail — extend the Core component's props instead.
- Hardcode a color, spacing value, or radius in a screen when a
  design token already covers it.
- Bypass the Repository layer and call `ApiClient`/`Dio` directly from
  a Notifier or widget.
- Create a new Riverpod provider for state that already belongs on an
  existing Notifier's state class.
- Scatter `if (AppEnvironment.current.flavor == AppFlavor.dev)`-style
  checks through feature code — add a field to `AppEnvironment`
  instead and read that.
- Hardcode an API base URL anywhere outside `AppEnvironment`.
- Commit `android/key.properties`, a keystore, or any provisioning
  profile/certificate.
- Invent a backend field (status, severity, etc.) that the API
  doesn't actually return, just to make a UI element look more
  complete.
- Add a dependency to `pubspec.yaml` without a concrete need — this
  project deliberately has a small, well-justified dependency list.

## Troubleshooting

**"Gradle build failed to produce an .apk file" on Android** — you
almost certainly omitted `--flavor`. The message is misleading: the
Gradle build *succeeded*. Because the project declares product
flavors, `assembleDebug` is a lifecycle task that assembles **every**
debug variant, so `build/app/outputs/flutter-apk/` ends up holding
`app-dev-debug.apk`, `app-alpha-debug.apk` and `app-prod-debug.apk` —
and none named `app-debug.apk`, which is the one file the Flutter tool
looks for.

```bash
flutter build apk --debug --flavor dev
```

**Android always needs `--flavor`.** There is no unflavored variant to
build, so `flutter run` and `flutter build apk` without it will fail
this way every time. (iOS is more forgiving: the original `Runner`
scheme still exists, so an unflavored `flutter run` works there — which
is why this bites on Android first.) If you already ran it without a
flavor, nothing is wasted: the APK you wanted is sitting in that
directory under its flavored name.

**"Your app uses the following plugins that apply Kotlin Gradle Plugin
(KGP): mobile_scanner"** — a warning, not the cause of a failed build,
and not actionable today: `mobile_scanner` 7.4.0 is the current release
and still applies KGP. It becomes an error in a future Flutter version,
so the fix is a `mobile_scanner` upgrade when upstream ships one — not
a change in this repo.

**"Gradle sync failed" / `resValue` errors on Android** — AGP 9
requires `buildFeatures { resValues = true }` (already set in
`android/app/build.gradle.kts`); if you see "Product Flavor ... contains
custom resource values, but the feature is disabled," that block was
removed or the file was reverted.

**Wrong app/API when running `--flavor <x>`** — confirm
`AppEnvironment._resolveFlavor()` actually maps every `appFlavor`
string to the right `AppFlavor` enum value, and that you passed
`--flavor` at all (omitting it silently defaults to `dev`).

**Wrong application ID / can't install dev and prod side by side** —
check `android/app/build.gradle.kts`'s `productFlavors` block for the
expected `applicationIdSuffix`; a mismatch there is the only thing
that would cause two flavors to collide.

**Wrong bundle identifier on iOS** — check that the target Xcode
*scheme* (`dev`/`alpha`/`prod`) is actually selected, not just the
build configuration; each scheme's Run/Profile/Archive actions must
point at the matching `Debug-<flavor>`/`Release-<flavor>`/
`Profile-<flavor>` configuration.

**`xcodebuild`/scheme not found** — schemes must be **shared** (under
`xcshareddata/xcschemes/`, not user-specific `xcuserdata/`) for
`flutter run --flavor <x>` to find them; all three (`dev`/`alpha`/
`prod`) already are.

**iOS build fails after editing `project.pbxproj` by hand** — don't.
Use the `xcodeproj` Ruby gem (`gem install xcodeproj`) to script
changes, verify with `xcodebuild -list -project ios/Runner.xcodeproj`
afterward, and keep a backup — hand-editing this file risks silent
corruption with no clear error until a much later build step.

**Camera preview is black, or a capability won't start** — work
through the states the capability already models before suspecting the
code. Permission is resolved *before* the camera starts in both camera
capabilities, so a black preview is not a permission problem: check
[Core QR Scanner](#core-qr-scanner) and
[Face Capture Core](#face-capture-core) for the four permission states
and the "Open Settings" path. On iOS a first build must run
`pod install` (Flutter does it) and the deployment target must be 15.5
for ML Kit — see [iOS Builds](#ios-builds).

**Face capture won't accept left/right, or accepts the wrong side** —
the two things to check are in
[Face Capture Core](#face-capture-core): the debug overlay's `yaw` row
(a dash means ML Kit reported no head pose at all, which is a detector
configuration problem, not a user problem), and the sign convention,
which depends on front-camera mirroring and therefore differs between
Android and iOS. Verify head pose on **both** platforms after touching
that code.

**UI Playground not appearing** — check
`AppEnvironment.current.enableUiPlayground` for the flavor/build-mode
combination you're running (it's intentionally `false` for `prod` and
for `devRelease`) — see [Environments & Flavors](#environments--flavors).

**Routing seems to skip a screen / redirect loop** — check
`app_router.dart`'s top-level `redirect:` against
`authSessionNotifierProvider`'s current `AuthSessionStatus` — most
navigation bugs here trace back to a session-status transition, not
the route table itself.

**State doesn't update after an action** — confirm the Notifier method
actually reassigns `state = state.copyWith(...)` (Riverpod's
`Notifier` only rebuilds listeners on reassignment, not in-place
mutation of a field).

**Login/refresh loop or unexpected logout** — check
`AuthInterceptor.onError` (`core/network/auth_interceptor.dart`) — the
`hasRetriedRequestKey`/`isRequestKey` flags in `AppConstants` prevent
infinite retry loops; a bug here usually means one of those flags
isn't being set on the retried request.

**A widget looks unthemed / wrong color** — confirm it's actually
using a `core/ui_kit/` component or reading
`Theme.of(context).colorScheme`, not a leftover hardcoded `Colors.*`
value.

**Layout overflow (red/yellow stripes)** — check whether the
overflowing widget is inside a `Row`/`Column` with `Expanded` siblings
and no `Flexible`/ellipsis handling on text — this exact bug happened
in `AppButton` (long label + icon in a constrained `Row`) and was
fixed by wrapping the label in `Flexible` with `overflow: TextOverflow.ellipsis`.

**Release build fails only in `--release`, not `--debug`** — usually
tree-shaking or a signing config issue, not a logic bug; check
`flutter build apk --flavor <x> --release` output directly rather than
assuming it's the same failure as debug.

## Security

- **Never commit secrets** — no API keys, keystores, `key.properties`,
  provisioning profiles, or certificates. `android/key.properties` and
  keystore files are already git-ignored; keep it that way.
- **Never log passwords or tokens** — `RedactedLogInterceptor`
  redacts `authorization`/`token`/`password`-keyed fields
  automatically, in every environment; don't add a second, unredacted
  logging path.
- **Avoid logging PII** — be deliberate about what a Notifier/DataSource
  prints even outside the HTTP layer; don't add `debugPrint(user)`-style
  dumps of a whole model.
- **Don't hardcode production credentials** anywhere in Dart source —
  `AppEnvironment` is compile-time configuration, not a secrets store;
  real secrets belong in `key.properties`/CI secrets/Apple Developer
  account config, never in a `.dart` file.
- **Keep signing credentials secure** — outside the repo, in a
  password manager or CI secrets, never in plain text in a commit.
- **Face photos are sensitive personal data.** The
  [Face Capture Core](#face-capture-core) is face *detection*, never
  recognition: it runs on-device, uploads nothing, identifies nobody,
  and hands back a temp file. Whatever a feature then does with that
  photo — upload, store, display — deserves password-level care and a
  look at local privacy law. Never log the image path, the bytes, or
  detection metadata.
- **Signatures are sensitive too.** The
  [Signature Pad Core](#signature-pad-core) hands back PNG bytes and
  forgets them — it never uploads, persists or logs a signature, and
  `SignatureResult.toString()` is deliberately byte-free so an
  accidental log line cannot leak one. A feature that stores or
  transmits a signature owns that decision, and the same care applies
  as to a face photo.
- **Camera captures are temporary files.** A `FaceCaptureResult`
  points at a file in the app's temp directory. Core never moves,
  copies or deletes it; the calling feature should copy it somewhere it
  controls or discard it once done, rather than leaving user photos in
  temp storage indefinitely.
- **Treat scanned codes as untrusted input** — a QR/barcode value is
  attacker-controllable. `AppQrScanner` deliberately returns the raw
  string and nothing else; never auto-open a scanned URL,
  auto-authenticate a scanned token, or send a scanned value to an
  endpoint before validating it. See
  [Core QR Scanner](#core-qr-scanner).
- **Don't expose developer tooling in production** — anything gated
  by `AppEnvironment.current.enableUiPlayground` (or a future flag
  like it) must default to `false` for `prod`; when adding a new
  debug-only feature, gate it the same way rather than a bare
  `kDebugMode` check (which doesn't account for flavor).

## Golden Rules

1. Follow the existing architecture — Presentation → Notifier →
   UseCase → Repository → DataSource.
2. Reuse before creating — check `core/ui_kit/` and the feature's
   existing widgets first.
3. Keep `core/` generic; keep feature-specific code inside
   `features/<x>/`.
4. Keep business logic out of widgets.
5. Use the Core UI Kit and its design tokens — no hardcoded colors,
   spacing, or radii in screens.
6. Keep environment/flavor configuration centralized in
   `AppEnvironment` — never scatter flavor checks.
7. Never commit secrets.
8. Add a UI Playground section for every new Core UI Kit component.
9. Don't invent backend fields or API URLs — flag what's missing
   instead of guessing.
10. Update this document when the architecture changes.

## Keeping This Document Updated

This document must evolve with the boilerplate. Update it whenever
you:

- Add, remove, or change a Core UI Kit component (including its
  Playground section)
- Add, remove, or change a **Core capability** (QR scanner, face
  capture, image viewer, signature pad, or a new one) — including its
  public API, its configuration, and its documented contract
- Add a new feature or change the feature-folder pattern
- Change the architecture, navigation, or state-management approach
- Change the API/networking layer or error-handling flow
- Add, remove, or reconfigure a build flavor/environment
- Change Android Gradle configuration or iOS schemes/configurations
- **Add, remove, or upgrade a dependency** — especially one that
  changes a platform requirement or carries a build warning
- **Change a platform requirement** — permissions, usage descriptions,
  `minSdk`, iOS deployment target, CocoaPods/SPM
- **Change the package/application identity or the renaming steps**
- **Change developer setup** — required tooling, commands, or the
  first-run sequence
- Change authentication or session handling
- Change local storage
- Change the testing strategy, or the test counts quoted in
  [Testing](#testing) and the capability sections

If you're not sure whether a change is "big enough" to document: if a
new developer would be confused finding it in the code without this
document mentioning it, document it.
