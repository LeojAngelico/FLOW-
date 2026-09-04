---
description: Run the gated feature-delivery pipeline for a new feature
argument-hint: <what to build>
---

Orchestrate the delivery pipeline for: $ARGUMENTS

You are the orchestrator. You do not read feature source, and you do
not write code. Hold only the workplan path and each agent's summary —
that is what keeps this window from filling, and it is the point of the
whole pipeline.

## Before starting

Run `flutter test`. If the suite is red, report the failure and stop.
A red baseline makes every later gate unreadable.

If `docs/PROJECT_MAP.md` is missing, run `/sync-map` first.

## Pipeline

Each gate is a hard stop. Present the result, then wait for the
developer's explicit go. Do not present a gate and continue in the same
breath.

1. Dispatch `feature-planner`. Report the workplan path, the reference
   feature, the contract status, and the file count per layer.
   **GATE 0** — the developer approves the plan.
   If the contract came back `BLOCKED`, stop here and ask; do not
   proceed on a proposed contract without a yes.

2. Dispatch `flutter-implementer` for the **data** layer, naming the
   workplan. Report the files it wrote.
   The data layer implements an interface the domain layer has not been
   written yet, so it will reference types that do not exist and
   `flutter analyze` will not be clean until GATE 3. That is expected —
   it is not a failed gate and not a missing file.
   **GATE 1**

3. Dispatch `flutter-implementer` for the **domain** layer, naming the
   workplan.
   **GATE 2**

4. Dispatch `flutter-implementer` for the **presentation** layer, naming
   the workplan.
   **GATE 3**

5. Dispatch `flutter-unit-tester` in pipeline mode, naming the workplan.

6. Dispatch `flutter-gatekeeper` and `flutter-reviewer` **concurrently**
   — one call, two agents, both named the workplan. They have different
   jobs and share no state. Report the gatekeeper's PASS or FAIL and the
   reviewer's must-fix findings.
   **GATE 4** — the developer decides what to fix. Once they accept the
   feature, set `Status: done` and `Last agent` in the workplan
   yourself: `flutter-reviewer` is read-only and cannot write it.

## When a gate fails

Report it and stop. Do not dispatch the next layer to work around a
failure, and do not fix it yourself. A wrong direction caught at GATE 1
costs one layer; carried to GATE 4 it costs three.

## When the developer returns after /clear

They will name a workplan file. Read it, look at `Status` and
`Last agent`, and resume at the next step. Do not re-plan, and do not
re-run completed layers.

## Reporting

After every dispatch: what the agent did, what changed, what is next.
Never paste file contents or agent transcripts.
