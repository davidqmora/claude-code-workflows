---
name: azure-architecture-guide
description: Opinionated Azure guidance for App Service, Storage, Cosmos DB, Event Grid, Key Vault, Application Insights, and Entra ID/B2C. Use when designing or reviewing Azure-backed .NET systems.
---

# Azure Architecture Guide

## Opinionated Defaults

- Hosting: Azure App Service unless the repo already standardizes elsewhere.
- Secrets: Azure Key Vault.
- Identity to Azure resources: Managed Identity first.
- Telemetry: Application Insights.
- Document data: Cosmos DB when document-style access patterns justify it.
- Object storage: Blob Storage.
- Key-value or table-style lookup patterns: Azure Table Storage where appropriate.
- Eventing: Event Grid for integration events.
- Identity for users: Entra ID or Entra ID B2C depending on audience.

## Architecture Boundaries

- Keep Azure SDK calls behind adapters or infrastructure services.
- Make resource naming, partition keys, blob paths, and event schemas explicit in the design.
- Treat retries, idempotency, poison-message handling, and duplicate event delivery as normal-case concerns.

## Configuration and Secrets

- Use ASP.NET Core configuration layering intentionally: appsettings, environment, Key Vault, and app-specific overrides.
- Never require plaintext secrets in source-controlled config.
- Prefer strongly typed options objects over ad hoc config reads.

## Identity and Security

- Prefer managed identity for service-to-service auth.
- Document required app registrations, scopes, roles, and callback URLs when Entra ID/B2C is involved.
- Keep token parsing and authorization rules near entry points, not scattered through business logic.

## Telemetry and Operations

- Instrument API requests, external calls, event handlers, and storage operations with useful dimensions.
- Log enough context to diagnose tenant, resource, correlation, and operation failures without leaking secrets.
- Document operational dependencies: queues/topics, storage containers, Cosmos containers, Key Vault secrets, identity roles.

## Service-Specific Notes

### Blob Storage
- Define container names, path conventions, content type handling, and overwrite semantics.

### Table Storage
- Define partition key and row key strategy up front.
- Validate access patterns before choosing table design.

### Cosmos DB
- Define container name, partition key, consistency expectations, and indexing implications.
- Model query patterns before finalizing document shape.

### Event Grid
- Version event contracts.
- Define publisher idempotency, consumer idempotency, and failure handling.

## When Not to Force Azure Defaults

- Do not introduce Azure services when the project already has a settled alternative.
- Do not use Cosmos DB for relational workloads that clearly belong in SQL.
- Do not add Event Grid when a direct synchronous call is simpler and sufficient.
