---
name: flutter-localization
description: Make Flutter features localization-ready. Use when adding screens, user-facing strings, validation/errors, dates, numbers, currency, pluralization, or locale-sensitive UI.
---

# Localization

For the configured locales, the arb directory, the generated class and
the regeneration command, read `docs/PROJECT_MAP.md` § Localization.

## Rule

No user-facing string is hardcoded in a widget. Not a label, not a
button, not a dialog, not a validation message, not an error, not an
empty state, not a notification.

## When adding a feature

1. List every new user-facing string.
2. Add each to the template arb file, then to every other locale the
   map lists. A key present in one locale and missing from another is a
   runtime fallback, not a translation.
3. Regenerate using the command in the map.
4. Reference strings through the generated accessor.
5. Check behaviour in the default locale.

## Formatting

Use locale-aware formatting for dates, times, numbers and currency.
Never assemble a sentence from concatenated fragments — word order
differs between languages and the result cannot be translated well.

Use plural forms rather than an if statement on a count.

## Layout

Translated strings are frequently longer than the original. Design so
that a longer string wraps or truncates deliberately rather than
overflowing, and verify with the largest text-scale setting.
