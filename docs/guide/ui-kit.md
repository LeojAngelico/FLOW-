# Core UI Kit

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
  [Environments & Flavors](builds-and-flavors.md#environments--flavors)). Not used inside
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
| `app_date_picker.dart` | `AppDatePicker.pickDate(...)` (wraps `showDatePicker`) — unused today, see above |

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
| Profile | `features/auth/presentation/profile/profile_page.dart` | `AppAvatar`, `AppCard`, `AppButton`, `AppConfirmationDialog`, `AppLoadingDialog`, `AppDialog` (language picker) |

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

## UI Playground

**What it is:** a debug-only screen (`lib/core/ui_kit/playground/ui_playground_page.dart`)
that demos every Core UI Kit component and its states — living visual
documentation, not a testing tool.

**How to reach it:** it's the last tab of the bottom navigation,
labeled "UI Kit" (only present when enabled), or directly via the
`/ui-playground` route (`lib/app/router/app_router.dart`).

**Visibility:** gated by `AppEnvironment.current.enableUiPlayground`,
**not** a plain `kDebugMode` check — see
[Environments & Flavors](builds-and-flavors.md#environments--flavors) for the exact rule
per flavor/build-mode combination. It is **never** available in the
`prod` flavor, in debug or release.

**When you add a new Core UI Kit component:** add a matching
`_Section(...)` block to `ui_playground_page.dart` showing its name,
one-line purpose, and its interesting states (variants, loading,
disabled, error, etc.) — mirror the existing sections' style. This
keeps the Playground trustworthy as documentation; a component that
exists in `ui_kit/` but isn't in the Playground is easy to forget.

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

