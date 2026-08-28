# FLOW Flutter Foundation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Prepare the FLOW Flutter project's architecture, dependencies, design system, data schema, and navigation skeleton so screen implementation can begin immediately afterward — no feature screens are built in this plan.

**Architecture:** Feature-first Clean Architecture with Riverpod codegen (`@riverpod`), a Drift/SQLite local database, go_router with a redirect gate, and a token-driven design system (`ThemeExtension`) backing a 17-component library (`CMP-01/02/03/04/05/06/07/08/10/11/12/13/14/15` plus `CMP-42/44`).

**Tech Stack:** Flutter (dev/prod flavors), `flutter_riverpod` + `riverpod_annotation`/`riverpod_generator`, `go_router`, `drift` + `sqlite3_flutter_libs`, `shared_preferences`, `flutter_local_notifications` + `timezone`, `freezed`/`json_serializable`, `share_plus`, `path_provider`, `flutter_svg`, `build_runner`.

**Spec:** `docs/superpowers/specs/2026-08-28-flow-flutter-foundation-design.md`

## Global Constraints

- Package identifier stays `oiracam.flow.bloop`; app name stays `FLOW`. No change needed, verify unchanged.
- Zero network dependency of any kind — no HTTP client, no `google_fonts` runtime fetching, no `INTERNET` Android permission introduced.
- No raw color/spacing/duration literals outside `lib/core/design/` — every value goes through a token.
- No direct `DateTime.now()` calls outside `lib/core/time/clock.dart` — everything else uses the injected `Clock`.
- Riverpod providers use codegen (`@riverpod`/`@Riverpod(keepAlive: true)`), not manual `Provider`/`NotifierProvider` declarations.
- Every new dependency is added via `flutter pub add` (or `flutter pub add --dev` for dev dependencies), never hand-edited version pins.
- After adding any `@riverpod`, `@freezed`, `@JsonSerializable`, or Drift-annotated class, run `dart run build_runner build --delete-conflicting-outputs` before the file is expected to compile.
- Dart/Flutter formatting: run `dart format .` before every commit that touches `.dart` files.
- Component states must never be communicated by color alone — every "selected"/"checked"/"error" state pairs a color change with an icon, border-weight, or shape change, per the spec.
- Onboarding-context icons come from the bundled SVGs in `assets/icons/onboarding/` via `flutter_svg` — never a Material icon substitute for those specific glyphs.
- Real, openly-licensed (SIL OFL) Inter and Press Start 2P font files are fetched and bundled locally — never `google_fonts`.

---

## Task 1: Remove unused dependencies and relocate auth/network to `reference/`

**Files:**
- Modify: `pubspec.yaml`
- Delete: `lib/features/auth/`, `lib/core/network/`, `lib/core/storage/`, `lib/core/auth/`, `lib/core/qr_scanner/`, `lib/core/face_capture/`, `lib/core/signature_pad/`, `lib/core/models/`
- Delete: `lib/l10n/app_fil.arb`, `lib/l10n/app_ceb.arb`
- Create: `reference/auth-and-network/README.md`
- Create: `reference/auth-and-network/` (copies of the deleted auth/network/storage code, before deletion from `lib/`)
- Modify: `lib/app/router/app_router.dart` (remove auth-feature imports/routes — see current file for `LoginPage`/`RegistrationPage`/`ProfilePage`/`SplashPage`/`auth_session_notifier` imports)
- Modify: `lib/app/main_shell.dart` (no auth references expected, verify)
- Modify: `lib/main.dart` (remove any auth/session bootstrap calls)

**Interfaces:**
- Consumes: nothing (first task)
- Produces: a `lib/` tree with no auth/network/secure-storage/camera/QR/signature code or dependencies; `reference/auth-and-network/` holding the preserved pattern outside the Flutter build

- [ ] **Step 1: Copy the auth/network code to `reference/` before touching anything in `lib/`**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
mkdir -p reference/auth-and-network/lib
cp -R lib/features/auth reference/auth-and-network/lib/auth_feature
cp -R lib/core/network reference/auth-and-network/lib/network
cp -R lib/core/storage reference/auth-and-network/lib/storage
cp -R lib/core/auth reference/auth-and-network/lib/auth_session
```

- [ ] **Step 2: Write the reference README explaining what this is and how to restore it**

Create `reference/auth-and-network/README.md`:

```markdown
# Auth & Network — Reference Pattern (not part of the FLOW build)

FLOW ships with no accounts, no backend, and no network calls (see
`docs/superpowers/specs/2026-08-28-flow-flutter-foundation-design.md`
Section 2). This folder preserves the boilerplate's original
REST-backed authentication pattern — login/registration/session,
the `dio`-based API client, and `flutter_secure_storage` token
handling — purely as a copyable reference, in case a future,
currently undocumented FLOW phase adds accounts.

This code is **not part of the Flutter build**: it is outside `lib/`,
not analyzed, not compiled, and its dependencies (`dio`,
`flutter_secure_storage`) are not in `pubspec.yaml`. To restore it:

1. Add `dio` and `flutter_secure_storage` back to `pubspec.yaml`.
2. Move `lib/auth_feature/` back to `lib/features/auth/`.
3. Move `lib/network/` back to `lib/core/network/`.
4. Move `lib/storage/` back to `lib/core/storage/`.
5. Move `lib/auth_session/` back to `lib/core/auth/`.
6. Re-wire the router and DI graph to reference the restored feature.
```

- [ ] **Step 3: Delete the auth/network/storage/device-capability code and old REST-response models from `lib/`**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
rm -rf lib/features/auth lib/core/network lib/core/storage lib/core/auth
rm -rf lib/core/qr_scanner lib/core/face_capture lib/core/signature_pad
rm -rf lib/core/models
rm -f lib/l10n/app_fil.arb lib/l10n/app_ceb.arb
```

- [ ] **Step 4: Remove the now-dead dependencies from `pubspec.yaml`**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter pub remove dio flutter_secure_storage geolocator camera mobile_scanner google_mlkit_face_detection image_picker
```

- [ ] **Step 5: Fix the router — remove every import and route that referenced the deleted auth feature**

Read `lib/app/router/app_router.dart` first to see its current imports and
route list (it currently imports `LoginPage`, `RegistrationPage`,
`ProfilePage`, `SplashPage`, `auth_session_notifier.dart`,
`auth_session_state.dart` and has `/login`, `/registration`, `/splash`
routes plus an `authState`-based `redirect`). Replace the whole file with
this minimal placeholder — Task 30 rebuilds it properly with the real
FLOW route table, this step only needs the project to compile again:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          return const Scaffold(body: Center(child: Text('FLOW')));
        },
      ),
    ],
  );
}
```

- [ ] **Step 6: Fix `lib/app/main_shell.dart` and `lib/main.dart` if they reference deleted code**

Read both files. `main_shell.dart` should have no auth references (it
only used `AppEnvironment` and localization) — leave it as-is for now,
Task 32 rebuilds it. In `lib/main.dart`, remove any import or call
referencing the deleted `core/auth` session manager; it should end up
looking like:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/environment/app_environment.dart';

void main() {
  AppEnvironment.initialize();

  runApp(const ProviderScope(child: App()));
}
```

- [ ] **Step 7: Fix `lib/app/app.dart` if it references the router provider by its old name or the deleted auth state**

Read `lib/app/app.dart`. It should only need `appRouterProvider` (now
codegen-generated as `appRouterProvider` by `riverpod_generator` from the
`@riverpod GoRouter appRouter(...)` function above) and `FlowTheme` (not
built yet — leave any theme reference as `ThemeData()` placeholder for
now, Task 10 replaces it):

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'router/app_router.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      routerConfig: router,
      theme: ThemeData(useMaterial3: true),
      darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark),
    );
  }
}
```

- [ ] **Step 8: Run codegen so `app_router.g.dart` exists**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
dart run build_runner build --delete-conflicting-outputs
```

Expected: generates `lib/app/router/app_router.g.dart` with no errors.
(`riverpod_generator` isn't in `pubspec.yaml` yet — Task 2 adds it. If
this fails with "riverpod_generator not found," skip running codegen
until after Task 2 and come back to verify this step then.)

- [ ] **Step 9: Run analyze to confirm the project compiles with the removals**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter analyze
```

Expected: no errors referencing deleted files (`dio`, `flutter_secure_storage`,
`geolocator`, `camera`, `mobile_scanner`, `google_mlkit_face_detection`,
`image_picker`, or the deleted `lib/features/auth`/`lib/core/network`/
`lib/core/storage`/`lib/core/auth`/`lib/core/qr_scanner`/
`lib/core/face_capture`/`lib/core/signature_pad`/`lib/core/models` paths).
Warnings about missing `riverpod_generator` package are expected and will
be resolved by Task 2 — do not fix those here.

- [ ] **Step 10: Commit**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
git add -A
git commit -m "Remove auth/network/device-capability code, relocate auth pattern to reference/"
```

---

## Task 2: Add the new dependency set

**Files:**
- Modify: `pubspec.yaml`

**Interfaces:**
- Consumes: nothing new
- Produces: every package Tasks 3+ need (`riverpod_annotation`, `riverpod_generator`, `drift`, `sqlite3_flutter_libs`, `drift_dev`, `shared_preferences`, `flutter_local_notifications`, `timezone`, `share_plus`, `path_provider`, `freezed_annotation`, `freezed`, `json_annotation`, `json_serializable`, `build_runner`, `flutter_svg`)

- [ ] **Step 1: Add runtime dependencies**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter pub add riverpod_annotation drift sqlite3_flutter_libs shared_preferences \
  flutter_local_notifications timezone share_plus path_provider \
  freezed_annotation json_annotation flutter_svg
```

- [ ] **Step 2: Add dev dependencies**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter pub add --dev riverpod_generator drift_dev build_runner freezed json_serializable
```

- [ ] **Step 3: Verify `flutter pub get` resolves cleanly**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter pub get
```

Expected: "Got dependencies!" with no version-solving errors. If drift/
riverpod_generator versions conflict, let `flutter pub add` pick the
resolvable versions rather than hand-pinning.

- [ ] **Step 4: Retry the Task 1 codegen step now that `riverpod_generator` exists**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
dart run build_runner build --delete-conflicting-outputs
flutter analyze
```

Expected: `lib/app/router/app_router.g.dart` generates successfully;
`flutter analyze` is clean.

- [ ] **Step 5: Commit**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
git add -A
git commit -m "Add FLOW foundation dependencies (riverpod codegen, drift, notifications, etc.)"
```

---

## Task 3: Fetch and bundle Inter and Press Start 2P fonts

**Files:**
- Create: `assets/fonts/Inter-Regular.ttf`, `assets/fonts/Inter-Medium.ttf`, `assets/fonts/Inter-SemiBold.ttf`, `assets/fonts/Inter-Bold.ttf`
- Create: `assets/fonts/PressStart2P-Regular.ttf`
- Modify: `pubspec.yaml` (`flutter.fonts:` section)

**Interfaces:**
- Consumes: nothing
- Produces: font family names `"Inter"` and `"Press Start 2P"` usable by `TextStyle(fontFamily: ...)` in Task 9's typography tokens

- [ ] **Step 1: Download the real, openly-licensed (SIL OFL) font files**

Inter ships official static `.ttf` builds in its GitHub releases; Press
Start 2P is on Google Fonts' GitHub repo. Fetch the real files — do not
fabricate placeholder font binaries:

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
mkdir -p assets/fonts
curl -fL -o /tmp/inter.zip "https://github.com/rsms/inter/releases/download/v4.1/Inter-4.1.zip"
unzip -o /tmp/inter.zip -d /tmp/inter-extracted
find /tmp/inter-extracted -iname "*.ttf" | grep -i "static" | grep -iE "Inter-(Regular|Medium|SemiBold|Bold)\.ttf$"
```

Copy the four matched static weights into `assets/fonts/`:

```bash
cp "$(find /tmp/inter-extracted -iname 'Inter-Regular.ttf' -path '*static*' | head -1)" assets/fonts/Inter-Regular.ttf
cp "$(find /tmp/inter-extracted -iname 'Inter-Medium.ttf' -path '*static*' | head -1)" assets/fonts/Inter-Medium.ttf
cp "$(find /tmp/inter-extracted -iname 'Inter-SemiBold.ttf' -path '*static*' | head -1)" assets/fonts/Inter-SemiBold.ttf
cp "$(find /tmp/inter-extracted -iname 'Inter-Bold.ttf' -path '*static*' | head -1)" assets/fonts/Inter-Bold.ttf

curl -fL -o assets/fonts/PressStart2P-Regular.ttf \
  "https://raw.githubusercontent.com/google/fonts/main/ofl/pressstart2p/PressStart2P-Regular.ttf"
```

If either download fails (network restrictions in the execution
environment), stop and tell the user directly rather than fabricating a
substitute font file — this is exactly the "asset that doesn't exist yet"
case the spec says not to silently fake. Report which file is missing and
where to place it once obtained.

- [ ] **Step 2: Verify the files are real font binaries, not HTML error pages**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
file assets/fonts/*.ttf
```

Expected: every file reports as `TrueType Font data` (or similar), not
`HTML document` or `ASCII text`. If any file is wrong, the download
failed silently — re-fetch it before proceeding.

- [ ] **Step 3: Declare the fonts in `pubspec.yaml`**

Add under the existing `flutter:` section, after `generate: true`:

```yaml
  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
          weight: 400
        - asset: assets/fonts/Inter-Medium.ttf
          weight: 500
        - asset: assets/fonts/Inter-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700
    - family: Press Start 2P
      fonts:
        - asset: assets/fonts/PressStart2P-Regular.ttf
```

- [ ] **Step 4: Verify pub get picks up the new asset declarations**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter pub get
flutter analyze
```

Expected: no errors. `flutter analyze` doesn't validate font assets
directly, but a malformed `pubspec.yaml` fonts block would fail `pub get`.

- [ ] **Step 5: Commit**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
git add assets/fonts pubspec.yaml pubspec.lock
git commit -m "Bundle Inter and Press Start 2P fonts locally (no network font fetching)"
```

---

## Task 4: `Clock` abstraction with a dev-flavor debug override

**Files:**
- Create: `lib/core/time/clock.dart`
- Create: `lib/core/time/clock_provider.dart`
- Test: `test/core/time/clock_test.dart`

**Interfaces:**
- Produces: `abstract class Clock { DateTime now(); }`, `class SystemClock implements Clock`, `class FixedClock implements Clock` (mutable via `set(DateTime)`), `clockProvider` (`Provider<Clock>`, codegen name from `@Riverpod(keepAlive: true) Clock clock(Ref ref)`), `clockOverrideProvider` (codegen `Notifier<DateTime?>` from `@riverpod class ClockOverride`)
- Consumes: `AppEnvironment.current.flavor` from `lib/core/environment/app_environment.dart` (already exists)

- [ ] **Step 1: Write the failing test**

```dart
// test/core/time/clock_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/time/clock.dart';
import 'package:flow/core/time/clock_provider.dart';

void main() {
  test('SystemClock.now() returns a value close to real time', () {
    const clock = SystemClock();
    final before = DateTime.now();
    final result = clock.now();
    final after = DateTime.now();

    expect(
      result.isAfter(before.subtract(const Duration(seconds: 1))) &&
          result.isBefore(after.add(const Duration(seconds: 1))),
      isTrue,
    );
  });

  test('FixedClock.now() returns the fixed instant until set again', () {
    final fixed = DateTime(2026, 1, 1, 12);
    final clock = FixedClock(fixed);

    expect(clock.now(), fixed);

    final later = DateTime(2026, 6, 1);
    clock.set(later);

    expect(clock.now(), later);
  });

  test('clockProvider defaults to a SystemClock', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(clockProvider), isA<SystemClock>());
  });

  test('clockProvider returns the override instant when clockOverrideProvider is set (dev flavor default)', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final overridden = DateTime(2030, 3, 3);
    container.read(clockOverrideProvider.notifier).set(overridden);

    expect(container.read(clockProvider).now(), overridden);
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/time/clock_test.dart
```

Expected: FAIL — `lib/core/time/clock.dart` and `clock_provider.dart` don't exist yet.

- [ ] **Step 3: Implement `Clock`, `SystemClock`, `FixedClock`**

```dart
// lib/core/time/clock.dart

/// Injectable source of "now". Nothing outside this file may call
/// `DateTime.now()` directly — everything else reads through a [Clock]
/// so tests can control time and the dev flavor can override it.
abstract class Clock {
  DateTime now();
}

class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}

/// A [Clock] whose instant is fixed until [set] is called again.
/// Used by tests and by the dev-flavor debug clock override.
class FixedClock implements Clock {
  FixedClock(this._current);

  DateTime _current;

  @override
  DateTime now() => _current;

  void set(DateTime value) {
    _current = value;
  }
}
```

- [ ] **Step 4: Implement the providers**

```dart
// lib/core/time/clock_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../environment/app_environment.dart';
import 'clock.dart';

part 'clock_provider.g.dart';

/// Only meaningful in the `dev` flavor — lets a future debug UI move
/// the app's clock forward/backward to test streaks, reminders, and
/// day-rollover logic without waiting in real time.
@riverpod
class ClockOverride extends _$ClockOverride {
  @override
  DateTime? build() => null;

  void set(DateTime? value) {
    state = value;
  }
}

@Riverpod(keepAlive: true)
Clock clock(Ref ref) {
  if (AppEnvironment.current.flavor == AppFlavor.dev) {
    final override = ref.watch(clockOverrideProvider);
    if (override != null) {
      return FixedClock(override);
    }
  }

  return const SystemClock();
}
```

- [ ] **Step 5: Run codegen, then run the test to verify it passes**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
dart run build_runner build --delete-conflicting-outputs
flutter test test/core/time/clock_test.dart
```

Expected: PASS, 4 tests. (The `clockProvider`/`clockOverrideProvider` tests
call `AppEnvironment.current`, which needs `AppEnvironment.initialize()`
to have run first — `flutter test` runs each file fresh with no `main()`
called, so if these fail with a `StateError` about `initialize()` not
being called, add `AppEnvironment.initialize();` as the first line inside
each `test(...)` body that reads `clockProvider`.)

- [ ] **Step 6: Commit**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
dart format lib/core/time test/core/time
git add lib/core/time test/core/time
git commit -m "Add Clock abstraction with dev-flavor debug override"
```

---

## Task 5: `Result`/`Failure` sealed types

**Files:**
- Create: `lib/core/result/result.dart`
- Create: `lib/core/result/failure.dart`
- Test: `test/core/result/result_test.dart`

**Interfaces:**
- Produces: `sealed class Result<T>` with `Ok<T>(T value)` and `Err<T>(Failure failure)` variants, pattern-matchable via Dart's `switch`; `sealed class Failure` with `ValidationFailure(String field, String message)`, `StorageFailure(String message)`, `PermissionFailure(String message)`, `UnknownFailure(String message)` variants
- Consumes: nothing

- [ ] **Step 1: Write the failing test**

```dart
// test/core/result/result_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/result/failure.dart';
import 'package:flow/core/result/result.dart';

void main() {
  test('Ok holds a value and is not an Err', () {
    const result = Result<int>.ok(42);

    expect(result, isA<Ok<int>>());
    switch (result) {
      case Ok(:final value):
        expect(value, 42);
      case Err():
        fail('expected Ok');
    }
  });

  test('Err holds a Failure', () {
    const result = Result<int>.err(StorageFailure('disk full'));

    switch (result) {
      case Ok():
        fail('expected Err');
      case Err(:final failure):
        expect(failure, isA<StorageFailure>());
        expect((failure as StorageFailure).message, 'disk full');
    }
  });

  test('ValidationFailure carries a field name and message', () {
    const failure = ValidationFailure('age', 'Age must be between 9 and 120.');

    expect(failure.field, 'age');
    expect(failure.message, 'Age must be between 9 and 120.');
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/result/result_test.dart
```

Expected: FAIL — files don't exist yet.

- [ ] **Step 3: Implement `Failure`**

```dart
// lib/core/result/failure.dart

/// Failure categories for the Repository -> UseCase -> Notifier
/// boundary. FLOW has no backend, so there are deliberately no
/// network-related cases here.
sealed class Failure {
  const Failure(this.message);

  final String message;
}

class ValidationFailure extends Failure {
  const ValidationFailure(this.field, String message) : super(message);

  final String field;
}

class StorageFailure extends Failure {
  const StorageFailure(String message) : super(message);
}

class PermissionFailure extends Failure {
  const PermissionFailure(String message) : super(message);
}

class UnknownFailure extends Failure {
  const UnknownFailure(String message) : super(message);
}
```

- [ ] **Step 4: Implement `Result`**

```dart
// lib/core/result/result.dart
import 'failure.dart';

sealed class Result<T> {
  const Result();

  const factory Result.ok(T value) = Ok<T>;
  const factory Result.err(Failure failure) = Err<T>;
}

class Ok<T> extends Result<T> {
  const Ok(this.value);

  final T value;
}

class Err<T> extends Result<T> {
  const Err(this.failure);

  final Failure failure;
}
```

- [ ] **Step 5: Run the test to verify it passes**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/result/result_test.dart
```

Expected: PASS, 3 tests.

- [ ] **Step 6: Commit**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
dart format lib/core/result test/core/result
git add lib/core/result test/core/result
git commit -m "Add Result/Failure sealed types"
```

---

## Task 6: `UnitConverter`

**Files:**
- Create: `lib/core/utils/unit_converter.dart`
- Test: `test/core/utils/unit_converter_test.dart`

**Interfaces:**
- Produces: `class UnitConverter` with static methods `mlToFlOz(int ml) -> double`, `flOzToMl(double flOz) -> int`, `kgToLb(double kg) -> double`, `lbToKg(double lb) -> double`
- Consumes: nothing

- [ ] **Step 1: Write the failing test**

```dart
// test/core/utils/unit_converter_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/utils/unit_converter.dart';

void main() {
  test('mlToFlOz converts using 1 fl oz = 29.5735 ml', () {
    expect(UnitConverter.mlToFlOz(295735), closeTo(10000, 0.01));
  });

  test('flOzToMl rounds to the nearest whole millilitre', () {
    expect(UnitConverter.flOzToMl(1), 30);
  });

  test('kgToLb converts using 1 lb = 0.453592 kg', () {
    expect(UnitConverter.kgToLb(1), closeTo(2.2046, 0.001));
  });

  test('lbToKg converts using 1 lb = 0.453592 kg', () {
    expect(UnitConverter.lbToKg(1), closeTo(0.453592, 0.000001));
  });

  test('kgToLb and lbToKg round-trip within a small tolerance', () {
    const originalKg = 68.0;
    final roundTripped = UnitConverter.lbToKg(UnitConverter.kgToLb(originalKg));

    expect(roundTripped, closeTo(originalKg, 0.001));
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/utils/unit_converter_test.dart
```

Expected: FAIL — `unit_converter.dart` doesn't exist yet.

- [ ] **Step 3: Implement `UnitConverter`**

```dart
// lib/core/utils/unit_converter.dart

/// Canonical storage is always metric (integer ml, double kg) per
/// BR-40/BR-41 — imperial is presentation-only. These conversions are
/// the single source of truth for that presentation layer.
class UnitConverter {
  UnitConverter._();

  static const double _mlPerFlOz = 29.5735;
  static const double _kgPerLb = 0.453592;

  static double mlToFlOz(int ml) => ml / _mlPerFlOz;

  static int flOzToMl(double flOz) => (flOz * _mlPerFlOz).round();

  static double kgToLb(double kg) => kg / _kgPerLb;

  static double lbToKg(double lb) => lb * _kgPerLb;
}
```

- [ ] **Step 4: Run the test to verify it passes**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/utils/unit_converter_test.dart
```

Expected: PASS, 5 tests.

- [ ] **Step 5: Commit**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
dart format lib/core/utils test/core/utils
git add lib/core/utils test/core/utils
git commit -m "Add UnitConverter for metric/imperial presentation conversions"
```

---

## Task 7: Spacing, radius, elevation, and motion tokens

**Files:**
- Create: `lib/core/design/tokens/flow_spacing.dart`
- Create: `lib/core/design/tokens/flow_radius.dart`
- Create: `lib/core/design/tokens/flow_elevation.dart`
- Create: `lib/core/design/tokens/flow_motion.dart`
- Test: `test/core/design/tokens/flow_tokens_test.dart`

**Interfaces:**
- Produces: `class FlowSpacing` (static `double` fields `xs2`, `xs`, `sm`, `md`, `lg`, `xl`, `xl2`, `xl3`, `xl4`, `xl5`, `xl6` for the 2/4/8/12/16/20/24/32/40/48/64 scale), `class FlowRadius` (static `double` fields `sm`=8, `md`=12, `lg`=16, `xl`=24, `pill`=999, `quickAddChip`=10), `class FlowElevation` (static `List<BoxShadow>` fields `level1`, `level2`, `level3` for light mode), `class FlowMotion` (static `Duration` fields `instant`, `fast`, `base`, `slow`, `celebrate`, `page`; static `Curve` fields `instantCurve`, `fastCurve`, `baseCurve`, `slowCurve`, `celebrateCurve`)
- Consumes: nothing

- [ ] **Step 1: Write the failing test**

```dart
// test/core/design/tokens/flow_tokens_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/tokens/flow_elevation.dart';
import 'package:flow/core/design/tokens/flow_motion.dart';
import 'package:flow/core/design/tokens/flow_radius.dart';
import 'package:flow/core/design/tokens/flow_spacing.dart';

void main() {
  test('FlowSpacing follows the 4dp base scale', () {
    expect(FlowSpacing.xs2, 2);
    expect(FlowSpacing.xs, 4);
    expect(FlowSpacing.sm, 8);
    expect(FlowSpacing.md, 16);
    expect(FlowSpacing.xl3, 32);
    expect(FlowSpacing.xl6, 64);
  });

  test('FlowRadius has the documented scale plus the QuickAddChip exception', () {
    expect(FlowRadius.sm, 8);
    expect(FlowRadius.md, 12);
    expect(FlowRadius.lg, 16);
    expect(FlowRadius.xl, 24);
    expect(FlowRadius.pill, 999);
    expect(FlowRadius.quickAddChip, 10);
  });

  test('FlowElevation levels never exceed level3 and each has at least one shadow', () {
    expect(FlowElevation.level1, isNotEmpty);
    expect(FlowElevation.level2, isNotEmpty);
    expect(FlowElevation.level3, isNotEmpty);
  });

  test('FlowMotion durations never exceed 650ms', () {
    for (final duration in [
      FlowMotion.instant,
      FlowMotion.fast,
      FlowMotion.base,
      FlowMotion.slow,
      FlowMotion.celebrate,
      FlowMotion.page,
    ]) {
      expect(duration.inMilliseconds, lessThanOrEqualTo(650));
    }
    expect(FlowMotion.celebrate.inMilliseconds, 650);
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/design/tokens/flow_tokens_test.dart
```

Expected: FAIL — none of the token files exist yet.

- [ ] **Step 3: Implement `FlowSpacing`**

```dart
// lib/core/design/tokens/flow_spacing.dart

/// 4dp-base spacing scale (06-design-system.md §3):
/// 2, 4, 8, 12, 16, 20, 24, 32, 40, 48, 64.
class FlowSpacing {
  FlowSpacing._();

  static const double xs2 = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double smMd = 12;
  static const double md = 16;
  static const double mdLg = 20;
  static const double lg = 24;
  static const double xl3 = 32;
  static const double xl4 = 40;
  static const double xl5 = 48;
  static const double xl6 = 64;
}
```

- [ ] **Step 4: Implement `FlowRadius`**

```dart
// lib/core/design/tokens/flow_radius.dart

/// Corner-radius scale (06-design-system.md §4). `pill` is currently
/// unused by any real component — QuickAddChip uses a dedicated 10px
/// radius per the Figma verification, not a pill (see the foundation
/// design spec, Section 6).
class FlowRadius {
  FlowRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double pill = 999;
  static const double quickAddChip = 10;
}
```

- [ ] **Step 5: Implement `FlowElevation`**

```dart
// lib/core/design/tokens/flow_elevation.dart
import 'package:flutter/material.dart';

/// Light-mode shadow elevation (06-design-system.md §5). Dark mode uses
/// surface-color steps instead of shadows (near-invisible on dark
/// backgrounds) — handled directly in FlowTheme's dark ColorScheme, not
/// here.
class FlowElevation {
  FlowElevation._();

  static const List<BoxShadow> level1 = [
    BoxShadow(color: Color(0x0F101820), offset: Offset(0, 1), blurRadius: 2),
    BoxShadow(color: Color(0x0A101820), offset: Offset(0, 1), blurRadius: 3),
  ];

  static const List<BoxShadow> level2 = [
    BoxShadow(color: Color(0x14101820), offset: Offset(0, 2), blurRadius: 8),
  ];

  static const List<BoxShadow> level3 = [
    BoxShadow(color: Color(0x1F101820), offset: Offset(0, 8), blurRadius: 24),
  ];
}
```

- [ ] **Step 6: Implement `FlowMotion`**

```dart
// lib/core/design/tokens/flow_motion.dart
import 'package:flutter/animation.dart';

/// Motion durations and curves (06-design-system.md §6). Nothing in the
/// app may animate longer than [celebrate] (650ms), and every animated
/// component must consume `reduceMotionProvider` (Task 10) to fall back
/// to an instant change or a short cross-fade.
class FlowMotion {
  FlowMotion._();

  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration base = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 450);
  static const Duration celebrate = Duration(milliseconds: 650);
  static const Duration page = Duration(milliseconds: 300);

  static const Curve instantCurve = Curves.easeOut;
  static const Curve fastCurve = Curves.easeOutCubic;
  static const Curve baseCurve = Curves.easeInOutCubic;
  static const Curve slowCurve = Curves.easeOutCubic;
  static const Curve celebrateCurve = Curves.easeOutBack;
}
```

- [ ] **Step 7: Run the test to verify it passes**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/design/tokens/flow_tokens_test.dart
```

Expected: PASS, 4 tests.

- [ ] **Step 8: Commit**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
dart format lib/core/design test/core/design
git add lib/core/design test/core/design
git commit -m "Add spacing, radius, elevation, and motion design tokens"
```

---

## Task 8: Color tokens (`FlowColors` theme extension, light + dark)

**Files:**
- Create: `lib/core/design/tokens/flow_colors.dart`
- Test: `test/core/design/tokens/flow_colors_test.dart`

**Interfaces:**
- Produces: `class FlowColors extends ThemeExtension<FlowColors>` with every field listed below, plus `static const FlowColors light = FlowColors(...)` and `static const FlowColors dark = FlowColors(...)`
- Consumes: nothing

- [ ] **Step 1: Write the failing test**

```dart
// test/core/design/tokens/flow_colors_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/tokens/flow_colors.dart';

void main() {
  test('light brand and semantic tokens match the verified hex values', () {
    const c = FlowColors.light;

    expect(c.brandPrimary, const Color(0xFF2FB6F0));
    expect(c.brandPrimaryPressed, const Color(0xFF085A82));
    expect(c.backgroundPrimary, const Color(0xFFFFFFFF));
    expect(c.textPrimary, const Color(0xFF101A2E));
    expect(c.error, const Color(0xFFC22A2E));
  });

  test('dark brand and semantic tokens match the verified hex values', () {
    const c = FlowColors.dark;

    expect(c.backgroundPrimary, const Color(0xFF101A33));
    expect(c.textPrimary, const Color(0xFFEAF2FF));
    expect(c.brandPrimary, const Color(0xFF2FB6F0));
  });

  test('game-surface tokens are genuinely theme-dependent (Figma-verified correction)', () {
    expect(FlowColors.light.panelDeep, const Color(0xFF085A82));
    expect(FlowColors.dark.panelDeep, const Color(0xFF06405E));

    expect(FlowColors.light.trackDark, const Color(0xFF143A52));
    expect(FlowColors.dark.trackDark, const Color(0xFF0C2436));

    expect(FlowColors.light.canvasGame, const Color(0xFFE4F5FD));
    expect(FlowColors.dark.canvasGame, FlowColors.dark.backgroundPrimary);
  });

  test('frame tokens are theme-independent', () {
    expect(FlowColors.light.frameInk, FlowColors.dark.frameInk);
    expect(FlowColors.light.frameDepth, FlowColors.dark.frameDepth);
  });

  test('copyWith overrides only the requested field', () {
    final overridden = FlowColors.light.copyWith(brandPrimary: Colors.red);

    expect(overridden.brandPrimary, Colors.red);
    expect(overridden.textPrimary, FlowColors.light.textPrimary);
  });

  test('lerp at t=0 returns this and at t=1 returns other', () {
    final result0 = FlowColors.light.lerp(FlowColors.dark, 0);
    final result1 = FlowColors.light.lerp(FlowColors.dark, 1);

    expect(result0.backgroundPrimary, FlowColors.light.backgroundPrimary);
    expect(result1.backgroundPrimary, FlowColors.dark.backgroundPrimary);
  });

  test('a FlowColors extension is retrievable from a ThemeData', () {
    final theme = ThemeData(extensions: const [FlowColors.light]);

    expect(theme.extension<FlowColors>(), FlowColors.light);
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/design/tokens/flow_colors_test.dart
```

Expected: FAIL — `flow_colors.dart` doesn't exist yet.

- [ ] **Step 3: Implement `FlowColors`**

```dart
// lib/core/design/tokens/flow_colors.dart
import 'package:flutter/material.dart';

/// Every color token from 06-design-system.md §2, verified against the
/// Figma file's bound variables (see the foundation design spec, Section
/// 6). `panelDeep`, `trackDark`, and `canvasGame` are genuinely
/// theme-dependent — a correction found during that verification, not
/// present in the original written doc.
class FlowColors extends ThemeExtension<FlowColors> {
  const FlowColors({
    required this.brandPrimary,
    required this.brandPrimaryTextSafe,
    required this.brandPrimaryPressed,
    required this.brandPrimaryActive,
    required this.brandSecondary,
    required this.xp,
    required this.achievement,
    required this.reward,
    required this.streak,
    required this.backgroundPrimary,
    required this.surfacePrimary,
    required this.surfaceTinted,
    required this.surfaceAlt,
    required this.border,
    required this.borderStrong,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.onPrimary,
    required this.trackSubtle,
    required this.success,
    required this.successSurface,
    required this.error,
    required this.errorSurface,
    required this.warning,
    required this.warningSurface,
    required this.info,
    required this.infoSurface,
    required this.streakSurface,
    required this.scrim,
    required this.canvasGame,
    required this.panelDeep,
    required this.panelDeepInk,
    required this.panelDeepAccent,
    required this.frameInk,
    required this.frameDepth,
    required this.frameBevel,
    required this.particle,
    required this.trackDark,
  });

  final Color brandPrimary;
  final Color brandPrimaryTextSafe;
  final Color brandPrimaryPressed;
  final Color brandPrimaryActive;
  final Color brandSecondary;
  final Color xp;
  final Color achievement;
  final Color reward;
  final Color streak;

  final Color backgroundPrimary;
  final Color surfacePrimary;
  final Color surfaceTinted;
  final Color surfaceAlt;
  final Color border;
  final Color borderStrong;
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;
  final Color onPrimary;
  final Color trackSubtle;
  final Color success;
  final Color successSurface;
  final Color error;
  final Color errorSurface;
  final Color warning;
  final Color warningSurface;
  final Color info;
  final Color infoSurface;
  final Color streakSurface;
  final Color scrim;

  final Color canvasGame;
  final Color panelDeep;
  final Color panelDeepInk;
  final Color panelDeepAccent;
  final Color frameInk;
  final Color frameDepth;
  final Color frameBevel;
  final Color particle;
  final Color trackDark;

  static const FlowColors light = FlowColors(
    brandPrimary: Color(0xFF2FB6F0),
    brandPrimaryTextSafe: Color(0xFF0A6E9E),
    brandPrimaryPressed: Color(0xFF085A82),
    brandPrimaryActive: Color(0xFF1C9AD1),
    brandSecondary: Color(0xFF8B6BF2),
    xp: Color(0xFF8BD450),
    achievement: Color(0xFFFFC542),
    reward: Color(0xFFFF7A59),
    streak: Color(0xFFB45309),
    backgroundPrimary: Color(0xFFFFFFFF),
    surfacePrimary: Color(0xFFF7FAFD),
    surfaceTinted: Color(0xFFE4F5FD),
    surfaceAlt: Color(0xFFEEF2F6),
    border: Color(0xFFD7DEE6),
    borderStrong: Color(0xFFAEBBC8),
    textPrimary: Color(0xFF101A2E),
    textSecondary: Color(0xFF4A5763),
    textDisabled: Color(0xFF6B7885),
    onPrimary: Color(0xFFFFFFFF),
    trackSubtle: Color(0xFFDCE6EF),
    success: Color(0xFF147A52),
    successSurface: Color(0xFFE4F5EE),
    error: Color(0xFFC22A2E),
    errorSurface: Color(0xFFFCEBEA),
    warning: Color(0xFFA85A08),
    warningSurface: Color(0xFFFDF8EC),
    info: Color(0xFF0A6E9E),
    infoSurface: Color(0xFFE6F2FB),
    streakSurface: Color(0xFFFDF1E3),
    scrim: Color(0x99101A2E),
    canvasGame: Color(0xFFE4F5FD),
    panelDeep: Color(0xFF085A82),
    panelDeepInk: Color(0xFFFFFFFF),
    panelDeepAccent: Color(0xFF7FDBFA),
    frameInk: Color(0xFF0B1E36),
    frameDepth: Color(0xFF0A3E5C),
    frameBevel: Color(0x595FCBF5),
    particle: Color(0x4D7FDBFA),
    trackDark: Color(0xFF143A52),
  );

  static const FlowColors dark = FlowColors(
    brandPrimary: Color(0xFF2FB6F0),
    brandPrimaryTextSafe: Color(0xFF2FB6F0),
    brandPrimaryPressed: Color(0xFF085A82),
    brandPrimaryActive: Color(0xFF1C9AD1),
    brandSecondary: Color(0xFFA488FF),
    xp: Color(0xFF8BD450),
    achievement: Color(0xFFFFC542),
    reward: Color(0xFFFF7A59),
    streak: Color(0xFFF5A15C),
    backgroundPrimary: Color(0xFF101A33),
    surfacePrimary: Color(0xFF182347),
    surfaceTinted: Color(0xFF1C2B57),
    surfaceAlt: Color(0xFF202F5E),
    border: Color(0xFF2A3A66),
    borderStrong: Color(0xFF3D4F8A),
    textPrimary: Color(0xFFEAF2FF),
    textSecondary: Color(0xFFA9B8D6),
    textDisabled: Color(0xFF8593A1),
    onPrimary: Color(0xFF08243A),
    trackSubtle: Color(0xFF22315C),
    success: Color(0xFF2FBE79),
    successSurface: Color(0xFF182347),
    error: Color(0xFFFF6B6B),
    errorSurface: Color(0xFF182347),
    warning: Color(0xFFFFA940),
    warningSurface: Color(0xFF182347),
    info: Color(0xFF2FB6F0),
    infoSurface: Color(0xFF182347),
    streakSurface: Color(0xFF182347),
    scrim: Color(0xB3000000),
    canvasGame: Color(0xFF101A33),
    panelDeep: Color(0xFF06405E),
    panelDeepInk: Color(0xFFFFFFFF),
    panelDeepAccent: Color(0xFF7FDBFA),
    frameInk: Color(0xFF0B1E36),
    frameDepth: Color(0xFF0A3E5C),
    frameBevel: Color(0x595FCBF5),
    particle: Color(0x4D7FDBFA),
    trackDark: Color(0xFF0C2436),
  );

  @override
  FlowColors copyWith({
    Color? brandPrimary,
    Color? brandPrimaryTextSafe,
    Color? brandPrimaryPressed,
    Color? brandPrimaryActive,
    Color? brandSecondary,
    Color? xp,
    Color? achievement,
    Color? reward,
    Color? streak,
    Color? backgroundPrimary,
    Color? surfacePrimary,
    Color? surfaceTinted,
    Color? surfaceAlt,
    Color? border,
    Color? borderStrong,
    Color? textPrimary,
    Color? textSecondary,
    Color? textDisabled,
    Color? onPrimary,
    Color? trackSubtle,
    Color? success,
    Color? successSurface,
    Color? error,
    Color? errorSurface,
    Color? warning,
    Color? warningSurface,
    Color? info,
    Color? infoSurface,
    Color? streakSurface,
    Color? scrim,
    Color? canvasGame,
    Color? panelDeep,
    Color? panelDeepInk,
    Color? panelDeepAccent,
    Color? frameInk,
    Color? frameDepth,
    Color? frameBevel,
    Color? particle,
    Color? trackDark,
  }) {
    return FlowColors(
      brandPrimary: brandPrimary ?? this.brandPrimary,
      brandPrimaryTextSafe: brandPrimaryTextSafe ?? this.brandPrimaryTextSafe,
      brandPrimaryPressed: brandPrimaryPressed ?? this.brandPrimaryPressed,
      brandPrimaryActive: brandPrimaryActive ?? this.brandPrimaryActive,
      brandSecondary: brandSecondary ?? this.brandSecondary,
      xp: xp ?? this.xp,
      achievement: achievement ?? this.achievement,
      reward: reward ?? this.reward,
      streak: streak ?? this.streak,
      backgroundPrimary: backgroundPrimary ?? this.backgroundPrimary,
      surfacePrimary: surfacePrimary ?? this.surfacePrimary,
      surfaceTinted: surfaceTinted ?? this.surfaceTinted,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      border: border ?? this.border,
      borderStrong: borderStrong ?? this.borderStrong,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textDisabled: textDisabled ?? this.textDisabled,
      onPrimary: onPrimary ?? this.onPrimary,
      trackSubtle: trackSubtle ?? this.trackSubtle,
      success: success ?? this.success,
      successSurface: successSurface ?? this.successSurface,
      error: error ?? this.error,
      errorSurface: errorSurface ?? this.errorSurface,
      warning: warning ?? this.warning,
      warningSurface: warningSurface ?? this.warningSurface,
      info: info ?? this.info,
      infoSurface: infoSurface ?? this.infoSurface,
      streakSurface: streakSurface ?? this.streakSurface,
      scrim: scrim ?? this.scrim,
      canvasGame: canvasGame ?? this.canvasGame,
      panelDeep: panelDeep ?? this.panelDeep,
      panelDeepInk: panelDeepInk ?? this.panelDeepInk,
      panelDeepAccent: panelDeepAccent ?? this.panelDeepAccent,
      frameInk: frameInk ?? this.frameInk,
      frameDepth: frameDepth ?? this.frameDepth,
      frameBevel: frameBevel ?? this.frameBevel,
      particle: particle ?? this.particle,
      trackDark: trackDark ?? this.trackDark,
    );
  }

  @override
  FlowColors lerp(ThemeExtension<FlowColors>? other, double t) {
    if (other is! FlowColors) {
      return this;
    }

    Color c(Color a, Color b) => Color.lerp(a, b, t)!;

    return FlowColors(
      brandPrimary: c(brandPrimary, other.brandPrimary),
      brandPrimaryTextSafe: c(brandPrimaryTextSafe, other.brandPrimaryTextSafe),
      brandPrimaryPressed: c(brandPrimaryPressed, other.brandPrimaryPressed),
      brandPrimaryActive: c(brandPrimaryActive, other.brandPrimaryActive),
      brandSecondary: c(brandSecondary, other.brandSecondary),
      xp: c(xp, other.xp),
      achievement: c(achievement, other.achievement),
      reward: c(reward, other.reward),
      streak: c(streak, other.streak),
      backgroundPrimary: c(backgroundPrimary, other.backgroundPrimary),
      surfacePrimary: c(surfacePrimary, other.surfacePrimary),
      surfaceTinted: c(surfaceTinted, other.surfaceTinted),
      surfaceAlt: c(surfaceAlt, other.surfaceAlt),
      border: c(border, other.border),
      borderStrong: c(borderStrong, other.borderStrong),
      textPrimary: c(textPrimary, other.textPrimary),
      textSecondary: c(textSecondary, other.textSecondary),
      textDisabled: c(textDisabled, other.textDisabled),
      onPrimary: c(onPrimary, other.onPrimary),
      trackSubtle: c(trackSubtle, other.trackSubtle),
      success: c(success, other.success),
      successSurface: c(successSurface, other.successSurface),
      error: c(error, other.error),
      errorSurface: c(errorSurface, other.errorSurface),
      warning: c(warning, other.warning),
      warningSurface: c(warningSurface, other.warningSurface),
      info: c(info, other.info),
      infoSurface: c(infoSurface, other.infoSurface),
      streakSurface: c(streakSurface, other.streakSurface),
      scrim: c(scrim, other.scrim),
      canvasGame: c(canvasGame, other.canvasGame),
      panelDeep: c(panelDeep, other.panelDeep),
      panelDeepInk: c(panelDeepInk, other.panelDeepInk),
      panelDeepAccent: c(panelDeepAccent, other.panelDeepAccent),
      frameInk: c(frameInk, other.frameInk),
      frameDepth: c(frameDepth, other.frameDepth),
      frameBevel: c(frameBevel, other.frameBevel),
      particle: c(particle, other.particle),
      trackDark: c(trackDark, other.trackDark),
    );
  }
}
```

- [ ] **Step 4: Run the test to verify it passes**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/design/tokens/flow_colors_test.dart
```

Expected: PASS, 7 tests.

- [ ] **Step 5: Commit**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
dart format lib/core/design/tokens test/core/design/tokens
git add lib/core/design/tokens test/core/design/tokens
git commit -m "Add FlowColors theme extension (light + dark, Figma-verified)"
```

---

## Task 9: Typography tokens (`FlowTypography` theme extension)

**Files:**
- Create: `lib/core/design/tokens/flow_typography.dart`
- Test: `test/core/design/tokens/flow_typography_test.dart`

**Interfaces:**
- Produces: `class FlowTypography extends ThemeExtension<FlowTypography>` with `TextStyle` fields `numericHero`, `numericL`, `pixelDisplay`, `pixelHero`, `pixelTitle`, `pixelUnit`, `labelGame`, `buttonGame`, `displayL`, `displayM`, `headline`, `titleL`, `titleM`, `bodyL`, `bodyM`, `label`, `caption`, `button`, and `static const FlowTypography standard = FlowTypography(...)` (identical in light/dark — type styles don't carry color, `FlowColors` supplies that separately)
- Consumes: font family names `"Inter"` and `"Press Start 2P"` from Task 3

- [ ] **Step 1: Write the failing test**

```dart
// test/core/design/tokens/flow_typography_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/tokens/flow_typography.dart';

void main() {
  test('numericHero matches the documented spec', () {
    const style = FlowTypography.standard.numericHero;

    expect(style.fontFamily, 'Inter');
    expect(style.fontSize, 56);
    expect(style.height, closeTo(60 / 56, 0.01));
    expect(style.fontWeight, FontWeight.w700);
    expect(style.letterSpacing, -1.5);
  });

  test('pixelTitle uses Press Start 2P and never falls below 20sp', () {
    const style = FlowTypography.standard.pixelTitle;

    expect(style.fontFamily, 'Press Start 2P');
    expect(style.fontSize, 20);
  });

  test('caption is the smallest style and nothing ships below it', () {
    const styles = [
      FlowTypography.standard.displayL,
      FlowTypography.standard.displayM,
      FlowTypography.standard.headline,
      FlowTypography.standard.titleL,
      FlowTypography.standard.titleM,
      FlowTypography.standard.bodyL,
      FlowTypography.standard.bodyM,
      FlowTypography.standard.label,
      FlowTypography.standard.caption,
      FlowTypography.standard.button,
    ];

    for (final style in styles) {
      expect(style.fontSize! >= FlowTypography.standard.caption.fontSize!, isTrue);
    }
  });

  test('buttonGame and labelGame are uppercase-tracked Inter, not Press Start 2P', () {
    expect(FlowTypography.standard.buttonGame.fontFamily, 'Inter');
    expect(FlowTypography.standard.buttonGame.letterSpacing, 1.2);
    expect(FlowTypography.standard.labelGame.fontFamily, 'Inter');
  });

  test('lerp at t=0 and t=1 returns the expected endpoint style', () {
    const other = FlowTypography.standard;
    final result = FlowTypography.standard.lerp(other, 1);

    expect(result.bodyL.fontSize, other.bodyL.fontSize);
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/design/tokens/flow_typography_test.dart
```

Expected: FAIL — `flow_typography.dart` doesn't exist yet.

- [ ] **Step 3: Implement `FlowTypography`**

```dart
// lib/core/design/tokens/flow_typography.dart
import 'package:flutter/material.dart';

/// Every type style from 06-design-system.md §3, verified against the
/// Figma file's bound text-style variables. `pixelTitle` wraps to a
/// maximum of 3 lines (the v3.1 changelog correction — the written
/// table's "max two lines" is stale); enforcing the line cap is the
/// consuming widget's responsibility, not this style object's.
class FlowTypography extends ThemeExtension<FlowTypography> {
  const FlowTypography({
    required this.numericHero,
    required this.numericL,
    required this.pixelDisplay,
    required this.pixelHero,
    required this.pixelTitle,
    required this.pixelUnit,
    required this.labelGame,
    required this.buttonGame,
    required this.displayL,
    required this.displayM,
    required this.headline,
    required this.titleL,
    required this.titleM,
    required this.bodyL,
    required this.bodyM,
    required this.label,
    required this.caption,
    required this.button,
  });

  final TextStyle numericHero;
  final TextStyle numericL;
  final TextStyle pixelDisplay;
  final TextStyle pixelHero;
  final TextStyle pixelTitle;
  final TextStyle pixelUnit;
  final TextStyle labelGame;
  final TextStyle buttonGame;
  final TextStyle displayL;
  final TextStyle displayM;
  final TextStyle headline;
  final TextStyle titleL;
  final TextStyle titleM;
  final TextStyle bodyL;
  final TextStyle bodyM;
  final TextStyle label;
  final TextStyle caption;
  final TextStyle button;

  static const String _inter = 'Inter';
  static const String _pixel = 'Press Start 2P';

  static const FlowTypography standard = FlowTypography(
    numericHero: TextStyle(
      fontFamily: _inter,
      fontSize: 56,
      height: 60 / 56,
      fontWeight: FontWeight.w700,
      letterSpacing: -1.5,
      fontFeatures: [FontFeature.tabularFigures()],
    ),
    numericL: TextStyle(
      fontFamily: _inter,
      fontSize: 28,
      height: 32 / 28,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      fontFeatures: [FontFeature.tabularFigures()],
    ),
    pixelDisplay: TextStyle(
      fontFamily: _pixel,
      fontSize: 20,
      height: 28 / 20,
      fontWeight: FontWeight.w400,
    ),
    pixelHero: TextStyle(
      fontFamily: _pixel,
      fontSize: 40,
      height: 44 / 40,
      fontWeight: FontWeight.w400,
    ),
    pixelTitle: TextStyle(
      fontFamily: _pixel,
      fontSize: 20,
      height: 28 / 20,
      fontWeight: FontWeight.w400,
    ),
    pixelUnit: TextStyle(
      fontFamily: _pixel,
      fontSize: 20,
      height: 24 / 20,
      fontWeight: FontWeight.w400,
    ),
    labelGame: TextStyle(
      fontFamily: _inter,
      fontSize: 12,
      height: 16 / 12,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
    ),
    buttonGame: TextStyle(
      fontFamily: _inter,
      fontSize: 16,
      height: 20 / 16,
      fontWeight: FontWeight.w700,
      letterSpacing: 1.2,
    ),
    displayL: TextStyle(
      fontFamily: _inter,
      fontSize: 40,
      height: 48 / 40,
      fontWeight: FontWeight.w700,
      letterSpacing: -1,
    ),
    displayM: TextStyle(
      fontFamily: _inter,
      fontSize: 32,
      height: 40 / 32,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
    ),
    headline: TextStyle(
      fontFamily: _inter,
      fontSize: 24,
      height: 32 / 24,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
    ),
    titleL: TextStyle(
      fontFamily: _inter,
      fontSize: 20,
      height: 28 / 20,
      fontWeight: FontWeight.w600,
    ),
    titleM: TextStyle(
      fontFamily: _inter,
      fontSize: 17,
      height: 24 / 17,
      fontWeight: FontWeight.w600,
    ),
    bodyL: TextStyle(
      fontFamily: _inter,
      fontSize: 16,
      height: 24 / 16,
      fontWeight: FontWeight.w400,
    ),
    bodyM: TextStyle(
      fontFamily: _inter,
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w400,
    ),
    label: TextStyle(
      fontFamily: _inter,
      fontSize: 13,
      height: 16 / 13,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
    ),
    caption: TextStyle(
      fontFamily: _inter,
      fontSize: 12,
      height: 16 / 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.2,
    ),
    button: TextStyle(
      fontFamily: _inter,
      fontSize: 16,
      height: 20 / 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    ),
  );

  @override
  FlowTypography copyWith({
    TextStyle? numericHero,
    TextStyle? numericL,
    TextStyle? pixelDisplay,
    TextStyle? pixelHero,
    TextStyle? pixelTitle,
    TextStyle? pixelUnit,
    TextStyle? labelGame,
    TextStyle? buttonGame,
    TextStyle? displayL,
    TextStyle? displayM,
    TextStyle? headline,
    TextStyle? titleL,
    TextStyle? titleM,
    TextStyle? bodyL,
    TextStyle? bodyM,
    TextStyle? label,
    TextStyle? caption,
    TextStyle? button,
  }) {
    return FlowTypography(
      numericHero: numericHero ?? this.numericHero,
      numericL: numericL ?? this.numericL,
      pixelDisplay: pixelDisplay ?? this.pixelDisplay,
      pixelHero: pixelHero ?? this.pixelHero,
      pixelTitle: pixelTitle ?? this.pixelTitle,
      pixelUnit: pixelUnit ?? this.pixelUnit,
      labelGame: labelGame ?? this.labelGame,
      buttonGame: buttonGame ?? this.buttonGame,
      displayL: displayL ?? this.displayL,
      displayM: displayM ?? this.displayM,
      headline: headline ?? this.headline,
      titleL: titleL ?? this.titleL,
      titleM: titleM ?? this.titleM,
      bodyL: bodyL ?? this.bodyL,
      bodyM: bodyM ?? this.bodyM,
      label: label ?? this.label,
      caption: caption ?? this.caption,
      button: button ?? this.button,
    );
  }

  @override
  FlowTypography lerp(ThemeExtension<FlowTypography>? other, double t) {
    if (other is! FlowTypography) {
      return this;
    }

    TextStyle s(TextStyle a, TextStyle b) => TextStyle.lerp(a, b, t)!;

    return FlowTypography(
      numericHero: s(numericHero, other.numericHero),
      numericL: s(numericL, other.numericL),
      pixelDisplay: s(pixelDisplay, other.pixelDisplay),
      pixelHero: s(pixelHero, other.pixelHero),
      pixelTitle: s(pixelTitle, other.pixelTitle),
      pixelUnit: s(pixelUnit, other.pixelUnit),
      labelGame: s(labelGame, other.labelGame),
      buttonGame: s(buttonGame, other.buttonGame),
      displayL: s(displayL, other.displayL),
      displayM: s(displayM, other.displayM),
      headline: s(headline, other.headline),
      titleL: s(titleL, other.titleL),
      titleM: s(titleM, other.titleM),
      bodyL: s(bodyL, other.bodyL),
      bodyM: s(bodyM, other.bodyM),
      label: s(label, other.label),
      caption: s(caption, other.caption),
      button: s(button, other.button),
    );
  }
}
```

- [ ] **Step 4: Run the test to verify it passes**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/design/tokens/flow_typography_test.dart
```

Expected: PASS, 5 tests. (If the `pixelTitle`/`pixelDisplay`/etc. tests fail
to *render* later in a widget test with "font not found," that's expected
until Task 3's fonts are actually bundled and `flutter pub get` has run —
this task's tests only check the `TextStyle` object's fields, not glyph
rendering.)

- [ ] **Step 5: Commit**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
dart format lib/core/design/tokens test/core/design/tokens
git add lib/core/design/tokens test/core/design/tokens
git commit -m "Add FlowTypography theme extension"
```

---

## Task 10: `FlowTheme` assembly (light/dark `ThemeData`) and `reduceMotionProvider`

**Files:**
- Create: `lib/core/design/theme/flow_theme.dart`
- Create: `lib/core/design/theme/reduce_motion_provider.dart`
- Create: `lib/core/design/theme/reduce_motion_listener.dart`
- Modify: `lib/app/app.dart` (wire `FlowTheme.light`/`FlowTheme.dark` and wrap the router in `ReduceMotionListener`)
- Test: `test/core/design/theme/flow_theme_test.dart`
- Test: `test/core/design/theme/reduce_motion_provider_test.dart`

**Interfaces:**
- Consumes: `FlowColors` (Task 8), `FlowTypography` (Task 9)
- Produces: `class FlowTheme { static ThemeData light; static ThemeData dark; }`, `reduceMotionProvider` (codegen `Notifier<bool>` with a `.sync(bool)` method), `class ReduceMotionListener extends ConsumerStatefulWidget`

- [ ] **Step 1: Write the failing theme test**

```dart
// test/core/design/theme/flow_theme_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/theme/flow_theme.dart';
import 'package:flow/core/design/tokens/flow_colors.dart';
import 'package:flow/core/design/tokens/flow_typography.dart';

void main() {
  test('light theme exposes FlowColors.light and FlowTypography.standard', () {
    expect(FlowTheme.light.extension<FlowColors>(), FlowColors.light);
    expect(FlowTheme.light.extension<FlowTypography>(), FlowTypography.standard);
    expect(FlowTheme.light.brightness, Brightness.light);
  });

  test('dark theme exposes FlowColors.dark and FlowTypography.standard', () {
    expect(FlowTheme.dark.extension<FlowColors>(), FlowColors.dark);
    expect(FlowTheme.dark.extension<FlowTypography>(), FlowTypography.standard);
    expect(FlowTheme.dark.brightness, Brightness.dark);
  });

  test('light and dark scaffold backgrounds match FlowColors backgroundPrimary', () {
    expect(FlowTheme.light.scaffoldBackgroundColor, FlowColors.light.backgroundPrimary);
    expect(FlowTheme.dark.scaffoldBackgroundColor, FlowColors.dark.backgroundPrimary);
  });

  test('both themes use Material 3', () {
    expect(FlowTheme.light.useMaterial3, isTrue);
    expect(FlowTheme.dark.useMaterial3, isTrue);
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/design/theme/flow_theme_test.dart
```

Expected: FAIL — `flow_theme.dart` doesn't exist yet.

- [ ] **Step 3: Implement `FlowTheme`**

```dart
// lib/core/design/theme/flow_theme.dart
import 'package:flutter/material.dart';

import '../tokens/flow_colors.dart';
import '../tokens/flow_typography.dart';

class FlowTheme {
  FlowTheme._();

  static final ThemeData light = _build(FlowColors.light, Brightness.light);
  static final ThemeData dark = _build(FlowColors.dark, Brightness.dark);

  static ThemeData _build(FlowColors colors, Brightness brightness) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: colors.brandPrimary,
      onPrimary: colors.textPrimary,
      secondary: colors.brandSecondary,
      onSecondary: colors.textPrimary,
      error: colors.error,
      onError: colors.backgroundPrimary,
      surface: colors.surfacePrimary,
      onSurface: colors.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.backgroundPrimary,
      fontFamily: 'Inter',
      appBarTheme: AppBarTheme(
        backgroundColor: colors.backgroundPrimary,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        titleTextStyle: FlowTypography.standard.titleL.copyWith(
          color: colors.textPrimary,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: FlowTypography.standard.displayL.copyWith(color: colors.textPrimary),
        displayMedium: FlowTypography.standard.displayM.copyWith(color: colors.textPrimary),
        headlineMedium: FlowTypography.standard.headline.copyWith(color: colors.textPrimary),
        titleLarge: FlowTypography.standard.titleL.copyWith(color: colors.textPrimary),
        titleMedium: FlowTypography.standard.titleM.copyWith(color: colors.textPrimary),
        bodyLarge: FlowTypography.standard.bodyL.copyWith(color: colors.textPrimary),
        bodyMedium: FlowTypography.standard.bodyM.copyWith(color: colors.textSecondary),
        labelLarge: FlowTypography.standard.button.copyWith(color: colors.textPrimary),
        labelSmall: FlowTypography.standard.caption.copyWith(color: colors.textSecondary),
      ),
      extensions: [colors, FlowTypography.standard],
    );
  }
}
```

- [ ] **Step 4: Run the theme test to verify it passes**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/design/theme/flow_theme_test.dart
```

Expected: PASS, 4 tests.

- [ ] **Step 5: Write the failing `reduceMotionProvider` test**

```dart
// test/core/design/theme/reduce_motion_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/theme/reduce_motion_provider.dart';

void main() {
  test('reduceMotionProvider defaults to false', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(reduceMotionProvider), isFalse);
  });

  test('sync updates the state when the value changes', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(reduceMotionProvider.notifier).sync(true);

    expect(container.read(reduceMotionProvider), isTrue);
  });

  test('sync is a no-op when the value is unchanged', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    var rebuildCount = 0;
    container.listen(reduceMotionProvider, (previous, next) => rebuildCount++);

    container.read(reduceMotionProvider.notifier).sync(false);

    expect(rebuildCount, 0);
  });
}
```

- [ ] **Step 6: Run the test to verify it fails**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/design/theme/reduce_motion_provider_test.dart
```

Expected: FAIL — `reduce_motion_provider.dart` doesn't exist yet.

- [ ] **Step 7: Implement `reduceMotionProvider` and `ReduceMotionListener`**

```dart
// lib/core/design/theme/reduce_motion_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reduce_motion_provider.g.dart';

/// Read once from `MediaQuery.disableAnimations` by [ReduceMotionListener]
/// and consumed by every animated component, per 10-accessibility.md.
/// No animated component exists yet in this foundation pass, but the
/// provider is created now since it's a cross-cutting requirement every
/// future animation must plug into from day one.
@riverpod
class ReduceMotion extends _$ReduceMotion {
  @override
  bool build() => false;

  void sync(bool value) {
    if (state != value) {
      state = value;
    }
  }
}
```

```dart
// lib/core/design/theme/reduce_motion_listener.dart
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'reduce_motion_provider.dart';

/// Wrap the app's root content in this widget once, near `MaterialApp`,
/// so `reduceMotionProvider` always reflects the OS setting.
class ReduceMotionListener extends ConsumerStatefulWidget {
  const ReduceMotionListener({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<ReduceMotionListener> createState() => _ReduceMotionListenerState();
}

class _ReduceMotionListenerState extends ConsumerState<ReduceMotionListener> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final value = MediaQuery.of(context).disableAnimations;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(reduceMotionProvider.notifier).sync(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
```

- [ ] **Step 8: Wire `FlowTheme` and `ReduceMotionListener` into `lib/app/app.dart`**

```dart
// lib/app/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/design/theme/flow_theme.dart';
import '../core/design/theme/reduce_motion_listener.dart';
import 'router/app_router.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return ReduceMotionListener(
      child: MaterialApp.router(
        routerConfig: router,
        theme: FlowTheme.light,
        darkTheme: FlowTheme.dark,
        themeMode: ThemeMode.system,
      ),
    );
  }
}
```

- [ ] **Step 9: Run codegen and both tests to verify everything passes**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
dart run build_runner build --delete-conflicting-outputs
flutter test test/core/design/theme/
flutter analyze
```

Expected: PASS, 7 tests total across both files; `flutter analyze` clean.

- [ ] **Step 10: Commit**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
dart format lib/core/design/theme lib/app test/core/design/theme
git add lib/core/design/theme lib/app test/core/design/theme
git commit -m "Add FlowTheme and reduceMotionProvider, wire into App"
```

---

## Task 11: Widget test harness (`pumpFlowWidget`)

**Files:**
- Create: `test/support/pump_flow_widget.dart`
- Test: `test/support/pump_flow_widget_test.dart`

**Interfaces:**
- Produces: `Future<void> pumpFlowWidget(WidgetTester tester, Widget child, {Brightness brightness = Brightness.light, List<Override> overrides = const []})` — wraps `child` in a `ProviderScope` + `MaterialApp` using `FlowTheme.light`/`dark`, sized to the 360×640dp reference viewport
- Consumes: `FlowTheme` (Task 10)

- [ ] **Step 1: Write the failing test**

```dart
// test/support/pump_flow_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'pump_flow_widget.dart';

void main() {
  testWidgets('pumpFlowWidget renders the given child inside a themed MaterialApp', (tester) async {
    await pumpFlowWidget(tester, const Text('hello'));

    expect(find.text('hello'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('pumpFlowWidget honors the brightness parameter', (tester) async {
    await pumpFlowWidget(tester, const SizedBox(), brightness: Brightness.dark);

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme!.brightness, Brightness.dark);
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/support/pump_flow_widget_test.dart
```

Expected: FAIL — `pump_flow_widget.dart` doesn't exist yet.

- [ ] **Step 3: Implement `pumpFlowWidget`**

```dart
// test/support/pump_flow_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/theme/flow_theme.dart';

/// Standard wrapper for widget tests in this project: a 360x640dp
/// (the design system's reference viewport) MaterialApp using the real
/// FlowTheme, inside a fresh ProviderScope.
Future<void> pumpFlowWidget(
  WidgetTester tester,
  Widget child, {
  Brightness brightness = Brightness.light,
  List<Override> overrides = const [],
}) async {
  tester.view.physicalSize = const Size(360, 640);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: brightness == Brightness.light ? FlowTheme.light : FlowTheme.dark,
        home: Scaffold(body: child),
      ),
    ),
  );
}
```

- [ ] **Step 4: Run the test to verify it passes**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/support/pump_flow_widget_test.dart
```

Expected: PASS, 2 tests.

- [ ] **Step 5: Commit**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
dart format test/support
git add test/support
git commit -m "Add pumpFlowWidget test harness helper"
```

---

## Task 12: Drift schema v1 — all 8 tables, migration harness, seed data

**Files:**
- Create: `lib/core/database/tables/user_profiles.dart`
- Create: `lib/core/database/tables/hydration_entries.dart`
- Create: `lib/core/database/tables/daily_hydration.dart`
- Create: `lib/core/database/tables/xp_events.dart`
- Create: `lib/core/database/tables/achievements.dart`
- Create: `lib/core/database/tables/trivia_progress.dart`
- Create: `lib/core/database/tables/reminder_settings.dart`
- Create: `lib/core/database/tables/progress_meta.dart`
- Create: `lib/core/database/seed/achievement_catalogue.dart`
- Create: `lib/core/database/app_database.dart`
- Test: `test/core/database/app_database_test.dart`

**Interfaces:**
- Consumes: `drift`, `sqlite3_flutter_libs`, `path_provider` (Task 2)
- Produces: `class AppDatabase extends _$AppDatabase` (generated base class from `@DriftDatabase`), with typed accessors `db.userProfiles`, `db.hydrationEntries`, `db.dailyHydration`, `db.xpEvents`, `db.achievements`, `db.triviaProgress`, `db.reminderSettings`, `db.progressMeta`; `kAchievementCatalogue` (a `List<String>` of seed achievement keys)

Note on scope: this task builds the schema, migration, and a minimal seed
proof — it does **not** populate the full 16-item achievement catalogue
(names/descriptions/thresholds/XP values), since those are documented
product content that belongs to Phase 5 ("Gamification"), not the
foundation. `kAchievementCatalogue` seeds two keys this plan can source
with confidence from the functional spec (`streak_7`, `level_99`); the
full catalogue is a Phase 5 task referencing `02-functional-spec.md`
§11.4.

- [ ] **Step 1: Write the failing integration test first**

```dart
// test/core/database/app_database_test.dart
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('opening a fresh database creates all 8 tables', () async {
    final tableNames = await db
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .get();
    final names = tableNames.map((row) => row.data['name'] as String).toSet();

    expect(names, containsAll([
      'user_profiles',
      'hydration_entries',
      'daily_hydration',
      'xp_events',
      'achievements',
      'trivia_progress',
      'reminder_settings',
      'progress_meta',
    ]));
  });

  test('a fresh database seeds the achievement catalogue', () async {
    final rows = await db.select(db.achievements).get();

    expect(rows.map((r) => r.key), containsAll(['streak_7', 'level_99']));
  });

  test('a fresh database seeds reminder defaults', () async {
    final row = await (db.select(db.reminderSettings)..where((t) => t.id.equals(1))).getSingle();

    expect(row.enabled, isTrue);
    expect(row.startMinuteOfDay, 480);
    expect(row.endMinuteOfDay, 1320);
    expect(row.intervalMinutes, 120);
  });

  test('a fresh database seeds progress_meta with bestStreak 0', () async {
    final row = await (db.select(db.progressMeta)..where((t) => t.id.equals(1))).getSingle();

    expect(row.bestStreak, 0);
  });

  test('inserting a user profile round-trips correctly', () async {
    await db.into(db.userProfiles).insert(
          UserProfilesCompanion.insert(
            id: const Value(1),
            age: 30,
            sex: 'male',
            weightKg: 70.5,
            activityLevel: 'moderate',
            environment: 'temperate',
            dailyTargetMl: 2000,
            targetSource: 'suggested',
            calculatorMethodId: 'reference_intake_v1',
            profileCreatedAt: 1000,
            updatedAt: 1000,
          ),
        );

    final row = await (db.select(db.userProfiles)..where((t) => t.id.equals(1))).getSingle();

    expect(row.weightKg, 70.5);
    expect(row.dailyTargetMl, 2000);
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/database/app_database_test.dart
```

Expected: FAIL — none of the database files exist yet.

- [ ] **Step 3: Implement the `UserProfiles` table**

```dart
// lib/core/database/tables/user_profiles.dart
import 'package:drift/drift.dart';

/// Singleton row (id always 1) — 08-data-model.md ENT-01.
class UserProfiles extends Table {
  IntColumn get id => integer()();
  TextColumn get displayName => text().nullable().customConstraint('CHECK (length(display_name) <= 24)')();
  IntColumn get age => integer().customConstraint('NOT NULL CHECK (age BETWEEN 9 AND 120)')();
  TextColumn get sex => text()();
  RealColumn get weightKg => real().customConstraint('NOT NULL CHECK (weight_kg BETWEEN 25.0 AND 250.0)')();
  TextColumn get activityLevel => text()();
  TextColumn get environment => text()();
  TextColumn get specialCircumstances => text().withDefault(const Constant(''))();
  IntColumn get dailyTargetMl => integer().customConstraint('NOT NULL CHECK (daily_target_ml BETWEEN 500 AND 4000)')();
  TextColumn get targetSource => text()();
  TextColumn get calculatorMethodId => text()();
  IntColumn get profileCreatedAt => integer()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
```

- [ ] **Step 4: Implement the `HydrationEntries` table**

```dart
// lib/core/database/tables/hydration_entries.dart
import 'package:drift/drift.dart';

/// 08-data-model.md ENT-02. `localDate` is assigned at creation and
/// never reassigned (DST/travel safety).
class HydrationEntries extends Table {
  TextColumn get id => text()();
  IntColumn get amountMl => integer().customConstraint('NOT NULL CHECK (amount_ml BETWEEN 50 AND 2000)')();
  IntColumn get occurredAt => integer()();
  TextColumn get localDate => text()();
  TextColumn get source => text()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
```

The two indexes on `localDate`/`occurredAt` are created separately, as
raw SQL in `AppDatabase`'s `onCreate` (Step 11 below) — that approach
works regardless of the installed drift version's index-annotation API:
`CREATE INDEX idx_hydration_entries_local_date ON hydration_entries(local_date);`
and
`CREATE INDEX idx_hydration_entries_occurred_at ON hydration_entries(occurred_at);`

- [ ] **Step 5: Implement the `DailyHydration` table**

```dart
// lib/core/database/tables/daily_hydration.dart
import 'package:drift/drift.dart';

/// Materialized aggregate, one row per local date — 08-data-model.md
/// ENT-03. `targetMl` is snapshotted on the first entry of the day and
/// never rewritten after.
class DailyHydration extends Table {
  TextColumn get date => text()();
  IntColumn get totalMl => integer().withDefault(const Constant(0))();
  IntColumn get targetMl => integer().customConstraint('NOT NULL CHECK (target_ml BETWEEN 500 AND 4000)')();
  BoolColumn get goalCompleted => boolean().withDefault(const Constant(false))();
  IntColumn get goalCompletedAt => integer().nullable()();
  IntColumn get entryCount => integer().withDefault(const Constant(0))();
  TextColumn get status => text().withDefault(const Constant('noData'))();

  @override
  Set<Column> get primaryKey => {date};
}
```

- [ ] **Step 6: Implement the `XpEvents` table**

```dart
// lib/core/database/tables/xp_events.dart
import 'package:drift/drift.dart';

/// Append-only ledger — 08-data-model.md ENT-04. `totalXp` is always
/// `SUM(amount)`, never a mutable counter, so edits/deletes stay
/// reconcilable.
class XpEvents extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  IntColumn get amount => integer().customConstraint('NOT NULL CHECK (amount >= 0)')();
  TextColumn get localDate => text()();
  IntColumn get occurredAt => integer()();
  TextColumn get refId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
```

The unique partial index (`at most one goalComplete per localDate`) is
created with raw SQL in `AppDatabase`'s `onCreate` (Step 11):
`CREATE UNIQUE INDEX idx_xp_events_one_goal_complete_per_day ON xp_events(local_date) WHERE type = 'goalComplete';`

- [ ] **Step 7: Implement the `Achievements` table**

```dart
// lib/core/database/tables/achievements.dart
import 'package:drift/drift.dart';

/// 08-data-model.md ENT-05. Name/description/group/threshold/XP live in
/// a const Dart catalogue (Phase 5), not this table — only unlock state
/// is persisted here.
class Achievements extends Table {
  TextColumn get key => text()();
  BoolColumn get unlocked => boolean().withDefault(const Constant(false))();
  IntColumn get unlockedAt => integer().nullable()();
  IntColumn get progressCurrent => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {key};
}
```

- [ ] **Step 8: Implement the `TriviaProgress` table**

```dart
// lib/core/database/tables/trivia_progress.dart
import 'package:drift/drift.dart';

/// 08-data-model.md ENT-06, keyed to the bundled trivia.json content.
class TriviaProgress extends Table {
  TextColumn get itemId => text()();
  TextColumn get type => text()();
  IntColumn get seenAt => integer().nullable()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  BoolColumn get answeredCorrectly => boolean().nullable()();
  BoolColumn get awardedXp => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {itemId};
}
```

- [ ] **Step 9: Implement the `ReminderSettings` table**

```dart
// lib/core/database/tables/reminder_settings.dart
import 'package:drift/drift.dart';

/// Singleton row (id always 1) — 08-data-model.md ENT-07.
class ReminderSettings extends Table {
  IntColumn get id => integer()();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  IntColumn get startMinuteOfDay => integer().withDefault(const Constant(480))();
  IntColumn get endMinuteOfDay => integer().withDefault(const Constant(1320))();
  IntColumn get intervalMinutes => integer().withDefault(const Constant(120))();
  TextColumn get activeWeekdays => text().withDefault(const Constant('1,2,3,4,5,6,7'))();
  TextColumn get messageStyle => text().withDefault(const Constant('friendly'))();
  TextColumn get soundId => text().nullable()();
  BoolColumn get stopWhenGoalMet => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}
```

- [ ] **Step 10: Implement the `ProgressMeta` table**

```dart
// lib/core/database/tables/progress_meta.dart
import 'package:drift/drift.dart';

/// Singleton row (id always 1) — 08-data-model.md, `bestStreak`
/// high-water mark that survives a partial data import/merge.
class ProgressMeta extends Table {
  IntColumn get id => integer()();
  IntColumn get bestStreak => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
```

- [ ] **Step 11: Implement the seed catalogue and `AppDatabase`**

```dart
// lib/core/database/seed/achievement_catalogue.dart

/// Seed keys only — the full 16-item catalogue (names, descriptions,
/// thresholds, XP values) is documented product content that belongs to
/// Phase 5 ("Gamification"), sourced from 02-functional-spec.md §11.4.
/// These two keys are the ones this foundation pass can source with
/// confidence from the functional spec, to prove the seeding mechanism.
const List<String> kAchievementCatalogue = ['streak_7', 'level_99'];
```

```dart
// lib/core/database/app_database.dart
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'seed/achievement_catalogue.dart';
import 'tables/achievements.dart';
import 'tables/daily_hydration.dart';
import 'tables/hydration_entries.dart';
import 'tables/progress_meta.dart';
import 'tables/reminder_settings.dart';
import 'tables/trivia_progress.dart';
import 'tables/user_profiles.dart';
import 'tables/xp_events.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    UserProfiles,
    HydrationEntries,
    DailyHydration,
    XpEvents,
    Achievements,
    TriviaProgress,
    ReminderSettings,
    ProgressMeta,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await customStatement(
            'CREATE INDEX idx_hydration_entries_local_date ON hydration_entries(local_date);',
          );
          await customStatement(
            'CREATE INDEX idx_hydration_entries_occurred_at ON hydration_entries(occurred_at);',
          );
          await customStatement(
            "CREATE UNIQUE INDEX idx_xp_events_one_goal_complete_per_day ON xp_events(local_date) WHERE type = 'goalComplete';",
          );
          await _seedAchievements();
          await _seedSingletonDefaults();
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  Future<void> _seedAchievements() {
    return batch((batch) {
      batch.insertAll(
        achievements,
        kAchievementCatalogue.map((key) => AchievementsCompanion.insert(key: key)).toList(),
      );
    });
  }

  Future<void> _seedSingletonDefaults() async {
    await into(reminderSettings).insert(const ReminderSettingsCompanion(id: Value(1)));
    await into(progressMeta).insert(const ProgressMetaCompanion(id: Value(1)));
  }
}

QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'flow.db'));
    return NativeDatabase.createInBackground(file);
  });
}
```

- [ ] **Step 12: Add the `path` package (drift's `NativeDatabase` file path helper) if not already present**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter pub add path
```

- [ ] **Step 13: Run codegen**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
dart run build_runner build --delete-conflicting-outputs
```

Expected: generates `lib/core/database/app_database.g.dart` with the
`_$AppDatabase` base class and all `*Companion` classes. If drift's
generator reports an error about a specific column API (drift's exact
DSL shifts slightly between versions), adjust that one column's syntax to
match the installed `drift` version's documentation — the schema
intent above (types, defaults, constraints) is what must be preserved.

- [ ] **Step 14: Run the test to verify it passes**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/database/app_database_test.dart
```

Expected: PASS, 5 tests.

- [ ] **Step 15: Commit**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
dart format lib/core/database test/core/database
git add lib/core/database test/core/database pubspec.yaml pubspec.lock
git commit -m "Add Drift schema v1: 8 tables, migration harness, seed data"
```

---

## Task 13: `SharedPreferences`/`AppDatabase` providers and `main()` bootstrap

**Files:**
- Create: `lib/core/preferences/shared_preferences_provider.dart`
- Create: `lib/core/preferences/onboarding_provider.dart`
- Create: `lib/core/database/database_provider.dart`
- Modify: `lib/main.dart`
- Test: `test/core/preferences/onboarding_provider_test.dart`
- Test: `test/core/database/database_provider_test.dart`

**Interfaces:**
- Consumes: `AppDatabase` (Task 12), `AppEnvironment.initialize()` (existing)
- Produces: `sharedPreferencesProvider` (`Provider<SharedPreferences>`, throws if not overridden), `onboardingCompleteProvider` (`Provider<bool>`, reads the `onboardingComplete` key), `appDatabaseProvider` (`Provider<AppDatabase>`, throws if not overridden), `databaseHealthyProvider` (`Provider<bool>`, throws if not overridden) — both overridden with real values resolved in `main()` before `runApp`

- [ ] **Step 1: Write the failing `onboardingCompleteProvider` test**

```dart
// test/core/preferences/onboarding_provider_test.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flow/core/preferences/onboarding_provider.dart';
import 'package:flow/core/preferences/shared_preferences_provider.dart';

void main() {
  test('onboardingCompleteProvider reads false when the key is unset', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    expect(container.read(onboardingCompleteProvider), isFalse);
  });

  test('onboardingCompleteProvider reads true when the key is set', () async {
    SharedPreferences.setMockInitialValues({'onboardingComplete': true});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    expect(container.read(onboardingCompleteProvider), isTrue);
  });

  test('sharedPreferencesProvider throws when not overridden', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(() => container.read(sharedPreferencesProvider), throwsUnimplementedError);
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/preferences/onboarding_provider_test.dart
```

Expected: FAIL — the preference provider files don't exist yet.

- [ ] **Step 3: Implement `sharedPreferencesProvider` and `onboardingCompleteProvider`**

```dart
// lib/core/preferences/shared_preferences_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'shared_preferences_provider.g.dart';

/// Overridden in main() with the real, already-`await`ed instance
/// before runApp — see Step 8 below. Values here are needed before the
/// database opens, so this can't be a FutureProvider the widget tree
/// waits on.
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(Ref ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main() before runApp.',
  );
}
```

```dart
// lib/core/preferences/onboarding_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'shared_preferences_provider.dart';

part 'onboarding_provider.g.dart';

const _onboardingCompleteKey = 'onboardingComplete';

@riverpod
bool onboardingComplete(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool(_onboardingCompleteKey) ?? false;
}
```

- [ ] **Step 4: Run codegen and the test to verify it passes**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
dart run build_runner build --delete-conflicting-outputs
flutter test test/core/preferences/onboarding_provider_test.dart
```

Expected: PASS, 3 tests.

- [ ] **Step 5: Write the failing `databaseHealthyProvider`/`appDatabaseProvider` test**

```dart
// test/core/database/database_provider_test.dart
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/database/app_database.dart';
import 'package:flow/core/database/database_provider.dart';

void main() {
  test('appDatabaseProvider throws when not overridden', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(() => container.read(appDatabaseProvider), throwsUnimplementedError);
  });

  test('databaseHealthyProvider throws when not overridden', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(() => container.read(databaseHealthyProvider), throwsUnimplementedError);
  });

  test('a healthy database can be read once overridden', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        databaseHealthyProvider.overrideWithValue(true),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(appDatabaseProvider), db);
    expect(container.read(databaseHealthyProvider), isTrue);
  });
}
```

- [ ] **Step 6: Run the test to verify it fails**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/database/database_provider_test.dart
```

Expected: FAIL — `database_provider.dart` doesn't exist yet.

- [ ] **Step 7: Implement `appDatabaseProvider` and `databaseHealthyProvider`**

```dart
// lib/core/database/database_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'app_database.dart';

part 'database_provider.g.dart';

/// Overridden in main() with the real, already-opened instance before
/// runApp — see Step 8 below.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  throw UnimplementedError(
    'appDatabaseProvider must be overridden in main() before runApp.',
  );
}

/// True unless opening/migrating the database threw in main() — drives
/// the router's redirect-to-/recovery gate (Task 30).
@Riverpod(keepAlive: true)
bool databaseHealthy(Ref ref) {
  throw UnimplementedError(
    'databaseHealthyProvider must be overridden in main() before runApp.',
  );
}
```

- [ ] **Step 8: Wire both into `lib/main.dart`**

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/database/app_database.dart';
import 'core/database/database_provider.dart';
import 'core/environment/app_environment.dart';
import 'core/preferences/shared_preferences_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppEnvironment.initialize();

  final prefs = await SharedPreferences.getInstance();

  final database = AppDatabase();
  var databaseIsHealthy = true;
  try {
    await database.customStatement('PRAGMA user_version');
  } catch (_) {
    databaseIsHealthy = false;
  }

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
}
```

- [ ] **Step 9: Run codegen, then run both new tests plus the full suite to verify nothing regressed**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
dart run build_runner build --delete-conflicting-outputs
flutter test test/core/database/database_provider_test.dart
flutter test
flutter analyze
```

Expected: all tests pass; `flutter analyze` clean.

- [ ] **Step 10: Commit**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
dart format lib/core/preferences lib/core/database lib/main.dart test/core/preferences test/core/database
git add lib/core/preferences lib/core/database lib/main.dart test/core/preferences test/core/database
git commit -m "Wire SharedPreferences and AppDatabase into the provider graph and main()"
```

---

## Task 14: Copy brand/icon/mascot assets into the project and declare them

**Files:**
- Create: `assets/icons/onboarding/*.svg` (copied)
- Create: `assets/icons/achievements/*.svg` (copied)
- Create: `assets/illustrations/mascot/*.svg` (copied)
- Create: `assets/brand/*.svg` (copied)
- Modify: `pubspec.yaml` (`flutter.assets:` section)

**Interfaces:**
- Consumes: nothing
- Produces: every onboarding/achievement/mascot/brand SVG available at `assets/icons/onboarding/`, `assets/icons/achievements/`, `assets/illustrations/mascot/`, `assets/brand/` inside the FLOW project, usable via `flutter_svg`'s `SvgPicture.asset(...)`

The FLOW project currently has **no `assets/` folder at all** — every
brand/icon/mascot SVG lives only in `~/Downloads/docs/assets/`, outside
the Flutter project. This task copies them in; it does not modify or
regenerate any of the source files.

- [ ] **Step 1: Copy every asset folder into the project**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
mkdir -p assets/icons assets/illustrations assets/brand
cp -R /Users/leojangelicomacario/Downloads/docs/assets/icons/onboarding assets/icons/onboarding
cp -R /Users/leojangelicomacario/Downloads/docs/assets/icons/achievements assets/icons/achievements
cp -R /Users/leojangelicomacario/Downloads/docs/assets/illustrations/mascot assets/illustrations/mascot
cp -R /Users/leojangelicomacario/Downloads/docs/assets/brand/. assets/brand/
find assets -name ".DS_Store" -delete
```

- [ ] **Step 2: Verify the copy is complete and every file is a real SVG**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
find assets/icons assets/illustrations assets/brand -type f | wc -l
find assets/icons assets/illustrations assets/brand -type f ! -name "*.svg"
```

Expected: the file count matches the source (~57 files across the four
folders per the earlier project audit); the second command prints
nothing (no non-SVG stragglers like `.DS_Store`).

- [ ] **Step 3: Declare the asset folders in `pubspec.yaml`**

Add under the existing `flutter:` section (Flutter picks up every file in
a declared directory, so one line per folder is enough — no need to list
every SVG individually):

```yaml
  assets:
    - assets/icons/onboarding/
    - assets/icons/achievements/
    - assets/illustrations/mascot/
    - assets/brand/
```

- [ ] **Step 4: Verify `pub get` picks up the new assets**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter pub get
flutter analyze
```

Expected: no errors. (Asset declarations aren't validated by `analyze`
directly, but a malformed YAML block would fail `pub get`.)

- [ ] **Step 5: Commit**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
git add assets pubspec.yaml pubspec.lock
git commit -m "Copy brand/icon/mascot SVG assets into the project"
```

---

## Task 15: Shared `FlowFrameBox` decoration primitive + `CMP-01 PrimaryButton`

**Files:**
- Create: `lib/core/design/components/flow_frame_box.dart`
- Create: `lib/core/design/components/primary_button.dart`
- Test: `test/core/design/components/flow_frame_box_test.dart`
- Test: `test/core/design/components/primary_button_test.dart`

**Interfaces:**
- Consumes: `FlowColors`, `FlowTypography` (Tasks 8–9), `FlowSpacing`/`FlowRadius` (Task 7), `pumpFlowWidget` (Task 11)
- Produces: `class FlowFrameBox extends StatelessWidget` (`{required Widget child, required Color fill, required Color frameInk, double radius, double depth, Color? depthColor, Color? bevelColor, BorderRadiusGeometry? borderRadius}`) — reused by every remaining `CMP-*` task; `class PrimaryButton extends StatelessWidget` (`{required String label, VoidCallback? onPressed, bool isLoading, IconData? trailingIcon, String? trailingIconAsset, bool isMilestone}`)

This is the shared "2dp `frame.ink` border + solid `frame.depth` offset +
inner bevel highlight" recipe nearly every component in this plan reuses
— build it once here rather than duplicating it 12 times.

- [ ] **Step 1: Write the failing `FlowFrameBox` test**

```dart
// test/core/design/components/flow_frame_box_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/components/flow_frame_box.dart';
import 'package:flow/core/design/tokens/flow_colors.dart';

import '../../../support/pump_flow_widget.dart';

void main() {
  testWidgets('renders its child', (tester) async {
    await pumpFlowWidget(
      tester,
      FlowFrameBox(
        fill: FlowColors.light.brandPrimary,
        frameInk: FlowColors.light.frameInk,
        child: const Text('inside'),
      ),
    );

    expect(find.text('inside'), findsOneWidget);
  });

  testWidgets('with depth > 0, occupies extra height equal to the depth', (tester) async {
    await pumpFlowWidget(
      tester,
      SizedBox(
        height: 60,
        child: FlowFrameBox(
          fill: FlowColors.light.brandPrimary,
          frameInk: FlowColors.light.frameInk,
          depth: 4,
          depthColor: FlowColors.light.frameDepth,
          child: const SizedBox(height: 56),
        ),
      ),
    );

    expect(find.byType(FlowFrameBox), findsOneWidget);
    final size = tester.getSize(find.byType(FlowFrameBox));
    expect(size.height, 60);
  });

  testWidgets('with depth == 0, occupies exactly the child height (pressed state)', (tester) async {
    await pumpFlowWidget(
      tester,
      FlowFrameBox(
        fill: FlowColors.light.brandPrimary,
        frameInk: FlowColors.light.frameInk,
        child: const SizedBox(height: 56, width: 200),
      ),
    );

    final size = tester.getSize(find.byType(FlowFrameBox));
    expect(size.height, 56);
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/design/components/flow_frame_box_test.dart
```

Expected: FAIL — `flow_frame_box.dart` doesn't exist yet.

- [ ] **Step 3: Implement `FlowFrameBox`**

```dart
// lib/core/design/components/flow_frame_box.dart
import 'package:flutter/material.dart';

import '../tokens/flow_radius.dart';

/// The pixel-frame recipe shared by nearly every CMP-* component: a
/// [fill] with a 2dp [frameInk] border, an optional solid [depth]
/// offset beneath it (never blurred — collapses to 0 for a pressed
/// state), and an optional inner top bevel highlight line.
class FlowFrameBox extends StatelessWidget {
  const FlowFrameBox({
    required this.child,
    required this.fill,
    required this.frameInk,
    this.radius = FlowRadius.sm,
    this.depth = 0,
    this.depthColor,
    this.bevelColor,
    this.borderWidth = 2,
    super.key,
  });

  final Widget child;
  final Color fill;
  final Color frameInk;
  final double radius;
  final double depth;
  final Color? depthColor;
  final Color? bevelColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);

    final content = Container(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: borderRadius,
        border: Border.all(color: frameInk, width: borderWidth),
      ),
      child: bevelColor == null
          ? child
          : Stack(
              children: [
                child,
                Positioned(
                  top: borderWidth,
                  left: borderWidth,
                  right: borderWidth,
                  child: Container(height: 2, color: bevelColor),
                ),
              ],
            ),
    );

    if (depth <= 0) {
      return content;
    }

    return Stack(
      children: [
        Positioned(
          top: depth,
          left: 0,
          right: 0,
          bottom: 0,
          child: DecoratedBox(
            decoration: BoxDecoration(color: depthColor, borderRadius: borderRadius),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: depth),
          child: content,
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: Run the `FlowFrameBox` test to verify it passes**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/design/components/flow_frame_box_test.dart
```

Expected: PASS, 3 tests.

- [ ] **Step 5: Write the failing `PrimaryButton` test**

```dart
// test/core/design/components/primary_button_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/components/primary_button.dart';

import '../../../support/pump_flow_widget.dart';

void main() {
  testWidgets('renders its label', (tester) async {
    await pumpFlowWidget(
      tester,
      PrimaryButton(label: 'Continue', onPressed: () {}),
    );

    expect(find.text('CONTINUE'), findsOneWidget);
  });

  testWidgets('is 60dp tall (56 + 4dp depth offset)', (tester) async {
    await pumpFlowWidget(
      tester,
      SizedBox(
        width: 328,
        child: PrimaryButton(label: 'Continue', onPressed: () {}),
      ),
    );

    final size = tester.getSize(find.byType(PrimaryButton));
    expect(size.height, 60);
  });

  testWidgets('calls onPressed when tapped', (tester) async {
    var tapped = false;
    await pumpFlowWidget(
      tester,
      PrimaryButton(label: 'Continue', onPressed: () => tapped = true),
    );

    await tester.tap(find.byType(PrimaryButton));
    expect(tapped, isTrue);
  });

  testWidgets('disabled when onPressed is null and does not call it on tap', (tester) async {
    await pumpFlowWidget(
      tester,
      const PrimaryButton(label: 'Continue', onPressed: null),
    );

    await tester.tap(find.byType(PrimaryButton), warnIfMissed: false);
    // No exception thrown means the disabled button ignored the tap.
    expect(find.text('CONTINUE'), findsOneWidget);
  });

  testWidgets('shows a spinner instead of the label when isLoading is true', (tester) async {
    await pumpFlowWidget(
      tester,
      PrimaryButton(label: 'Continue', onPressed: () {}, isLoading: true),
    );

    expect(find.text('CONTINUE'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders a trailing icon when trailingIcon is given', (tester) async {
    await pumpFlowWidget(
      tester,
      PrimaryButton(label: 'Continue', onPressed: () {}, trailingIcon: Icons.arrow_forward_rounded),
    );

    expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
  });

  testWidgets('pressed state fills with brandPrimaryActive while the finger is down', (tester) async {
    await pumpFlowWidget(
      tester,
      PrimaryButton(label: 'Continue', onPressed: () {}),
    );

    final gesture = await tester.startGesture(tester.getCenter(find.byType(PrimaryButton)));
    await tester.pump();

    final container = tester.widget<Container>(
      find.descendant(of: find.byType(PrimaryButton), matching: find.byType(Container)).first,
    );
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, FlowColors.light.brandPrimaryActive);

    await gesture.up();
  });

  testWidgets('milestone variant fills with achievement instead of brandPrimary', (tester) async {
    await pumpFlowWidget(
      tester,
      PrimaryButton(label: 'Continue', onPressed: () {}, isMilestone: true),
    );

    final container = tester.widget<Container>(
      find.descendant(of: find.byType(PrimaryButton), matching: find.byType(Container)).first,
    );
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, FlowColors.light.achievement);
  });
}
```

Add this import alongside the existing ones at the top of the file:

```dart
import 'package:flow/core/design/tokens/flow_colors.dart';
```

- [ ] **Step 6: Run the test to verify it fails**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/design/components/primary_button_test.dart
```

Expected: FAIL — `primary_button.dart` doesn't exist yet.

- [ ] **Step 7: Implement `PrimaryButton`**

```dart
// lib/core/design/components/primary_button.dart
import 'package:flutter/material.dart';

import '../theme/flow_theme.dart';
import '../tokens/flow_colors.dart';
import '../tokens/flow_radius.dart';
import '../tokens/flow_spacing.dart';
import '../tokens/flow_typography.dart';
import 'flow_frame_box.dart';

/// CMP-01. Primary CTA. 56dp tall + 4dp solid frame/depth offset (60dp
/// total layout height). Label is text/primary navy on brand/primary —
/// never onPrimary white, which fails WCAG 1.4.3 at 2.32:1. Pressed
/// collapses the depth offset; that collapse IS the tap affordance.
class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.trailingIcon,
    this.isMilestone = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? trailingIcon;
  final bool isMilestone;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  bool get _isDisabled => widget.onPressed == null || widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FlowColors>()!;
    final typography = Theme.of(context).extension<FlowTypography>()!;

    final Color fill;
    final Color labelColor;
    final Color frameColor;

    if (_isDisabled) {
      fill = colors.border;
      labelColor = colors.textDisabled;
      frameColor = colors.borderStrong;
    } else {
      fill = _pressed
          ? colors.brandPrimaryActive
          : widget.isMilestone
              ? colors.achievement
              : colors.brandPrimary;
      labelColor = colors.textPrimary;
      frameColor = colors.frameInk;
    }

    return GestureDetector(
      onTapDown: _isDisabled ? null : (_) => setState(() => _pressed = true),
      onTapCancel: _isDisabled ? null : () => setState(() => _pressed = false),
      onTapUp: _isDisabled ? null : (_) => setState(() => _pressed = false),
      onTap: _isDisabled ? null : widget.onPressed,
      child: FlowFrameBox(
        fill: fill,
        frameInk: frameColor,
        radius: FlowRadius.sm,
        depth: _isDisabled || _pressed ? 0 : 4,
        depthColor: colors.frameDepth,
        bevelColor: _isDisabled ? null : colors.frameBevel,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: FlowSpacing.lg),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.isLoading)
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: labelColor),
                  )
                else ...[
                  Text(
                    widget.label.toUpperCase(),
                    style: typography.buttonGame.copyWith(color: labelColor),
                  ),
                  if (widget.trailingIcon != null) ...[
                    const SizedBox(width: FlowSpacing.sm),
                    Icon(widget.trailingIcon, size: 22, color: labelColor),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 8: Run the `PrimaryButton` test to verify it passes**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/design/components/primary_button_test.dart
```

Expected: PASS, 8 tests.

- [ ] **Step 9: Commit**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
dart format lib/core/design/components test/core/design/components
git add lib/core/design/components test/core/design/components
git commit -m "Add FlowFrameBox primitive and CMP-01 PrimaryButton"
```

---

## Task 16: `CMP-02 SecondaryButton`

**Files:**
- Create: `lib/core/design/components/secondary_button.dart`
- Test: `test/core/design/components/secondary_button_test.dart`

**Interfaces:**
- Consumes: `FlowColors`, `FlowTypography`, `FlowSpacing` (Tasks 7–9)
- Produces: `class SecondaryButton extends StatefulWidget` (`{required String label, required VoidCallback? onPressed}`)

- [ ] **Step 1: Write the failing test**

```dart
// test/core/design/components/secondary_button_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/components/secondary_button.dart';

import '../../../support/pump_flow_widget.dart';

void main() {
  testWidgets('renders its uppercased label', (tester) async {
    await pumpFlowWidget(
      tester,
      SecondaryButton(label: 'Adjust manually', onPressed: () {}),
    );

    expect(find.text('ADJUST MANUALLY'), findsOneWidget);
  });

  testWidgets('is 52dp tall — 4dp shorter than PrimaryButton', (tester) async {
    await pumpFlowWidget(
      tester,
      SizedBox(
        width: 328,
        child: SecondaryButton(label: 'Adjust manually', onPressed: () {}),
      ),
    );

    expect(tester.getSize(find.byType(SecondaryButton)).height, 52);
  });

  testWidgets('calls onPressed when tapped', (tester) async {
    var tapped = false;
    await pumpFlowWidget(
      tester,
      SecondaryButton(label: 'Adjust manually', onPressed: () => tapped = true),
    );

    await tester.tap(find.byType(SecondaryButton));
    expect(tapped, isTrue);
  });

  testWidgets('renders without throwing when disabled', (tester) async {
    await pumpFlowWidget(
      tester,
      const SecondaryButton(label: 'Adjust manually', onPressed: null),
    );

    expect(find.text('ADJUST MANUALLY'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/design/components/secondary_button_test.dart
```

Expected: FAIL — `secondary_button.dart` doesn't exist yet.

- [ ] **Step 3: Implement `SecondaryButton`**

```dart
// lib/core/design/components/secondary_button.dart
import 'package:flutter/material.dart';

import '../theme/flow_theme.dart';
import '../tokens/flow_colors.dart';
import '../tokens/flow_radius.dart';
import '../tokens/flow_spacing.dart';
import '../tokens/flow_typography.dart';

/// CMP-02. Outline only, no fill, no depth — deliberately 4dp shorter
/// than CMP-01's 60dp footprint so it visibly sits lower in the
/// hierarchy without needing a lighter color.
class SecondaryButton extends StatefulWidget {
  const SecondaryButton({required this.label, required this.onPressed, super.key});

  final String label;
  final VoidCallback? onPressed;

  @override
  State<SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<SecondaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FlowColors>()!;
    final typography = Theme.of(context).extension<FlowTypography>()!;
    final isDisabled = widget.onPressed == null;

    final Color borderColor;
    final Color labelColor;
    if (isDisabled) {
      borderColor = colors.surfacePrimary;
      labelColor = colors.textSecondary;
    } else if (_pressed) {
      borderColor = colors.brandPrimary;
      labelColor = colors.textPrimary;
    } else {
      borderColor = colors.frameInk;
      labelColor = colors.textPrimary;
    }

    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => setState(() => _pressed = true),
      onTapCancel: isDisabled ? null : () => setState(() => _pressed = false),
      onTapUp: isDisabled ? null : (_) => setState(() => _pressed = false),
      onTap: isDisabled ? null : widget.onPressed,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: FlowSpacing.lg),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(FlowRadius.sm),
        ),
        child: Text(
          widget.label.toUpperCase(),
          style: typography.buttonGame.copyWith(color: labelColor),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run the test to verify it passes**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/design/components/secondary_button_test.dart
```

Expected: PASS, 4 tests.

- [ ] **Step 5: Commit**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
dart format lib/core/design/components test/core/design/components
git add lib/core/design/components test/core/design/components
git commit -m "Add CMP-02 SecondaryButton"
```

---

## Task 17: `CMP-03 TextButton`

**Files:**
- Create: `lib/core/design/components/flow_text_button.dart`
- Test: `test/core/design/components/flow_text_button_test.dart`

**Interfaces:**
- Consumes: `FlowColors`, `FlowTypography` (Tasks 8–9), `flutter_svg` (Task 2), `assets/icons/onboarding/icon-info.svg` (Task 14)
- Produces: `class FlowTextButton extends StatelessWidget` (`{required String label, required VoidCallback? onPressed, bool showIcon = true}`) — named `FlowTextButton` rather than `TextButton` to avoid clashing with Flutter's built-in `TextButton`

- [ ] **Step 1: Write the failing test**

```dart
// test/core/design/components/flow_text_button_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/components/flow_text_button.dart';

import '../../../support/pump_flow_widget.dart';

void main() {
  testWidgets('renders its label without uppercasing', (tester) async {
    await pumpFlowWidget(
      tester,
      FlowTextButton(label: 'How we calculated this', onPressed: () {}),
    );

    expect(find.text('How we calculated this'), findsOneWidget);
  });

  testWidgets('is 48dp tall regardless of label length', (tester) async {
    await pumpFlowWidget(
      tester,
      FlowTextButton(label: 'Skip', onPressed: () {}),
    );

    expect(tester.getSize(find.byType(FlowTextButton)).height, 48);
  });

  testWidgets('shows the leading icon by default', (tester) async {
    await pumpFlowWidget(
      tester,
      FlowTextButton(label: 'How we calculated this', onPressed: () {}),
    );

    expect(find.byType(SvgPicture), findsOneWidget);
  });

  testWidgets('hides the leading icon when showIcon is false (the Skip/NoIcon variant)', (tester) async {
    await pumpFlowWidget(
      tester,
      FlowTextButton(label: 'Skip', onPressed: () {}, showIcon: false),
    );

    expect(find.byType(SvgPicture), findsNothing);
  });

  testWidgets('calls onPressed when tapped', (tester) async {
    var tapped = false;
    await pumpFlowWidget(
      tester,
      FlowTextButton(label: 'Skip', onPressed: () => tapped = true, showIcon: false),
    );

    await tester.tap(find.byType(FlowTextButton));
    expect(tapped, isTrue);
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/design/components/flow_text_button_test.dart
```

Expected: FAIL — `flow_text_button.dart` doesn't exist yet.

- [ ] **Step 3: Implement `FlowTextButton`**

```dart
// lib/core/design/components/flow_text_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/flow_theme.dart';
import '../tokens/flow_colors.dart';
import '../tokens/flow_spacing.dart';
import '../tokens/flow_typography.dart';

/// CMP-03. Text-only tappable link, 48dp tall regardless of label
/// length — a real hit target, not just the text glyph bounds (needed
/// explicitly for the ONB-08 Skip control). Label color is always
/// brandPrimaryTextSafe, never raw brandPrimary (2.32:1 contrast
/// failure). The [showIcon] = false case is the Skip/"NoIcon" variant.
class FlowTextButton extends StatelessWidget {
  const FlowTextButton({
    required this.label,
    required this.onPressed,
    this.showIcon = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FlowColors>()!;
    final typography = Theme.of(context).extension<FlowTypography>()!;
    final isDisabled = onPressed == null;
    final labelColor = isDisabled ? colors.textSecondary : colors.brandPrimaryTextSafe;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: FlowSpacing.smMd),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showIcon) ...[
              SvgPicture.asset(
                'assets/icons/onboarding/icon-info.svg',
                width: 20,
                height: 26,
              ),
              const SizedBox(width: FlowSpacing.sm),
            ],
            Text(label, style: typography.bodyM.copyWith(color: labelColor, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run the test to verify it passes**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/design/components/flow_text_button_test.dart
```

Expected: PASS, 5 tests.

- [ ] **Step 5: Commit**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
dart format lib/core/design/components test/core/design/components
git add lib/core/design/components test/core/design/components
git commit -m "Add CMP-03 FlowTextButton"
```

---

## Task 18: `CMP-42 BackButton`

**Files:**
- Create: `lib/core/design/components/back_button.dart`
- Test: `test/core/design/components/back_button_test.dart`

**Interfaces:**
- Consumes: `FlowFrameBox` (Task 15), `FlowColors` (Task 8), `flutter_svg`, `assets/icons/onboarding/icon-chevron-left.svg` (Task 14)
- Produces: `class FlowBackButton extends StatelessWidget` (`{required VoidCallback? onPressed}`) — named `FlowBackButton` to avoid clashing with Flutter's built-in `BackButton`

- [ ] **Step 1: Write the failing test**

```dart
// test/core/design/components/back_button_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/components/back_button.dart';

import '../../../support/pump_flow_widget.dart';

void main() {
  testWidgets('has a 48x48dp tappable content area (51dp tall including the 3dp depth offset)', (tester) async {
    await pumpFlowWidget(tester, FlowBackButton(onPressed: () {}));

    // Same footprint pattern as CMP-01 PrimaryButton (56 + 4 = 60): the
    // widget's total height includes the depth offset beneath the
    // 48dp tappable content.
    expect(tester.getSize(find.byType(FlowBackButton)), const Size(48, 51));
  });

  testWidgets('renders the pixel chevron-left icon asset', (tester) async {
    await pumpFlowWidget(tester, FlowBackButton(onPressed: () {}));

    expect(find.byType(SvgPicture), findsOneWidget);
  });

  testWidgets('calls onPressed when tapped', (tester) async {
    var tapped = false;
    await pumpFlowWidget(tester, FlowBackButton(onPressed: () => tapped = true));

    await tester.tap(find.byType(FlowBackButton));
    expect(tapped, isTrue);
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/design/components/back_button_test.dart
```

Expected: FAIL — `back_button.dart` doesn't exist yet.

- [ ] **Step 3: Implement `FlowBackButton`**

```dart
// lib/core/design/components/back_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/flow_theme.dart';
import '../tokens/flow_colors.dart';
import 'flow_frame_box.dart';

/// CMP-42. 48x48dp touch target, framed to match the button system but
/// with a shallower 3dp depth than CMP-01's 4dp, so it reads as
/// secondary. Onboarding uses no Material Symbols — this is the bundled
/// pixel chevron-left asset, reused (rotated) by CMP-14 SettingRow.
class FlowBackButton extends StatelessWidget {
  const FlowBackButton({required this.onPressed, super.key});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FlowColors>()!;

    return GestureDetector(
      onTap: onPressed,
      child: FlowFrameBox(
        fill: colors.surfacePrimary,
        frameInk: colors.frameInk,
        depth: 3,
        depthColor: colors.frameDepth,
        child: const SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: SizedBox(
              width: 14,
              height: 22,
              child: SvgPicture.asset('assets/icons/onboarding/icon-chevron-left.svg'),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run the test to verify it passes**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/design/components/back_button_test.dart
```

Expected: PASS, 3 tests.

- [ ] **Step 5: Commit**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
dart format lib/core/design/components test/core/design/components
git add lib/core/design/components test/core/design/components
git commit -m "Add CMP-42 BackButton"
```

---

## Task 19: `CMP-44 StepTrack`

**Files:**
- Create: `lib/core/design/components/step_track.dart`
- Test: `test/core/design/components/step_track_test.dart`

**Interfaces:**
- Consumes: `FlowColors` (Task 8)
- Produces: `class StepTrack extends StatelessWidget` (`{required int currentStep, int totalSteps = 5}`) — `currentStep` is 1-indexed

- [ ] **Step 1: Write the failing test**

```dart
// test/core/design/components/step_track_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/components/step_track.dart';
import 'package:flow/core/design/tokens/flow_colors.dart';

import '../../../support/pump_flow_widget.dart';

void main() {
  testWidgets('renders totalSteps done/current/upcoming nodes', (tester) async {
    await pumpFlowWidget(tester, const StepTrack(currentStep: 1));

    // 5 nodes total: 1 current + 4 upcoming when on step 1.
    expect(find.byKey(const ValueKey('step-track-node')), findsNWidgets(5));
  });

  testWidgets('the current node is visually larger (22dp) than done/upcoming nodes (14dp)', (tester) async {
    await pumpFlowWidget(tester, const StepTrack(currentStep: 3));

    final nodes = tester.widgetList<Container>(
      find.descendant(
        of: find.byKey(const ValueKey('step-track-node')),
        matching: find.byType(Container),
      ),
    );
    // At least one 22dp current node exists among the rendered nodes.
    expect(
      nodes.any((c) => (c.constraints?.maxWidth ?? c.constraints?.minWidth) == 22),
      isTrue,
    );
  });

  testWidgets('step 1 of 5 has no done nodes, step 5 of 5 has all nodes done or current', (tester) async {
    await pumpFlowWidget(tester, const StepTrack(currentStep: 5, totalSteps: 5));

    expect(find.byKey(const ValueKey('step-track-node')), findsNWidgets(5));
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/design/components/step_track_test.dart
```

Expected: FAIL — `step_track.dart` doesn't exist yet.

- [ ] **Step 3: Implement `StepTrack`**

```dart
// lib/core/design/components/step_track.dart
import 'package:flutter/material.dart';

import '../theme/flow_theme.dart';
import '../tokens/flow_colors.dart';

enum _StepState { done, current, upcoming }

/// CMP-44. Onboarding progression (ONB-03 to ONB-07). Every node state
/// carries a shape cue as well as a color, never color alone: done =
/// 14dp square with a light notch, current = 22dp square with a white
/// core (deliberately larger so "you are here" survives greyscale),
/// upcoming = 14dp square on trackSubtle. Pair with a plain "Step N of
/// N" text label elsewhere — that label is not part of this widget.
class StepTrack extends StatelessWidget {
  const StepTrack({required this.currentStep, this.totalSteps = 5, super.key});

  final int currentStep;
  final int totalSteps;

  _StepState _stateFor(int step) {
    if (step < currentStep) return _StepState.done;
    if (step == currentStep) return _StepState.current;
    return _StepState.upcoming;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FlowColors>()!;
    final children = <Widget>[];

    for (var step = 1; step <= totalSteps; step++) {
      final state = _stateFor(step);
      children.add(_StepNode(state: state, colors: colors));
      if (step != totalSteps) {
        final connectorDone = state != _StepState.upcoming;
        children.add(
          Expanded(
            child: Container(
              height: 4,
              color: connectorDone ? colors.brandPrimary : colors.trackSubtle,
            ),
          ),
        );
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }
}

class _StepNode extends StatelessWidget {
  const _StepNode({required this.state, required this.colors});

  final _StepState state;
  final FlowColors colors;

  @override
  Widget build(BuildContext context) {
    final size = state == _StepState.current ? 22.0 : 14.0;
    final fill = state == _StepState.upcoming ? colors.trackSubtle : colors.brandPrimary;

    return Container(
      key: const ValueKey('step-track-node'),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: fill,
        border: Border.all(color: colors.frameInk, width: 2),
        borderRadius: BorderRadius.circular(state == _StepState.current ? 3 : 2),
      ),
      child: Center(
        child: Container(
          width: state == _StepState.current ? 8 : 4,
          height: state == _StepState.current ? 8 : 4,
          decoration: BoxDecoration(
            color: colors.onPrimary,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run the test to verify it passes**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/design/components/step_track_test.dart
```

Expected: PASS, 3 tests. (If the size-matching assertion in test 2 is
brittle against `Container`'s `constraints` representation, replace it
with `tester.getSize(...)` on the specific node's `Finder` instead — the
intent is "the current node's rendered box is 22x22, others are 14x14."
)

- [ ] **Step 5: Commit**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
dart format lib/core/design/components test/core/design/components
git add lib/core/design/components test/core/design/components
git commit -m "Add CMP-44 StepTrack"
```

---

## Task 20: `CMP-04 QuickAddChip`

**Files:**
- Create: `lib/core/design/components/quick_add_chip.dart`
- Test: `test/core/design/components/quick_add_chip_test.dart`

**Interfaces:**
- Consumes: `FlowColors` (Task 8), `flutter_svg`, `assets/icons/onboarding/icon-droplet.svg` (Task 14)
- Produces: `class QuickAddChip extends StatelessWidget` (`{required int amountMl, required bool selected, required VoidCallback onTap}`)

- [ ] **Step 1: Write the failing test**

```dart
// test/core/design/components/quick_add_chip_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/components/quick_add_chip.dart';

import '../../../support/pump_flow_widget.dart';

void main() {
  testWidgets('renders the amount in millilitres', (tester) async {
    await pumpFlowWidget(
      tester,
      QuickAddChip(amountMl: 350, selected: false, onTap: () {}),
    );

    expect(find.text('350 ML'), findsOneWidget);
  });

  testWidgets('is 56dp tall', (tester) async {
    await pumpFlowWidget(
      tester,
      QuickAddChip(amountMl: 350, selected: false, onTap: () {}),
    );

    expect(tester.getSize(find.byType(QuickAddChip)).height, 56);
  });

  testWidgets('calls onTap when tapped', (tester) async {
    var tapped = false;
    await pumpFlowWidget(
      tester,
      QuickAddChip(amountMl: 350, selected: false, onTap: () => tapped = true),
    );

    await tester.tap(find.byType(QuickAddChip));
    expect(tapped, isTrue);
  });

  testWidgets('renders without throwing when selected', (tester) async {
    await pumpFlowWidget(
      tester,
      QuickAddChip(amountMl: 500, selected: true, onTap: () {}),
    );

    expect(find.text('500 ML'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/design/components/quick_add_chip_test.dart
```

Expected: FAIL — `quick_add_chip.dart` doesn't exist yet.

- [ ] **Step 3: Implement `QuickAddChip`**

```dart
// lib/core/design/components/quick_add_chip.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/flow_theme.dart';
import '../tokens/flow_colors.dart';
import '../tokens/flow_radius.dart';
import '../tokens/flow_typography.dart';

/// CMP-04. 56dp tall, a dedicated 10px radius — NOT radius.pill. The
/// written design-system doc reserved radius.pill for this component,
/// but the actual built chip in Figma uses 10px (see the foundation
/// design spec, Section 6); radius.pill is unused by the current design.
class QuickAddChip extends StatelessWidget {
  const QuickAddChip({
    required this.amountMl,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final int amountMl;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FlowColors>()!;
    final typography = Theme.of(context).extension<FlowTypography>()!;

    final fill = selected ? colors.brandPrimary : colors.surfacePrimary;
    final labelColor = colors.textPrimary;
    final borderWidth = selected ? 3.0 : 2.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        key: const ValueKey('quick-add-chip'),
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: fill,
          border: Border.all(color: colors.frameInk, width: borderWidth),
          borderRadius: BorderRadius.circular(FlowRadius.quickAddChip),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 11,
              height: 14,
              child: SvgPicture.asset('assets/icons/onboarding/icon-droplet.svg'),
            ),
            const SizedBox(width: 4),
            Text(
              '$amountMl ML',
              style: typography.labelGame.copyWith(color: labelColor),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run the test to verify it passes**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/design/components/quick_add_chip_test.dart
```

Expected: PASS, 4 tests.

- [ ] **Step 5: Commit**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
dart format lib/core/design/components test/core/design/components
git add lib/core/design/components test/core/design/components
git commit -m "Add CMP-04 QuickAddChip"
```

---

## Task 21: `CMP-05 SegmentedChoice`

**Files:**
- Create: `lib/core/design/components/segmented_choice.dart`
- Test: `test/core/design/components/segmented_choice_test.dart`

**Interfaces:**
- Consumes: `FlowFrameBox` (Task 15), `FlowColors`/`FlowTypography` (Tasks 8–9)
- Produces: `class SegmentedChoice<T> extends StatelessWidget` (`{required List<T> options, required T selected, required String Function(T) labelBuilder, required ValueChanged<T> onChanged, double segmentHeight = 48}`) — a generic widget covering both the 2-segment `/Unit` (kg/lb, `segmentHeight: 48` → 56dp shell) and 3-segment `/Sex` (`segmentHeight: 56` → 64dp shell) variants from Figma

- [ ] **Step 1: Write the failing test**

```dart
// test/core/design/components/segmented_choice_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/components/segmented_choice.dart';

import '../../../support/pump_flow_widget.dart';

void main() {
  testWidgets('renders a label per option', (tester) async {
    await pumpFlowWidget(
      tester,
      SegmentedChoice<String>(
        options: const ['KG', 'LB'],
        selected: 'KG',
        labelBuilder: (o) => o,
        onChanged: (_) {},
      ),
    );

    expect(find.text('KG'), findsOneWidget);
    expect(find.text('LB'), findsOneWidget);
  });

  testWidgets('the 2-segment /Unit shell is 56dp tall (48dp segment + 4dp padding each side)', (tester) async {
    await pumpFlowWidget(
      tester,
      SizedBox(
        width: 168,
        child: SegmentedChoice<String>(
          options: const ['KG', 'LB'],
          selected: 'KG',
          labelBuilder: (o) => o,
          onChanged: (_) {},
        ),
      ),
    );

    expect(tester.getSize(find.byType(SegmentedChoice<String>)).height, 56);
  });

  testWidgets('the 3-segment /Sex shell is 64dp tall when segmentHeight is 56', (tester) async {
    await pumpFlowWidget(
      tester,
      SizedBox(
        width: 328,
        child: SegmentedChoice<String>(
          options: const ['Female', 'Male', 'Prefer not to say'],
          selected: 'Female',
          labelBuilder: (o) => o,
          onChanged: (_) {},
          segmentHeight: 56,
        ),
      ),
    );

    expect(tester.getSize(find.byType(SegmentedChoice<String>)).height, 64);
  });

  testWidgets('tapping an unselected segment calls onChanged with that option', (tester) async {
    String? changedTo;
    await pumpFlowWidget(
      tester,
      SegmentedChoice<String>(
        options: const ['KG', 'LB'],
        selected: 'KG',
        labelBuilder: (o) => o,
        onChanged: (value) => changedTo = value,
      ),
    );

    await tester.tap(find.text('LB'));
    expect(changedTo, 'LB');
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/design/components/segmented_choice_test.dart
```

Expected: FAIL — `segmented_choice.dart` doesn't exist yet.

- [ ] **Step 3: Implement `SegmentedChoice`**

```dart
// lib/core/design/components/segmented_choice.dart
import 'package:flutter/material.dart';

import '../theme/flow_theme.dart';
import '../tokens/flow_colors.dart';
import '../tokens/flow_typography.dart';
import 'flow_frame_box.dart';

/// CMP-05. Two verified variants: `/Unit` (2 segments, segmentHeight 48
/// -> 56dp shell) and `/Sex` (3 segments, segmentHeight 56 -> 64dp
/// shell, wrapping enabled — a "WRAP FIX" the Figma file itself notes
/// was needed for "Prefer not to say" to stay legible). Selection is
/// three cues: brand fill + 2dp ink frame + a pixel check — never color
/// alone.
class SegmentedChoice<T> extends StatelessWidget {
  const SegmentedChoice({
    required this.options,
    required this.selected,
    required this.labelBuilder,
    required this.onChanged,
    this.segmentHeight = 48,
    super.key,
  });

  final List<T> options;
  final T selected;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onChanged;
  final double segmentHeight;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FlowColors>()!;
    final typography = Theme.of(context).extension<FlowTypography>()!;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfacePrimary,
        border: Border.all(color: colors.frameInk, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          for (final option in options)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: GestureDetector(
                  onTap: () => onChanged(option),
                  child: option == selected
                      ? FlowFrameBox(
                          fill: colors.brandPrimary,
                          frameInk: colors.frameInk,
                          radius: 5,
                          bevelColor: colors.frameBevel,
                          child: SizedBox(
                            height: segmentHeight,
                            child: Center(
                              child: Text(
                                labelBuilder(option).toUpperCase(),
                                textAlign: TextAlign.center,
                                style: typography.buttonGame.copyWith(color: colors.textPrimary),
                              ),
                            ),
                          ),
                        )
                      : SizedBox(
                          height: segmentHeight,
                          child: Center(
                            child: Text(
                              labelBuilder(option).toUpperCase(),
                              textAlign: TextAlign.center,
                              style: typography.buttonGame.copyWith(color: colors.textSecondary),
                            ),
                          ),
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run the test to verify it passes**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/design/components/segmented_choice_test.dart
```

Expected: PASS, 4 tests.

- [ ] **Step 5: Commit**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
dart format lib/core/design/components test/core/design/components
git add lib/core/design/components test/core/design/components
git commit -m "Add CMP-05 SegmentedChoice"
```

---

## Task 22: `CMP-06 ChoiceCard`

**Files:**
- Create: `lib/core/design/components/choice_card.dart`
- Test: `test/core/design/components/choice_card_test.dart`

**Interfaces:**
- Consumes: `FlowColors`/`FlowTypography` (Tasks 8–9), `flutter_svg`, `assets/icons/onboarding/icon-check.svg` (Task 14)
- Produces: `class ChoiceCard extends StatelessWidget` (`{required String title, required String description, required int barsFilled, required bool selected, required VoidCallback onTap}`) — `barsFilled` is 1–5, driving the leading pixel bar-meter

- [ ] **Step 1: Write the failing test**

```dart
// test/core/design/components/choice_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/components/choice_card.dart';

import '../../../support/pump_flow_widget.dart';

void main() {
  testWidgets('renders title and description', (tester) async {
    await pumpFlowWidget(
      tester,
      ChoiceCard(
        title: 'Lightly active',
        description: 'Some walking, light movement most days',
        barsFilled: 2,
        selected: false,
        onTap: () {},
      ),
    );

    expect(find.text('Lightly active'), findsOneWidget);
    expect(find.text('Some walking, light movement most days'), findsOneWidget);
  });

  testWidgets('renders exactly 5 bars in the leading bar-meter', (tester) async {
    await pumpFlowWidget(
      tester,
      ChoiceCard(
        title: 'Lightly active',
        description: 'desc',
        barsFilled: 2,
        selected: false,
        onTap: () {},
      ),
    );

    expect(find.byKey(const ValueKey('choice-card-bar')), findsNWidgets(5));
  });

  testWidgets('is at least 76dp tall', (tester) async {
    await pumpFlowWidget(
      tester,
      SizedBox(
        width: 328,
        child: ChoiceCard(
          title: 'Lightly active',
          description: 'Some walking, light movement most days',
          barsFilled: 2,
          selected: false,
          onTap: () {},
        ),
      ),
    );

    expect(tester.getSize(find.byType(ChoiceCard)).height, greaterThanOrEqualTo(76));
  });

  testWidgets('calls onTap when tapped', (tester) async {
    var tapped = false;
    await pumpFlowWidget(
      tester,
      ChoiceCard(
        title: 'Lightly active',
        description: 'desc',
        barsFilled: 2,
        selected: false,
        onTap: () => tapped = true,
      ),
    );

    await tester.tap(find.byType(ChoiceCard));
    expect(tapped, isTrue);
  });

  testWidgets('renders without throwing when selected', (tester) async {
    await pumpFlowWidget(
      tester,
      ChoiceCard(
        title: 'Lightly active',
        description: 'desc',
        barsFilled: 2,
        selected: true,
        onTap: () {},
      ),
    );

    expect(find.text('Lightly active'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/design/components/choice_card_test.dart
```

Expected: FAIL — `choice_card.dart` doesn't exist yet.

- [ ] **Step 3: Implement `ChoiceCard`**

```dart
// lib/core/design/components/choice_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/flow_theme.dart';
import '../tokens/flow_colors.dart';
import '../tokens/flow_spacing.dart';
import '../tokens/flow_typography.dart';

/// CMP-06. Activity-level row (ONB-05). Min height 76dp. The leading
/// pixel bar-meter (1-5 bars filled) ties the choice to "player stat"
/// language rather than a generic icon. Selected = tinted fill + 3dp
/// frame (thicker, not just recolored) + trailing check-badge — never
/// color alone.
class ChoiceCard extends StatelessWidget {
  const ChoiceCard({
    required this.title,
    required this.description,
    required this.barsFilled,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String title;
  final String description;
  final int barsFilled;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FlowColors>()!;
    final typography = Theme.of(context).extension<FlowTypography>()!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 76),
        padding: const EdgeInsets.symmetric(horizontal: FlowSpacing.md, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? colors.surfaceTinted : colors.surfacePrimary,
          border: Border.all(color: colors.frameInk, width: selected ? 3 : 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _BarMeter(filled: barsFilled, colors: colors),
            const SizedBox(width: FlowSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: typography.titleM.copyWith(color: colors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(description, style: typography.bodyM.copyWith(color: colors.textSecondary)),
                ],
              ),
            ),
            if (selected) ...[
              const SizedBox(width: FlowSpacing.md),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: colors.brandPrimary,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.frameInk, width: 2),
                ),
                padding: const EdgeInsets.all(6),
                child: SvgPicture.asset('assets/icons/onboarding/icon-check.svg'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BarMeter extends StatelessWidget {
  const _BarMeter({required this.filled, required this.colors});

  final int filled;
  final FlowColors colors;

  @override
  Widget build(BuildContext context) {
    const heights = [8.0, 12.0, 16.0, 20.0, 24.0];

    return SizedBox(
      width: 32,
      height: 24,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (var i = 0; i < 5; i++)
            Container(
              key: const ValueKey('choice-card-bar'),
              width: 4,
              height: heights[i],
              decoration: BoxDecoration(
                color: i < filled ? colors.brandPrimary : colors.trackSubtle,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run the test to verify it passes**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/design/components/choice_card_test.dart
```

Expected: PASS, 5 tests.

- [ ] **Step 5: Commit**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
dart format lib/core/design/components test/core/design/components
git add lib/core/design/components test/core/design/components
git commit -m "Add CMP-06 ChoiceCard"
```

---

## Task 23: `CMP-07 IconChoiceTile`

**Files:**
- Create: `lib/core/design/components/icon_choice_tile.dart`
- Test: `test/core/design/components/icon_choice_tile_test.dart`

**Interfaces:**
- Consumes: `FlowColors`/`FlowTypography` (Tasks 8–9)
- Produces: `class IconChoiceTile extends StatelessWidget` (`{required String label, required int level, required bool selected, required VoidCallback onTap}`) — `level` is 1–4, driving the thermometer fill height and color (aqua→gold→orange→coral)

**Missing-asset note:** Figma's `CMP-07` uses a pixel "thermometer" icon
whose fill height *and* color shift with the environment level — but no
`icon-thermometer*.svg` (or equivalent) exists anywhere in
`assets/icons/onboarding/` (confirmed during the Figma verification
pass; see the design spec's Section 10 for the broader onboarding-icon
inventory mismatch). Per the spec's instruction not to fabricate a
missing asset, this task builds a simple `Container`-based thermometer
placeholder (a bulb + column, filled/colored by `level`) instead of an
`SvgPicture`. Flag this to whoever owns the Figma/asset pipeline; swap
`_ThermometerIndicator` for a real `SvgPicture.asset(...)` once the
proper pixel-art asset exists — no other part of this widget's API
needs to change.

- [ ] **Step 1: Write the failing test**

```dart
// test/core/design/components/icon_choice_tile_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/components/icon_choice_tile.dart';

import '../../../support/pump_flow_widget.dart';

void main() {
  testWidgets('renders its label', (tester) async {
    await pumpFlowWidget(
      tester,
      IconChoiceTile(label: 'Warm', level: 2, selected: false, onTap: () {}),
    );

    expect(find.text('Warm'), findsOneWidget);
  });

  testWidgets('is 104dp tall', (tester) async {
    await pumpFlowWidget(
      tester,
      SizedBox(
        width: 154,
        child: IconChoiceTile(label: 'Warm', level: 2, selected: false, onTap: () {}),
      ),
    );

    expect(tester.getSize(find.byType(IconChoiceTile)).height, 104);
  });

  testWidgets('calls onTap when tapped', (tester) async {
    var tapped = false;
    await pumpFlowWidget(
      tester,
      IconChoiceTile(label: 'Warm', level: 2, selected: false, onTap: () => tapped = true),
    );

    await tester.tap(find.byType(IconChoiceTile));
    expect(tapped, isTrue);
  });

  testWidgets('renders without throwing at every level 1-4', (tester) async {
    for (final level in [1, 2, 3, 4]) {
      await pumpFlowWidget(
        tester,
        IconChoiceTile(label: 'Level $level', level: level, selected: false, onTap: () {}),
      );
      expect(find.text('Level $level'), findsOneWidget);
    }
  });

  testWidgets('renders without throwing when selected', (tester) async {
    await pumpFlowWidget(
      tester,
      IconChoiceTile(label: 'Warm', level: 2, selected: true, onTap: () {}),
    );

    expect(find.text('Warm'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/design/components/icon_choice_tile_test.dart
```

Expected: FAIL — `icon_choice_tile.dart` doesn't exist yet.

- [ ] **Step 3: Implement `IconChoiceTile`**

```dart
// lib/core/design/components/icon_choice_tile.dart
import 'package:flutter/material.dart';

import '../theme/flow_theme.dart';
import '../tokens/flow_colors.dart';
import '../tokens/flow_typography.dart';

/// CMP-07. 2x2 grid tile (ONB-06), built at 104dp (Figma's own note:
/// "min 96dp tall per 05 ONB-06; built at 104dp"). Selected = tinted
/// fill + 3dp frame + check badge, same three-cue pattern as CMP-06.
class IconChoiceTile extends StatelessWidget {
  const IconChoiceTile({
    required this.label,
    required this.level,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final int level;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FlowColors>()!;
    final typography = Theme.of(context).extension<FlowTypography>()!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 104,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? colors.surfaceTinted : colors.surfacePrimary,
          border: Border.all(color: colors.frameInk, width: selected ? 3 : 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ThermometerIndicator(level: level),
            const SizedBox(height: 8),
            Text(label, style: typography.titleM.copyWith(color: colors.textPrimary)),
            if (selected)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: colors.brandPrimary,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.frameInk, width: 2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder for the missing thermometer asset — see this task's
/// "Missing-asset note." Fill height and color both move with [level]
/// so temperature reads through two channels, not one.
class _ThermometerIndicator extends StatelessWidget {
  const _ThermometerIndicator({required this.level});

  final int level;

  static const _levelColors = [
    Color(0xFF7FDBFA), // 1: temperate — aqua
    Color(0xFFFFC542), // 2: warm — gold
    Color(0xFFFF9142), // 3: hot — orange
    Color(0xFFFF7A59), // 4: very hot — coral
  ];

  @override
  Widget build(BuildContext context) {
    final color = _levelColors[(level - 1).clamp(0, 3)];
    final fillFraction = level / 4;

    return SizedBox(
      width: 20,
      height: 32,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: fillFraction,
                child: Container(width: 8, color: color),
              ),
            ),
          ),
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run the test to verify it passes**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/design/components/icon_choice_tile_test.dart
```

Expected: PASS, 5 tests.

- [ ] **Step 5: Commit**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
dart format lib/core/design/components test/core/design/components
git add lib/core/design/components test/core/design/components
git commit -m "Add CMP-07 IconChoiceTile (with placeholder thermometer pending real asset)"
```

---

## Task 24: `CMP-08 Pillar`

**Files:**
- Create: `lib/core/design/components/pillar.dart`
- Test: `test/core/design/components/pillar_test.dart`

**Interfaces:**
- Consumes: `FlowColors`/`FlowTypography` (Tasks 8–9), `flutter_svg`, `assets/icons/onboarding/{icon-droplet,icon-chart,icon-book}.svg` (Task 14)
- Produces: `class Pillar extends StatelessWidget` (`{required String iconAsset, required String title, required String description}`) — static, no selection state; three instances (Hydrate/Progress/Learn, per `CPY-012`–`017`) are composed in a column on the welcome screen (Task 32), not by this widget itself

- [ ] **Step 1: Write the failing test**

```dart
// test/core/design/components/pillar_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/components/pillar.dart';

import '../../../support/pump_flow_widget.dart';

void main() {
  testWidgets('renders title, description, and its icon', (tester) async {
    await pumpFlowWidget(
      tester,
      const Pillar(
        iconAsset: 'assets/icons/onboarding/icon-droplet.svg',
        title: 'Hydrate',
        description: 'Know your daily target and track your water.',
      ),
    );

    expect(find.text('Hydrate'), findsOneWidget);
    expect(find.text('Know your daily target and track your water.'), findsOneWidget);
    expect(find.byType(SvgPicture), findsOneWidget);
  });

  testWidgets('is at least 76dp tall', (tester) async {
    await pumpFlowWidget(
      tester,
      SizedBox(
        width: 328,
        child: const Pillar(
          iconAsset: 'assets/icons/onboarding/icon-droplet.svg',
          title: 'Hydrate',
          description: 'Know your daily target and track your water.',
        ),
      ),
    );

    expect(tester.getSize(find.byType(Pillar)).height, greaterThanOrEqualTo(76));
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/design/components/pillar_test.dart
```

Expected: FAIL — `pillar.dart` doesn't exist yet.

- [ ] **Step 3: Implement `Pillar`**

```dart
// lib/core/design/components/pillar.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/flow_theme.dart';
import '../tokens/flow_colors.dart';
import '../tokens/flow_spacing.dart';
import '../tokens/flow_typography.dart';

/// CMP-08. Welcome-screen (ONB-02) value-prop row. Static — no
/// selection state. 28dp leading icon. Icon-to-content mapping used by
/// the welcome screen (Task 32): Hydrate -> icon-droplet, Progress ->
/// icon-chart, Learn -> icon-book.
class Pillar extends StatelessWidget {
  const Pillar({
    required this.iconAsset,
    required this.title,
    required this.description,
    super.key,
  });

  final String iconAsset;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FlowColors>()!;
    final typography = Theme.of(context).extension<FlowTypography>()!;

    return Container(
      constraints: const BoxConstraints(minHeight: 76),
      padding: const EdgeInsets.symmetric(horizontal: FlowSpacing.md, vertical: 14),
      decoration: BoxDecoration(
        color: colors.surfacePrimary,
        border: Border.all(color: colors.frameInk, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(width: 28, height: 28, child: SvgPicture.asset(iconAsset)),
          const SizedBox(width: FlowSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: typography.titleM.copyWith(color: colors.textPrimary)),
                const SizedBox(height: 2),
                Text(description, style: typography.bodyM.copyWith(color: colors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run the test to verify it passes**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/design/components/pillar_test.dart
```

Expected: PASS, 2 tests.

- [ ] **Step 5: Commit**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
dart format lib/core/design/components test/core/design/components
git add lib/core/design/components test/core/design/components
git commit -m "Add CMP-08 Pillar"
```

---

## Task 25: `CMP-10 TextField`

**Files:**
- Create: `lib/core/design/components/flow_text_field.dart`
- Test: `test/core/design/components/flow_text_field_test.dart`

**Interfaces:**
- Consumes: `FlowColors`/`FlowTypography` (Tasks 8–9)
- Produces: `class FlowTextField extends StatelessWidget` (`{required TextEditingController controller, String? errorText, bool numericHero = false, String? hintText, ValueChanged<String>? onChanged}`) — named `FlowTextField` to avoid clashing with Flutter's built-in `TextField`

- [ ] **Step 1: Write the failing test**

```dart
// test/core/design/components/flow_text_field_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/components/flow_text_field.dart';

import '../../../support/pump_flow_widget.dart';

void main() {
  testWidgets('is 56dp tall', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await pumpFlowWidget(
      tester,
      SizedBox(width: 328, child: FlowTextField(controller: controller)),
    );

    expect(tester.getSize(find.byType(FlowTextField)).height, 56);
  });

  testWidgets('typing updates the controller and calls onChanged', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    String? changed;

    await pumpFlowWidget(
      tester,
      FlowTextField(controller: controller, onChanged: (v) => changed = v),
    );

    await tester.enterText(find.byType(FlowTextField), 'Alex');
    expect(controller.text, 'Alex');
    expect(changed, 'Alex');
  });

  testWidgets('shows the error message below the field when errorText is set', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await pumpFlowWidget(
      tester,
      FlowTextField(controller: controller, errorText: 'Age must be between 9 and 120.'),
    );

    expect(find.text('Age must be between 9 and 120.'), findsOneWidget);
  });

  testWidgets('renders without an error message when errorText is null', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await pumpFlowWidget(tester, FlowTextField(controller: controller));

    expect(find.byType(Text), findsNothing);
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/design/components/flow_text_field_test.dart
```

Expected: FAIL — `flow_text_field.dart` doesn't exist yet.

- [ ] **Step 3: Implement `FlowTextField`**

```dart
// lib/core/design/components/flow_text_field.dart
import 'package:flutter/material.dart';

import '../theme/flow_theme.dart';
import '../tokens/flow_colors.dart';
import '../tokens/flow_spacing.dart';
import '../tokens/flow_typography.dart';

/// CMP-10. radius.sm, 2dp border, no depth offset (inputs aren't
/// tappable buttons, so no press affordance). Focused uses brandPrimary
/// stroke; Error uses color.error, with the message rendered separately
/// below in caption + error — never color alone.
class FlowTextField extends StatefulWidget {
  const FlowTextField({
    required this.controller,
    this.errorText,
    this.numericHero = false,
    this.hintText,
    this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final String? errorText;
  final bool numericHero;
  final String? hintText;
  final ValueChanged<String>? onChanged;

  @override
  State<FlowTextField> createState() => _FlowTextFieldState();
}

class _FlowTextFieldState extends State<FlowTextField> {
  final _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() => _focused = _focusNode.hasFocus));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FlowColors>()!;
    final typography = Theme.of(context).extension<FlowTypography>()!;
    final hasError = widget.errorText != null;

    final Color borderColor;
    if (hasError) {
      borderColor = colors.error;
    } else if (_focused) {
      borderColor = colors.brandPrimary;
    } else {
      borderColor = colors.borderStrong;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: FlowSpacing.md),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: colors.surfacePrimary,
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            onChanged: widget.onChanged,
            style: (widget.numericHero ? typography.numericHero : typography.bodyL)
                .copyWith(color: colors.textPrimary),
            decoration: InputDecoration(
              border: InputBorder.none,
              isCollapsed: true,
              hintText: widget.hintText,
              hintStyle: typography.bodyL.copyWith(color: colors.textSecondary),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: FlowSpacing.xs, left: FlowSpacing.xs),
            child: Text(
              widget.errorText!,
              style: typography.caption.copyWith(color: colors.error),
            ),
          ),
      ],
    );
  }
}
```

- [ ] **Step 4: Run the test to verify it passes**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/design/components/flow_text_field_test.dart
```

Expected: PASS, 4 tests.

- [ ] **Step 5: Commit**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
dart format lib/core/design/components test/core/design/components
git add lib/core/design/components test/core/design/components
git commit -m "Add CMP-10 FlowTextField"
```

---

## Task 26: `CMP-11 Slider`

**Files:**
- Create: `lib/core/design/components/flow_slider.dart`
- Test: `test/core/design/components/flow_slider_test.dart`

**Interfaces:**
- Consumes: `FlowColors`/`FlowTypography` (Tasks 8–9)
- Produces: `class FlowSlider extends StatelessWidget` (`{required double value, required double min, required double max, required ValueChanged<double> onChanged, required String Function(double) rangeLabelBuilder, double step = 0.5}`) — named `FlowSlider` to avoid clashing with Flutter's built-in `Slider`

- [ ] **Step 1: Write the failing test**

```dart
// test/core/design/components/flow_slider_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/components/flow_slider.dart';

import '../../../support/pump_flow_widget.dart';

void main() {
  testWidgets('renders the min and max range labels', (tester) async {
    await pumpFlowWidget(
      tester,
      FlowSlider(
        value: 68,
        min: 25,
        max: 250,
        onChanged: (_) {},
        rangeLabelBuilder: (v) => '${v.round()} kg',
      ),
    );

    expect(find.text('25 kg'), findsOneWidget);
    expect(find.text('250 kg'), findsOneWidget);
  });

  testWidgets('exposes a Semantics value for screen readers stepping by 1', (tester) async {
    await pumpFlowWidget(
      tester,
      FlowSlider(
        value: 68,
        min: 25,
        max: 250,
        onChanged: (_) {},
        rangeLabelBuilder: (v) => '${v.round()} kg',
      ),
    );

    final semantics = tester.getSemantics(find.byType(Slider));
    expect(semantics.value, '68 kilograms');
  });

  testWidgets('dragging the underlying Slider calls onChanged', (tester) async {
    double? changed;
    await pumpFlowWidget(
      tester,
      SizedBox(
        width: 328,
        child: FlowSlider(
          value: 68,
          min: 25,
          max: 250,
          onChanged: (v) => changed = v,
          rangeLabelBuilder: (v) => '${v.round()} kg',
        ),
      ),
    );

    await tester.drag(find.byType(Slider), const Offset(50, 0));
    expect(changed, isNotNull);
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/design/components/flow_slider_test.dart
```

Expected: FAIL — `flow_slider.dart` doesn't exist yet.

- [ ] **Step 3: Implement `FlowSlider`**

Built on Flutter's own `Slider` (themed to look like the pixel track via
`SliderThemeData`) rather than a from-scratch gesture handler — this
keeps drag physics, keyboard support, and accessibility free, and the
[Semantics] wrapper below is what actually satisfies CMP-11's
`Semantics(value: "68 kilograms")` requirement:

```dart
// lib/core/design/components/flow_slider.dart
import 'package:flutter/material.dart';

import '../theme/flow_theme.dart';
import '../tokens/flow_colors.dart';
import '../tokens/flow_typography.dart';

/// CMP-11. Range/step come from the caller (e.g. 25-250kg, step 0.5 for
/// the weight slider). The numeric field stays the accessible primary
/// control elsewhere on screen — this slider is an enhancement, exposed
/// to screen readers as "N kilograms" stepping by 1 whole unit.
class FlowSlider extends StatelessWidget {
  const FlowSlider({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.rangeLabelBuilder,
    this.step = 0.5,
    this.unitLabel = 'kilograms',
    super.key,
  });

  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final String Function(double) rangeLabelBuilder;
  final double step;
  final String unitLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FlowColors>()!;
    final typography = Theme.of(context).extension<FlowTypography>()!;
    final divisions = ((max - min) / step).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 12,
            activeTrackColor: colors.brandPrimary,
            inactiveTrackColor: colors.trackDark,
            thumbColor: colors.brandPrimary,
            overlayColor: colors.brandPrimary.withValues(alpha: 0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
          ),
          child: Semantics(
            value: '${value.round()} $unitLabel',
            increasedValue: '${(value + 1).round()} $unitLabel',
            decreasedValue: '${(value - 1).round()} $unitLabel',
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              rangeLabelBuilder(min),
              style: typography.labelGame.copyWith(color: colors.textSecondary),
            ),
            Text(
              rangeLabelBuilder(max),
              style: typography.labelGame.copyWith(color: colors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: Run the test to verify it passes**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/design/components/flow_slider_test.dart
```

Expected: PASS, 3 tests.

- [ ] **Step 5: Commit**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
dart format lib/core/design/components test/core/design/components
git add lib/core/design/components test/core/design/components
git commit -m "Add CMP-11 FlowSlider"
```

---

## Task 27: `CMP-12 CheckRow`

**Files:**
- Create: `lib/core/design/components/check_row.dart`
- Test: `test/core/design/components/check_row_test.dart`

**Interfaces:**
- Consumes: `FlowColors`/`FlowTypography` (Tasks 8–9), `flutter_svg`, `assets/icons/onboarding/icon-check.svg` (Task 14)
- Produces: `class CheckRow extends StatelessWidget` (`{required String label, required bool checked, required ValueChanged<bool> onChanged}`)

- [ ] **Step 1: Write the failing test**

```dart
// test/core/design/components/check_row_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/components/check_row.dart';

import '../../../support/pump_flow_widget.dart';

void main() {
  testWidgets('renders its label', (tester) async {
    await pumpFlowWidget(
      tester,
      CheckRow(label: "I'm pregnant", checked: false, onChanged: (_) {}),
    );

    expect(find.text("I'm pregnant"), findsOneWidget);
  });

  testWidgets('is 48dp tall (full-row hit target)', (tester) async {
    await pumpFlowWidget(
      tester,
      SizedBox(
        width: 328,
        child: CheckRow(label: "I'm pregnant", checked: false, onChanged: (_) {}),
      ),
    );

    expect(tester.getSize(find.byType(CheckRow)).height, 48);
  });

  testWidgets('shows the check icon only when checked', (tester) async {
    await pumpFlowWidget(
      tester,
      CheckRow(label: "I'm pregnant", checked: false, onChanged: (_) {}),
    );
    expect(find.byType(SvgPicture), findsNothing);

    await pumpFlowWidget(
      tester,
      CheckRow(label: "I'm pregnant", checked: true, onChanged: (_) {}),
    );
    expect(find.byType(SvgPicture), findsOneWidget);
  });

  testWidgets('tapping toggles via onChanged with the opposite value', (tester) async {
    bool? newValue;
    await pumpFlowWidget(
      tester,
      CheckRow(label: "I'm pregnant", checked: false, onChanged: (v) => newValue = v),
    );

    await tester.tap(find.byType(CheckRow));
    expect(newValue, isTrue);
  });

  testWidgets('exposes true checkbox Semantics', (tester) async {
    await pumpFlowWidget(
      tester,
      CheckRow(label: "I'm pregnant", checked: true, onChanged: (_) {}),
    );

    final semantics = tester.getSemantics(find.byType(CheckRow));
    expect(semantics.hasFlag(SemanticsFlag.hasCheckedState), isTrue);
    expect(semantics.hasFlag(SemanticsFlag.isChecked), isTrue);
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/design/components/check_row_test.dart
```

Expected: FAIL — `check_row.dart` doesn't exist yet.

- [ ] **Step 3: Implement `CheckRow`**

```dart
// lib/core/design/components/check_row.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/flow_theme.dart';
import '../tokens/flow_colors.dart';
import '../tokens/flow_spacing.dart';
import '../tokens/flow_typography.dart';

/// CMP-12. 48dp tall (full-row hit target), true checkbox semantics.
/// Checked = brand.primary fill + pixel check icon + 2dp frame — three
/// cues, matching the unit-toggle and step-track pattern rather than
/// color alone.
class CheckRow extends StatelessWidget {
  const CheckRow({
    required this.label,
    required this.checked,
    required this.onChanged,
    super.key,
  });

  final String label;
  final bool checked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FlowColors>()!;
    final typography = Theme.of(context).extension<FlowTypography>()!;

    return Semantics(
      checked: checked,
      child: GestureDetector(
        onTap: () => onChanged(!checked),
        child: SizedBox(
          height: 48,
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: checked ? colors.brandPrimary : colors.surfacePrimary,
                  border: Border.all(color: colors.frameInk, width: 2),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: checked
                    ? SvgPicture.asset(
                        'assets/icons/onboarding/icon-check.svg',
                        width: 14,
                        height: 10,
                      )
                    : null,
              ),
              const SizedBox(width: FlowSpacing.smMd),
              Text(label, style: typography.bodyL.copyWith(color: colors.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run the test to verify it passes**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/design/components/check_row_test.dart
```

Expected: PASS, 5 tests.

- [ ] **Step 5: Commit**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
dart format lib/core/design/components test/core/design/components
git add lib/core/design/components test/core/design/components
git commit -m "Add CMP-12 CheckRow"
```

---

## Task 28: `CMP-13 InfoCard`

**Files:**
- Create: `lib/core/design/components/info_card.dart`
- Test: `test/core/design/components/info_card_test.dart`

**Interfaces:**
- Consumes: `FlowColors`/`FlowTypography` (Tasks 8–9), `flutter_svg`, `assets/icons/onboarding/{icon-info,icon-info-filled}.svg` (Task 14)
- Produces: `class InfoCard extends StatelessWidget` (`{required String message, InfoCardKind kind = InfoCardKind.info}`), `enum InfoCardKind { info, caution }`

**Bug fix, not a faithful reproduction:** the real Figma export for the
`Caution` variant sets its text color to the same value as its
background fill (`warning` on `warning`), making the message invisible.
This implementation uses the evidently-intended tinted pattern instead
(`warningSurface` background, `warning` text — matching how `Info`
itself pairs `infoSurface`/`info`) per the design spec's Section 10.

- [ ] **Step 1: Write the failing test**

```dart
// test/core/design/components/info_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/components/info_card.dart';
import 'package:flow/core/design/tokens/flow_colors.dart';

import '../../../support/pump_flow_widget.dart';

void main() {
  testWidgets('renders its message', (tester) async {
    await pumpFlowWidget(
      tester,
      const InfoCard(message: 'Hydration needs vary from person to person.'),
    );

    expect(find.text('Hydration needs vary from person to person.'), findsOneWidget);
  });

  testWidgets('Info kind uses infoSurface background', (tester) async {
    await pumpFlowWidget(
      tester,
      const InfoCard(message: 'msg', kind: InfoCardKind.info),
    );

    final container = tester.widget<Container>(find.byType(Container).first);
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, FlowColors.light.infoSurface);
  });

  testWidgets('Caution kind uses warningSurface background with legible warning text (bug fix, not the raw Figma export)', (tester) async {
    await pumpFlowWidget(
      tester,
      const InfoCard(message: "That's quite high.", kind: InfoCardKind.caution),
    );

    final container = tester.widget<Container>(find.byType(Container).first);
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, FlowColors.light.warningSurface);

    final text = tester.widget<Text>(find.text("That's quite high."));
    expect(text.style!.color, FlowColors.light.warning);
    expect(text.style!.color, isNot(decoration.color));
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/design/components/info_card_test.dart
```

Expected: FAIL — `info_card.dart` doesn't exist yet.

- [ ] **Step 3: Implement `InfoCard`**

```dart
// lib/core/design/components/info_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/flow_theme.dart';
import '../tokens/flow_colors.dart';
import '../tokens/flow_spacing.dart';
import '../tokens/flow_typography.dart';

enum InfoCardKind { info, caution }

/// CMP-13. Non-blocking notice, two kinds (not three — the written
/// design-system summary said info/warning/error, Figma has exactly
/// two). Icon + colored text together carry the meaning, never color
/// alone.
class InfoCard extends StatelessWidget {
  const InfoCard({required this.message, this.kind = InfoCardKind.info, super.key});

  final String message;
  final InfoCardKind kind;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FlowColors>()!;
    final typography = Theme.of(context).extension<FlowTypography>()!;
    final isCaution = kind == InfoCardKind.caution;

    final background = isCaution ? colors.warningSurface : colors.infoSurface;
    final foreground = isCaution ? colors.warning : colors.info;
    final iconAsset = isCaution
        ? 'assets/icons/onboarding/icon-info-filled.svg'
        : 'assets/icons/onboarding/icon-info.svg';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: FlowSpacing.md, vertical: FlowSpacing.smMd),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 20, height: 26, child: SvgPicture.asset(iconAsset)),
          const SizedBox(width: FlowSpacing.smMd),
          Expanded(
            child: Text(message, style: typography.bodyM.copyWith(color: foreground)),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run the test to verify it passes**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/design/components/info_card_test.dart
```

Expected: PASS, 3 tests.

- [ ] **Step 5: Commit**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
dart format lib/core/design/components test/core/design/components
git add lib/core/design/components test/core/design/components
git commit -m "Add CMP-13 InfoCard (fixes the Caution-variant contrast bug found in Figma)"
```

---

## Task 29: `CMP-14 SettingRow`

**Files:**
- Create: `lib/core/design/components/setting_row.dart`
- Test: `test/core/design/components/setting_row_test.dart`

**Interfaces:**
- Consumes: `FlowColors`/`FlowTypography` (Tasks 8–9), `flutter_svg`, `assets/icons/onboarding/icon-chevron-left.svg` (Task 14)
- Produces: `class SettingRow extends StatelessWidget` (`{required String label, required String value, required VoidCallback onTap}`)

- [ ] **Step 1: Write the failing test**

```dart
// test/core/design/components/setting_row_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/components/setting_row.dart';

import '../../../support/pump_flow_widget.dart';

void main() {
  testWidgets('renders the label and value', (tester) async {
    await pumpFlowWidget(
      tester,
      SettingRow(label: 'Start', value: '08:00', onTap: () {}),
    );

    expect(find.text('Start'), findsOneWidget);
    expect(find.text('08:00'), findsOneWidget);
  });

  testWidgets('is 56dp tall', (tester) async {
    await pumpFlowWidget(
      tester,
      SizedBox(
        width: 328,
        child: SettingRow(label: 'Start', value: '08:00', onTap: () {}),
      ),
    );

    expect(tester.getSize(find.byType(SettingRow)).height, 56);
  });

  testWidgets('calls onTap when tapped', (tester) async {
    var tapped = false;
    await pumpFlowWidget(
      tester,
      SettingRow(label: 'Start', value: '08:00', onTap: () => tapped = true),
    );

    await tester.tap(find.byType(SettingRow));
    expect(tapped, isTrue);
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/design/components/setting_row_test.dart
```

Expected: FAIL — `setting_row.dart` doesn't exist yet.

- [ ] **Step 3: Implement `SettingRow`**

```dart
// lib/core/design/components/setting_row.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/flow_theme.dart';
import '../tokens/flow_colors.dart';
import '../tokens/flow_spacing.dart';
import '../tokens/flow_typography.dart';

/// CMP-14. 56dp row, opens a native time picker or interval sheet
/// (wiring is the caller's job via [onTap]). Carries the full pixel
/// frame treatment, not a plain chevron row. The chevron reuses
/// CMP-42's chevron-left asset, rotated 180 degrees — one icon file
/// across all of onboarding, per the Figma file's own note.
class SettingRow extends StatelessWidget {
  const SettingRow({
    required this.label,
    required this.value,
    required this.onTap,
    super.key,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FlowColors>()!;
    final typography = Theme.of(context).extension<FlowTypography>()!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: FlowSpacing.md),
        decoration: BoxDecoration(
          color: colors.surfacePrimary,
          border: Border.all(color: colors.frameInk, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(label, style: typography.bodyL.copyWith(color: colors.textPrimary)),
            ),
            Text(value, style: typography.bodyL.copyWith(color: colors.textSecondary)),
            const SizedBox(width: FlowSpacing.sm),
            Transform.rotate(
              angle: pi,
              child: SizedBox(
                width: 14,
                height: 22,
                child: SvgPicture.asset('assets/icons/onboarding/icon-chevron-left.svg'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run the test to verify it passes**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/design/components/setting_row_test.dart
```

Expected: PASS, 3 tests.

- [ ] **Step 5: Commit**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
dart format lib/core/design/components test/core/design/components
git add lib/core/design/components test/core/design/components
git commit -m "Add CMP-14 SettingRow"
```

---

## Task 30: `CMP-15 DayToggle`

**Files:**
- Create: `lib/core/design/components/day_toggle.dart`
- Test: `test/core/design/components/day_toggle_test.dart`

**Interfaces:**
- Consumes: `FlowColors`/`FlowTypography` (Tasks 8–9)
- Produces: `class DayToggle extends StatelessWidget` (`{required String dayLetter, required bool selected, required VoidCallback onTap}`)

- [ ] **Step 1: Write the failing test**

```dart
// test/core/design/components/day_toggle_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/components/day_toggle.dart';

import '../../../support/pump_flow_widget.dart';

void main() {
  testWidgets('renders the day letter', (tester) async {
    await pumpFlowWidget(
      tester,
      DayToggle(dayLetter: 'M', selected: true, onTap: () {}),
    );

    expect(find.text('M'), findsOneWidget);
  });

  testWidgets('is a 40dp circle', (tester) async {
    await pumpFlowWidget(
      tester,
      DayToggle(dayLetter: 'M', selected: true, onTap: () {}),
    );

    expect(tester.getSize(find.byType(DayToggle)), const Size(40, 40));
  });

  testWidgets('calls onTap when tapped', (tester) async {
    var tapped = false;
    await pumpFlowWidget(
      tester,
      DayToggle(dayLetter: 'M', selected: false, onTap: () => tapped = true),
    );

    await tester.tap(find.byType(DayToggle));
    expect(tapped, isTrue);
  });

  testWidgets('renders without throwing when off', (tester) async {
    await pumpFlowWidget(
      tester,
      DayToggle(dayLetter: 'M', selected: false, onTap: () {}),
    );

    expect(find.text('M'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/design/components/day_toggle_test.dart
```

Expected: FAIL — `day_toggle.dart` doesn't exist yet.

- [ ] **Step 3: Implement `DayToggle`**

```dart
// lib/core/design/components/day_toggle.dart
import 'package:flutter/material.dart';

import '../theme/flow_theme.dart';
import '../tokens/flow_colors.dart';
import '../tokens/flow_typography.dart';

/// CMP-15. 40dp circle, single-letter day label. On = brand.primary
/// fill + 2dp frame.ink border + navy label.
class DayToggle extends StatelessWidget {
  const DayToggle({
    required this.dayLetter,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String dayLetter;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<FlowColors>()!;
    final typography = Theme.of(context).extension<FlowTypography>()!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? colors.brandPrimary : colors.surfacePrimary,
          shape: BoxShape.circle,
          border: Border.all(color: colors.frameInk, width: 2),
        ),
        child: Text(
          dayLetter.toUpperCase(),
          style: typography.labelGame.copyWith(
            color: selected ? colors.textPrimary : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run the test to verify it passes**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/core/design/components/day_toggle_test.dart
```

Expected: PASS, 4 tests.

- [ ] **Step 5: Commit**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
dart format lib/core/design/components test/core/design/components
git add lib/core/design/components test/core/design/components
git commit -m "Add CMP-15 DayToggle"
```

---

## Task 31: Redirect gate logic (`resolveRedirect`)

**Files:**
- Create: `lib/app/router/app_redirect.dart`
- Test: `test/app/router/app_redirect_test.dart`

**Interfaces:**
- Consumes: nothing (pure function, no Riverpod/widget dependency — kept
  separately testable from the `GoRouter` wiring itself)
- Produces: `String? resolveRedirect({required bool databaseHealthy, required bool onboardingComplete, required String location})`

- [ ] **Step 1: Write the failing test**

```dart
// test/app/router/app_redirect_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/app/router/app_redirect.dart';

void main() {
  test('redirects to /recovery when the database failed to open, regardless of location', () {
    expect(
      resolveRedirect(databaseHealthy: false, onboardingComplete: true, location: '/home'),
      '/recovery',
    );
    expect(
      resolveRedirect(databaseHealthy: false, onboardingComplete: false, location: '/onboarding/welcome'),
      '/recovery',
    );
  });

  test('redirects to /onboarding/welcome when onboarding is incomplete and not already there', () {
    expect(
      resolveRedirect(databaseHealthy: true, onboardingComplete: false, location: '/home'),
      '/onboarding/welcome',
    );
  });

  test('does not redirect when onboarding is incomplete and already under /onboarding', () {
    expect(
      resolveRedirect(databaseHealthy: true, onboardingComplete: false, location: '/onboarding/weight'),
      isNull,
    );
  });

  test('redirects to /home when onboarding is complete but location is under /onboarding', () {
    expect(
      resolveRedirect(databaseHealthy: true, onboardingComplete: true, location: '/onboarding/welcome'),
      '/home',
    );
  });

  test('does not redirect when onboarding is complete and location is outside /onboarding', () {
    expect(
      resolveRedirect(databaseHealthy: true, onboardingComplete: true, location: '/progress'),
      isNull,
    );
  });

  test('/recovery takes priority over the onboarding rules', () {
    expect(
      resolveRedirect(databaseHealthy: false, onboardingComplete: true, location: '/onboarding/welcome'),
      '/recovery',
    );
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/app/router/app_redirect_test.dart
```

Expected: FAIL — `app_redirect.dart` doesn't exist yet.

- [ ] **Step 3: Implement `resolveRedirect`**

```dart
// lib/app/router/app_redirect.dart

/// The router's global redirect gate, per 04-user-flows.md §4.1. Kept
/// as a pure function (no BuildContext/Ref) so it's trivially unit
/// tested without standing up a GoRouter or widget tree.
String? resolveRedirect({
  required bool databaseHealthy,
  required bool onboardingComplete,
  required String location,
}) {
  if (!databaseHealthy) {
    return '/recovery';
  }

  final underOnboarding = location.startsWith('/onboarding');

  if (!onboardingComplete && !underOnboarding) {
    return '/onboarding/welcome';
  }

  if (onboardingComplete && underOnboarding) {
    return '/home';
  }

  return null;
}
```

- [ ] **Step 4: Run the test to verify it passes**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/app/router/app_redirect_test.dart
```

Expected: PASS, 6 tests.

- [ ] **Step 5: Commit**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
dart format lib/app/router test/app/router
git add lib/app/router test/app/router
git commit -m "Add pure resolveRedirect function for the router's redirect gate"
```

---

## Task 32: Onboarding placeholder screens + router wiring

**Files:**
- Create: `lib/features/onboarding/presentation/splash_page.dart`
- Create: `lib/features/onboarding/presentation/welcome_page.dart`
- Create: `lib/features/onboarding/presentation/basics_page.dart`
- Create: `lib/features/onboarding/presentation/weight_page.dart`
- Create: `lib/features/onboarding/presentation/activity_page.dart`
- Create: `lib/features/onboarding/presentation/environment_page.dart`
- Create: `lib/features/onboarding/presentation/target_page.dart`
- Create: `lib/features/onboarding/presentation/reminders_page.dart`
- Modify: `lib/app/router/app_router.dart` (replace the Task 1 placeholder with the real redirect + onboarding routes)
- Test: `test/app/router/app_router_test.dart`

**Interfaces:**
- Consumes: `resolveRedirect` (Task 31), `onboardingCompleteProvider`/`databaseHealthyProvider` (Task 13)
- Produces: 8 placeholder page widgets (each `{super.key}`-only, no params yet); `appRouterProvider` now serves `/`, `/onboarding/welcome`, `/onboarding/basics`, `/onboarding/weight`, `/onboarding/activity`, `/onboarding/environment`, `/onboarding/target`, `/onboarding/reminders`

- [ ] **Step 1: Write the 8 placeholder screens**

Each follows the same minimal shape — a titled `Scaffold`, no real UI:

```dart
// lib/features/onboarding/presentation/splash_page.dart
import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('FLOW')));
  }
}
```

```dart
// lib/features/onboarding/presentation/welcome_page.dart
import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Welcome')), body: const SizedBox());
  }
}
```

```dart
// lib/features/onboarding/presentation/basics_page.dart
import 'package:flutter/material.dart';

class BasicsPage extends StatelessWidget {
  const BasicsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Basics')), body: const SizedBox());
  }
}
```

```dart
// lib/features/onboarding/presentation/weight_page.dart
import 'package:flutter/material.dart';

class WeightPage extends StatelessWidget {
  const WeightPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Weight')), body: const SizedBox());
  }
}
```

```dart
// lib/features/onboarding/presentation/activity_page.dart
import 'package:flutter/material.dart';

class ActivityPage extends StatelessWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Activity Level')), body: const SizedBox());
  }
}
```

```dart
// lib/features/onboarding/presentation/environment_page.dart
import 'package:flutter/material.dart';

class EnvironmentPage extends StatelessWidget {
  const EnvironmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Environment')), body: const SizedBox());
  }
}
```

```dart
// lib/features/onboarding/presentation/target_page.dart
import 'package:flutter/material.dart';

class TargetPage extends StatelessWidget {
  const TargetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Suggested Target')), body: const SizedBox());
  }
}
```

```dart
// lib/features/onboarding/presentation/reminders_page.dart
import 'package:flutter/material.dart';

class RemindersPage extends StatelessWidget {
  const RemindersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Reminder Setup')), body: const SizedBox());
  }
}
```

- [ ] **Step 2: Write the failing router test**

```dart
// test/app/router/app_router_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/app/router/app_router.dart';
import 'package:flow/core/preferences/onboarding_provider.dart';
import 'package:flow/core/database/database_provider.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester, {required bool onboardingComplete}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingCompleteProvider.overrideWithValue(onboardingComplete),
          databaseHealthyProvider.overrideWithValue(true),
        ],
        child: Consumer(
          builder: (context, ref, _) => MaterialApp.router(routerConfig: ref.watch(appRouterProvider)),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a new user (onboarding incomplete) lands on the Welcome screen', (tester) async {
    await pumpApp(tester, onboardingComplete: false);

    expect(find.text('Welcome'), findsOneWidget);
  });

  testWidgets('a returning user (onboarding complete) is redirected away from /onboarding routes', (tester) async {
    await pumpApp(tester, onboardingComplete: true);

    // /home doesn't exist until Task 33 — for now we only assert we did
    // NOT land on an onboarding screen, since the redirect fires before
    // Task 33 adds a real destination.
    expect(find.text('Welcome'), findsNothing);
  });
}
```

- [ ] **Step 3: Run the test to verify it fails**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/app/router/app_router_test.dart
```

Expected: FAIL — `app_router.dart` still has the Task 1 minimal placeholder with no redirect logic or onboarding routes.

- [ ] **Step 4: Rewrite `app_router.dart` with the real redirect gate and onboarding routes**

```dart
// lib/app/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/database/database_provider.dart';
import '../../core/preferences/onboarding_provider.dart';
import '../../features/onboarding/presentation/activity_page.dart';
import '../../features/onboarding/presentation/basics_page.dart';
import '../../features/onboarding/presentation/environment_page.dart';
import '../../features/onboarding/presentation/reminders_page.dart';
import '../../features/onboarding/presentation/splash_page.dart';
import '../../features/onboarding/presentation/target_page.dart';
import '../../features/onboarding/presentation/weight_page.dart';
import '../../features/onboarding/presentation/welcome_page.dart';
import 'app_redirect.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final databaseHealthy = ref.read(databaseHealthyProvider);
      final onboardingComplete = ref.read(onboardingCompleteProvider);

      return resolveRedirect(
        databaseHealthy: databaseHealthy,
        onboardingComplete: onboardingComplete,
        location: state.matchedLocation,
      );
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/onboarding/welcome',
        builder: (context, state) => const WelcomePage(),
      ),
      GoRoute(
        path: '/onboarding/basics',
        builder: (context, state) => const BasicsPage(),
      ),
      GoRoute(
        path: '/onboarding/weight',
        builder: (context, state) => const WeightPage(),
      ),
      GoRoute(
        path: '/onboarding/activity',
        builder: (context, state) => const ActivityPage(),
      ),
      GoRoute(
        path: '/onboarding/environment',
        builder: (context, state) => const EnvironmentPage(),
      ),
      GoRoute(
        path: '/onboarding/target',
        builder: (context, state) => const TargetPage(),
      ),
      GoRoute(
        path: '/onboarding/reminders',
        builder: (context, state) => const RemindersPage(),
      ),
    ],
  );
}
```

- [ ] **Step 5: Run codegen and the test to verify it passes**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
dart run build_runner build --delete-conflicting-outputs
flutter test test/app/router/app_router_test.dart
```

Expected: PASS, 2 tests. (The second test currently only asserts we
*left* the onboarding welcome screen — GoRouter will throw a "no route"
error for `/home` until Task 33 adds it. If that error surfaces as a
test failure rather than being silently swallowed by `pumpAndSettle`,
change the second test's assertion to
`expect(tester.takeException(), isNotNull);` instead, documenting that
`/home` is intentionally not wired up yet.)

- [ ] **Step 6: Commit**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
dart format lib/features/onboarding lib/app/router test/app/router
git add lib/features/onboarding lib/app/router test/app/router
git commit -m "Add onboarding placeholder screens and wire the real redirect gate"
```

---

## Task 33: 4-tab shell + root placeholder screens

**Files:**
- Create: `lib/features/hydration/presentation/home_page.dart`
- Create: `lib/features/hydration/presentation/progress_page.dart`
- Create: `lib/features/gamification/presentation/awards_page.dart`
- Create: `lib/features/settings/presentation/profile_page.dart`
- Modify: `lib/app/main_shell.dart` (replace with a `NavigationBar`-based 4-tab shell)
- Modify: `lib/app/router/app_router.dart` (add the `StatefulShellRoute.indexedStack` with 4 branches)
- Delete: `lib/core/widgets/bottom_navigation/` (superseded by `NavigationBar`, see rationale below)
- Modify: `lib/l10n/app_en.arb` (add `navProgress`, `navAwards`; keep existing `navHome`, `navProfile`)
- Test: `test/app/main_shell_test.dart`

**Interfaces:**
- Consumes: `appRouterProvider` (Task 32), `AppLocalizations` (existing `lib/l10n/generated/`)
- Produces: 4 root placeholder pages; `MainShell` widget (`{required StatefulNavigationShell navigationShell}`)

**Rationale for replacing `core/widgets/bottom_navigation/`:** that folder
predates this plan and its exact API wasn't part of the verified spec —
rather than risk a foundation task silently depending on an unverified
legacy widget's behavior, this task uses Flutter's built-in `NavigationBar`
(Material 3, no extra dependency, styled through `FlowTheme`) and removes
the now-unused custom folder to avoid leaving dead code behind.

- [ ] **Step 1: Add the two missing localization keys**

Open `lib/l10n/app_en.arb` and add, alongside the existing `navHome`/
`navProfile` keys:

```json
  "navProgress": "Progress",
  "navAwards": "Awards",
```

- [ ] **Step 2: Regenerate localization and write the 4 root placeholder screens**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter gen-l10n
```

```dart
// lib/features/hydration/presentation/home_page.dart
import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(appBar: AppBar(title: Text(loc.navHome)), body: const SizedBox());
  }
}
```

```dart
// lib/features/hydration/presentation/progress_page.dart
import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(appBar: AppBar(title: Text(loc.navProgress)), body: const SizedBox());
  }
}
```

```dart
// lib/features/gamification/presentation/awards_page.dart
import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

class AwardsPage extends StatelessWidget {
  const AwardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(appBar: AppBar(title: Text(loc.navAwards)), body: const SizedBox());
  }
}
```

```dart
// lib/features/settings/presentation/profile_page.dart
import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(appBar: AppBar(title: Text(loc.navProfile)), body: const SizedBox());
  }
}
```

- [ ] **Step 3: Delete the superseded bottom-navigation folder**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
rm -rf lib/core/widgets/bottom_navigation
```

- [ ] **Step 4: Write the failing shell test**

```dart
// test/app/main_shell_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/app/router/app_router.dart';
import 'package:flow/core/database/database_provider.dart';
import 'package:flow/core/preferences/onboarding_provider.dart';

void main() {
  testWidgets('a returning user lands on Home with all 4 tabs visible', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingCompleteProvider.overrideWithValue(true),
          databaseHealthyProvider.overrideWithValue(true),
        ],
        child: Consumer(
          builder: (context, ref, _) => MaterialApp.router(routerConfig: ref.watch(appRouterProvider)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('Awards'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('tapping the Progress tab navigates to the Progress screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingCompleteProvider.overrideWithValue(true),
          databaseHealthyProvider.overrideWithValue(true),
        ],
        child: Consumer(
          builder: (context, ref, _) => MaterialApp.router(routerConfig: ref.watch(appRouterProvider)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(NavigationDestination, 'Progress'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Progress'), findsOneWidget);
  });
}
```

- [ ] **Step 5: Run the test to verify it fails**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/app/main_shell_test.dart
```

Expected: FAIL — `/home` and the shell aren't wired into the router yet.

- [ ] **Step 6: Rewrite `lib/app/main_shell.dart`**

```dart
// lib/app/main_shell.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/generated/app_localizations.dart';

class MainShell extends StatelessWidget {
  const MainShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex);
        },
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_rounded), label: loc.navHome),
          NavigationDestination(icon: const Icon(Icons.show_chart_rounded), label: loc.navProgress),
          NavigationDestination(icon: const Icon(Icons.emoji_events_rounded), label: loc.navAwards),
          NavigationDestination(icon: const Icon(Icons.person_rounded), label: loc.navProfile),
        ],
      ),
    );
  }
}
```

- [ ] **Step 7: Add the `StatefulShellRoute` to `app_router.dart`**

Add these imports alongside the existing onboarding-page imports:

```dart
import '../../features/gamification/presentation/awards_page.dart';
import '../../features/hydration/presentation/home_page.dart';
import '../../features/hydration/presentation/progress_page.dart';
import '../../features/settings/presentation/profile_page.dart';
import '../main_shell.dart';
```

Then append this route to the `routes:` list, after the
`/onboarding/reminders` route:

```dart
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/home', builder: (context, state) => const HomePage())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/progress', builder: (context, state) => const ProgressPage())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/awards', builder: (context, state) => const AwardsPage())],
          ),
          StatefulShellBranch(
            routes: [GoRoute(path: '/profile', builder: (context, state) => const ProfilePage())],
          ),
        ],
      ),
```

- [ ] **Step 8: Run the test to verify it passes**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/app/main_shell_test.dart
flutter test test/app/router/app_router_test.dart
```

Expected: PASS on both files — the second test from Task 32 (returning
user leaves onboarding) now has a real `/home` destination to land on;
revert its assertion back to
`expect(find.widgetWithText(AppBar, 'Home'), findsOneWidget);` if you
had changed it to an exception check in Task 32's Step 5.

- [ ] **Step 9: Commit**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
dart format lib/features lib/app lib/l10n test/app
git add lib/features lib/app lib/l10n test/app
git commit -m "Add 4-tab shell (Home/Progress/Awards/Profile) with root placeholder screens"
```

---

## Task 34: Pushed placeholder screens, recovery screen, and final route wiring

**Files:**
- Create: `lib/features/hydration/presentation/add_water_page.dart`
- Create: `lib/features/trivia/presentation/trivia_page.dart`
- Create: `lib/features/hydration/presentation/day_detail_page.dart`
- Create: `lib/features/gamification/presentation/achievement_detail_page.dart`
- Create: `lib/features/hydration/presentation/target_settings_page.dart`
- Create: `lib/features/reminders/presentation/reminder_settings_page.dart`
- Create: `lib/features/settings/presentation/general_settings_page.dart`
- Create: `lib/features/settings/presentation/about_page.dart`
- Create: `lib/features/onboarding/presentation/recovery_page.dart`
- Modify: `lib/app/router/app_router.dart` (add the 9 remaining routes)
- Test: `test/app/router/app_router_pushed_routes_test.dart`

**Interfaces:**
- Consumes: `appRouterProvider` (Tasks 32–33)
- Produces: every route from the design spec's Section 7 route table now exists — `/home/add`, `/home/trivia`, `/progress/day/:date`, `/awards/:achievementId`, `/profile/target`, `/profile/reminders`, `/profile/settings`, `/profile/settings/about`, `/recovery`

- [ ] **Step 1: Write the 9 placeholder screens**

```dart
// lib/features/hydration/presentation/add_water_page.dart
import 'package:flutter/material.dart';

class AddWaterPage extends StatelessWidget {
  const AddWaterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Add Water')), body: const SizedBox());
  }
}
```

```dart
// lib/features/trivia/presentation/trivia_page.dart
import 'package:flutter/material.dart';

class TriviaPage extends StatelessWidget {
  const TriviaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Trivia')), body: const SizedBox());
  }
}
```

```dart
// lib/features/hydration/presentation/day_detail_page.dart
import 'package:flutter/material.dart';

class DayDetailPage extends StatelessWidget {
  const DayDetailPage({required this.date, super.key});

  final String date;

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(date)), body: const SizedBox());
  }
}
```

```dart
// lib/features/gamification/presentation/achievement_detail_page.dart
import 'package:flutter/material.dart';

class AchievementDetailPage extends StatelessWidget {
  const AchievementDetailPage({required this.achievementId, super.key});

  final String achievementId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Achievement')), body: const SizedBox());
  }
}
```

```dart
// lib/features/hydration/presentation/target_settings_page.dart
import 'package:flutter/material.dart';

class TargetSettingsPage extends StatelessWidget {
  const TargetSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Hydration Target')), body: const SizedBox());
  }
}
```

```dart
// lib/features/reminders/presentation/reminder_settings_page.dart
import 'package:flutter/material.dart';

class ReminderSettingsPage extends StatelessWidget {
  const ReminderSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Reminders')), body: const SizedBox());
  }
}
```

```dart
// lib/features/settings/presentation/general_settings_page.dart
import 'package:flutter/material.dart';

class GeneralSettingsPage extends StatelessWidget {
  const GeneralSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Settings')), body: const SizedBox());
  }
}
```

```dart
// lib/features/settings/presentation/about_page.dart
import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('About FLOW')), body: const SizedBox());
  }
}
```

```dart
// lib/features/onboarding/presentation/recovery_page.dart
import 'package:flutter/material.dart';

/// ERR-01. Reached when the database fails to open — offers Import or
/// Reset in a later phase; this foundation pass only needs the
/// placeholder destination to exist so the redirect gate has somewhere
/// real to send the user.
class RecoveryPage extends StatelessWidget {
  const RecoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Data Recovery')), body: const SizedBox());
  }
}
```

- [ ] **Step 2: Write the failing test**

```dart
// test/app/router/app_router_pushed_routes_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flow/app/router/app_router.dart';
import 'package:flow/core/database/database_provider.dart';
import 'package:flow/core/preferences/onboarding_provider.dart';

void main() {
  Future<GoRouter> pumpRouter(WidgetTester tester, {required bool databaseHealthy}) async {
    late GoRouter router;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingCompleteProvider.overrideWithValue(true),
          databaseHealthyProvider.overrideWithValue(databaseHealthy),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            router = ref.watch(appRouterProvider);
            return MaterialApp.router(routerConfig: router);
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  testWidgets('every pushed route renders without throwing', (tester) async {
    final router = await pumpRouter(tester, databaseHealthy: true);

    for (final route in [
      '/home/add',
      '/home/trivia',
      '/progress/day/2026-01-01',
      '/awards/streak_7',
      '/profile/target',
      '/profile/reminders',
      '/profile/settings',
      '/profile/settings/about',
    ]) {
      router.go(route);
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsWidgets, reason: 'route $route should render a Scaffold');
    }
  });

  testWidgets('the day-detail route passes the date path parameter through', (tester) async {
    final router = await pumpRouter(tester, databaseHealthy: true);

    router.go('/progress/day/2026-03-15');
    await tester.pumpAndSettle();

    expect(find.text('2026-03-15'), findsOneWidget);
  });

  testWidgets('an unhealthy database redirects to /recovery', (tester) async {
    await pumpRouter(tester, databaseHealthy: false);

    expect(find.text('Data Recovery'), findsOneWidget);
  });
}
```

- [ ] **Step 3: Run the test to verify it fails**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/app/router/app_router_pushed_routes_test.dart
```

Expected: FAIL — none of the 9 routes exist in `app_router.dart` yet.

- [ ] **Step 4: Add the 9 routes to `app_router.dart`**

Add these imports:

```dart
import '../../features/gamification/presentation/achievement_detail_page.dart';
import '../../features/hydration/presentation/add_water_page.dart';
import '../../features/hydration/presentation/day_detail_page.dart';
import '../../features/hydration/presentation/target_settings_page.dart';
import '../../features/onboarding/presentation/recovery_page.dart';
import '../../features/reminders/presentation/reminder_settings_page.dart';
import '../../features/settings/presentation/about_page.dart';
import '../../features/settings/presentation/general_settings_page.dart';
import '../../features/trivia/presentation/trivia_page.dart';
```

Append these routes to the top-level `routes:` list, as siblings of the
`StatefulShellRoute` (not nested inside it — these are full-screen pushes
that hide the bottom nav):

```dart
      GoRoute(path: '/home/add', builder: (context, state) => const AddWaterPage()),
      GoRoute(path: '/home/trivia', builder: (context, state) => const TriviaPage()),
      GoRoute(
        path: '/progress/day/:date',
        builder: (context, state) => DayDetailPage(date: state.pathParameters['date']!),
      ),
      GoRoute(
        path: '/awards/:achievementId',
        builder: (context, state) => AchievementDetailPage(
          achievementId: state.pathParameters['achievementId']!,
        ),
      ),
      GoRoute(path: '/profile/target', builder: (context, state) => const TargetSettingsPage()),
      GoRoute(path: '/profile/reminders', builder: (context, state) => const ReminderSettingsPage()),
      GoRoute(path: '/profile/settings', builder: (context, state) => const GeneralSettingsPage()),
      GoRoute(path: '/profile/settings/about', builder: (context, state) => const AboutPage()),
      GoRoute(path: '/recovery', builder: (context, state) => const RecoveryPage()),
```

- [ ] **Step 5: Run the test to verify it passes**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test test/app/router/app_router_pushed_routes_test.dart
```

Expected: PASS, 3 tests.

- [ ] **Step 6: Run the entire test suite to confirm nothing regressed**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test
flutter analyze
```

Expected: every test across the whole project passes; `flutter analyze` clean.

- [ ] **Step 7: Commit**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
dart format lib/features lib/app test/app
git add lib/features lib/app test/app
git commit -m "Add remaining pushed placeholder screens, recovery screen, and complete the route table"
```

---

## Task 35: Final validation pass

**Files:**
- No new files — this task only runs verification commands and fixes
  anything they surface.

**Interfaces:**
- Consumes: everything from Tasks 1–34
- Produces: a project matching every criterion in the design spec's
  Section 11 ("Validation criteria for this pass")

- [ ] **Step 1: Confirm dependency resolution is clean**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter pub get
```

Expected: "Got dependencies!" with no errors.

- [ ] **Step 2: Format the whole project**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
dart format .
```

Expected: reports how many files were formatted; run again to confirm 0
files changed on the second pass.

- [ ] **Step 3: Run static analysis and fix anything it surfaces**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter analyze
```

Expected: no errors. Pre-existing info-level lints unrelated to this plan
(e.g. in untouched auth-adjacent files that no longer exist, or
long-standing style notices) are acceptable; anything introduced by
Tasks 1–34 must be fixed before moving on.

- [ ] **Step 4: Run the entire test suite**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter test
```

Expected: every test from every task passes. If anything regressed,
find the owning task above and fix it there rather than patching around
it here.

- [ ] **Step 5: Spot-check dark-theme rendering**

Every component task's tests run against `FlowTheme.light` (`pumpFlowWidget`'s
default). Confirm dark mode also renders cleanly by writing one throwaway
smoke test — not committed, just run and discarded — that pumps a few
representative components under `brightness: Brightness.dark`:

```dart
// Run this inline, e.g. via `flutter test --plain-name "dark smoke"` on a
// temp file, then delete the temp file — this is a one-off check, not a
// permanent addition to the suite (every component's real tests already
// exist per-task; this only verifies the dark ColorScheme wiring itself).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow/core/design/components/primary_button.dart';
import 'package:flow/core/design/components/choice_card.dart';
import 'package:flow/core/design/components/info_card.dart';

import 'test/support/pump_flow_widget.dart';

void main() {
  testWidgets('dark smoke: representative components render without error', (tester) async {
    await pumpFlowWidget(
      tester,
      Column(
        children: [
          PrimaryButton(label: 'Continue', onPressed: () {}),
          ChoiceCard(title: 'X', description: 'Y', barsFilled: 2, selected: true, onTap: () {}),
          const InfoCard(message: 'msg', kind: InfoCardKind.caution),
        ],
      ),
      brightness: Brightness.dark,
    );

    expect(tester.takeException(), isNull);
  });
}
```

Expected: no exception. If one surfaces, it's almost always a
`FlowColors.dark` field that got left out of `copyWith`/`lerp` in Task 8 —
fix it there.

- [ ] **Step 6: Verify the package identifier and app name are unchanged**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
grep -r "oiracam.flow.bloop" android/app/build.gradle.kts ios/Runner.xcodeproj/project.pbxproj
grep "^name:" pubspec.yaml
```

Expected: `oiracam.flow.bloop` still appears in both Android and iOS
config; `pubspec.yaml`'s `name:` is still `flow`. (App *display* name
`FLOW` was already verified in the prior cleanup session — not
re-checked here.)

- [ ] **Step 7: Verify no forbidden dependencies crept back in**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
grep -E "^\s*(dio|flutter_secure_storage|geolocator|camera|mobile_scanner|google_mlkit_face_detection|image_picker|google_fonts|fl_chart|get_it|injectable|hive|isar):" pubspec.yaml
grep "INTERNET" android/app/src/main/AndroidManifest.xml
```

Expected: the first command prints nothing (no forbidden package is
declared); the second command prints nothing (no `INTERNET` permission).

- [ ] **Step 8: Boot the app on the dev flavor and confirm it reaches Home**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
flutter build apk --debug --flavor dev
```

Expected: build succeeds. (A full `flutter run` on a device/emulator to
visually confirm splash → onboarding-or-home is worth doing manually if
a device is available, but isn't required for this automated pass — the
route/redirect tests in Tasks 32–34 already exercise that logic.)

- [ ] **Step 9: Verify `reference/auth-and-network/` is excluded from the build**

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
grep -r "reference/" pubspec.yaml || echo "not referenced in pubspec.yaml (expected)"
find lib -path "*auth*" -o -path "*network*" 2>/dev/null
```

Expected: `reference/` isn't mentioned in `pubspec.yaml`; the second
command prints nothing (no auth/network code remains inside `lib/`).

- [ ] **Step 10: Commit any fixes made during this pass**

If Steps 1–9 required any corrections, commit them:

```bash
cd /Users/leojangelicomacario/Development/Flutter/Projects/FLOW
git add -A
git commit -m "Fix issues surfaced by the final foundation validation pass"
```

If nothing needed fixing, this task produces no commit — that's fine,
it means Tasks 1–34 already left the project in the validated state.
