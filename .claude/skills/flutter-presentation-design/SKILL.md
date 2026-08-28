---
name: flutter-presentation-design
description: Implement Flutter presentation layers from Figma, screenshots, mockups, or requirements without inventing unnecessary UI. Use for screens, widgets, design systems, responsive layouts, accessibility, and visual validation.
---

# Presentation Workflow

## Design priority

`Approved Figma > approved mockup/screenshot > existing design system > platform conventions > AI proposal`

## If Figma exists

Inspect the relevant design when access is available.

Identify:
- screens
- states
- spacing
- typography
- colors
- components
- interactions
- responsive behavior

Reuse existing Flutter components where appropriate.

Do not redesign an approved UI without a reason.

If an important behavior is unclear, ask rather than inventing a materially different UX.

## If no design exists

Inspect the existing theme/design system first.

Use platform conventions for conventional UI.

For significant visual decisions, propose a direction before implementation.

Do not create one-off styling when a reusable design system component is appropriate.

## Responsive/accessibility

Consider:
- small/large phones
- tablets when relevant
- portrait/landscape
- safe areas
- keyboard
- text scaling
- accessibility semantics
- touch targets
- contrast
- long localized strings

Evaluate Android and iOS presentation differences where relevant.

## Business logic

UI renders application state.

Business rules belong outside widgets:

`Domain/UseCase → ViewModel/Notifier → UI`

## Validation

When a reference exists, compare implementation against it for layout, spacing, typography, sizing, states, navigation, and responsive behavior.

Do not claim pixel-perfect accuracy unless it was actually validated.
