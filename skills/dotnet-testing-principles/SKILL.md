---
name: dotnet-testing-principles
description: .NET-specific testing defaults for xUnit, ASP.NET Core integration tests, EF Core, Azure integrations, and Blazor-adjacent service testing. Use when designing or implementing tests for .NET systems.
---

# .NET Testing Principles

## Framework Defaults

- Default to xUnit for new test projects.
- Use `dotnet test` as the canonical test runner.
- Keep unit, integration, and end-to-end test projects clearly separated when the repo is large enough to justify it.

## Unit Tests

- Test domain and application services without the web host when possible.
- Mock only process boundaries: external HTTP, queues, clocks, storage SDKs, and other infrastructure.
- Prefer deterministic builders/fixtures over broad auto-generated test data.

## ASP.NET Core Integration Tests

- Prefer `WebApplicationFactory<TEntryPoint>` or `TestServer` for API integration tests.
- Exercise real middleware, routing, model binding, filters, JSON serialization, and auth configuration whenever the behavior depends on them.
- Verify HTTP status, payload shape, and persistence/side effects that matter to the acceptance criteria.

## Data Layer Testing

- Do not rely on mocks alone for repository/query correctness.
- For EF Core, prefer provider-realistic integration tests where query translation matters.
- Be explicit about dialect gaps when using in-memory substitutes.
- For Cosmos DB, Storage Tables, and Blob Storage, test boundary adapters with realistic request/response shapes and naming/partition conventions.

## Azure-Facing Tests

- Keep cloud SDK usage behind interfaces or thin adapters so unit tests stay fast.
- Cover auth/config wiring for managed identity, Key Vault-backed configuration, and event publishing in integration tests where those flows are first-class requirements.
- Use contract-style tests for serialized event payloads and storage document shapes.

## API Test Quality

- Each acceptance criterion should map to at least one verifiable API or service-level test.
- Verify authentication and authorization behavior explicitly for protected endpoints.
- Include unhappy-path tests for validation failures, missing resources, and downstream service failures when they are user-visible or operationally important.

## Test Naming and Structure

- Use descriptive names in the form `Should_<Outcome>_When_<Condition>` or the repo’s established equivalent.
- Keep Arrange/Act/Assert structure obvious.
- Prefer one business behavior per test.

## Quality Gates

- `dotnet build` must succeed for changed projects.
- `dotnet test` must pass for affected test projects.
- Add coverage only where the repo already measures it; otherwise prefer meaningful assertion depth over synthetic coverage work.
