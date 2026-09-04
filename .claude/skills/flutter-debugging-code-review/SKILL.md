---
name: flutter-debugging-code-review
description: Debug and review Flutter code using root-cause analysis and focused changes. Use for compiler errors, runtime bugs, architecture issues, regressions, performance problems, and code review.
---

# Debugging

Before tracing a flow, read `.claude/skills/flutter-architecture-map/SKILL.md`
to identify which layer the symptom belongs to.

Do not immediately rewrite.

Use:

`Error → Understand → Identify layer → Trace flow → Root cause → Smallest safe fix → Regression test`

Separate:
- symptom
- root cause
- required fix
- optional improvement

## Review priority

1. correctness
2. crashes/data loss
3. security/privacy
4. architecture
5. state management
6. platform compatibility
7. localization
8. testability
9. performance
10. style
