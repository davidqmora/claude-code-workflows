---
name: blazor-ui-guide
description: Blazor-specific technical decision criteria, anti-patterns, debugging techniques, and UI quality workflow. Use when making Blazor UI decisions or performing Blazor-focused quality assurance.
---

# Blazor UI Guide

## UI Anti-Patterns

- Large components mixing data access, orchestration, and presentation
- Repeated markup patterns copied across pages instead of reusable components
- Heavy use of JS interop where Blazor-native patterns suffice
- Hidden state changes through cascading values or mutable shared singletons
- UI that only models the happy path and omits loading, empty, or error states
- Event handlers that perform business logic directly instead of delegating to services

## Design Guidance

- Reuse existing layouts, forms, and component primitives before introducing new ones.
- Prefer explicit component contracts with typed parameters and callbacks.
- Design UI states first, then wire data and interactions to those states.
- Keep accessibility visible in the design: focus order, labels, keyboard navigation, validation messages.

## Debugging Guidance

- Start with the first application exception or renderer error.
- Check component lifecycle ordering when duplicated loads or unexpected rerenders occur.
- Inspect parameter values, auth state, and service registration before assuming rendering bugs.
- Reduce problems to a minimal component reproduction when interop or lifecycle behavior is unclear.

## Quality Workflow

For Blazor UI work, prefer this order:
1. format/build checks via the repo’s .NET workflow
2. bUnit or component-level tests
3. ASP.NET Core host/integration tests when routing/auth/config are involved
4. Playwright/browser E2E only for true multi-step journeys

## Technical Decision Triggers

- New shared component or layout pattern
- New JS interop dependency
- Auth-driven UI behavior
- Cross-page state management
- Server vs WebAssembly trade-offs

## Completeness Checks

- Every changed component documents or implements default/loading/empty/error states
- Existing similar components were searched before adding a new one
- Parameter changes have identified call sites
- Accessibility and validation behavior are covered in tests or explicitly documented
