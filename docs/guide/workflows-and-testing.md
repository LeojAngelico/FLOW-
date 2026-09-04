# Workflows & Testing

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
([Navigation & Routing](architecture.md#navigation--routing)).

**Add a new API endpoint** — see
[Networking & API Layer](architecture.md#networking--api-layer).

**Add a model** — domain model in `features/<x>/domain/models/`
(plain Dart, no JSON knowledge); if the API's JSON shape differs from
the domain model, add a corresponding DTO in `features/<x>/data/models/`
with `fromJson`/`toDomain()`.

**Add a Repository** — interface in `domain/repositories/`,
implementation in `data/repositories/`. `data/providers/` constructs
the implementation and exposes it as a Riverpod `Provider` **typed as
the domain interface**; `domain/providers/` reads that provider when it
builds the UseCases.

**Add a UseCase** — a single class with one `execute(...)` method in
`domain/usecases/`, taking the Repository as a constructor dependency,
registered as a `Provider` alongside the others in
`domain/providers/`.

**Add a Riverpod provider/Notifier** — see
[State Management](architecture.md#state-management).

**Use a Core UI component** — see
[Core UI Kit](ui-kit.md#core-ui-kit); import `core/ui_kit/ui_kit.dart`.

**Create a new Core UI component** — decide Core vs. Feature first
([Core vs. Feature responsibility](ui-kit.md#core-vs-feature-responsibility)).
For Core: add the file under the right `core/ui_kit/<category>/`
subfolder, export it from `ui_kit.dart`, use only
`Theme.of(context)`/token classes for styling, and add a Playground
section (next workflow).

**Add a UI Playground example** — see
[UI Playground](ui-kit.md#ui-playground).

**Add form validation** — see [Forms & Validation](architecture.md#forms--validation).

**Handle loading/empty/error state** — see
[Loading, Empty & Error States](architecture.md#loading-empty--error-states).

**Add local storage** — see [Local Storage](architecture.md#local-storage).

**Modify the theme** — edit `AppTheme.light`
(`lib/app/theme/app_theme.dart`); every `ui_kit/` component picks up
the change automatically since none of them hardcode colors.

**Add a new flavor/environment** — add a case to `AppFlavor` and
`AppEnvironment._configFor` (Dart), a `productFlavors { create(...) }`
block in `android/app/build.gradle.kts` (Android), and a new
xcconfig/scheme pair mirroring the existing `dev`/`alpha`/`prod` ones
(iOS) — see [Environments & Flavors](builds-and-flavors.md#environments--flavors),
[Android Builds](builds-and-flavors.md#android-builds), [iOS Builds](builds-and-flavors.md#ios-builds).

**Build an APK / AAB / iOS app** — see
[Android Builds](builds-and-flavors.md#android-builds) / [iOS Builds](builds-and-flavors.md#ios-builds).

## Testing

**Current coverage:** see `docs/PROJECT_MAP.md` § Test Coverage. That
section is generated, so unlike this paragraph's predecessor it cannot
drift. Run `/sync-map` if it looks stale, and `/unit-test` to close a
gap.

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
  [Core UI Kit](ui-kit.md#core-ui-kit) and
  [Common Architecture Mistakes](#common-architecture-mistakes).
- **Architecture boundaries:** enforced by convention, not tooling —
  there's no lint rule blocking a `core/` file from importing a
  feature; it's on you to keep the dependency direction correct (see
  [Architecture](architecture.md#architecture)).

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
