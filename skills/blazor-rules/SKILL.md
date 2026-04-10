---
name: blazor-rules
description: Blazor component and UI development rules for Razor components, forms, validation, state handling, and JS interop boundaries. Use when implementing or reviewing Blazor UI code.
---

# Blazor Development Rules

## Core Principles

- Prefer idiomatic Razor components and C# code-behind patterns over framework workarounds.
- Keep presentation concerns in components and business logic in services or application layers.
- Reuse existing components, layouts, and shared primitives before adding new ones.
- Model loading, empty, success, and error UI states explicitly.

## Component Design

- Keep components focused on a single UI responsibility.
- Use `[Parameter]` inputs as the public component contract.
- Prefer strongly typed parameters, event callbacks, and view models.
- Split large components when markup, event handling, and state management become hard to reason about.
- Prefer composition and child components over large conditional blocks.

## State and Data Flow

- Keep authoritative state in the nearest sensible owner component or service.
- Pass data down via parameters and communicate up with `EventCallback` or explicit callbacks.
- Avoid hidden coupling through cascading values unless the state is truly cross-cutting.
- Be explicit about server-side vs WebAssembly latency and loading behavior when fetching data.

## Forms and Validation

- Prefer `EditForm` with explicit validation strategy.
- Keep transport validation, domain validation, and field-level UX concerns conceptually separate.
- Show actionable validation and error messages without leaking internal exception details.

## JS Interop

- Use JS interop only when Blazor or existing shared components cannot satisfy the requirement.
- Isolate JS interop behind small adapter-style services or component wrappers.
- Make initialization, disposal, and failure behavior explicit.

## Rendering and Lifecycle

- Use lifecycle methods intentionally; avoid side effects during rendering.
- Prefer async lifecycle methods for I/O.
- Guard against duplicate loading and event registration.
- Dispose subscriptions, timers, and JS interop handles when required.

## Security and Auth

- Keep secrets and privileged operations server-side.
- Treat auth state, claims, and protected UI branches as first-class design concerns.
- Prefer established Entra ID / B2C integration patterns already used in the solution.

## Testing Expectations

- Prefer bUnit for component tests.
- Test rendered output, user interaction, validation, and event flows rather than internals.
- Use Playwright only for real multi-step browser journeys.
- Coordinate with `dotnet-testing-principles` for broader host/API integration behavior.
