---
name: flutter-localization
description: Make Flutter features localization-ready. Use when adding screens, user-facing strings, validation/errors, dates, numbers, currency, pluralization, or locale-sensitive UI.
---

# Localization Workflow

Do not hardcode user-facing strings in widgets.

Use the project's existing Flutter localization approach.

When adding a feature:

1. Identify every new user-facing string.
2. Add it to localization resources.
3. Regenerate generated localization code when required.
4. Use localized accessors in UI.
5. Check default locale behavior.
6. Consider longer translations and text expansion.

Localize:
- labels
- buttons
- dialogs
- validation
- errors
- empty states
- notifications
- plural forms

Use locale-aware formatting for dates, times, numbers, currency, and measurements.

Avoid concatenating sentence fragments that make translation unnatural.

Design layouts to survive longer translated strings and larger text sizes.
