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
