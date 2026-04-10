---
name: blazor-test-implement
description: Blazor test implementation patterns and conventions for bUnit, ASP.NET Core host-backed UI verification, and Playwright E2E. Use when implementing tests for Blazor UI features.
---

# Blazor Test Implementation Patterns

## Reference Selection

| Test Type | Recommended Approach | When to Use |
|-----------|----------------------|-------------|
| **Component** | bUnit | Rendering, parameters, events, validation, conditional UI |
| **Host / Integration** | ASP.NET Core integration tests | Routing, auth wiring, DI/config behavior, API-backed page behavior |
| **E2E** | Playwright | True browser-level journeys across multiple screens |

## Common Principles

- Follow Arrange-Act-Assert.
- Test observable behavior, not implementation details.
- Prefer the narrowest test level that proves the requirement.
- Keep tests deterministic and independent.

## bUnit Defaults

- Assert rendered text, markup fragments, form validation messages, callback invocation, and visible state transitions.
- Prefer explicit service registration for test doubles rather than broad mocking.
- Keep JS interop mocked or abstracted unless the test specifically targets that boundary.

## Host-Backed UI Verification

- Use integration-style tests when routing, auth, configuration, or server-backed component behavior matters.
- Verify both authenticated and unauthenticated states where relevant.
- Exercise realistic serializers, auth wiring, and DI registrations when those are part of the behavior under test.

## E2E

- Reserve Playwright for cross-page journeys or browser-only behavior.
- Keep E2E counts small and focused on business-critical paths.
