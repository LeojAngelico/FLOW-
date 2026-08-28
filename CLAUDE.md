# CLAUDE.md — Reusable Flutter Development Constitution
## Purpose

Reusable rules for Flutter applications built from this boilerplate.

- Android + iOS are first-class platforms.
- Prefer maintainable, secure, localized, testable code.
- Keep AI context and tool usage economical.
- Do not put project-specific requirements here.

Use:
- `CLAUDE.md` → universal rules
- `PROJECT.md` → current app requirements/decisions
- Skills → detailed conditional workflows
- source code → current implementation truth
## Decision Priority

1. Explicit current project requirements
2. Existing working project conventions
3. This file
4. Flutter/Dart best practices
5. Personal preference

Inspect existing code before changing it. Never invent requirements.

## Architecture

Preferred flow:

`UI → ViewModel/Notifier → UseCase → Repository → DataSource → API/Local Storage`

UI renders state and handles presentation only. No direct API/repository calls or business logic.

ViewModels/Notifiers own presentation state and coordinate UseCases.

UseCases represent meaningful application operations.

Repositories abstract data access; domain defines contracts and data implements them.

DataSources communicate with APIs, storage, databases, files, or platform services.

Use the simplest architecture that fits the feature. Do not create unnecessary layers.

## Reuse and Scope

Before creating a class/model/service/component/dependency:
1. Search for an existing equivalent.
2. Reuse it when appropriate.
3. Create new code only when responsibility or reuse would otherwise become unclear.

Keep changes focused. Do not rewrite unrelated files or silently refactor working modules.

## Feature Workflow

For non-trivial features:

`Requirement → Inspect → API → Platform → Permissions → Security → Localization → Design → Implement → Targeted validation → Stop`

Use relevant Skills for detailed checks.

## API Contract

Before coupling a feature to a backend, identify when applicable:
- endpoint/path and method
- auth and headers
- path/query parameters
- request body and required/optional fields
- types/enums/validation
- success/error responses and status codes
- pagination/uploads
- token/refresh behavior

If the contract is unknown, ask for documentation/examples or clearly propose a contract for confirmation. Never silently invent an API.

## Android + iOS

Every feature must be evaluated for both platforms.

For camera, microphone, photos, files/storage, location, notifications, Bluetooth, biometrics, contacts, sensors, background work, deep links, sharing, or other native capabilities:
- check Android and iOS requirements
- handle permissions properly
- handle denied/restricted/permanently denied states
- handle permission changes after Settings
- handle unavailable capabilities
- consider lifecycle/platform differences

Use the Platform Permissions Skill when relevant.

## Security

Security is part of every feature.

Consider authentication, authorization, secure storage, HTTPS/TLS, untrusted input, sensitive data, logs, analytics, deep links, files, permissions, dependencies, and backend security.

Never hardcode secrets or log tokens/passwords/sensitive data unnecessarily.

Client validation is not authorization. Flag controls that require backend/infrastructure support. Never claim an app is hack-proof.

Use the Security Skill when relevant.

## Localization

User-facing strings must be localization-ready. Localize labels, buttons, dialogs, validation/errors, empty states, notifications, pluralization, and locale-sensitive dates/numbers/currency. Use the project's existing approach and design for longer translations/text scaling. Use the Localization Skill when relevant.

## Presentation

Design priority:

`Approved Figma > approved mockup/screenshot > existing design system > platform conventions > AI proposal`

If Figma exists, follow the approved design and inspect it when accessible. Do not redesign it without reason.

If no design exists, use the existing design system/platform conventions. Propose significant visual decisions before implementation.

Always consider responsive layouts, accessibility, safe areas, keyboard behavior, text scaling, localization expansion, and Android/iOS differences.

Use the Presentation Skill when relevant.

## Documentation

Use `///` for important public/non-obvious classes, interfaces, UseCases, ViewModels/Notifiers, reusable services, complex utilities, and important shared models. Comments explain why/non-obvious behavior, not obvious lines.

## Testing and Completion

Prefer targeted unit/widget tests and relevant checks.

Consider validation, errors, duplicate actions, network failure, unauthorized sessions, malformed data, stale UI, navigation, permissions, platform differences, and localization expansion.

A feature is complete when applicable:
- API contract confirmed
- architecture/state/error handling correct
- localization added
- Android/iOS implications checked
- permissions/security reviewed
- important classes documented
- relevant tests/checks completed
- no unrelated changes

## Device Testing — Developer Owned

After implementing a task, do NOT automatically launch Android emulators, iOS simulators, or perform device-level UI simulation.

The developer performs manual Android/iOS testing by default.

Claude may run inexpensive, targeted validation such as analysis, formatting, type checks, or relevant unit/widget tests when useful.

Run device/simulator/integration testing only when:
- the developer explicitly requests it, or
- device-level verification is genuinely required to diagnose the task.

After implementation, state what was actually validated and what remains for manual testing.

## Context and Token Efficiency

Be economical without sacrificing correctness.

- Inspect only files relevant to the current task.
- Prefer targeted searches over full-repository analysis.
- Do not reread unchanged files unnecessarily.
- Do not dump full files when a focused patch is enough.
- Avoid redundant tool calls and repeated explanations.
- Do not run broad tests/builds for small changes unless useful.
- Stop after focused implementation and validation.

Keep one session focused on one feature/task.

When an unrelated task begins, prefer a fresh session or `/clear`.

For a long session that still needs the same task context, use `/compact` with a focus when useful.

Do not ask for information already available in project files, Skills, or context.

**Correctness, security, API verification, and necessary validation always take priority over token savings.**

## Communication

The developer is learning Flutter. Briefly explain what changed, where/why, what was validated, and what to manually test. Avoid unnecessary theory or repetition.

## Golden Rules

**Existing pattern > new abstraction**

**Simple solution > clever solution**

**Focused change > broad rewrite**

**Explicit API contract > invented API**

**Android + iOS > single-platform assumption**

**Secure by default > security after a bug**

**Localized UI > hardcoded strings**

**Targeted context > whole-repository rereading**

**Concise useful output > unnecessary verbosity**

**Correctness/security > token savings**
