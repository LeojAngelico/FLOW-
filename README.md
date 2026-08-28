# FLOW

Built on a reusable Flutter boilerplate and reference implementation for
scalable Android and iOS applications.

Authentication and a full Core UI Kit are already wired end-to-end —
rather than an empty skeleton, so every pattern here is one you can
read in context and copy. The layering, the component library and the
reusable device capabilities are the parts meant to carry over as new
features are built.

**Built on**

- **MVVM** with **Riverpod** (`Notifier` / `NotifierProvider`)
- **Clean Architecture** layering, with a strict dependency direction
- A hand-built, theme-driven **Core UI Kit** — no third-party design system
- Reusable, feature-independent **Core capabilities**
- Three environments (`dev` / `alpha` / `prod`) with per-flavor identity
- Android and iOS as first-class targets

## Core capabilities

Each is generic, returns a value to the calling screen, and holds no
business logic of its own.

| | |
|---|---|
| **Core UI Kit** | 16 theme-driven components — buttons, inputs, cards, dialogs, sheets, feedback and empty/error states — plus design tokens for spacing, radius, sizing and motion |
| **QR Scanner** | Full-screen scanner that returns the raw scanned string; interpreting it is the caller's job |
| **Face Capture** | On-device face **detection** with auto-capture — framing, head pose and optional smile. Not facial recognition, and no identity matching |
| **Image Viewer** | Immersive single-image and gallery viewer with pinch, pan and double-tap zoom |
| **Signature Pad** | Handwritten signature capture, exported as a PNG with a transparent background containing only the strokes |
| **UI Playground** | Living documentation — a debug-only screen where every component and capability can be tried on a real device |

## Architecture

```
Presentation          widgets render state and nothing else
      ↓
Notifier / ViewModel  presentation state, no business rules
      ↓
UseCase               one meaningful operation
      ↓
Repository            abstracts data access
      ↓
DataSource            API, secure storage, platform services
```

`lib/core/` holds everything reusable and feature-independent — the UI
Kit, the capabilities above, networking, storage and error handling. It
must never depend on a feature. `lib/features/<name>/` holds the
business logic, split into `data/`, `domain/` and `presentation/`.

## Environments

`dev`, `alpha` and `prod`, each with Debug and Release variants and its
own application ID, display name and API base URL — so all three can be
installed on one device at once. Everything environment-dependent is
resolved in one place (`AppEnvironment`) rather than scattered through
flavor checks.

## Quick start

```bash
flutter pub get
flutter run --flavor dev
```

> `--flavor` is **required** on Android. With product flavors declared
> there is no unflavored variant, and omitting it fails with a
> misleading "Gradle build failed to produce an .apk file".

**Requirements:** Flutter 3.44.7 · Dart `^3.12.2` · Android `minSdk` 24
· iOS 15.5+ (ML Kit's minimum, used by Face Capture).

Face Capture and the QR Scanner need a **physical device** — a
simulated camera has no face or code to detect.

## Documentation

For complete setup, architecture, development workflows, Core
components, flavors, package renaming, build instructions, testing,
and troubleshooting, see:

**[`Instructions.md`](Instructions.md)**

Start there before adding features to a new project — the renaming and
per-flavor verification steps come first.
