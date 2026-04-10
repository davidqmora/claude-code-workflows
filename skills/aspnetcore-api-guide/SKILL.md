---
name: aspnetcore-api-guide
description: ASP.NET Core Web API design and implementation guidance covering controllers or minimal APIs, DI, validation, OpenAPI, auth, and service boundaries. Use when designing or implementing HTTP APIs in .NET.
---

# ASP.NET Core API Guide

## API Shape Defaults

- Follow existing project conventions first: controllers vs minimal APIs, MediatR vs direct services, result objects vs exceptions.
- Keep handlers thin and move business logic into services or use-case classes.
- Make request/response contracts explicit and version-friendly.
- Prefer OpenAPI-documented, JSON-first APIs unless the existing system dictates otherwise.

## Dependency Injection

- Register dependencies centrally and predictably.
- Prefer constructor injection.
- Keep service lifetimes intentional:
  - Singleton only for stateless or thread-safe components.
  - Scoped for request-oriented services and DbContext consumers.
  - Transient sparingly.

## Validation and Contracts

- Validate transport shape at the API boundary.
- Separate transport validation from domain/business validation when they serve different purposes.
- Return consistent error payloads and status codes.
- Avoid passing raw `IConfiguration`, `HttpContext`, or SDK clients deep into domain logic.

## Authentication and Authorization

- Prefer policy-based authorization.
- Verify both authenticated and unauthorized/forbidden paths in tests.
- Treat Entra ID and Entra ID B2C integration details as first-class design decisions when auth is in scope.

## Observability

- Emit structured logs with correlation-friendly properties.
- Instrument important inbound requests, outbound calls, and long-running operations.
- Use Application Insights/OpenTelemetry-friendly patterns for traces and metrics.

## OpenAPI and Compatibility

- Keep endpoint naming, status codes, and schema evolution intentional.
- When changing an existing contract, document the compatibility plan and affected consumers.
- Treat route templates, pagination, filtering, and event payloads as public contracts.

## Background and Event-Driven Work

- Use hosted/background services intentionally; keep them testable and bounded.
- Define idempotency and retry expectations for Event Grid consumers or publishers.
- Separate message contract mapping from core business logic.
