---
name: dotnet-build-and-quality
description: .NET quality-check workflow for formatting, analyzers, builds, tests, and OpenAPI/build hygiene. Use when verifying or fixing quality issues in .NET projects.
---

# .NET Build and Quality Workflow

## Detection Priorities

Inspect the repo to determine:
- solution and project files (`.sln`, `.csproj`)
- test projects
- formatter/analyzer configuration
- OpenAPI generation or validation steps
- coverage tooling already present

## Default Quality Workflow

1. `dotnet format --verify-no-changes` when formatting is established
2. `dotnet build`
3. `dotnet test`
4. Project-specific integration or end-to-end steps

If the repo uses different established commands, follow those instead.

## Analyzer Expectations

- Respect nullable warnings.
- Treat analyzer warnings as quality issues unless the repo intentionally suppresses them.
- Prefer fixing root causes over broad suppression or `NoWarn`.

## Build Expectations

- Ensure affected projects compile cleanly.
- Keep package references and target frameworks aligned with the existing solution.
- Verify source generators, OpenAPI generation, and configuration binding code still compile when those are part of the repo.

## Test Expectations

- Run the narrowest affected test scope first, then widen as confidence grows.
- Re-run failed tests after each meaningful fix.
- Do not skip failing tests without an explicit documented reason and user approval.

## Common Fix Themes

- DI registration mismatches
- nullable and serialization mismatches
- auth/options configuration errors
- incorrect async usage or missing cancellation propagation
- stale OpenAPI contracts or event schemas
