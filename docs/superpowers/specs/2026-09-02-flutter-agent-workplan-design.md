# Flutter Agent Workplan — Design

**Date:** 2026-09-02
**Status:** Approved, pending implementation plan
**Repo at time of writing:** `flutter_incident_reporting` (MeCARE Nurse App) v0.0.2+2, branch `develop`

---

## 1. Goal

Turn this project's AI setup from a pile of advisory documents into an
executable, resumable, portable feature-delivery pipeline.

Two goals held simultaneously:

1. **Smarter output** — Claude should already know this codebase's
   conventions instead of rediscovering them every session.
2. **Token efficiency** — the cost of knowing should be lower than the
   cost of rediscovering.

A third constraint, added during design: the system must be **reusable
across other Flutter projects built from this boilerplate**.

## 2. Non-goals

- Replacing developer-owned manual device testing. `CLAUDE.md` keeps
  ownership of Android/iOS device runs with the developer.
- CI/CD pipelines, coverage gates, or automated release workflows.
- Backend or API changes.
- Migrating the existing test suite to a mocking library.
- An ADR folder, CHANGELOG, or CONTRIBUTING file. Solo-developer
  project; these would not be read.

---

## 3. Problem statement

### 3.1 The skills carry principles, not facts

The nine skills in `.claude/skills/` total 11,426 bytes and are almost
entirely restatements of `CLAUDE.md` (7,281 bytes, loaded every
session). None of them names a single file path, class, or command
from this repository.

Two skills are pure duplication:

| Skill | Bytes | Duplicates |
|---|---|---|
| `flutter-development-workflow` | 1,139 | `CLAUDE.md` § Feature Workflow |
| `flutter-context-efficiency` | 2,352 | `CLAUDE.md` § Context and Token Efficiency |

### 3.2 The real cost is rediscovery, not the skills

Implementing one feature requires re-reading the same unchanging
convention-bearing files — the reference data source, repository
implementation, provider wiring, notifier, error mapper, and several
UI Kit components. Estimated **15,000–25,000 tokens per feature**,
repeated in every new session, for information that does not change.

### 3.3 Documented state has drifted from real state

`Instructions.md` § Testing states the project "has exactly one test
file, `test/widget_test.dart` — the unmodified default Flutter
counter-app template". In fact `test/` contains six files totalling
1,237 lines, including four substantial notifier tests. The
documentation is four test files behind reality.

This drift is structural, not careless: hand-maintained facts always
decay. The design must generate facts rather than store them by hand.

### 3.4 Confirmed pain points

All four were confirmed by the developer:

1. Context exhaustion mid-feature.
2. Completion gates forgotten (localization, permissions, security, tests).
3. New code inconsistent with existing patterns.
4. Workflow too manual — every step must be requested explicitly.

---

## 4. Core design principle

> **Skills carry METHOD (portable). `PROJECT_MAP.md` carries FACTS
> (generated). Skills reference the map.**

Facts placed inside skills would be wrong the moment the skills are
copied to another project — worse than absent, because a lying skill
is trusted. Facts placed in a generated map are correct in whatever
repository the map was generated from, and are refreshed by re-running
one command.

This resolves the tension between "know the codebase" and "be
portable", and it removes the maintenance burden of drift: after a
refactor, run `/sync-map`.

---

## 5. Two tiers

### Tier 1 — Portable

Copied unchanged into any project derived from this boilerplate.

```
CLAUDE.md                       constitution; no project facts
.claude/agents/*.md             6 agents
.claude/commands/*.md           /feature, /unit-test, /sync-map
.claude/skills/*/SKILL.md       method only
docs/guide/*.md                 boilerplate developer guide
```

### Tier 2 — Generated or project-authored

Never copied between projects.

```
PROJECT.md                      app requirements and decisions (hand-written, per project)
docs/PROJECT_MAP.md             generated inventory (never hand-written)
docs/workplans/*.md             per-task working state (generated)
```

### Reuse workflow

Chosen method: **manual copy from the boilerplate repo** (the
boilerplate is upstream; improvements are copied back by hand).

```
1. Copy the boilerplate            → Tier 1 comes with it
2. Follow docs/guide/new-project-setup.md
                                   → rename, bundle IDs, flavors, branding
3. Write PROJECT.md                → what this app is
4. Run /sync-map                   → generates PROJECT_MAP.md from real code
5. /feature <description>          → ready
```

---

## 6. Skill layer redesign

Net count stays at nine; the contents change substantially. Every
retained skill is rewritten to contain **method plus a pointer into
`PROJECT_MAP.md`**, never inline project facts.

### Removed (2)

| Skill | Reason |
|---|---|
| `flutter-development-workflow` | Becomes the `/feature` command. A workflow that must be executed belongs in a command, not a document. |
| `flutter-context-efficiency` | Duplicates `CLAUDE.md`. Its operative rules move into agent definitions, where they constrain behaviour instead of describing it. |

### Added (2)

| Skill | Purpose |
|---|---|
| `flutter-architecture-map` | The directory contract, layer responsibilities, file-naming rules, and the provider wiring chain (`domain/providers/` declares the interface provider, `data/providers/` overrides it with the implementation). Portable, because every project from this boilerplate shares this shape. Read first by every agent. |
| `flutter-riverpod-state` | Notifier/State conventions for Riverpod 3 — `Notifier`/`NotifierProvider`, never `StateNotifier` or `ChangeNotifier`; state class shape; loading/error/empty modelling; `ProviderContainer` override pattern. Currently absent despite being the most frequently written code in the project. |

### Renamed and rewritten (1)

| From | To | Change |
|---|---|---|
| `flutter-presentation-design` | `flutter-ui-kit` | Keeps the design-priority ladder. Adds a hard rule: consult `PROJECT_MAP.md` § UI Kit Catalog before creating any widget; if a component exists, use it. Directly addresses pain point 3. |

### Rewritten against the map (4)

`flutter-api-contract`, `flutter-localization`,
`flutter-platform-permissions`, `flutter-testing-qa` — each keeps its
method and gains a pointer to the relevant `PROJECT_MAP.md` section
(network layer, locales, platform config, test coverage).

`flutter-testing-qa` additionally documents the house test style
described in § 9.

### Trimmed (2)

`flutter-security` and `flutter-debugging-code-review` are legitimately
principle-based. Trim overlap with `CLAUDE.md`; keep the substance.

### CLAUDE.md

Trimmed of sections that move into skills or commands, so the
always-loaded cost drops. The Decision Priority, Golden Rules,
Android+iOS mandate, and the developer-owned device-testing rule stay.

---

## 7. Agent roster

Six agents in `.claude/agents/`. All Tier 1 — none contains project
facts; all read `PROJECT_MAP.md`.

| Agent | Model | Tools | Responsibility |
|---|---|---|---|
| `project-mapper` | sonnet | Read, Grep, Glob, Write | Scans the repo, writes `docs/PROJECT_MAP.md`. Mechanical, so sonnet. |
| `feature-planner` | opus | Read, Grep, Glob, Write | Requirement + map + `PROJECT.md` → workplan file. Selects the reference feature to mirror, plans files per layer, establishes the API contract or blocks on it. Sets the direction of the whole feature, so opus. |
| `flutter-implementer` | sonnet | Read, Edit, Write, Grep, Glob | **Proactive** (see § 7.1). Invoked three times — data, then domain, then presentation. One layer per invocation, briefed from the workplan. Follows a plan rather than forming one, so sonnet. |
| `flutter-unit-tester` | sonnet | Read, Write, Grep, Glob, Bash(`flutter test *`) | **Proactive** (see § 7.1). Dual-mode; see § 9. Write access restricted to `test/`. |
| `flutter-gatekeeper` | sonnet | Read, Grep, Glob, Bash(`flutter analyze *`), Bash(`flutter test *`) | Mechanical pass/fail checklist; see § 11. |
| `flutter-reviewer` | opus | Read, Grep, Glob | Architecture and root-cause judgement: business logic in widgets, direct repository access from UI, layer violations, reinvented UI Kit components. |

### Rationale for merges and omissions

- **API-contract analysis is inside `feature-planner`**, not a separate
  agent. Contract discovery happens during planning, and the planner
  needs the same information; splitting adds a briefing round-trip
  for no gain.
- **`flutter-gatekeeper` and `flutter-reviewer` stay separate** despite
  both being review. One is a mechanical checklist, the other is
  judgement, and separation lets them run **in parallel** at the final
  gate — different concerns, no shared state.

### Token levers built into the roster

1. **Model tiering** — four sonnet, two opus. Opus only where judgement
   determines direction (planning) or correctness (review).
2. **Tool restriction** — read-only agents get `Read`/`Grep`/`Glob`
   only. Smaller system prompts, and no capacity to wander or damage.
   No `WebSearch`/`WebFetch` on any agent; nothing here is on the web.
3. **Parallel final gate** — gatekeeper and reviewer run concurrently.

### 7.1 Proactive invocation

Two agents are declared **proactive**: Claude delegates to them without
being asked by name, via `Use PROACTIVELY` / `MUST BE USED` phrasing in
the agent's `description` frontmatter.

This matters for the **ad-hoc path**, not the `/feature` path. `/feature`
already invokes every agent explicitly. But most requests never start
with `/feature` — they start with "add a refresh button to the profile
page". Without proactive declarations those requests bypass the entire
system: no map, no conventions check, no tests, no gates. Proactivity
gives ad-hoc work a second entrance into the same machinery.

**Proactive invocation does not mean proactive execution.** The layer
gates stay exactly as specified in § 12. The agent is chosen
automatically; it still stops for approval.

| Agent | Trigger |
|---|---|
| `flutter-unit-tester` | **MUST BE USED** after any Notifier, UseCase, or Repository implementation is created or modified. Low risk, and it directly closes the most frequently missed gate. |
| `flutter-implementer` | **Use PROACTIVELY** when a change touches two or more files, or crosses a layer boundary. |

**Delegation threshold for `flutter-implementer`.** Single-file trivial
edits — a string change, a padding fix, a rename — stay in the main
session. Spinning up a subagent for a one-line change costs briefing
overhead that the change does not justify. The threshold is: two or
more files, or a layer boundary crossed.

The four non-proactive agents stay explicitly invoked. `project-mapper`
runs on `/sync-map`; `feature-planner` on `/feature`; `flutter-gatekeeper`
and `flutter-reviewer` at Gate 4 or on request. Making the planner
proactive would have it firing on questions rather than tasks, and
making the reviewers proactive would have them running against
half-finished work.

---

## 8. Commands

Three slash commands in `.claude/commands/`.

### `/feature <description>`

Orchestrates the delivery pipeline. Holds only the workplan path and
each agent's summary — never the agents' working context.

```
/feature <description>
   |
   +- feature-planner ---------------> GATE 0  approve the plan
   +- flutter-implementer (data) -----> GATE 1
   +- flutter-implementer (domain) ---> GATE 2
   +- flutter-implementer (presentation) -> GATE 3
   +- flutter-unit-tester (pipeline mode)
   +- flutter-gatekeeper  ---+
   |                         +-- parallel --> GATE 4  final
   +- flutter-reviewer ------+
```

Every gate is a hard stop. The orchestrator does not proceed without
an explicit go from the developer.

### `/unit-test [target]`

On-demand entry to `flutter-unit-tester`. See § 9.

### Ad-hoc path (no command)

A request made in plain conversation reaches the same agents through
the proactive declarations in § 7.1. The difference from `/feature` is
that no workplan file is created unless the work turns out to span more
than one layer, at which point `feature-planner` is invoked and the task
joins the normal gated pipeline.

### `/sync-map`

Runs `project-mapper`; regenerates `docs/PROJECT_MAP.md`. Run after
adding a feature, adding a UI Kit component, changing routes or
locales, or any structural refactor.

---

## 9. Unit testing

### 9.1 Actual current state

Six files, 1,237 lines:

| File | Lines |
|---|---|
| `test/features/patient/patient_details_notifier_test.dart` | 327 |
| `test/features/dashboard/dashboard_notifier_test.dart` | 311 |
| `test/features/activity/record_activity_notifier_test.dart` | 300 |
| `test/features/auth/login_notifier_test.dart` | 204 |
| `test/core/models/date_created_test.dart` | 65 |
| `test/widget_test.dart` | 30 (default counter template, broken) |

### 9.2 House style — to be mirrored, not replaced

Established by the four existing notifier tests:

- Hand-written fakes implementing the **domain repository interface**
  (e.g. `_FakePatientRepository implements PatientRepository`).
- **No mocking library.** `dev_dependencies` holds only `flutter_test`
  and `flutter_lints`. Confirmed decision: keep it that way — it
  satisfies `CLAUDE.md`'s "do not add dependencies unless justified",
  and the existing tests need no migration.
- Fakes expose deliberate failure switches (e.g. `failNextFetch`) to
  exercise error paths without an HTTP layer.
- `ProviderContainer` with provider overrides; assertions on emitted
  state.
- Fakes are documented with `///`.

### 9.3 Coverage gap

| Kind | Total | Tested | Untested |
|---|---|---|---|
| Notifiers | 13 | 4 | 9 |
| UseCases | 15 | 0 | 15 |
| Repository implementations | 4 | 0 | 4 |
| Domain models | 6 | 0 | 6 |
| UI Kit components | 20 | 0 | 20 |

Untested notifiers: `locale`, `router_refresh`, `profile`,
`registration`, `auth_session`, `create_incident`, `edit_incident`,
`incident_details`, `incident_list`.

### 9.4 Agent modes

**Pipeline mode** — invoked by `/feature` after the presentation layer.
Tests only the code that feature added.

**On-demand mode** — invoked by `/unit-test`:

```
/unit-test lib/features/incident/presentation/incident_list_notifier.dart
/unit-test incident        # whole feature
/unit-test usecases        # whole layer
/unit-test                 # highest-priority gap from the map
```

Backlog runs write `docs/workplans/YYYY-MM-DD-test-coverage.md`, so a
long coverage session is resumable on the same terms as a feature.

### 9.5 Priority order

1. Fix or delete `test/widget_test.dart` — while the suite is red,
   `flutter-gatekeeper` has no green baseline to assert against.
2. The 9 untested notifiers — presentation logic, highest value.
3. The 15 usecases — pure Dart, cheap and fast.
4. The 4 repository implementations — where DTO-to-domain mapping bugs hide.
5. The 20 UI Kit components — `Instructions.md` already identifies
   these as the easiest high-value tests.

### 9.6 Scope decision

The backlog is **on-demand only**. The implementation plan delivers the
`/unit-test` command, the agent, the rewritten `flutter-testing-qa`
skill, and the coverage section of the map. Writing the 54 missing
tests is developer-triggered work, not part of this build.

---

## 10. `docs/PROJECT_MAP.md`

Generated by `project-mapper`. Never edited by hand. Sectioned so that
a skill or agent can be pointed at one section rather than the file.

```
## Identity            package name, version, flavors, bundle IDs
## Features            per feature: layers present, screens, routes
## Routes              path -> screen, from app_router.dart
## UI Kit Catalog      every component, its file, its category
## Design Tokens       token classes and what they cover
## Network Layer       client, interceptors, request/response conventions, error mapping
## State               notifiers and the state class each owns
## Providers           the interface-provider to implementation-provider wiring
## Localization        locales, .arb locations, regeneration command
## Platform            native-capability packages, declared permissions per platform
## Test Coverage       tested vs untested, by kind
## Generated           timestamp and the commit it was generated from
```

The `Generated` footer lets any reader see whether the map is stale
relative to `HEAD`.

## 11. `docs/workplans/YYYY-MM-DD-<task>.md`

Written by `feature-planner`, updated by **every** agent before it
reports back.

```markdown
# Workplan: <task>
Status: planning | data | domain | presentation | tests | gates | done
Reference feature: <feature>          Last agent: <agent>

## Requirement
## API contract          confirmed | proposed | BLOCKED
## File plan             checkboxed, grouped by layer
## Decisions log         what was chosen and why
## Gate results          analyze / tests / localization / platform / security
## Manual QA for the developer
```

This file, not the agents, is what solves context exhaustion. When the
window fills mid-feature the developer runs `/clear` and points a fresh
session at the workplan; it resumes at the exact step with the earlier
decisions intact.

## 12. Gates

| Gate | After | Checks |
|---|---|---|
| 0 | `feature-planner` | Plan, reference feature, file plan, API contract |
| 1 | data layer | DTOs, data source, repository implementation, provider registration |
| 2 | domain layer | Models, repository interface, usecases, provider registration |
| 3 | presentation layer | Notifier, state, page, widgets, route |
| 4 | gatekeeper + reviewer (parallel) | Full completion checklist |

`flutter-gatekeeper` returns pass/fail, never a suggestion, on:

- `flutter analyze` clean
- `flutter test` green
- no hardcoded user-facing strings
- permissions declared in **both** `AndroidManifest.xml` and `Info.plist`
- `///` on new public classes, usecases, notifiers, and shared models
- no changes unrelated to the task

## 13. Documentation restructure

### `README.md` — replaced

Currently a changelog for a tooling package called "Flutter AI
Optimization v4", with install steps for that package. It does not say
what the app is, how to run it, or where the documentation lives.
Replaced with roughly 40 lines: what MeCARE is, quickstart, flavor
table, links.

### `Instructions.md` — split

1,444 lines, of which 346 (24%) are one-time new-project setup. The
existing `## I Need To...` table becomes a real router to real files.

| File | Approx. lines | Source sections |
|---|---|---|
| `Instructions.md` | ~110 | Router (`I Need To...`), Project Overview, Golden Rules, Keeping This Document Updated |
| `docs/guide/new-project-setup.md` | 346 | Starting a New Project From This Boilerplate |
| `docs/guide/architecture.md` | ~266 | Architecture, Project Structure, State Management, Navigation, Networking, Auth, Local Storage, Error Handling, Loading/Empty/Error States, Forms, Localization, Security |
| `docs/guide/ui-kit.md` | ~265 | Core UI Kit, Real-World Usage, UI Playground, Theme and Design Tokens |
| `docs/guide/builds-and-flavors.md` | ~192 | Environments and Flavors, Android Builds, iOS Builds, Build Matrix |
| `docs/guide/workflows-and-testing.md` | ~145 | Development Workflows, Testing, Code Quality, Common Architecture Mistakes |
| `docs/guide/troubleshooting.md` | ~90 | Troubleshooting, Debug Tools |

Content is moved, not rewritten, except the stale Testing section
(§ 3.3), which is corrected during the move. The line counts above
account for all 1,444 lines of the current document; nothing is
dropped.

### New files

| File | Tier |
|---|---|
| `PROJECT.md` | Project-authored. **Currently missing** although `CLAUDE.md` names it as the home for app requirements and decisions. |
| `docs/PROJECT_MAP.md` | Generated |
| `docs/workplans/` | Generated |

## 14. Token model — honest accounting

**Subagents increase total tokens per feature.** Each carries briefing
overhead and its own system prompt. Anyone promising otherwise is
selling something.

The gains are elsewhere:

1. **`PROJECT_MAP.md` is the real saving.** It removes an estimated
   15,000–25,000 tokens of rediscovery per feature, in every session,
   for the life of the project. This is the single most cost-effective
   item in this design.
2. **The main window stops filling.** The orchestrator holds the
   workplan path and agent summaries — roughly 10–15k rather than
   60–90k. No mid-feature compaction.
3. **Less rework.** A mistake caught at Gate 1 is cheap; the same
   mistake caught after a finished feature costs roughly three times
   as much. This saving shows up in elapsed time rather than in a
   token counter.

If pure token reduction were the only goal, the correct advice would be
to build `PROJECT_MAP.md` and the skill rewrite and skip the agents.
The agents buy reliability and resumability with additional tokens.
That trade was accepted deliberately.

## 15. Success criteria

- A new project from the boilerplate reaches a working `/feature`
  pipeline via: copy, setup guide, write `PROJECT.md`, `/sync-map`.
- No skill contains a project-specific file path, class name, or
  identifier.
- `/sync-map` regenerates every project fact from source.
- A feature interrupted mid-layer resumes from its workplan file in a
  fresh session with no loss of decisions.
- `flutter-gatekeeper` returns pass/fail against a green baseline.
- `/unit-test` writes tests matching the existing hand-written-fake
  house style, with no new dependency.
- An ad-hoc request that crosses a layer boundary is delegated to
  `flutter-implementer` without being asked by name, and still stops
  at its layer gate.
- A new or modified Notifier, UseCase, or Repository implementation
  does not reach Gate 4 without `flutter-unit-tester` having run.
