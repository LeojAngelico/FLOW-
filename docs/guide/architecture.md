# Architecture

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
│   ├── network/                  # Dio setup, interceptors, ApiClient
│   ├── storage/                  # SecureStorageService
│   ├── ui_kit/                   # ★ The Core UI Kit — see below
│   ├── utils/                    # Platform-wrapping helpers (image picker, location, date picker)
│   └── widgets/                  # Pre-UI-Kit shared widgets (bottom nav) — see note below
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
└── l10n/generated/                # Generated AppLocalizations — do not hand-edit
```

> **Note on `core/widgets/`**: `AppBottomNavigation` predates the
> Core UI Kit and hasn't been migrated into `core/ui_kit/` yet. It's
> still the right place to look for the bottom-nav component, but if
> you're adding new generic components, put them in `core/ui_kit/`,
> not here.

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

## Networking & API Layer

- **`ApiClient`** (`core/network/api_client.dart`) — thin wrapper over
  a single shared `Dio` instance (`get`/`post`/`put`/`delete`).
- **`dioProvider`** (`core/network/network_providers.dart`) builds that
  `Dio` instance: base URL from `AppEnvironment.current.apiBaseUrl`
  (see [Environments & Flavors](builds-and-flavors.md#environments--flavors)), a
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
- **Don't expose developer tooling in production** — anything gated
  by `AppEnvironment.current.enableUiPlayground` (or a future flag
  like it) must default to `false` for `prod`; when adding a new
  debug-only feature, gate it the same way rather than a bare
  `kDebugMode` check (which doesn't account for flavor).

