---
name: csharp-rules
description: C# and .NET coding rules for domain services, ASP.NET Core applications, background workers, and shared libraries. Use when implementing or reviewing C# code.
---

# C# and .NET Development Rules

## Core Principles

- Prefer clear, idiomatic C# over framework cleverness.
- Keep domain logic independent from transport, persistence, and Azure SDK details.
- Use nullable reference types and treat warnings as design feedback, not noise.
- Prefer composition and DI over static helpers and service locators.

## Type and API Design

- Model domain concepts with explicit types and value objects when they prevent invalid states.
- Prefer records for immutable DTOs and request/response models.
- Prefer classes for entities and components with lifecycle or mutable behavior.
- Keep public APIs narrow and intention-revealing.
- For methods with 3+ related inputs, prefer an options object or request model.

## Asynchrony and Cancellation

- Use `async`/`await` end-to-end for I/O work.
- Accept `CancellationToken` on public async methods that may perform I/O or long-running work.
- Pass the token through to EF Core, HttpClient, Azure SDK, and other downstream APIs.
- Do not block on async with `.Result` or `.Wait()`.

## Error Handling

- Do not swallow exceptions.
- Translate infrastructure exceptions at boundaries into domain-appropriate failures.
- Return framework-specific HTTP results only at the API boundary, not in core services.
- Log with structured properties and redact secrets, tokens, keys, and PII.

## ASP.NET Core Conventions

- Keep controllers/minimal API handlers thin.
- Put orchestration and business rules in application/domain services.
- Validate input at entry points using framework validation plus explicit business validation where required.
- Use options binding for configuration; avoid scattering direct configuration reads.
- Keep authentication and authorization explicit with policies/requirements where possible.

## Data Access

- Prefer repository or query-service boundaries when they clarify domain intent.
- Use EF Core projections intentionally to avoid over-fetching.
- Avoid leaking EF entities across service boundaries when DTOs or domain models are clearer.
- Treat Cosmos DB partitioning, Storage table keys, and blob naming conventions as part of the design, not incidental details.

## Azure Integration Defaults

- Prefer managed identity over connection strings when supported.
- Use Key Vault for secrets; do not hardcode credentials or commit them.
- Use Application Insights/OpenTelemetry-compatible instrumentation for important operations.
- Keep Azure SDK clients behind application-facing abstractions when that improves testability or reduces coupling.

## Testing Expectations

- Write tests close to the behavior under change.
- Prefer xUnit for new .NET test projects unless the repo already standardizes on NUnit or MSTest.
- Use WebApplicationFactory/TestServer for API integration tests.
- Use real serializers, model binding, and auth configuration in integration tests when feasible.

## Code Quality

- Prefer expression of intent over micro-optimizations.
- Extract repeated conditionals, mapping logic, and Azure resource conventions once they repeat three times.
- Delete unused code and dead registrations promptly.
- Keep comments focused on why a rule or integration nuance exists.
