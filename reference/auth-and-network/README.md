# Auth & Network — Reference Pattern (not part of the FLOW build)

FLOW ships with no accounts, no backend, and no network calls (see
`docs/superpowers/specs/2026-08-28-flow-flutter-foundation-design.md`
Section 2). This folder preserves the boilerplate's original
REST-backed authentication pattern — login/registration/session,
the `dio`-based API client, and `flutter_secure_storage` token
handling — purely as a copyable reference, in case a future,
currently undocumented FLOW phase adds accounts.

This code is **not part of the Flutter build**: it is outside `lib/`,
not analyzed, not compiled, and its dependencies (`dio`,
`flutter_secure_storage`) are not in `pubspec.yaml`. To restore it:

1. Add `dio` and `flutter_secure_storage` back to `pubspec.yaml`.
2. Move `lib/auth_feature/` back to `lib/features/auth/`.
3. Move `lib/network/` back to `lib/core/network/`.
4. Move `lib/storage/` back to `lib/core/storage/`.
5. Move `lib/auth_session/` back to `lib/core/auth/`.
6. Re-wire the router and DI graph to reference the restored feature.
