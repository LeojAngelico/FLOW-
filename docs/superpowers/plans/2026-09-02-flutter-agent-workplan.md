# Flutter Agent Workplan Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace this project's advisory AI documentation with an executable, resumable, portable feature-delivery pipeline made of six agents, three commands, a generated project map, and a rewritten skill layer.

**Architecture:** Two tiers. Tier 1 (agents, commands, skills, `CLAUDE.md`, `docs/guide/`) carries **method** and contains no project-specific identifier, so it copies unchanged into any project derived from this boilerplate. Tier 2 (`docs/PROJECT_MAP.md`, `PROJECT.md`, `docs/workplans/`) carries **facts** and is generated or project-authored. Skills point into the map instead of hardcoding facts. A Dart test enforces the tier separation mechanically.

**Tech Stack:** Claude Code agents (`.claude/agents/*.md`), skills (`.claude/skills/*/SKILL.md`), slash commands (`.claude/commands/*.md`), Markdown, and Dart tests run by `flutter test`. No new package dependencies.

**Spec:** `docs/superpowers/specs/2026-09-02-flutter-agent-workplan-design.md`

## Global Constraints

- **No new dependencies.** `dev_dependencies` stays `flutter_test` + `flutter_lints: ^6.0.0`. No mocking library. Spec § 9.2.
- **Tier 1 files contain no project-specific identifier.** Enforced by `test/ai_setup_test.dart`. Spec § 4, § 15.
- **Proactive invocation, not proactive execution.** Layer gates in Spec § 12 are unaffected by the proactive declarations. Spec § 7.1.
- **Agent models:** `project-mapper` sonnet, `feature-planner` opus, `flutter-implementer` sonnet, `flutter-unit-tester` sonnet, `flutter-gatekeeper` sonnet, `flutter-reviewer` opus. Spec § 7.
- **Read-only agents get `Read, Grep, Glob` only.** No `WebSearch` or `WebFetch` on any agent. Spec § 7.
- **`flutter-unit-tester` write access is restricted to `test/`.** Spec § 7.
- **Test house style:** hand-written fakes implementing the domain repository interface, `ProviderContainer` with overrides, `///` on fakes, deliberate failure switches. Spec § 9.2.
- **Verification command:** `flutter test` must be green after every task. `flutter analyze` must report no issues.
- **Commit after every task.** Author identity is already configured in the developer's environment.
- The developer owns Android/iOS device testing. No task launches an emulator or simulator.

## File Structure

**Created — Tier 1 (portable):**

| Path | Responsibility |
|---|---|
| `.claude/agents/project-mapper.md` | Scans the repo, writes `docs/PROJECT_MAP.md` |
| `.claude/agents/feature-planner.md` | Requirement → workplan file |
| `.claude/agents/flutter-implementer.md` | Writes one architectural layer per invocation |
| `.claude/agents/flutter-unit-tester.md` | Writes tests; pipeline and on-demand modes |
| `.claude/agents/flutter-gatekeeper.md` | Mechanical pass/fail completion checklist |
| `.claude/agents/flutter-reviewer.md` | Architecture and root-cause judgement |
| `.claude/commands/feature.md` | Orchestrates the gated pipeline |
| `.claude/commands/unit-test.md` | On-demand entry to the unit tester |
| `.claude/commands/sync-map.md` | Regenerates the project map |
| `.claude/skills/flutter-architecture-map/SKILL.md` | Directory contract, layers, provider wiring |
| `.claude/skills/flutter-riverpod-state/SKILL.md` | Notifier/State conventions |
| `.claude/skills/flutter-ui-kit/SKILL.md` | Component-reuse rule (replaces `flutter-presentation-design`) |
| `docs/guide/*.md` | Six chapters split out of `Instructions.md` |

**Created — Tier 2 (generated or project-authored):**

| Path | Responsibility |
|---|---|
| `docs/PROJECT_MAP.md` | Generated inventory of this repository |
| `PROJECT.md` | This app's requirements and decisions |
| `docs/workplans/.gitkeep` | Home for per-task workplan files |

**Created — verification:**

| Path | Responsibility |
|---|---|
| `test/ai_setup_test.dart` | Validates agent/skill/command structure and enforces tier separation |

**Modified:**

| Path | Change |
|---|---|
| `test/widget_test.dart` | Replaced; currently the broken default counter template |
| `.claude/skills/flutter-api-contract/SKILL.md` | Rewritten to point at the map |
| `.claude/skills/flutter-localization/SKILL.md` | Rewritten to point at the map |
| `.claude/skills/flutter-platform-permissions/SKILL.md` | Rewritten to point at the map |
| `.claude/skills/flutter-testing-qa/SKILL.md` | Rewritten around the house test style |
| `.claude/skills/flutter-security/SKILL.md` | Trimmed |
| `.claude/skills/flutter-debugging-code-review/SKILL.md` | Trimmed |
| `CLAUDE.md` | Trimmed of sections that moved |
| `README.md` | Replaced |
| `Instructions.md` | Reduced to a router |

**Deleted:**

| Path | Reason |
|---|---|
| `.claude/skills/flutter-development-workflow/` | Becomes `/feature` |
| `.claude/skills/flutter-context-efficiency/` | Duplicates `CLAUDE.md` |
| `.claude/skills/flutter-presentation-design/` | Renamed to `flutter-ui-kit` |

---

## Phase 0 — Green baseline

Every later task verifies with `flutter test`. That command currently fails, so the suite must be green before anything else is built.

### Task 1: Remove the broken default widget test

`test/widget_test.dart` is the unmodified Flutter counter-app template. Its `pumpWidget` call is commented out while its assertions remain, so it fails. Spec § 9.5 item 1.

It is deleted rather than repaired. Booting the real `App` widget in a test requires secure storage, the router, and the network layer; a smoke test worth having is a larger piece of work, and Spec § 9.6 puts UI Kit widget tests in the on-demand backlog.

**Files:**
- Delete: `test/widget_test.dart`

**Interfaces:**
- Consumes: nothing
- Produces: a green `flutter test` baseline that every later task depends on

- [ ] **Step 1: Confirm the suite is currently red**

Run: `flutter test`
Expected: FAIL, with failures originating in `test/widget_test.dart`. The other five files pass.

- [ ] **Step 2: Delete the file**

```bash
rm test/widget_test.dart
```

- [ ] **Step 3: Confirm the suite is green**

Run: `flutter test`
Expected: PASS, all tests, no failures.

- [ ] **Step 4: Confirm the analyzer is clean**

Run: `flutter analyze`
Expected: `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add -A test/
git commit -m "test: remove broken default counter widget test

The file was the unmodified Flutter template with its pumpWidget call
commented out and its assertions left in place, so the suite could not
go green. UI Kit widget tests are tracked as on-demand work."
```

---

## Phase 1 — Validation harness, project map, and `/sync-map`

### Task 2: AI setup structure test and the `project-mapper` agent

The AI setup is Markdown, so the test that guards it validates structure rather than behaviour: frontmatter parses, required keys are present, and the declared name matches the filename. Written first, against an empty `.claude/agents/`, so it fails before the agent exists.

**Files:**
- Create: `test/ai_setup_test.dart`
- Create: `.claude/agents/project-mapper.md`

**Interfaces:**
- Consumes: nothing
- Produces: `_frontmatter(File) -> Map<String, String>`, a helper reused by Task 3; the `.claude/agents/` directory convention that Tasks 11–15 add files to

- [ ] **Step 1: Write the failing test**

Create `test/ai_setup_test.dart`:

```dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Reads the leading `---` delimited frontmatter block of a Markdown
/// file into a flat map. Values are returned verbatim, unquoted and
/// untrimmed of internal whitespace, which is all these assertions need.
Map<String, String> readFrontmatter(File file) {
  final lines = file.readAsLinesSync();
  if (lines.isEmpty || lines.first.trim() != '---') {
    fail('${file.path}: missing opening --- frontmatter delimiter');
  }
  final result = <String, String>{};
  for (var i = 1; i < lines.length; i++) {
    if (lines[i].trim() == '---') return result;
    final separator = lines[i].indexOf(':');
    if (separator <= 0) continue;
    result[lines[i].substring(0, separator).trim()] =
        lines[i].substring(separator + 1).trim();
  }
  fail('${file.path}: missing closing --- frontmatter delimiter');
}

List<File> markdownFilesIn(String directoryPath) {
  final directory = Directory(directoryPath);
  if (!directory.existsSync()) return const [];
  return directory
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.md'))
      .toList();
}

void main() {
  group('agent definitions', () {
    test('at least one agent is defined', () {
      expect(markdownFilesIn('.claude/agents'), isNotEmpty);
    });

    test('every agent declares name, description, tools and model', () {
      for (final file in markdownFilesIn('.claude/agents')) {
        final frontmatter = readFrontmatter(file);
        for (final key in ['name', 'description', 'tools', 'model']) {
          expect(
            frontmatter[key],
            isNotNull,
            reason: '${file.path}: frontmatter is missing "$key"',
          );
          expect(
            frontmatter[key],
            isNotEmpty,
            reason: '${file.path}: frontmatter key "$key" is empty',
          );
        }
      }
    });

    test('every agent name matches its filename', () {
      for (final file in markdownFilesIn('.claude/agents')) {
        final expected = file.uri.pathSegments.last.replaceAll('.md', '');
        expect(
          readFrontmatter(file)['name'],
          expected,
          reason: '${file.path}: name must equal the filename',
        );
      }
    });

    test('no agent may reach the network', () {
      for (final file in markdownFilesIn('.claude/agents')) {
        final tools = readFrontmatter(file)['tools']!;
        expect(
          tools.contains('WebSearch') || tools.contains('WebFetch'),
          isFalse,
          reason: '${file.path}: network tools are not permitted',
        );
      }
    });
  });

  group('skill definitions', () {
    test('every skill directory holds a SKILL.md naming itself', () {
      final skillsRoot = Directory('.claude/skills');
      expect(skillsRoot.existsSync(), isTrue);
      for (final entry in skillsRoot.listSync().whereType<Directory>()) {
        final skillName = entry.uri.pathSegments
            .where((segment) => segment.isNotEmpty)
            .last;
        final skillFile = File('${entry.path}/SKILL.md');
        expect(
          skillFile.existsSync(),
          isTrue,
          reason: '${entry.path}: SKILL.md is missing',
        );
        final frontmatter = readFrontmatter(skillFile);
        expect(frontmatter['name'], skillName);
        expect(frontmatter['description'], isNotEmpty);
      }
    });
  });
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/ai_setup_test.dart`
Expected: FAIL on `at least one agent is defined` — `.claude/agents` does not exist yet, so `markdownFilesIn` returns an empty list.

- [ ] **Step 3: Create the `project-mapper` agent**

Create `.claude/agents/project-mapper.md`:

```markdown
---
name: project-mapper
description: Scans this repository and regenerates docs/PROJECT_MAP.md. Invoked by /sync-map. Run after adding a feature, adding a UI component, or changing routes, locales, flavors, or platform permissions.
tools: Read, Grep, Glob, Write
model: sonnet
---

# Project Mapper

You regenerate `docs/PROJECT_MAP.md`. It is the single source of
generated facts about this repository. Everything else in the AI setup
is written to be portable and reads its facts from your output.

## Rules

Report only what you can see in the source. Never infer, never carry
anything over from a previous version of the map, and never write a
fact you did not read from a file. An empty section is correct when
the repository has nothing to put in it.

Overwrite the whole file. Do not merge.

## Method

Read `.claude/skills/flutter-architecture-map/SKILL.md` first — it
defines the directory contract you are inventorying against.

Then gather, in this order:

1. **Identity** — package name, description and version from
   `pubspec.yaml`; flavor names from the Android Gradle config and the
   iOS schemes; application ID suffixes.
2. **Features** — every directory under `lib/features/`, which of
   `data/`, `domain/`, `presentation/` each one has, and the screens in
   each.
3. **Routes** — every route path and the screen it renders, from the
   router file under `lib/app/router/`.
4. **UI Kit Catalog** — every component file under the UI kit
   directory, grouped by its category subdirectory, with the public
   class each declares. Exclude token files, the barrel export and any
   playground page.
5. **Design Tokens** — every token class and what it covers.
6. **Network Layer** — the HTTP client, interceptors, the request and
   response class conventions used in `data/`, and the error-mapping
   type.
7. **State** — every Notifier and the state class it owns.
8. **Providers** — the interface-provider to implementation-provider
   wiring, quoting one real example.
9. **Localization** — configured locales, the `.arb` directory, the
   generated output class, and the regeneration command.
10. **Platform** — packages that use native capabilities, and the
    permissions actually declared in the Android manifest and the iOS
    `Info.plist`, listed per platform.
11. **Test Coverage** — for Notifiers, UseCases, repository
    implementations, domain models and UI components: the total, how
    many have tests, and the names of those that do not.
12. **Generated** — the current date and the short commit hash the map
    was generated from.

## Output

Write `docs/PROJECT_MAP.md` with one `##` section per numbered item
above, in that order, using those names. Keep entries terse — a table
or list, not prose. This file is read far more often than it is
written, so every line must earn its tokens.

End the file with the `## Generated` section so a reader can tell
whether the map is stale relative to HEAD.
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/ai_setup_test.dart`
Expected: PASS, four agent assertions and one skill assertion.

- [ ] **Step 5: Run the full suite and the analyzer**

Run: `flutter test && flutter analyze`
Expected: all tests pass; `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add test/ai_setup_test.dart .claude/agents/project-mapper.md
git commit -m "feat: add AI setup structure test and project-mapper agent

The test validates agent and skill frontmatter and forbids network
tools on agents. project-mapper is the first agent it guards."
```

---

### Task 3: Portability guard

Spec § 15 requires that no Tier 1 file contains a project-specific identifier. That requirement decays silently unless a machine checks it, so this test scans every Tier 1 file for identifiers belonging to this particular app.

**Files:**
- Modify: `test/ai_setup_test.dart` (append one group to `main()`)

**Interfaces:**
- Consumes: `readFrontmatter`, `markdownFilesIn` from Task 2
- Produces: the `tier1Files()` helper, and the constraint that Tasks 6–15 must satisfy when writing skill and agent bodies

- [ ] **Step 1: Write the failing test**

Append inside `main()` in `test/ai_setup_test.dart`, after the `skill definitions` group:

```dart
  group('tier separation', () {
    /// Identifiers belonging to this specific application. A Tier 1
    /// file naming any of these would be wrong the moment it is copied
    /// into another project from the same boilerplate — and a skill
    /// that states a wrong fact is worse than one that states none,
    /// because it is trusted.
    const projectSpecificIdentifiers = <String>[
      'flutter_incident_reporting',
      'MeCARE',
      'AppButton',
      'AppTextField',
      'PatientRepository',
      'patient_details',
      'mobile_scanner',
      'Baloo 2',
    ];

    List<File> tier1Files() {
      final files = <File>[
        ...markdownFilesIn('.claude/agents'),
        ...markdownFilesIn('.claude/commands'),
        File('CLAUDE.md'),
      ];
      final skillsRoot = Directory('.claude/skills');
      if (skillsRoot.existsSync()) {
        for (final entry in skillsRoot.listSync().whereType<Directory>()) {
          final skillFile = File('${entry.path}/SKILL.md');
          if (skillFile.existsSync()) files.add(skillFile);
        }
      }
      return files.where((file) => file.existsSync()).toList();
    }

    test('no Tier 1 file names a project-specific identifier', () {
      final violations = <String>[];
      for (final file in tier1Files()) {
        final contents = file.readAsStringSync();
        for (final identifier in projectSpecificIdentifiers) {
          if (contents.contains(identifier)) {
            violations.add('${file.path} contains "$identifier"');
          }
        }
      }
      expect(
        violations,
        isEmpty,
        reason: 'Tier 1 must stay portable. Move these facts into '
            'docs/PROJECT_MAP.md and reference the section instead:\n'
            '${violations.join('\n')}',
      );
    });

    test('generated files are never Tier 1', () {
      expect(File('docs/PROJECT_MAP.md').existsSync(), isTrue,
          reason: 'run /sync-map to generate the project map');
      expect(markdownFilesIn('.claude/agents')
          .any((file) => file.path.contains('PROJECT_MAP')), isFalse);
    });
  });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/ai_setup_test.dart -n "tier separation"`
Expected: FAIL on `generated files are never Tier 1` — `docs/PROJECT_MAP.md` does not exist yet. The identifier scan passes, because `project-mapper.md` was written without project facts.

- [ ] **Step 3: Create the workplan directory and a placeholder map**

The map's real contents come from `/sync-map` in Task 4. This step only creates the file so the structural assertion has something to find.

```bash
mkdir -p docs/workplans
touch docs/workplans/.gitkeep
printf '# Project Map\n\nNot yet generated. Run `/sync-map`.\n' > docs/PROJECT_MAP.md
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/ai_setup_test.dart`
Expected: PASS, all groups.

- [ ] **Step 5: Commit**

```bash
git add test/ai_setup_test.dart docs/PROJECT_MAP.md docs/workplans/.gitkeep
git commit -m "test: enforce tier separation between portable and generated files

Scans agents, commands, skills and CLAUDE.md for identifiers specific
to this app. A Tier 1 file that names one would be false as soon as it
is copied into another project from this boilerplate."
```

---

### Task 4: The `/sync-map` command and the first real map

**Files:**
- Create: `.claude/commands/sync-map.md`
- Modify: `docs/PROJECT_MAP.md` (replaced by the agent's output)

**Interfaces:**
- Consumes: `.claude/agents/project-mapper.md` from Task 2
- Produces: `docs/PROJECT_MAP.md` with the twelve `##` sections named in the project-mapper agent; every skill written in Phase 2 references these section names

- [ ] **Step 1: Create the command**

Create `.claude/commands/sync-map.md`:

```markdown
---
description: Regenerate docs/PROJECT_MAP.md from the current source tree
---

Delegate to the `project-mapper` agent.

Instruct it to regenerate `docs/PROJECT_MAP.md` in full from the
current source tree, following the twelve sections defined in its own
agent file, and to overwrite rather than merge.

When it returns, report only:

- which sections changed since the previous map
- any section it had to leave empty, and why

Do not restate the map's contents. The developer can read the file.
```

- [ ] **Step 2: Run the command**

Run `/sync-map` in a Claude Code session at the repository root.

Expected: `docs/PROJECT_MAP.md` is rewritten with twelve `##` sections. Spot-check three facts against source, all of which the plan author verified while writing this plan:

| Section | Must contain |
|---|---|
| `## UI Kit Catalog` | exactly 20 components across the categories `buttons`, `dialogs`, `feedback`, `indicators`, `inputs`, `surfaces` — excluding the 5 token files, the barrel and the playground page |
| `## Localization` | three locales (`en`, `fil`, `ceb`), arb-dir `lib/l10n`, output class `AppLocalizations` |
| `## Test Coverage` | 13 Notifiers with 4 tested; 15 UseCases with 0 tested; 4 repository implementations with 0 tested |

If any of these three is wrong, the agent's method section is at fault — correct `.claude/agents/project-mapper.md` and re-run rather than hand-editing the map.

- [ ] **Step 3: Verify the map is not counted as Tier 1**

Run: `flutter test test/ai_setup_test.dart`
Expected: PASS. The identifier scan must still pass — the map is full of project-specific identifiers, and it must not be picked up by `tier1Files()`.

- [ ] **Step 4: Run the full suite and the analyzer**

Run: `flutter test && flutter analyze`
Expected: all tests pass; `No issues found!`

- [ ] **Step 5: Commit**

```bash
git add .claude/commands/sync-map.md docs/PROJECT_MAP.md
git commit -m "feat: add /sync-map and generate the first project map

The map carries every project-specific fact so that agents, skills and
commands can stay portable across projects from this boilerplate."
```

---

## Phase 2 — The skill layer

Nine skills before, nine after, with substantially different contents. Spec § 6.

Each task in this phase adds one assertion to the `skill definitions` group in `test/ai_setup_test.dart`, so the suite stays green at every task boundary rather than going red for the length of the phase.

### Task 5: Remove the two duplicated skills

`flutter-development-workflow` (1,139 bytes) restates `CLAUDE.md` § Feature Workflow; it becomes the `/feature` command in Task 15. `flutter-context-efficiency` (2,352 bytes) restates `CLAUDE.md` § Context and Token Efficiency; its operative rules move into agent definitions, where they constrain behaviour instead of describing it. Spec § 6.

**Files:**
- Delete: `.claude/skills/flutter-development-workflow/`
- Delete: `.claude/skills/flutter-context-efficiency/`
- Modify: `test/ai_setup_test.dart`

**Interfaces:**
- Consumes: the `skill definitions` group from Task 2
- Produces: `skillNames() -> List<String>`, used by Tasks 6, 7 and 8

- [ ] **Step 1: Write the failing test**

Add to the top of the `skill definitions` group in `test/ai_setup_test.dart`:

```dart
    List<String> skillNames() {
      final skillsRoot = Directory('.claude/skills');
      if (!skillsRoot.existsSync()) return const [];
      return skillsRoot
          .listSync()
          .whereType<Directory>()
          .map((entry) =>
              entry.uri.pathSegments.where((s) => s.isNotEmpty).last)
          .toList();
    }

    test('skills that duplicate CLAUDE.md are absent', () {
      expect(skillNames(), isNot(contains('flutter-development-workflow')),
          reason: 'this workflow belongs in the /feature command');
      expect(skillNames(), isNot(contains('flutter-context-efficiency')),
          reason: 'these rules belong in CLAUDE.md and agent definitions');
    });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/ai_setup_test.dart -n "duplicate"`
Expected: FAIL — both directories still exist.

- [ ] **Step 3: Delete the two skills**

```bash
rm -rf .claude/skills/flutter-development-workflow
rm -rf .claude/skills/flutter-context-efficiency
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/ai_setup_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add -A .claude/skills test/ai_setup_test.dart
git commit -m "refactor: drop the two skills that duplicated CLAUDE.md

flutter-development-workflow becomes the /feature command;
flutter-context-efficiency's rules move into agent definitions."
```

---

### Task 6: The `flutter-architecture-map` skill

The highest-value skill in the set: the directory contract every agent reads before touching code. Portable, because every project derived from this boilerplate shares this shape. Spec § 6.

**Files:**
- Create: `.claude/skills/flutter-architecture-map/SKILL.md`
- Modify: `test/ai_setup_test.dart`

**Interfaces:**
- Consumes: `skillNames()` from Task 5
- Produces: the skill that `project-mapper`, `feature-planner`, `flutter-implementer` and `flutter-reviewer` all name as their first read

- [ ] **Step 1: Write the failing test**

Add to the `skill definitions` group:

```dart
    test('the architecture map skill exists and points at PROJECT_MAP', () {
      expect(skillNames(), contains('flutter-architecture-map'));
      final contents = File(
        '.claude/skills/flutter-architecture-map/SKILL.md',
      ).readAsStringSync();
      expect(contents, contains('docs/PROJECT_MAP.md'));
    });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/ai_setup_test.dart -n "architecture map"`
Expected: FAIL — the directory does not exist.

- [ ] **Step 3: Create the skill**

Create `.claude/skills/flutter-architecture-map/SKILL.md`:

```markdown
---
name: flutter-architecture-map
description: The directory contract, layer responsibilities and provider wiring for this Flutter boilerplate. Read this before creating any file, deciding where code belongs, or reviewing structure.
---

# Architecture Map

This skill describes the **shape**. For what actually exists in this
repository — features, routes, components, endpoints — read
`docs/PROJECT_MAP.md`. If the map is missing or stale, run `/sync-map`.

## Flow

`UI → Notifier → UseCase → Repository → DataSource → API or storage`

Dependencies point inward. `domain/` knows nothing about `data/`.
`data/` implements interfaces that `domain/` declares.

## Directory contract

Every feature lives at `lib/features/<feature>/` with three layers.

```
data/
  datasources/    talks to the network or platform; transport lives here
  models/         DTOs with fromJson and toDomain
  requests/       one class per call, with toJson
  responses/      one class per call, parsing the envelope
  repositories/   implements the domain repository interface
  providers/      binds the interface provider to the implementation
domain/
  models/         plain Dart; no JSON knowledge, no framework imports
  repositories/   abstract interface only
  usecases/       one class, one execute method, repository injected
  providers/      declares the usecase providers
presentation/
  <screen>_page.dart       renders state; no business logic
  <screen>_notifier.dart   coordinates usecases
  <screen>_state.dart      the state this screen owns
  widgets/                 pieces used only by this feature
```

Shared code lives under `lib/core/`. App-level wiring — router, theme,
locale, shell — lives under `lib/app/`.

A feature that has no remote data has no `data/` directory. Do not
create empty layers to complete a pattern.

## Provider wiring

Two provider files per feature, and the direction matters.

- `data/providers/` constructs the data source and repository
  implementation, and exposes the repository **typed as the domain
  interface**.
- `domain/providers/` constructs the usecases, reading the repository
  provider declared in `data/providers/`.

This is what lets tests override one provider and replace the whole
data layer with a fake. See `docs/PROJECT_MAP.md` § Providers for a
worked example from this repository.

## Placement decisions

| Question | Answer |
|---|---|
| Where does a validation rule go? | A usecase, or the domain model. Never a widget. |
| Where does JSON parsing go? | `data/models/`, `data/responses/`. Never `domain/`. |
| Where does a reused widget go? | The core UI kit if any feature could use it; the feature's `widgets/` otherwise. |
| Where does an error become a message? | The error mapper in `lib/core/`. See § Network Layer of the map. |
| Where does navigation go? | The router under `lib/app/`. Notifiers expose state; pages navigate. |

## Before creating anything

1. Read `docs/PROJECT_MAP.md` for what already exists.
2. Find the closest existing feature and mirror it. Consistency with a
   working neighbour beats an improvement nobody else follows.
3. Create a new class only when reuse or responsibility would otherwise
   be unclear.
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/ai_setup_test.dart`
Expected: PASS, including the tier-separation scan — this skill names no project-specific identifier.

- [ ] **Step 5: Commit**

```bash
git add .claude/skills/flutter-architecture-map test/ai_setup_test.dart
git commit -m "feat: add the flutter-architecture-map skill

Describes the layer contract and provider wiring shape, and delegates
every concrete fact to docs/PROJECT_MAP.md so it stays portable."
```

---

### Task 7: The `flutter-riverpod-state` skill

Absent today, despite Notifiers being the most frequently written code in the project. Spec § 6.

**Files:**
- Create: `.claude/skills/flutter-riverpod-state/SKILL.md`
- Modify: `test/ai_setup_test.dart`

**Interfaces:**
- Consumes: `skillNames()` from Task 5
- Produces: the state conventions that `flutter-implementer` follows for the presentation layer and `flutter-unit-tester` follows when overriding providers

- [ ] **Step 1: Write the failing test**

Add to the `skill definitions` group:

```dart
    test('the riverpod state skill exists and forbids legacy notifiers', () {
      expect(skillNames(), contains('flutter-riverpod-state'));
      final contents = File(
        '.claude/skills/flutter-riverpod-state/SKILL.md',
      ).readAsStringSync();
      expect(contents, contains('StateNotifier'),
          reason: 'the skill must name what is forbidden, not stay silent');
      expect(contents, contains('ProviderContainer'));
    });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/ai_setup_test.dart -n "riverpod state"`
Expected: FAIL — the directory does not exist.

- [ ] **Step 3: Create the skill**

Create `.claude/skills/flutter-riverpod-state/SKILL.md`:

```markdown
---
name: flutter-riverpod-state
description: Riverpod presentation-state conventions for this boilerplate — Notifier, NotifierProvider, state classes, async and error states, and provider overrides in tests. Use when creating or modifying any Notifier, state class, provider, or screen state.
---

# Riverpod State

For the Notifiers that already exist in this repository and the state
class each one owns, read `docs/PROJECT_MAP.md` § State.

## What to use

Use `Notifier` with `NotifierProvider`.

Do not use `StateNotifier`, `ChangeNotifier`, or `setState` for
application state. They are not this project's pattern, and mixing
patterns is worse than either one alone.

## State classes

One state class per screen, owned by that screen's Notifier, in its own
`<screen>_state.dart`.

- Immutable, with a `copyWith`.
- Model loading, error and empty as explicit fields or an explicit
  status, not as a null that the widget has to interpret.
- Hold presentation-ready values. A widget should render a state field,
  not compute from it.
- Value equality, so rebuilds happen when the value actually changed.

## Notifiers

- Coordinate usecases. A Notifier that talks to a repository directly
  has skipped a layer.
- Read dependencies through `ref.read` of the usecase providers.
- Catch failures at the Notifier boundary and put them into state.
  Never let an exception escape into the widget tree.
- Guard against duplicate submissions: an in-flight action must not be
  startable twice.

## Testing

Construct a `ProviderContainer` and override the repository provider
declared in the feature's `data/providers/` with a hand-written fake.
Overriding at the repository boundary exercises the real usecases and
the real Notifier while replacing only the network.

Always `addTearDown(container.dispose)`.

Assert on emitted state values, not on internal calls.

See `.claude/skills/flutter-testing-qa/SKILL.md` for the fake style,
and `docs/PROJECT_MAP.md` § Test Coverage for what is already covered.
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/ai_setup_test.dart`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add .claude/skills/flutter-riverpod-state test/ai_setup_test.dart
git commit -m "feat: add the flutter-riverpod-state skill

Covers Notifier and state-class conventions and the ProviderContainer
override pattern used by this project's existing tests."
```

---

### Task 8: Rename `flutter-presentation-design` to `flutter-ui-kit`

The design-priority ladder is kept. What is added is the hard reuse rule that addresses the confirmed pain point of rebuilding components that already exist. Spec § 6.

**Files:**
- Delete: `.claude/skills/flutter-presentation-design/`
- Create: `.claude/skills/flutter-ui-kit/SKILL.md`
- Modify: `test/ai_setup_test.dart`

**Interfaces:**
- Consumes: `skillNames()` from Task 5
- Produces: the component-reuse rule that `flutter-reviewer` enforces

- [ ] **Step 1: Write the failing test**

Add to the `skill definitions` group:

```dart
    test('the ui kit skill replaces the presentation-design skill', () {
      expect(skillNames(), isNot(contains('flutter-presentation-design')));
      expect(skillNames(), contains('flutter-ui-kit'));
      final contents =
          File('.claude/skills/flutter-ui-kit/SKILL.md').readAsStringSync();
      expect(contents, contains('UI Kit Catalog'),
          reason: 'the skill must send the reader to the map section');
    });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/ai_setup_test.dart -n "ui kit skill"`
Expected: FAIL — the old directory is present and the new one is not.

- [ ] **Step 3: Create the new skill and delete the old one**

Create `.claude/skills/flutter-ui-kit/SKILL.md`:

```markdown
---
name: flutter-ui-kit
description: Build presentation layers from the existing design system instead of inventing UI. Use for screens, widgets, styling, responsive layout, accessibility, and any decision about whether to create a new component.
---

# UI Kit

## Before creating any widget

Read `docs/PROJECT_MAP.md` § UI Kit Catalog.

If a component there does the job, use it. If one nearly does, extend
it rather than forking it. Create a new component only when no existing
one has that responsibility — and then decide whether it belongs to the
shared kit or to the feature.

Rebuilding something the kit already provides is the most common defect
in this codebase's history. Check first, every time.

## Design priority

`Approved design file > approved mockup or screenshot > existing design
system > platform conventions > your own proposal`

Where an approved design exists, follow it and inspect it when access
is available. Do not redesign it. Where a behaviour is genuinely
unclear, ask rather than invent a materially different experience.

## Styling

Use the design tokens and the theme. See `docs/PROJECT_MAP.md`
§ Design Tokens.

Never hardcode a colour, radius, spacing value or text style in a
widget. A component that hardcodes them will not follow a theme change,
which is the entire reason the tokens exist.

## Shared or feature-owned

A component belongs to the shared kit when any feature could plausibly
use it and it carries no feature-specific logic. Otherwise it belongs
in that feature's `widgets/`.

A shared component must be exported from the kit's barrel file and must
style itself only from the theme and tokens.

## Always consider

Small and large phones; safe areas; the keyboard; text scaling;
accessibility semantics and touch targets; contrast; and layouts that
survive longer translated strings.

Evaluate Android and iOS presentation differences where they matter.

## Business logic

A widget renders state. Business rules live in the usecase and the
Notifier. If a widget is deciding something, it is in the wrong layer —
see `.claude/skills/flutter-architecture-map/SKILL.md`.

## Claims

Do not claim a layout matches a design unless it was actually compared
against one.
```

Then remove the old directory:

```bash
rm -rf .claude/skills/flutter-presentation-design
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/ai_setup_test.dart`
Expected: PASS. The tier-separation scan must also pass — the catalog lives in the map, so no component class name appears here.

- [ ] **Step 5: Commit**

```bash
git add -A .claude/skills test/ai_setup_test.dart
git commit -m "refactor: rename presentation-design skill to flutter-ui-kit

Keeps the design-priority ladder and adds the reuse rule: consult the
map's UI Kit Catalog before creating any widget."
```

---

### Task 9: Point the four fact-dependent skills at the map

`flutter-api-contract`, `flutter-localization`, `flutter-platform-permissions` and `flutter-testing-qa` each keep their method and gain a pointer to the relevant map section, replacing the discovery reads they currently force. Spec § 6.

**Files:**
- Modify: `.claude/skills/flutter-api-contract/SKILL.md`
- Modify: `.claude/skills/flutter-localization/SKILL.md`
- Modify: `.claude/skills/flutter-platform-permissions/SKILL.md`
- Modify: `.claude/skills/flutter-testing-qa/SKILL.md`
- Modify: `test/ai_setup_test.dart`

**Interfaces:**
- Consumes: the map sections `## Network Layer`, `## Localization`, `## Platform`, `## Test Coverage` produced in Task 4
- Produces: `flutter-testing-qa`'s documented house style, which `flutter-unit-tester` follows in Task 13

- [ ] **Step 1: Write the failing test**

Add to the `skill definitions` group:

```dart
    test('fact-dependent skills reference their map section', () {
      const expectedSection = <String, String>{
        'flutter-api-contract': 'Network Layer',
        'flutter-localization': 'Localization',
        'flutter-platform-permissions': 'Platform',
        'flutter-testing-qa': 'Test Coverage',
      };
      expectedSection.forEach((skill, section) {
        final contents =
            File('.claude/skills/$skill/SKILL.md').readAsStringSync();
        expect(contents, contains('docs/PROJECT_MAP.md'),
            reason: '$skill must send the reader to the map');
        expect(contents, contains(section),
            reason: '$skill must name the map section it depends on');
      });
    });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/ai_setup_test.dart -n "map section"`
Expected: FAIL — none of the four mentions the map.

- [ ] **Step 3: Rewrite `flutter-api-contract`**

Replace the body below the frontmatter, keeping the existing `name` and `description`, with:

```markdown
# API Contract

For this project's HTTP client, interceptors, request and response
class conventions, and error-mapping type, read
`docs/PROJECT_MAP.md` § Network Layer. Do not rediscover them by
reading the data layer.

## Before coupling to a backend

Identify: path and method; authentication and headers; path and query
parameters; request body with required and optional fields; types,
enums and validation; the success response; error responses and status
codes; pagination; upload handling; and token refresh behaviour.

## When the contract is unknown

Do not invent an API, and do not proceed quietly on a guess.

Ask for documentation, a collection export, or a sample response. If a
proposal is useful, label it explicitly as proposed and get
confirmation before coupling implementation to it.

An implementation built on a guessed contract is worse than no
implementation, because it looks finished.

## Implementation

Transport details stay in the data layer. Reuse the existing client and
interceptors; do not construct a second one. Do not add a duplicate
response model for a shape that is already parsed somewhere.

Map errors through the project's existing error type rather than
letting a transport exception reach a Notifier.

## Security

Never log tokens, credentials or sensitive payloads. Treat every
response as untrusted input. Client-side validation is not
authorization.
```

- [ ] **Step 4: Rewrite `flutter-localization`**

Replace the body below the frontmatter with:

```markdown
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
```

- [ ] **Step 5: Rewrite `flutter-platform-permissions`**

Replace the body below the frontmatter with:

```markdown
# Platform Capabilities and Permissions

For the packages this project uses for native capabilities and the
permissions actually declared for each platform, read
`docs/PROJECT_MAP.md` § Platform.

## Rule

Every platform-dependent feature is evaluated for **both** Android and
iOS before it is considered complete. Android and iOS permission
behaviour is not equivalent, and assuming it is produces a feature that
works on one platform and fails silently on the other.

## For each capability

1. Confirm the Flutter package supports what is needed on both
   platforms.
2. Add the Android manifest declaration.
3. Add the iOS usage-description key, with a string a reviewer will
   accept — it is shown to the user.
4. Implement the runtime request in context, at the moment the
   capability is needed, not at launch.
5. Handle denied, permanently denied and restricted separately. They
   need different UI: retry, send to Settings, and explain.
6. Handle the permission changing while the app is backgrounded and the
   user returns from Settings.
7. Handle hardware that is absent or unavailable.
8. Consider what happens across app lifecycle transitions.
9. Remember that emulators and simulators do not faithfully reproduce
   permission or hardware behaviour. State plainly that device testing
   is required, and leave it to the developer.

## Restraint

Do not request a permission the feature does not need, and do not
request it earlier than needed. Each unnecessary prompt costs trust and
grants.

When adding a package, inspect its native setup and the permissions it
pulls in before treating the feature as done.
```

- [ ] **Step 6: Rewrite `flutter-testing-qa`**

Replace the body below the frontmatter with:

```markdown
# Testing and QA

For what is already covered and what is not, read
`docs/PROJECT_MAP.md` § Test Coverage.

## House style — mirror it, do not replace it

This project uses **hand-written fakes**. There is no mocking library
in `dev_dependencies`, and that is deliberate.

- A fake is a class that `implements` the domain repository interface.
- Give it deliberate failure switches — a flag the test sets to make
  the next call throw — so error paths can be exercised without an HTTP
  layer.
- Document the fake with `///`, saying what real thing it stands in
  for.
- Seed it with static fixture data rather than building fixtures in
  every test.

Construct a `ProviderContainer`, override the repository provider from
the feature's `data/providers/` with the fake, and
`addTearDown(container.dispose)`.

Read an existing test before writing a new one and match it. Consistency
with the four tests already in this repository matters more than any
improvement to their style.

## What to test, in priority order

1. **Notifiers** — presentation logic; the highest value in this
   codebase.
2. **UseCases** — pure Dart, fast, cheap.
3. **Repository implementations** — where DTO-to-domain mapping bugs
   hide.
4. **Widgets** — components in the shared kit are the easiest
   high-value widget tests, being mostly stateless with no network.

Assert on behaviour and emitted state, never on internal call order.

## Edge cases worth a test

Empty and boundary input; input beyond the limit; duplicate submission
and repeated taps; network failure and timeout; an unauthorized
session; malformed or missing fields in a response; stale UI after a
change; back navigation; a denied permission; and a longer localized
string.

## Reporting a bug

Title; environment; preconditions; steps; expected; actual; severity;
evidence.

## Claims

Never state that tests pass without having run them and read the
output.
```

- [ ] **Step 8: Run the test to verify it passes**

Run: `flutter test test/ai_setup_test.dart`
Expected: PASS, including the tier-separation scan — no locale code, package name or class name appears in any of the four.

- [ ] **Step 8: Commit**

```bash
git add .claude/skills test/ai_setup_test.dart
git commit -m "refactor: point the fact-dependent skills at PROJECT_MAP

Each keeps its method and names the map section it depends on, instead
of forcing rediscovery reads through the data layer."
```

---

### Task 10: Trim the two principle skills and cap skill size

`flutter-security` and `flutter-debugging-code-review` are legitimately principle-based and keep their substance; only their overlap with `CLAUDE.md` is removed. The size cap added here is what stops any skill from drifting back into being a second constitution. Spec § 6.

**Files:**
- Modify: `.claude/skills/flutter-security/SKILL.md`
- Modify: `.claude/skills/flutter-debugging-code-review/SKILL.md`
- Modify: `test/ai_setup_test.dart`

**Interfaces:**
- Consumes: `skillNames()` from Task 5
- Produces: a 4,000-byte ceiling that every future skill must respect

- [ ] **Step 1: Write the failing test**

Add to the `skill definitions` group:

```dart
    test('no skill exceeds 4000 bytes', () {
      final oversized = <String>[];
      for (final skill in skillNames()) {
        final file = File('.claude/skills/$skill/SKILL.md');
        final size = file.lengthSync();
        if (size > 4000) oversized.add('$skill is $size bytes');
      }
      expect(oversized, isEmpty,
          reason: 'a skill this long has become a second constitution; '
              'move facts to docs/PROJECT_MAP.md and rules to CLAUDE.md\n'
              '${oversized.join('\n')}');
    });
```

- [ ] **Step 2: Run the test**

Run: `flutter test test/ai_setup_test.dart -n "4000 bytes"`
Expected: PASS. The largest skill written so far is under the ceiling. This assertion is a regression guard, not a red-to-green cycle — it is written now, while the set is lean, precisely so that it fails later if a skill bloats.

- [ ] **Step 3: Trim `flutter-security`**

Remove from the body the material that `CLAUDE.md` § Security already states: the "never hardcode secrets", "use HTTPS/TLS" and "never claim an app is hack-proof" lines. Keep the nine review questions, the untrusted-input list, the secure-storage rule, the "client-side checks are not authorization" rule, and the instruction to flag controls needing backend support.

Add as the first line of the body:

```markdown
For where this project stores credentials and how it maps errors, read
`docs/PROJECT_MAP.md` § Network Layer.
```

- [ ] **Step 4: Trim `flutter-debugging-code-review`**

Keep the debugging sequence, the symptom/root-cause/fix/optional separation, and the ten-item review priority list. Remove the "avoid unrelated refactoring" and "do not claim a build passed unless it was run" lines, both of which `CLAUDE.md` states.

Add as the first line of the body:

```markdown
Before tracing a flow, read `.claude/skills/flutter-architecture-map/SKILL.md`
to identify which layer the symptom belongs to.
```

- [ ] **Step 5: Verify the whole suite and the analyzer**

Run: `flutter test && flutter analyze`
Expected: all tests pass; `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add .claude/skills test/ai_setup_test.dart
git commit -m "refactor: trim the principle skills and cap skill size at 4000 bytes

Removes overlap with CLAUDE.md and adds a regression guard against a
skill growing into a second constitution."
```

---

## Phase 3 — The remaining agents and the commands

Every agent added here is validated by the structure test from Task 2 and the tier-separation scan from Task 3 the moment it lands.

### Task 11: The `feature-planner` agent and the workplan format

The only opus agent on the writing path. It produces the workplan file, which is what makes an interrupted feature resumable. Spec § 7, § 11.

**Files:**
- Create: `.claude/agents/feature-planner.md`

**Interfaces:**
- Consumes: `docs/PROJECT_MAP.md` (Task 4), `flutter-architecture-map` (Task 6)
- Produces: `docs/workplans/YYYY-MM-DD-<task>.md` with the seven sections defined below; every later agent reads and updates this file

- [ ] **Step 1: Create the agent**

Create `.claude/agents/feature-planner.md`:

```markdown
---
name: feature-planner
description: Turns a feature requirement into a written workplan — reference feature, per-layer file plan, API contract, and gate checklist. Invoked by /feature, and whenever an ad-hoc request turns out to span more than one architectural layer.
tools: Read, Grep, Glob, Write
model: opus
---

# Feature Planner

You plan. You do not implement. Writing production code is out of
scope for you even when the change looks trivial.

## Read first

1. `docs/PROJECT_MAP.md` — what exists
2. `PROJECT.md` — what this app is and what has been decided
3. `.claude/skills/flutter-architecture-map/SKILL.md` — where code goes

Read feature source only after the map has told you which feature is
the closest match. Reading broadly before that is the waste this whole
system exists to remove.

## Establish the API contract

If the feature needs a backend call, settle the contract before
planning files: path, method, auth, parameters, request body, response
shape, error codes.

If the contract is unknown, **stop**. Write the workplan with the
contract marked `BLOCKED`, state exactly what you need, and return.
Do not propose an endpoint as though it were confirmed, and do not plan
a data layer against a guess.

## Choose a reference feature

Name the one existing feature the new work should mirror, and say why.
Every later agent follows it. Getting this wrong makes the whole
feature inconsistent, so pick the closest real match rather than the
most convenient one.

## Write the workplan

Write `docs/workplans/YYYY-MM-DD-<short-task-name>.md`:

    # Workplan: <task>
    Status: planning
    Reference feature: <feature>          Last agent: feature-planner

    ## Requirement
    What is being built, and the acceptance criteria.

    ## API contract
    confirmed | proposed | BLOCKED — with the contract or the question.

    ## File plan
    Checkboxes, grouped under Data / Domain / Presentation, each with
    the exact path and one line on its responsibility.

    ## Decisions log
    What you chose and why. Include what you rejected.

    ## Gate results
    analyze / tests / localization / platform / security — empty for now.

    ## Manual QA for the developer
    What only a person on a device can confirm.

Then report to the orchestrator: the workplan path, the reference
feature, the contract status, and the file count per layer. Nothing
else — the file holds the detail.

## Scope discipline

Remove anything the requirement does not need. A plan is the cheapest
place to delete work, and the only place where deleting it costs
nothing.

If the requirement is really several features, say so and propose the
split instead of planning all of it.
```

- [ ] **Step 2: Verify the structure test accepts it**

Run: `flutter test test/ai_setup_test.dart`
Expected: PASS. `name` matches the filename, all four frontmatter keys are present, no network tools, and no project-specific identifier.

- [ ] **Step 3: Commit**

```bash
git add .claude/agents/feature-planner.md
git commit -m "feat: add the feature-planner agent

Produces the workplan file that makes an interrupted feature resumable,
and blocks rather than guessing when the API contract is unknown."
```

---

### Task 12: The `flutter-implementer` agent

Proactive by declaration, gated by execution. Spec § 7, § 7.1, § 12.

**Files:**
- Create: `.claude/agents/flutter-implementer.md`
- Modify: `test/ai_setup_test.dart`

**Interfaces:**
- Consumes: the workplan written by `feature-planner` (Task 11)
- Produces: updates to the workplan's `## File plan` checkboxes and `## Decisions log`, which `flutter-gatekeeper` and `flutter-reviewer` read at Gate 4

- [ ] **Step 1: Write the failing test**

Add a new group to `main()` in `test/ai_setup_test.dart`:

```dart
  group('proactive declarations', () {
    test('the implementer is declared proactive with a threshold', () {
      final description = readFrontmatter(
        File('.claude/agents/flutter-implementer.md'),
      )['description']!;
      expect(description, contains('PROACTIVELY'));
      expect(description.toLowerCase(), contains('two or more files'));
    });
  });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/ai_setup_test.dart -n "proactive"`
Expected: FAIL — the agent file does not exist, so `readFrontmatter` cannot read it.

- [ ] **Step 3: Create the agent**

Create `.claude/agents/flutter-implementer.md`:

```markdown
---
name: flutter-implementer
description: Implements one architectural layer of a planned feature. Use PROACTIVELY when a change touches two or more files or crosses a layer boundary. Single-file trivial edits do not need this agent.
tools: Read, Edit, Write, Grep, Glob
model: sonnet
---

# Implementer

You implement **one layer per invocation**. The layer is named in your
instructions: data, domain, or presentation. Do not start the next one.
Stopping at the layer boundary is what lets the developer catch a wrong
direction after one layer instead of three.

## Read first

1. The workplan file named in your instructions — the file plan for
   your layer, the reference feature, and the decisions already made
2. `.claude/skills/flutter-architecture-map/SKILL.md`
3. The reference feature's equivalent layer, in full

Read the reference layer before writing anything. You are matching an
existing pattern, not designing one.

Also read, for your layer:

- data → `.claude/skills/flutter-api-contract/SKILL.md`
- presentation → `.claude/skills/flutter-riverpod-state/SKILL.md`,
  `.claude/skills/flutter-ui-kit/SKILL.md`,
  `.claude/skills/flutter-localization/SKILL.md`
- any layer touching a native capability →
  `.claude/skills/flutter-platform-permissions/SKILL.md`

## Rules

Build only the files in the plan for your layer. A file you think is
missing is a planning question — note it and raise it; do not add it.

Mirror the reference feature's naming, file layout and provider wiring
exactly.

Do not modify a file outside your layer. Do not refactor anything the
task did not ask you to change. Do not add a dependency.

Register providers as you go — an unregistered provider is an
unfinished layer, not a later task.

Document with `///`: public classes, usecases, notifiers, shared
models, and anything whose behaviour is not obvious from its name.

No hardcoded user-facing strings. No hardcoded colours, spacing or
radii.

## Before you report

Check your own layer against the plan: every checkbox ticked, nothing
extra written.

Update the workplan file: tick the file plan boxes for your layer, set
`Status` to your layer's name, set `Last agent`, and add anything you
decided that the plan did not specify to `## Decisions log`.

## Report

The files you created or modified, the decisions you added, and
anything you could not do and why. Do not paste file contents — the
developer reads the diff.
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/ai_setup_test.dart`
Expected: PASS, all groups.

- [ ] **Step 5: Commit**

```bash
git add .claude/agents/flutter-implementer.md test/ai_setup_test.dart
git commit -m "feat: add the proactive flutter-implementer agent

Implements one layer per invocation and stops at the layer boundary.
Declared proactive above a two-file threshold so one-line edits stay in
the main session."
```

---

### Task 13: The `flutter-unit-tester` agent and `/unit-test`

The most strongly proactive agent, and the direct answer to the confirmed pain point of tests being forgotten. Spec § 7.1, § 9.

**Files:**
- Create: `.claude/agents/flutter-unit-tester.md`
- Create: `.claude/commands/unit-test.md`
- Modify: `test/ai_setup_test.dart`

**Interfaces:**
- Consumes: `flutter-testing-qa` (Task 9), `docs/PROJECT_MAP.md` § Test Coverage (Task 4)
- Produces: test files under `test/`, and `docs/workplans/YYYY-MM-DD-test-coverage.md` for backlog runs

- [ ] **Step 1: Write the failing test**

Add to the `proactive declarations` group:

```dart
    test('the unit tester is declared mandatory after state code', () {
      final description = readFrontmatter(
        File('.claude/agents/flutter-unit-tester.md'),
      )['description']!;
      expect(description, contains('MUST BE USED'));
      expect(description, contains('Notifier'));
      expect(description, contains('UseCase'));
    });

    test('the unit tester cannot write outside test/', () {
      final body =
          File('.claude/agents/flutter-unit-tester.md').readAsStringSync();
      expect(body, contains('test/'),
          reason: 'the write restriction must be stated in the body');
    });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/ai_setup_test.dart -n "unit tester"`
Expected: FAIL — the agent file does not exist.

- [ ] **Step 3: Create the agent**

Create `.claude/agents/flutter-unit-tester.md`:

```markdown
---
name: flutter-unit-tester
description: Writes unit and widget tests in this project's established style. MUST BE USED after any Notifier, UseCase, or Repository implementation is created or modified. Also handles on-demand requests to test existing code, via /unit-test.
tools: Read, Write, Grep, Glob, Bash
model: sonnet
---

# Unit Tester

You write tests. You never modify production code — if a test cannot be
written without changing `lib/`, that is a finding to report, not a
change to make. Write only under `test/`.

## Read first

1. `.claude/skills/flutter-testing-qa/SKILL.md` — the house style
2. `docs/PROJECT_MAP.md` § Test Coverage — what is already covered
3. **An existing test for the same kind of subject**, in full

The third is not optional. This project has a specific, deliberate test
style and your job is to extend it, not to improve on it.

## Two modes

**Pipeline mode** — invoked after a feature's presentation layer. Test
only what that feature added. The workplan file names it.

**On-demand mode** — invoked by `/unit-test`. The target may be one
file, a feature, a layer, or nothing at all. With no target, take the
highest-priority gap from the map:

1. Notifiers
2. UseCases
3. Repository implementations
4. Shared UI components

For a run covering more than about three subjects, first write
`docs/workplans/YYYY-MM-DD-test-coverage.md` listing the targets as
checkboxes, and tick them as you go, so the run survives an interrupted
session.

## Style — mirror, do not invent

Hand-written fakes implementing the domain repository interface. No
mocking library, and do not add one.

Give fakes deliberate failure switches so error paths are reachable
without a network. Document each fake with `///`, naming what it stands
in for. Seed static fixtures rather than rebuilding them per test.

`ProviderContainer` with the repository provider overridden;
`addTearDown(container.dispose)`.

## What to assert

Behaviour and emitted state. Never internal call order.

Cover the success path, the failure path, and the edge cases the
testing skill lists that actually apply — empty input, boundary values,
duplicate submission, network failure, unauthorized session, malformed
response.

A test that cannot fail is worse than no test. If you cannot describe
the bug a test would catch, delete it.

## Verify

Run `flutter test` on the files you wrote and read the output.

Never report a test as passing without having run it. If a test fails
because the production code is wrong, say so plainly — do not weaken
the assertion to make it green.

## Report

Files written, subjects covered, what you deliberately did not cover
and why, and any production defect the tests exposed.
```

- [ ] **Step 4: Create the command**

Create `.claude/commands/unit-test.md`:

```markdown
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
```

- [ ] **Step 5: Run the test to verify it passes**

Run: `flutter test test/ai_setup_test.dart`
Expected: PASS.

- [ ] **Step 6: Exercise the agent once, end to end**

Run: `/unit-test lib/features/incident/presentation/incident_list_notifier.dart`

Expected: a new test file under `test/features/incident/`, using a hand-written fake, with no new entry in `pubspec.yaml`. Then:

Run: `flutter test && flutter analyze && git diff --stat pubspec.yaml`
Expected: all tests pass; `No issues found!`; empty diff for `pubspec.yaml`.

This is the first real proof that the pipeline produces work in the house style. If the generated test uses a mocking library or edits `lib/`, fix the agent file and re-run rather than fixing the generated test by hand.

- [ ] **Step 7: Commit**

```bash
git add .claude/agents/flutter-unit-tester.md .claude/commands/unit-test.md test/ai_setup_test.dart test/features/incident
git commit -m "feat: add the flutter-unit-tester agent and /unit-test

Declared mandatory after any Notifier, UseCase or Repository change.
Includes the first test it generated, as proof it matches the existing
hand-written-fake style."
```

---

### Task 14: The two review agents

Kept separate so they can run concurrently at Gate 4: one is a mechanical checklist, the other is judgement. Spec § 7, § 12.

**Files:**
- Create: `.claude/agents/flutter-gatekeeper.md`
- Create: `.claude/agents/flutter-reviewer.md`

**Interfaces:**
- Consumes: the workplan's `## File plan` and `## Gate results` sections
- Produces: a written `PASS` or `FAIL` in `## Gate results`, which `/feature` reads at Gate 4

- [ ] **Step 1: Create the gatekeeper**

Create `.claude/agents/flutter-gatekeeper.md`:

```markdown
---
name: flutter-gatekeeper
description: Runs the completion checklist against finished work and returns a mechanical pass or fail. Invoked at the final gate of /feature, or on request before a commit.
tools: Read, Grep, Glob, Bash
model: sonnet
---

# Gatekeeper

You return **PASS or FAIL**. You do not offer suggestions, and you do
not fix anything. A checklist that negotiates is not a checklist.

Judgement about architecture belongs to `flutter-reviewer`, which runs
alongside you. Stay mechanical.

## Scope

Only the files the workplan lists, plus anything else the diff touched.
Pre-existing problems elsewhere are not your finding.

## Checks

Run each. Record the evidence, not an impression.

1. **Analyzer** — `flutter analyze`. Any issue is a FAIL.
2. **Tests** — `flutter test`. Any failure is a FAIL. Read the output;
   do not assume.
3. **Localization** — grep the changed presentation files for string
   literals passed to user-facing widgets. Any hardcoded user-facing
   string is a FAIL. Confirm every new key exists in *every* locale
   listed in `docs/PROJECT_MAP.md` § Localization; a key present in one
   and missing from another is a FAIL.
4. **Platform** — if the change touches a native capability, confirm
   the Android manifest declaration and the iOS usage-description key
   both exist. One without the other is a FAIL.
5. **Security** — grep the diff for hardcoded credentials and for
   logging of tokens or credentials. Either is a FAIL.
6. **Documentation** — every new public class, usecase, notifier and
   shared model has a `///` comment. Missing ones are a FAIL.
7. **Scope** — every changed file appears in the workplan's file plan.
   An unexplained file is a FAIL.

## Report

Write the result into the workplan's `## Gate results`, then report:

    PASS
or
    FAIL
    - <check>: <what is wrong, at file:line>

Nothing else. No summary of the feature, no praise, no advice.
```

- [ ] **Step 2: Create the reviewer**

Create `.claude/agents/flutter-reviewer.md`:

```markdown
---
name: flutter-reviewer
description: Reviews finished work for architectural correctness and root causes. Invoked at the final gate of /feature, or on request. Read-only.
tools: Read, Grep, Glob
model: opus
---

# Reviewer

You review. You change nothing.

The mechanical checklist is `flutter-gatekeeper`'s job and runs
alongside you. Do not duplicate it — no analyzer, no test run, no
string-literal grep. Spend your attention on what a checklist cannot
see.

## Read first

1. The workplan — what was intended, and what was decided
2. `.claude/skills/flutter-architecture-map/SKILL.md`
3. `docs/PROJECT_MAP.md` § UI Kit Catalog and § Providers
4. The diff, then the reference feature it was supposed to mirror

## What to look for, in priority order

1. **Correctness** — does it do what the requirement asked?
2. **Crashes and data loss** — unhandled failure paths, lost user input.
3. **Layer violations** — business logic inside a widget; a widget or
   Notifier reaching past its layer; JSON knowledge in `domain/`;
   transport details outside `data/`.
4. **Reinvention** — a widget that duplicates something in the UI Kit
   Catalog; a second model for a shape already parsed; a hand-rolled
   helper that exists in `core/`.
5. **Divergence from the reference feature** — naming, file layout,
   provider wiring that differs without a reason in the decisions log.
6. **State modelling** — loading, error and empty represented as nulls
   the widget has to interpret; a missing guard against duplicate
   submission.
7. **Testability** — code that cannot be tested without changing it.

## How to report

For each finding: the file and line, what is wrong, why it matters, and
the smallest fix.

Separate **must fix** from **worth considering**. Say plainly when
there is nothing in the first category.

Do not propose refactoring outside the diff. Do not restate what the
code does. Do not claim anything was verified that you did not read.
```

- [ ] **Step 3: Verify the structure test accepts both**

Run: `flutter test test/ai_setup_test.dart`
Expected: PASS. Both have all four frontmatter keys, no network tools, and no project-specific identifier. Note that `flutter-reviewer` has no `Bash` — it is strictly read-only.

- [ ] **Step 4: Commit**

```bash
git add .claude/agents/flutter-gatekeeper.md .claude/agents/flutter-reviewer.md
git commit -m "feat: add the gatekeeper and reviewer agents

Kept separate so they run concurrently at the final gate: one is a
mechanical pass/fail checklist, the other is architectural judgement."
```

---

### Task 15: The `/feature` command

The orchestrator. It holds the workplan path and each agent's summary — never the agents' working context. That is what keeps the main window from filling. Spec § 8, § 12.

**Files:**
- Create: `.claude/commands/feature.md`
- Modify: `test/ai_setup_test.dart`

**Interfaces:**
- Consumes: all six agents from Tasks 2, 11, 12, 13, 14
- Produces: the five-gate pipeline that Task 19 exercises end to end

- [ ] **Step 1: Write the failing test**

Add a new group to `main()` in `test/ai_setup_test.dart`:

```dart
  group('commands', () {
    test('the three commands exist', () {
      for (final command in ['feature', 'unit-test', 'sync-map']) {
        expect(File('.claude/commands/$command.md').existsSync(), isTrue,
            reason: '.claude/commands/$command.md is missing');
      }
    });

    test('every command declares a description', () {
      for (final file in markdownFilesIn('.claude/commands')) {
        expect(readFrontmatter(file)['description'], isNotEmpty,
            reason: '${file.path}: frontmatter is missing "description"');
      }
    });

    test('the feature command names every gate', () {
      final contents = File('.claude/commands/feature.md').readAsStringSync();
      for (final gate in ['GATE 0', 'GATE 1', 'GATE 2', 'GATE 3', 'GATE 4']) {
        expect(contents, contains(gate),
            reason: 'the pipeline must stop at $gate');
      }
    });
  });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/ai_setup_test.dart -n "commands"`
Expected: FAIL on `the three commands exist` — `feature.md` is missing.

- [ ] **Step 3: Create the command**

Create `.claude/commands/feature.md`:

```markdown
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
   **GATE 1**

3. Dispatch `flutter-implementer` for the **domain** layer.
   **GATE 2**

4. Dispatch `flutter-implementer` for the **presentation** layer.
   **GATE 3**

5. Dispatch `flutter-unit-tester` in pipeline mode.

6. Dispatch `flutter-gatekeeper` and `flutter-reviewer` **concurrently**
   — one call, two agents. They have different jobs and share no state.
   Report the gatekeeper's PASS or FAIL and the reviewer's must-fix
   findings.
   **GATE 4** — the developer decides what to fix.

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
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/ai_setup_test.dart`
Expected: PASS, all groups.

- [ ] **Step 5: Run the full suite and the analyzer**

Run: `flutter test && flutter analyze`
Expected: all tests pass; `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add .claude/commands/feature.md test/ai_setup_test.dart
git commit -m "feat: add the /feature orchestration command

Five hard gates, parallel final review, and resumption from a workplan
file after /clear. The orchestrator holds summaries only."
```

---

## Phase 4 — Documentation

### Task 16: `PROJECT.md` and `README.md`

`CLAUDE.md` names `PROJECT.md` as the home for app requirements and decisions, and the file has never existed. `README.md` is currently a changelog for an AI tooling package rather than a project readme. Spec § 13.

**Files:**
- Create: `PROJECT.md`
- Modify: `README.md`

**Interfaces:**
- Consumes: `docs/PROJECT_MAP.md` (Task 4) for the facts it must not repeat
- Produces: the file `feature-planner` reads second, after the map

- [ ] **Step 1: Write `PROJECT.md`**

This is Tier 2 and is written from what the developer knows, not generated. Keep it to what a planner needs and cannot get from the map — the map already holds structure, so this file holds intent.

```markdown
# PROJECT.md

The app-specific counterpart to `CLAUDE.md`. `CLAUDE.md` holds rules
that are true of every app from this boilerplate; this file holds what
is true of this one. Structural facts live in `docs/PROJECT_MAP.md` and
are generated — do not repeat them here.

## What this app is

One paragraph: who uses it, in what setting, to do what.

## Users and roles

Who logs in, and what each role may do.

## Backend

Which API this app talks to, where its documentation lives, and how
authentication works at the contract level.

## Decisions

A running list. Each entry: the decision, the date, and the reason.
This is the section that stops a past choice being silently reversed.

## Out of scope

What this app deliberately does not do. As useful as the scope itself.

## Open questions

Anything unresolved that a planner would otherwise guess at.
```

Fill each section with this app's real content before committing. A `PROJECT.md` left as headings is worse than none, because `feature-planner` reads it as though it were true.

- [ ] **Step 2: Replace `README.md`**

Write a project readme of roughly forty lines covering: what the app is in two sentences; prerequisites; the clone-to-run steps; a table of the flavors with the command for each; where the documentation lives (`Instructions.md` as the router, `PROJECT.md`, `docs/PROJECT_MAP.md`, `docs/guide/`); and how to run tests and the analyzer.

Take the flavor names and commands from `docs/PROJECT_MAP.md` § Identity rather than from memory.

Delete the existing contents entirely. Nothing in the "Flutter AI Optimization v4" changelog belongs in a project readme — it describes an install procedure for a tooling package that this repository has now superseded.

- [ ] **Step 3: Verify**

Run: `flutter test && flutter analyze`
Expected: all tests pass; `No issues found!`

Confirm by reading that `README.md` no longer mentions "Flutter AI Optimization" and that every command in it runs.

- [ ] **Step 4: Commit**

```bash
git add PROJECT.md README.md
git commit -m "docs: add PROJECT.md and replace the README

CLAUDE.md has always named PROJECT.md as the home for app requirements
and decisions; it never existed. The README was a changelog for an AI
tooling package rather than a readme for this app."
```

---

### Task 17: Split `Instructions.md` into a router and six chapters

1,444 lines, of which 346 are one-time setup that is read once per project and then never again. The existing `## I Need To...` table already has the shape of a router; this task makes it point at real files. Spec § 13.

Content is **moved, not rewritten**, with one exception noted below.

**Files:**
- Modify: `Instructions.md`
- Create: `docs/guide/new-project-setup.md`
- Create: `docs/guide/architecture.md`
- Create: `docs/guide/ui-kit.md`
- Create: `docs/guide/builds-and-flavors.md`
- Create: `docs/guide/workflows-and-testing.md`
- Create: `docs/guide/troubleshooting.md`
- Modify: `test/ai_setup_test.dart`

The `new-project-setup.md` chapter also gains the Tier 1 reuse workflow from Spec § 5, which has no other home in the deliverables.

**Interfaces:**
- Consumes: nothing
- Produces: the `docs/guide/` chapter set that `Instructions.md` and `README.md` link to

- [ ] **Step 1: Write the failing test**

Add a new group to `main()` in `test/ai_setup_test.dart`:

```dart
  group('developer guide', () {
    const chapters = <String>[
      'new-project-setup',
      'architecture',
      'ui-kit',
      'builds-and-flavors',
      'workflows-and-testing',
      'troubleshooting',
    ];

    test('every chapter exists and is not a stub', () {
      for (final chapter in chapters) {
        final file = File('docs/guide/$chapter.md');
        expect(file.existsSync(), isTrue, reason: '${file.path} is missing');
        expect(file.lengthSync(), greaterThan(1000),
            reason: '${file.path} looks like a stub');
      }
    });

    test('Instructions.md is a router, not a manual', () {
      final file = File('Instructions.md');
      expect(file.readAsLinesSync().length, lessThan(200),
          reason: 'the guide chapters live under docs/guide/ now');
      final contents = file.readAsStringSync();
      for (final chapter in chapters) {
        expect(contents, contains('docs/guide/$chapter.md'),
            reason: 'the router must link to $chapter');
      }
    });
  });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/ai_setup_test.dart -n "developer guide"`
Expected: FAIL on `every chapter exists` — `docs/guide/` does not exist.

- [ ] **Step 3: Locate the section boundaries**

Do not hardcode line numbers; they shift as soon as the first extraction happens.

Run: `grep -n '^## ' Instructions.md`

Use the printed line numbers to extract each `##` section together with all of its `###` subsections, working from the **bottom of the file upward** so earlier offsets stay valid.

- [ ] **Step 4: Move each section to its chapter**

Each chapter file starts with an `# Title` heading and then the moved sections verbatim.

| Chapter | Sections to move, in this order |
|---|---|
| `new-project-setup.md` | Starting a New Project From This Boilerplate |
| `architecture.md` | Architecture; Project Structure; State Management; Navigation & Routing; Networking & API Layer; Authentication & Session; Local Storage; Error Handling; Loading, Empty & Error States; Forms & Validation; Localization; Security |
| `ui-kit.md` | Core UI Kit; Real-World Usage — Core UI Kit in Production Screens; UI Playground; Theme & Design Tokens |
| `builds-and-flavors.md` | Environments & Flavors; Android Builds; iOS Builds; Build Matrix |
| `workflows-and-testing.md` | Development Workflows; Testing; Code Quality; Common Architecture Mistakes |
| `troubleshooting.md` | Troubleshooting; Debug Tools |

Remaining in `Instructions.md`: `I Need To...`, `Project Overview`, `Golden Rules`, and `Keeping This Document Updated`. Together with the new intro that is roughly 110 lines, which accounts for all 1,444 lines of the original — nothing is dropped.

- [ ] **Step 5: Correct the one stale section during the move**

The `Testing` section moving into `workflows-and-testing.md` states that the project "has exactly one test file, `test/widget_test.dart` — the unmodified default Flutter counter-app template". That has been wrong for four test files, and Task 1 deleted the file it names.

Replace that paragraph with a pointer:

```markdown
**Current coverage:** see `docs/PROJECT_MAP.md` § Test Coverage. That
section is generated, so unlike this paragraph's predecessor it cannot
drift. Run `/sync-map` if it looks stale, and `/unit-test` to close a
gap.
```

This is the only content rewritten in this task. Everything else is moved verbatim.

- [ ] **Step 6: Document the Tier 1 reuse workflow**

Spec § 5 defines how this system is carried into the next project, and
nothing in the deliverables states it. Append to
`docs/guide/new-project-setup.md`, after the existing setup steps:

```markdown
## Carrying the AI setup forward

This boilerplate is upstream. To start a new project from it, copy the
portable tier across unchanged:

    .claude/          agents, commands, skills
    CLAUDE.md         the constitution
    docs/guide/       these chapters

Do **not** copy `docs/PROJECT_MAP.md`, `PROJECT.md`, or
`docs/workplans/`. They describe the project they came from, and a
stale map is worse than none because it is trusted.

Then:

1. Work through the setup steps above — rename, bundle IDs, flavors,
   branding.
2. Write `PROJECT.md` for the new app.
3. Run `/sync-map` to generate `docs/PROJECT_MAP.md` from the new
   source tree.
4. Run `flutter test` — `test/ai_setup_test.dart` verifies the copied
   setup is structurally intact and still portable.

Improvements made to the portable tier in a downstream project are
copied back here by hand. There is no automatic sync, deliberately:
the merge conflicts would land in exactly the files that must stay
free of project-specific content.
```

- [ ] **Step 7: Rewrite the router**

Repoint every row of the `## I Need To...` table at `docs/guide/<chapter>.md#<anchor>` instead of an in-document anchor, and add rows for the three new destinations:

| I need to... | See |
|---|---|
| Know what already exists in this app | `docs/PROJECT_MAP.md` |
| Know what this app is for | `PROJECT.md` |
| Build a feature with the agent pipeline | `/feature`, then `docs/superpowers/specs/2026-09-02-flutter-agent-workplan-design.md` |

Add one line under the title stating that the chapters live in `docs/guide/` and that `docs/PROJECT_MAP.md` is generated by `/sync-map`.

- [ ] **Step 7: Run the test to verify it passes**

Run: `flutter test test/ai_setup_test.dart`
Expected: PASS, all groups.

- [ ] **Step 9: Verify no content was lost**

Run: `wc -l Instructions.md docs/guide/*.md`
Expected: the total is within about twenty lines of 1,444 — the difference being the six new chapter titles and the rewritten Testing paragraph.

Run: `grep -rn 'unmodified default Flutter' Instructions.md docs/guide/`
Expected: no matches.

- [ ] **Step 10: Commit**

```bash
git add Instructions.md docs/guide test/ai_setup_test.dart
git commit -m "docs: split Instructions.md into a router and six chapters

The I Need To table becomes a real router. A reader now loads one
chapter instead of 1,444 lines, and the one-time setup guide is out of
the path of daily reading. Corrects the stale Testing section."
```

---

### Task 18: Trim `CLAUDE.md`

`CLAUDE.md` is loaded in full at the start of every session, so anything in it that has moved elsewhere is a tax paid every time. Spec § 6.

**Files:**
- Modify: `CLAUDE.md`
- Modify: `test/ai_setup_test.dart`

**Interfaces:**
- Consumes: the skills from Phase 2 and the commands from Phase 3, which now own the removed material
- Produces: a smaller always-loaded constitution

- [ ] **Step 1: Write the failing test**

Add to the `tier separation` group:

```dart
    test('CLAUDE.md stays a constitution, not a manual', () {
      final size = File('CLAUDE.md').lengthSync();
      expect(size, lessThan(6000),
          reason: 'CLAUDE.md is loaded every session; it is $size bytes. '
              'Move procedure into a skill and facts into PROJECT_MAP.');
    });
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `flutter test test/ai_setup_test.dart -n "constitution"`
Expected: FAIL — `CLAUDE.md` is 7,281 bytes.

- [ ] **Step 3: Remove what has moved**

Delete these sections, each of which now has a better home:

| Section | Now lives in |
|---|---|
| Feature Workflow | `.claude/commands/feature.md` |
| Context and Token Efficiency | the agent definitions, which enforce it |
| API Contract | `.claude/skills/flutter-api-contract/SKILL.md` |
| Localization | `.claude/skills/flutter-localization/SKILL.md` |
| Presentation | `.claude/skills/flutter-ui-kit/SKILL.md` |

Keep, unchanged: Purpose, Decision Priority, Architecture, Reuse and Scope, Android + iOS, Security, Documentation, Testing and Completion, Device Testing — Developer Owned, Communication, Golden Rules.

Replace the deleted sections with one short block:

```markdown
## Where the rest lives

- `PROJECT.md` — what this app is, and the decisions made about it
- `docs/PROJECT_MAP.md` — what currently exists; generated by `/sync-map`
- `.claude/skills/` — how to do a particular kind of work
- `.claude/commands/` — `/feature`, `/unit-test`, `/sync-map`
- `Instructions.md` — router into `docs/guide/`

Read the map before exploring source. It exists so that you do not have
to rediscover this project every session.
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `flutter test test/ai_setup_test.dart`
Expected: PASS. The tier-separation scan must also still pass — the new block names no project-specific identifier.

- [ ] **Step 5: Commit**

```bash
git add CLAUDE.md test/ai_setup_test.dart
git commit -m "refactor: trim CLAUDE.md to a constitution

Removes the five sections that now live in skills and commands. The
file is loaded every session, so duplicated procedure is a tax paid
every time. Adds a size guard at 6000 bytes."
```

---

### Task 19: End-to-end verification and the portability rehearsal

Every previous task verified a part. This one verifies that the parts work as a system, and — the constraint that shaped the whole design — that the system survives being copied into another project. Spec § 15.

**Files:**
- Modify: `docs/PROJECT_MAP.md` (regenerated)
- Create: one workplan file under `docs/workplans/`, produced by the run

**Interfaces:**
- Consumes: everything built in Tasks 1–18
- Produces: evidence against each of the spec's six success criteria

- [ ] **Step 1: Regenerate the map against the finished tree**

Run: `/sync-map`

Expected: `## Test Coverage` now reflects the test added in Task 13, and the file no longer says "Not yet generated".

- [ ] **Step 2: Exercise the full pipeline on a real, small feature**

Run `/feature` with a genuinely small requirement — one screen, one endpoint, mirroring an existing feature.

Verify at each stop:

| Gate | Must observe |
|---|---|
| GATE 0 | A workplan file exists under `docs/workplans/` with all seven sections filled, and a named reference feature |
| GATE 1 | Only data-layer files changed; providers registered |
| GATE 2 | Only domain-layer files changed |
| GATE 3 | Only presentation-layer files changed; no hardcoded strings |
| GATE 4 | Gatekeeper returns a bare PASS or FAIL; reviewer returns findings separated into must-fix and worth-considering |

The pipeline **must stop at every gate**. If it runs two layers without waiting, `.claude/commands/feature.md` is at fault — fix the command, not the output.

- [ ] **Step 3: Verify resumption after a cleared context**

Midway through the run — after GATE 1 — run `/clear`, then in the fresh session give only the workplan path.

Expected: the session reads `Status` and `Last agent`, resumes at the domain layer, and does not re-plan or rewrite the data layer.

This is the criterion the whole workplan-file design exists to satisfy. If it fails, the agents are not updating the file before reporting.

- [ ] **Step 4: Verify proactive invocation on the ad-hoc path**

Without using any command, ask in plain conversation for a change that crosses a layer boundary.

Expected: `flutter-implementer` is delegated to without being named, and it still stops at its layer gate.

Then ask for a one-line string change.

Expected: it is **not** delegated — the threshold keeps a trivial edit in the main session.

- [ ] **Step 5: Verify the mandatory tester**

Modify any Notifier by hand and ask for the change to be finished.

Expected: `flutter-unit-tester` runs without being asked.

- [ ] **Step 6: Rehearse portability**

This is the constraint that shaped the two-tier split, so it is verified rather than assumed.

```bash
mkdir -p /tmp/portability-check
cp -R .claude CLAUDE.md /tmp/portability-check/
grep -rEn 'flutter_incident_reporting|MeCARE|AppButton|AppTextField|PatientRepository|patient_details|mobile_scanner|Baloo 2' /tmp/portability-check/ || echo "PORTABLE: no project-specific identifier found"
```

Expected: `PORTABLE: no project-specific identifier found`.

Then confirm the copied tree carries no generated file:

```bash
ls /tmp/portability-check/docs 2>/dev/null || echo "correct: no generated docs copied"
rm -rf /tmp/portability-check
```

- [ ] **Step 7: Confirm every success criterion**

Check each line of Spec § 15 against what Steps 1–6 produced. Any criterion without evidence is a gap — record it in the commit message rather than declaring the plan complete.

- [ ] **Step 8: Full verification**

Run: `flutter test && flutter analyze`
Expected: all tests pass; `No issues found!`

- [ ] **Step 9: Commit**

```bash
git add -A docs .claude
git commit -m "chore: verify the agent pipeline end to end

Exercises all five gates, resumption after /clear, proactive delegation
on the ad-hoc path, the mandatory tester, and the portability rehearsal
against Tier 1."
```

---

## Notes for whoever executes this

**The tests are the spec's enforcement, not decoration.** `test/ai_setup_test.dart` is what stops this system decaying back into advisory documents: the tier-separation scan keeps skills portable, the 4,000-byte skill cap and the 6,000-byte `CLAUDE.md` cap stop either growing into a second constitution. If a task tempts you to weaken one of those assertions, the content is wrong, not the test.

**When a generated artifact looks wrong, fix the generator.** If `docs/PROJECT_MAP.md` has a bad section, correct `.claude/agents/project-mapper.md` and re-run `/sync-map`. If a generated test uses the wrong style, correct `.claude/agents/flutter-unit-tester.md` and regenerate. Hand-editing generated output puts the drift back in on the first regeneration.

**Phases 1 and 2 carry most of the value.** Spec § 14 is explicit that the agents cost more tokens than they save, and that `docs/PROJECT_MAP.md` plus the skill rewrite is the 80/20. If work has to stop early, stopping after Task 10 leaves a coherent, useful system. Stopping mid-phase-3 leaves agents with no orchestrator.
