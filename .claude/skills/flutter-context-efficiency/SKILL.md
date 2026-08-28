---
name: flutter-context-efficiency
description: Keep Flutter development sessions focused and economical. Use when starting, implementing, debugging, or validating a feature to minimize unnecessary context, file reads, tool calls, builds, and emulator usage.
---

# Context Efficiency Workflow

## 1. Scope first

Identify the exact feature/task and acceptance criteria.

Do not perform a full-project analysis unless the task genuinely requires it.

## 2. Inspect narrowly

Prefer:
1. project structure
2. relevant feature files
3. directly related models/services/providers
4. targeted search for references

Avoid rereading unchanged files.

If a file is not relevant to the task, do not inspect it just for completeness.

## 3. Implement narrowly

Reuse existing patterns.

Modify only affected files.

Prefer a focused patch over a rewrite.

Do not add dependencies unless justified.

## 4. Validate cheaply first

Prefer, when relevant:
- targeted `flutter analyze`
- formatting
- targeted unit tests
- targeted widget tests
- focused static/type checks

Do not automatically run:
- full app builds
- Android emulator
- iOS simulator
- device UI simulation
- broad integration suites

The developer owns manual Android/iOS testing by default.

## 5. Stop condition

After implementation and appropriate cheap validation:
- summarize what changed
- state exactly what was validated
- state what the developer should manually test
- stop

Do not continue exploring or optimizing unless the task requires it.

## 6. Session hygiene

Keep one session focused on one feature/task.

Use `/clear` when moving to an unrelated task.

Use `/compact` when the same task must continue but the conversation has accumulated substantial irrelevant context.

Do not use `/compact` as a substitute for persistent project instructions; important reusable rules belong in `CLAUDE.md` or Skills.

## 7. Large investigations

If a task requires repository-wide analysis, security auditing, or broad research, isolate that work when possible instead of filling the main feature-development conversation with unnecessary detail.

## 8. Token-saving rules

Never sacrifice correctness, security, API-contract verification, platform compatibility, or required validation just to reduce usage.

The target is **minimum necessary context**, not minimum possible context.
