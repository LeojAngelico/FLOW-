---
name: flutter-architecture-map
description: The directory contract, layer responsibilities and provider wiring for this Flutter boilerplate. Read this before creating any file, deciding where code belongs, or reviewing structure.
---

# Architecture Map

This skill describes the **shape**. For what actually exists in this
repository — features, routes, components, endpoints — read
`docs/PROJECT_MAP.md`. If the map is missing or stale, run `/sync-map`.

## Flow

`UI → Notifier → UseCase → Repository → DataSource → API or storage`

Dependencies point inward. `domain/` knows nothing about `data/`.
`data/` implements interfaces that `domain/` declares.

## Directory contract

Every feature lives at `lib/features/<feature>/` with three layers.

```
data/
  datasources/    talks to the network or platform; transport lives here
  models/         DTOs with fromJson and toDomain
  requests/       one class per call, with toJson
  responses/      one class per call, parsing the envelope
  repositories/   implements the domain repository interface
  providers/      binds the interface provider to the implementation
domain/
  models/         plain Dart; no JSON knowledge, no framework imports
  repositories/   abstract interface only
  usecases/       one class, one execute method, repository injected
  providers/      declares the usecase providers
presentation/
  <screen>_page.dart       renders state; no business logic
  <screen>_notifier.dart   coordinates usecases
  <screen>_state.dart      the state this screen owns
  widgets/                 pieces used only by this feature
```

A feature with more than one screen groups each under
`presentation/<screen>/` with the same four entries inside. Mirror the
reference feature's choice rather than picking one.

Shared code lives under `lib/core/`. App-level wiring — router, theme,
locale, shell — lives under `lib/app/`.

A feature that has no remote data has no `data/` directory. Do not
create empty layers to complete a pattern.

## Provider wiring

Two provider files per feature, and the direction matters.

- `data/providers/` constructs the data source and repository
  implementation, and exposes the repository **typed as the domain
  interface**.
- `domain/providers/` constructs the usecases, reading the repository
  provider declared in `data/providers/`.

This is what lets tests override one provider and replace the whole
data layer with a fake. See `docs/PROJECT_MAP.md` § Providers for a
worked example from this repository.

## Placement decisions

| Question | Answer |
|---|---|
| Where does a validation rule go? | A usecase, or the domain model. Never a widget. |
| Where does JSON parsing go? | `data/models/`, `data/responses/`. Never `domain/`. |
| Where does a reused widget go? | The core UI kit if any feature could use it; the feature's `widgets/` otherwise. |
| Where does an error become a message? | The error mapper in `lib/core/`. See § Network Layer of the map. |
| Where does navigation go? | The router under `lib/app/`. Notifiers expose state; pages navigate. |

## Before creating anything

1. Read `docs/PROJECT_MAP.md` for what already exists.
2. Find the closest existing feature and mirror it. Consistency with a
   working neighbour beats an improvement nobody else follows.
3. Create a new class only when reuse or responsibility would otherwise
   be unclear.
