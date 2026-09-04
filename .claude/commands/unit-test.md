---
description: Write unit tests for existing code, on demand
argument-hint: [file path, feature name, layer, or nothing]
---

Delegate to the `flutter-unit-tester` agent in on-demand mode.

Target: $ARGUMENTS

If no target was given, instruct the agent to read
`docs/PROJECT_MAP.md` § Test Coverage and take the highest-priority
gap.

Before dispatching, confirm the suite is currently green by running
`flutter test`. A red baseline makes the agent's own verification
unreadable, so report the failure and stop instead of dispatching.

When the agent returns, report the files written, the pass result it
observed, and any production defect it found. Do not paste test source.
