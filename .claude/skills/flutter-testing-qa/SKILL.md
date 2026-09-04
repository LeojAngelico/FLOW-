---
name: flutter-testing-qa
description: Design focused tests and QA coverage for Flutter features, including unit, widget, integration, manual QA, edge cases, and regression checks.
---

# Testing and QA

For what is already covered and what is not, read
`docs/PROJECT_MAP.md` § Test Coverage.

## House style — mirror it, do not replace it

This project uses **hand-written fakes**. There is no mocking library
in `dev_dependencies`, and that is deliberate.

- A fake is a class that `implements` the domain repository interface.
- Give it deliberate failure switches — a flag the test sets to make
  the next call throw — so error paths can be exercised without an HTTP
  layer.
- Document the fake with `///`, saying what real thing it stands in
  for.
- Seed it with static fixture data rather than building fixtures in
  every test.

Construct a `ProviderContainer`, override the repository provider from
the feature's `data/providers/` with the fake, and
`addTearDown(container.dispose)`.

Read an existing test before writing a new one and match it. Consistency
with the tests already in this repository matters more than any
improvement to their style.

## What to test, in priority order

1. **Notifiers** — presentation logic; the highest value in this
   codebase.
2. **UseCases** — pure Dart, fast, cheap.
3. **Repository implementations** — where DTO-to-domain mapping bugs
   hide.
4. **Widgets** — components in the shared kit are the easiest
   high-value widget tests, being mostly stateless with no network.

Assert on behaviour and emitted state, never on internal call order.

## Edge cases worth a test

Empty and boundary input; input beyond the limit; duplicate submission
and repeated taps; network failure and timeout; an unauthorized
session; malformed or missing fields in a response; stale UI after a
change; back navigation; a denied permission; and a longer localized
string.

## Reporting a bug

Title; environment; preconditions; steps; expected; actual; severity;
evidence.

## Claims

Never state that tests pass without having run them and read the
output.
