# Builds & Flavors

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
| `dev` | `mecare.nurse.app.dev` | MeCare Nurse App Dev |
| `alpha` | `mecare.nurse.app.alpha` | MeCare Nurse App Alpha |
| `prod` | `mecare.nurse.app` | MeCare Nurse App |

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
```

These produce a **universal** APK — arm64, armv7 and x86_64 bundled
together — which is 2-3x larger than any one device needs. For a build
to hand to a real phone (manual testing, ad-hoc distribution), use the
script below instead.

### Phone-only versioned APK

`scripts/build_apk.sh [flavor] [build_type]` (defaults: `dev release`)
builds a single-ABI (`arm64-v8a` only — the architecture virtually
every phone in active use runs) release or debug APK and copies it to
`dist/apk/` as:

```
<AppName>_v<version>_<flavor><BuildType>.apk
```

e.g. `MeCareNurseApp_v0.0.2_devRelease.apk`. The version comes from
`pubspec.yaml`'s `version:` line (build number stripped); the app name
is fixed in the script.

```bash
scripts/build_apk.sh              # dev, release
scripts/build_apk.sh alpha debug
scripts/build_apk.sh prod release
```

Or from a Claude Code session: `/build-apk [dev|alpha|prod] [debug|release]`.

`dist/` is git-ignored — it holds build output, not source. If the
naming convention or the target ABI ever needs to change, edit
`scripts/build_apk.sh` itself rather than building ad hoc, so every
build — from the script, the command, or CI — stays consistent.

### AAB (App Bundle) — for Google Play

```bash
flutter build appbundle --flavor dev --release
flutter build appbundle --flavor alpha --release
flutter build appbundle --flavor prod --release
```

Unlike the APK, don't restrict `--target-platform` here: Google Play
splits an AAB per installing device's ABI itself, so a universal AAB
already serves each device only what it needs. Output lands at
`build/app/outputs/bundle/<flavor>Release/app-<flavor>-release.aab`.

**Signing:** if `android/key.properties` exists (see below), release
builds — both APK and AAB — sign with that real keystore automatically.
Without it, they fall back to the debug keystore so
`flutter build apk --release` still works out of the box locally. To
set up real signing:

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
| `dev` | `mecare.nurse.app.dev` | MeCare Nurse App Dev |
| `alpha` | `mecare.nurse.app.alpha` | MeCare Nurse App Alpha |
| `prod` | `mecare.nurse.app` | MeCare Nurse App |

Driven by `.xcconfig` files under `ios/Flutter/Flavors/`:
`Dev.xcconfig`/`Alpha.xcconfig`/`Prod.xcconfig` define
`FLUTTER_TARGET_BUNDLE_ID_SUFFIX` and `APP_DISPLAY_NAME`; the 9
per-build-type files (e.g. `Debug-dev.xcconfig`) each `#include` the
existing base config plus the relevant flavor file.
`Info.plist`'s `CFBundleDisplayName` reads `$(APP_DISPLAY_NAME)`.

The project has no `Podfile` — it uses Swift Package Manager — so
there's no CocoaPods target list to keep in sync when adding flavors.

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

All six variants above have been built and verified (simulator debug
×3, unsigned device release ×3) with correct, distinct bundle
identifiers and display names.

### Distributable build (`.ipa`) — for TestFlight/App Store

The commands above only verify the build compiles; they don't produce
something installable off a device. For an actual signed `.ipa`:

```bash
flutter build ipa --flavor dev --release
flutter build ipa --flavor alpha --release
flutter build ipa --flavor prod --release
```

This requires a valid Apple Developer signing team already selected
for the `Runner` target (see below) — without one, use `--no-codesign`
instead, which produces an unsigned `.app` for verification only.
Output `.ipa` and the Xcode archive land under `build/ios/ipa/` and
`build/ios/archive/`. Upload the `.ipa` via Xcode Organizer or
`xcrun altool`/Transporter.

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

