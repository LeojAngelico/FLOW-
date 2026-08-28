---
name: flutter-testing-qa
description: Design focused tests and QA coverage for Flutter features, including unit, widget, integration, manual QA, edge cases, and regression checks.
---

# Testing and QA

Prioritize behavior over implementation details.

## Unit tests

Focus on:
- UseCases
- ViewModels/Notifiers
- validators
- mappers
- business rules

## Widget tests

Focus on:
- important screens
- forms
- validation
- loading/error/success/empty states
- important interactions

## Integration tests

Focus on high-value end-to-end flows.

## QA edge cases

Consider:
- empty/boundary input
- beyond-limit input
- duplicate submissions
- repeated taps
- network failure/timeout
- unauthorized session
- malformed/missing API data
- stale UI
- navigation/back behavior
- permission denial
- Android/iOS differences
- localization expansion

When reporting bugs include:
- concise title
- environment
- preconditions
- reproduction steps
- expected result
- actual result
- severity/priority
- evidence when available
