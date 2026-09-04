---
name: flutter-riverpod-state
description: Riverpod presentation-state conventions for this boilerplate — Notifier, NotifierProvider, state classes, async and error states, and provider overrides in tests. Use when creating or modifying any Notifier, state class, provider, or screen state.
---

# Riverpod State

For the Notifiers that already exist in this repository and the state
class each one owns, read `docs/PROJECT_MAP.md` § State.

## What to use

Use `Notifier` with `NotifierProvider`.

Do not use `StateNotifier`, `ChangeNotifier`, or `setState` for
application state. They are not this project's pattern, and mixing
patterns is worse than either one alone.

## State classes

One state class per screen, owned by that screen's Notifier, in its own
`<screen>_state.dart`.

- Immutable, with a `copyWith`.
- Model loading, error and empty as explicit fields or an explicit
  status, not as a null that the widget has to interpret.
- Hold presentation-ready values. A widget should render a state field,
  not compute from it.
- Value equality, so rebuilds happen when the value actually changed.

## Notifiers

- Coordinate usecases. A Notifier that talks to a repository directly
  has skipped a layer.
- Read dependencies through `ref.read` of the usecase providers.
- Catch failures at the Notifier boundary and put them into state.
  Never let an exception escape into the widget tree.
- Guard against duplicate submissions: an in-flight action must not be
  startable twice.

## Testing

Construct a `ProviderContainer` and override the repository provider
declared in the feature's `data/providers/` with a hand-written fake.
Overriding at the repository boundary exercises the real usecases and
the real Notifier while replacing only the network.

Always `addTearDown(container.dispose)`.

Assert on emitted state values, not on internal calls.

See `.claude/skills/flutter-testing-qa/SKILL.md` for the fake style,
and `docs/PROJECT_MAP.md` § Test Coverage for what is already covered.
