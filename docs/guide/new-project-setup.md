# New Project Setup

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
   As of this writing, that's `lib/features/incident/data/datasources/incident_remote_data_source.dart`.
   (This boilerplate has no `test/widget_test.dart` — the generated
   counter test was deleted when the AI setup was rebuilt. See
   `docs/PROJECT_MAP.md` § Test Coverage for what actually exists.)
   Change it to
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
[Environments & Flavors](builds-and-flavors.md#environments--flavors) and
[Build Matrix](builds-and-flavors.md#build-matrix) for the full `devDebug`/.../`prodRelease`
combination table — that structure doesn't change for a new project,
only the identifiers underneath it.

### Step 5 — Configure environment/API settings

Separate task from renaming the app identity — see
[Environments & Flavors](builds-and-flavors.md#environments--flavors) for the full
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
  and is trivially extractable. See [Security](architecture.md#security).

### Step 6 — Replace branding

| What | Android | iOS | Notes |
|---|---|---|---|
| App display name | `resValue("string", "app_name", "...")` per flavor in `android/app/build.gradle.kts` | `APP_DISPLAY_NAME` per flavor in `ios/Flutter/Flavors/*.xcconfig` | Already flavor-aware in this boilerplate — just change the string values |
| App icon | `android/app/src/main/res/mipmap-*/ic_launcher.png` (currently the default Flutter icon, unmodified) | `ios/Runner/Assets.xcassets/AppIcon.appiconset/` (also still the default) | No `flutter_launcher_icons`-style generator is set up — icons are replaced manually today, or you can add that package yourself |
| Splash/launch screen | `android/app/src/main/res/drawable{,-v21}/launch_background.xml` + `styles.xml` (`LaunchTheme`) | `ios/Runner/Base.lproj/LaunchScreen.storyboard` + `Assets.xcassets/LaunchImage.imageset/` | Native launch screens, shown before the Flutter engine draws its first frame — separate from this app's own `SplashPage` Dart widget (`lib/features/auth/presentation/splash/splash_page.dart`), which only runs *after* that |
| Theme colors | — | — | `lib/app/theme/app_theme.dart` → `AppTheme.light`'s `ColorScheme.fromSeed(seedColor: ...)`. See [Theme & Design Tokens](ui-kit.md#theme--design-tokens) |
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
unused imports — see [Code Quality](workflows-and-testing.md#code-quality); your rename
shouldn't add anything beyond that). This boilerplate has no
`test/widget_test.dart` — `flutter test` runs the real suite. See
`docs/PROJECT_MAP.md` § Test Coverage for current coverage (also
[Testing](workflows-and-testing.md#testing)).

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
([Build Matrix](builds-and-flavors.md#build-matrix)), not just the variant that's failing.


## Carrying the AI setup forward

This boilerplate is upstream. To start a new project from it, copy the
portable tier across unchanged:

    .claude/                  agents, commands, skills
    CLAUDE.md                 the constitution
    Instructions.md           the router into the chapters
    docs/guide/               these chapters
    test/ai_setup_test.dart   the harness that checks all of the above

Do **not** copy `docs/PROJECT_MAP.md`, `PROJECT.md`, or
`docs/workplans/`. They describe the project they came from, and a
stale map is worse than none because it is trusted. Leave
`.claude/settings.local.json` behind too — it holds absolute paths from
the source machine.

Then:

1. Work through the setup steps above — rename, bundle IDs, flavors,
   branding.
2. Write `PROJECT.md` for the new app.
3. Run `/sync-map` to generate `docs/PROJECT_MAP.md` from the new
   source tree.
4. Run `flutter test` — `test/ai_setup_test.dart` verifies the copied
   setup is structurally intact and still portable.

Improvements made to the portable tier in a downstream project are
copied back here by hand. There is no automatic sync, deliberately:
the merge conflicts would land in exactly the files that must stay
free of project-specific content.
