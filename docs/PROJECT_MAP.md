# Project Map

Generated facts about this repository. See
`.claude/skills/flutter-architecture-map/SKILL.md` for the directory
contract this inventories against. Regenerate with `/sync-map` — do
not hand-edit.

## Identity

| | |
|---|---|
| Package name | `flutter_incident_reporting` |
| Description | "A new Flutter project." (pubspec — not project-specific) |
| Version | `0.0.2+2` |

**Flavors** — `dev`, `alpha`, `prod` (Android product flavors, `android/app/build.gradle.kts`; iOS schemes `dev.xcscheme`, `alpha.xcscheme`, `prod.xcscheme`).

| Flavor | Android applicationId suffix | iOS bundle ID suffix |
|---|---|---|
| dev | `.dev` | `.dev` |
| alpha | `.alpha` | `.alpha` |
| prod | *(none — canonical `mecare.nurse.app`)* | *(none)* |

Base Android `applicationId` / iOS `PRODUCT_BUNDLE_IDENTIFIER`: `mecare.nurse.app`.

## Features

Six directories under `lib/features/`:

| Feature | data/ | domain/ | presentation/ | Screens |
|---|---|---|---|---|
| `auth` | yes | yes | yes | `login`, `registration`, `profile`, `splash` (+ `session/` — session state, no page) |
| `incident` | yes | yes | yes | `incident_page` (list), `create_incident_page`, `edit_incident_page`, `incident_details_page` |
| `patient` | yes | yes | yes | `details/patient_details_page` (tabs: info, activity timeline) |
| `activity` | yes | yes | yes | `record/record_activity_page`, `update/update_record_activity_page`, `review/review_submit_page`, `completed/visit_completed_page` |
| `dashboard` | no | no | yes | `dashboard_page` |
| `home` | no | no | yes | `home_page` (boilerplate incident-list home; not the MeCARE entry point) |

`dashboard` and `home` have no `data/`/`domain/` of their own — `dashboard` reads `patient`'s `GetPatientsByWardUseCase`/providers directly; `home` reads `incident`'s `IncidentListNotifier`.

## Routes

From `lib/app/router/app_router.dart` (`GoRouter`, `initialLocation: /splash`):

| Path | Screen |
|---|---|
| `/ui-playground` | `UiPlaygroundPage` (only when `AppEnvironment.enableUiPlayground`) |
| `/splash` | `SplashPage` |
| `/login` | `LoginPage` |
| `/registration` | `RegistrationPage` |
| `/dashboard` | `DashboardPage` |
| `/scan` | `QrScannerPage` (generic, patient-agnostic) |
| `/patients/:code` | `PatientDetailsPage` |
| `/activities/record` | `RecordActivityPage` (`extra`: `Patient`) |
| `/activities/update` | `UpdateRecordActivityPage` (`extra`: `int` index) |
| `/activities/review` | `ReviewSubmitPage` (`extra`: `Patient`) |
| `/activities/completed` | `VisitCompletedPage` (`extra`: `Patient`) |
| `/incidents/create` | `CreateIncidentPage` |
| `/incidents/:id` | `IncidentDetailsPage` |
| `/incidents/:id/edit` | `EditIncidentPage` (`extra`: `Incident`) |
| `/home` | `HomePage` (shell branch) |
| `/incidents` | `IncidentPage` (shell branch) |
| `/profile` | `ProfilePage` (shell branch) |

`/home`, `/incidents`, `/profile` are grouped under a `StatefulShellRoute.indexedStack` (`MainShell`) — the boilerplate bottom-navigation shell, still reachable but not the MeCARE entry point (`/dashboard` is). Redirect logic: unauthenticated → `/login`; authenticated on splash/login/registration → `/dashboard`.

## UI Kit Catalog

`lib/core/ui_kit/`, barrel `ui_kit.dart`. Excludes `tokens/`, the barrel, and `playground/ui_playground_page.dart`.

| Category | File | Class |
|---|---|---|
| buttons | `app_button.dart` | `AppButton` |
| inputs | `app_text_field.dart` | `AppTextField` |
| inputs | `app_password_field.dart` | `AppPasswordField` |
| surfaces | `app_avatar.dart` | `AppAvatar` |
| surfaces | `app_bottom_sheet.dart` | `AppBottomSheet` |
| surfaces | `app_card.dart` | `AppCard` |
| surfaces | `app_info_row.dart` | `AppInfoRow` |
| surfaces | `app_section_header.dart` | `AppSectionHeader` |
| indicators | `app_badge.dart` | `AppBadge` |
| indicators | `app_chip.dart` | `AppChip` |
| indicators | `app_environment_badge.dart` | `AppEnvironmentBadge` |
| feedback | `app_alert_banner.dart` | `AppAlertBanner` |
| feedback | `app_empty_state.dart` | `AppEmptyState` |
| feedback | `app_error_state.dart` | `AppErrorState` |
| feedback | `app_loading_indicator.dart` | `AppLoadingIndicator` |
| feedback | `app_result_view.dart` | `AppResultView` |
| feedback | `app_snackbar.dart` | `AppSnackbar` |
| dialogs | `app_confirmation_dialog.dart` | `AppConfirmationDialog` |
| dialogs | `app_dialog.dart` | `AppDialog` |
| dialogs | `app_loading_dialog.dart` | `AppLoadingDialog` |

20 components across 5 category subdirectories (buttons, inputs, surfaces, indicators, feedback, dialogs — 6 counting dialogs separately).

## Design Tokens

`lib/core/ui_kit/tokens/`:

| Class | Covers |
|---|---|
| `AppColors` | Warning role (M3 has none), MeCARE brand colors (`brandBlue`, `brandRed`), decorative motif color, and the hand-built MeCARE `ColorScheme` (navy primary, periwinkle containers, mint tertiary/success, red error) |
| `AppSpacing` | Spacing scale: `xs`(4) `sm`(8) `md`(12) `lg`(16) `xl`(24) `xxl`(32) |
| `AppRadius` | Corner radii: `sm`(8) `md`(12) `lg`(16) `xl`(20) `pill`(999) + matching `BorderRadius` constants |
| `AppSizing` | Touch target (48), button heights, icon sizes, dialog icon, avatar sizes |
| `AppMotion` | Animation durations: `fast`(150ms) `medium`(250ms) `slow`(400ms) |

## Network Layer

- **HTTP client**: `Dio`, built in `lib/core/network/network_providers.dart` (`dioProvider`), wrapped by `ApiClient` (`lib/core/network/api_client.dart`) exposing `get`/`post`/`put`/`delete`.
- **Interceptors** (attached in `dioProvider`, in order):
  - `RedactedLogInterceptor` — logs method/URL/status always; headers+body only when `AppEnvironment.logLevel == verbose`, nothing when `minimal`. Redacts `authorization`, `token`, `password`, `access_token`, `refresh_token` keys.
  - `AuthInterceptor` (`QueuedInterceptor`) — attaches `Authorization: Bearer <token>` from `AuthSessionManager`; on a `401` (not itself a refresh call, not already retried) refreshes the token via a **separate** `Dio` instance (`_refreshDio`, no interceptors — avoids an infinite loop) and retries the original request once; on refresh failure calls `AuthSessionManager.clearSession()`.
- **Request convention**: one class per call under `data/requests/`, e.g. `CreateIncidentRequest` — plain fields, `toJson()` where needed (GET/list-style requests) or consumed directly (multipart calls like `createIncident`/`editIncident` build `FormData` in the datasource).
- **Response convention**: one class per call under `data/responses/`, suffixed `...ResponseDto`, e.g. `IncidentResponseDto.fromJson` — parses the shared envelope (`msg`→message, `status`, `status_code`→statusCode, `data`) and the payload. Shared envelope-only shape: `GeneralResponseDto` (`lib/core/models/general_response.dart`) for calls with no meaningful data payload, also carries `errors`/`has_requirements`.
- **Data models**: `data/models/` DTOs (e.g. `IncidentModel`) mirror the response shape with `fromJson` + `toDomain()` converting to the plain `domain/models/` type.
- **Error mapping**: `ErrorMapper.map(Object)` (`lib/core/errors/error_mapper.dart`) — `DioException` → `Failure` subtype (`NetworkFailure` for timeouts/connection errors, `ServerFailure` for 5xx, `UnauthorizedFailure` for 401, `ValidationFailure` for 400/422, `UnknownFailure` otherwise), parsing the backend's `status_code`/`msg`/`errors` fields where present. `Failure.message` is either a stable `ErrorCodes` constant (localized via `ErrorLocalizer` at display time) or raw backend text for `ValidationFailure`.
- **Credential/token storage**: `SecureStorageService` (`lib/core/storage/secure_storage_service.dart`) wraps `flutter_secure_storage`, storing access token, cached user JSON, and locale code. `AuthSessionManager` (`lib/core/auth/`) reads/writes the token through it and exposes `clearSession()`, called by the auth interceptor on unrecoverable 401s.

## State

Notifier classes under `presentation/` (Riverpod `Notifier<State>`), plus one app-level notifier:

| Notifier | State owned |
|---|---|
| `LoginNotifier` | `LoginState` |
| `RegistrationNotifier` | `RegistrationState` |
| `ProfileNotifier` | `ProfileState` |
| `AuthSessionNotifier` | `AuthSessionState` (`AuthSessionStatus`: checking/authenticated/unauthenticated) |
| `IncidentListNotifier` | `IncidentListState` |
| `CreateIncidentNotifier` | `CreateIncidentState` |
| `EditIncidentNotifier` | `EditIncidentState` |
| `IncidentDetailsNotifier` | `IncidentDetailsState` |
| `PatientDetailsNotifier` | `PatientDetailsState` |
| `RecordActivityNotifier` | `RecordActivityState` |
| `DashboardNotifier` | `DashboardState` |
| `LocaleNotifier` (`lib/app/locale/`) | `Locale` (app-level, not a feature state class) |

`RouterRefreshNotifier` (`lib/app/router/`) is a plain `ChangeNotifier` used as `GoRouter`'s `refreshListenable`, not a Riverpod `Notifier<State>` — infrastructure, not feature state.

## Providers

Two-file wiring per feature, `data/providers/` → `domain/providers/`, per the skill contract. Worked example from `patient`:

`lib/features/patient/data/providers/patient_data_providers.dart`:
```dart
final patientRepositoryProvider = Provider<PatientRepository>((ref) {
  return PatientRepositoryImpl(
    remoteDataSource: ref.read(patientRemoteDataSourceProvider),
  );
});
```

`lib/features/patient/domain/providers/patient_domain_providers.dart`:
```dart
final getPatientsByWardUseCaseProvider =
    Provider<GetPatientsByWardUseCase>((ref) {
  return GetPatientsByWardUseCase(
    ref.read(patientRepositoryProvider),
  );
});
```

`auth` and `activity` follow the same direct-typed pattern. `incident` uses a variant: `data/providers/` exposes the concrete `incidentRepositoryImplProvider` (typed `IncidentRepositoryImpl`), and `domain/providers/incident_domain_provider.dart` re-exposes it as `incidentRepositoryProvider` (typed `IncidentRepository`) before wiring its usecases — same effect, one extra indirection.

## Localization

- **Locales**: `en` (template), `fil`, `ceb` — from `lib/l10n/app_en.arb`, `app_fil.arb`, `app_ceb.arb`.
- **ARB directory**: `lib/l10n/` (`l10n.yaml`: `arb-dir: lib/l10n`, `template-arb-file: app_en.arb`).
- **Generated output class**: `AppLocalizations`, written to `lib/l10n/generated/app_localizations.dart` (`output-dir: lib/l10n/generated`).
- **Regeneration command**: `flutter gen-l10n` (also runs automatically on `flutter pub get`/`flutter run` since `pubspec.yaml` sets `flutter: generate: true`).
- `ceb` has no built-in Material/Cupertino localizations, so `lib/app/locale/unsupported_locale_fallback_delegates.dart` supplies `CebFallbackMaterialLocalizationsDelegate` / `CebFallbackCupertinoLocalizationsDelegate`, added after `AppLocalizations.localizationsDelegates` in `app.dart`.

## Platform

**Packages using native capabilities**: `image_picker` (camera/gallery), `geolocator` (location), `mobile_scanner` (camera/QR), `flutter_secure_storage` (Keychain/Keystore).

Wrapped by: `AppImagePicker` (`lib/core/utils/app_image_picker.dart`), `AppLocation` (`lib/core/utils/app_location.dart`, handles service-disabled/denied/denied-forever), `QrScannerPage` (`lib/core/scanner/`).

**Android** (`android/app/src/main/AndroidManifest.xml`):
- `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`
- `CAMERA`
- `uses-feature android.hardware.camera` / `.camera.autofocus` — both `required="false"`

**iOS** (`ios/Runner/Info.plist`):
- `NSLocationWhenInUseUsageDescription` — "This app uses your location when creating an incident report."
- `NSPhotoLibraryUsageDescription` — "This app needs access to your photos to attach an image to an incident report."
- `NSCameraUsageDescription` — "MeCARE uses the camera to scan patient QR codes and to capture photos for records."

## Test Coverage

`test/` has 6 files: 4 Notifier tests, 1 core-model test (`DateCreated`, not a feature domain model), and `ai_setup_test.dart` (checks AI-setup markdown frontmatter, not app code).

**Notifiers** — 12 total, 4 tested:
- Tested: `LoginNotifier`, `RecordActivityNotifier`, `DashboardNotifier`, `PatientDetailsNotifier`
- Untested: `RegistrationNotifier`, `ProfileNotifier`, `AuthSessionNotifier`, `IncidentListNotifier`, `CreateIncidentNotifier`, `EditIncidentNotifier`, `IncidentDetailsNotifier`, `LocaleNotifier`

**UseCases** — 15 total, 0 tested (all exercised only indirectly through the notifier tests above, via fake repositories):
`LoginUseCase`, `RefreshTokenUseCase`, `RegisterUseCase`, `GetProfileUseCase`, `LogoutUseCase`, `GetIncidentsUseCase`, `GetIncidentDetailsUseCase`, `CreateIncidentUseCase`, `EditIncidentUseCase`, `DeleteIncidentUseCase`, `GetPatientsByWardUseCase`, `GetPatientDetailsUseCase`, `GetPatientActivityUseCase`, `CreateActivityUseCase`, `GetActivityTypesUseCase`

**Repository implementations** — 4 total, 0 tested directly:
`AuthRepositoryImpl`, `IncidentRepositoryImpl`, `PatientRepositoryImpl`, `ActivityRepositoryImpl` (tests substitute hand-written fakes implementing the domain interface instead of exercising these)

**Domain models** — 6 total, 0 with dedicated tests:
`User`, `Incident`, `Patient`, `ActivityRecord`, `ActivityTypeOption`, `ActivityEntry`

**UI components** — 20 total (see § UI Kit Catalog), 0 with widget tests.

## Generated

Generated 2026-09-02 from commit `64863c1`.
