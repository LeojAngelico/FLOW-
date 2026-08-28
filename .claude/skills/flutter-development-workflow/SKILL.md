---
name: flutter-development-workflow
description: Execute a focused Flutter feature workflow from requirements through inspection, implementation, validation, and review while minimizing unnecessary context and changes.
---

# Feature Workflow

1. Understand the requirement and acceptance criteria.
2. Inspect only relevant existing code.
3. Check reusable components/models/services.
4. Discover API contract if needed.
5. Check Android/iOS implications.
6. Check permissions/hardware if needed.
7. Check security/privacy.
8. Check localization.
9. Check presentation/design source.
10. Choose the smallest architecture-compatible solution.
11. Implement focused changes.
12. Run targeted analysis/tests.
13. Review regressions and platform implications.
14. Summarize files changed, behavior, validation, and risks.

## Efficiency

Do not repeatedly inspect the whole repository.

Prefer targeted searches and relevant files.

Do not dump full files when a focused patch is enough.

Do not repeat known context.

Token savings must never override correctness, security, API verification, platform compatibility, or necessary testing.
