# Fullstack (Monorepo) Flow

This reference defines the orchestration flow for projects spanning multiple layers (service/backend + UI/client). It extends the standard orchestration guide without modifying it.

## When This Flow Applies

- Multiple Design Docs exist targeting different layers (for example service/backend and UI/client)
- A single feature requires implementation across both a service/backend layer and a UI/client layer
- The orchestrator is invoked via `fullstack-implement` or `fullstack-build` commands

## Design Phase

### Large Scale Fullstack (6+ Files) - 14 Steps

| Step | Agent | Purpose | Output |
|------|-------|---------|--------|
| 1 | requirement-analyzer | Requirement analysis + scale determination **[Stop]** | Requirements + scale |
| 2 | prd-creator | PRD covering entire feature (all layers) | Single PRD |
| 3 | document-reviewer | PRD review **[Stop]** | Approval |
| 4 | (orchestrator) | Ask user for prototype code **[Stop]** | Prototype path or none |
| 5 | ui-spec-designer | UI Spec from PRD + optional prototype | UI Spec |
| 6 | document-reviewer | UI Spec review **[Stop]** | Approval |
| 7 | codebase-analyzer ×2 | Codebase analysis per layer (pass req-analyzer output + PRD path, filtered to layer) | Codebase guidance per layer |
| 8 | technical-designer | **Service/Backend** Design Doc (with service/backend codebase-analyzer context) | Service/Backend Design Doc |
| 9 | technical-designer-frontend | **UI/Client** Design Doc (with UI/client codebase-analyzer context + service/backend Integration Points + UI Spec) | UI/Client Design Doc |
| 10 | code-verifier ×2 | Verify each Design Doc against existing code | Verification results |
| 11 | document-reviewer ×2 | Review each Design Doc (with code-verifier results as code_verification) | Reviews |
| 12 | design-sync | Cross-layer consistency verification (source: UI/client Design Doc) **[Stop]** | Sync status |
| 13 | acceptance-test-generator | Integration/E2E test skeleton from cross-layer contracts | Test skeletons |
| 14 | work-planner | Work plan from all Design Docs **[Stop: Batch approval]** | Work plan |

### Medium Scale Fullstack (3-5 Files) - 12 Steps

| Step | Agent | Purpose | Output |
|------|-------|---------|--------|
| 1 | requirement-analyzer | Requirement analysis + scale determination **[Stop]** | Requirements + scale |
| 2 | codebase-analyzer ×2 | Codebase analysis per layer (pass req-analyzer output, filtered to layer) | Codebase guidance per layer |
| 3 | (orchestrator) | Ask user for prototype code **[Stop]** | Prototype path or none |
| 4 | ui-spec-designer | UI Spec from requirements + optional prototype | UI Spec |
| 5 | document-reviewer | UI Spec review **[Stop]** | Approval |
| 6 | technical-designer | **Service/Backend** Design Doc (with service/backend codebase-analyzer context) | Service/Backend Design Doc |
| 7 | technical-designer-frontend | **UI/Client** Design Doc (with UI/client codebase-analyzer context + service/backend Integration Points + UI Spec) | UI/Client Design Doc |
| 8 | code-verifier ×2 | Verify each Design Doc against existing code | Verification results |
| 9 | document-reviewer ×2 | Review each Design Doc (with code-verifier results as code_verification) | Reviews |
| 10 | design-sync | Cross-layer consistency verification (source: UI/client Design Doc) **[Stop]** | Sync status |
| 11 | acceptance-test-generator | Integration/E2E test skeleton from cross-layer contracts | Test skeletons |
| 12 | work-planner | Work plan from all Design Docs **[Stop: Batch approval]** | Work plan |

### Parallelization in Multi-Agent Steps

Steps marked with ×2 (codebase-analyzer ×2, code-verifier ×2, document-reviewer ×2) invoke the agent once per layer. These invocations are independent and can run in parallel when the orchestrator supports concurrent Agent tool calls.

### Codebase Analysis Before Design Doc Creation

Before each Design Doc creation, invoke codebase-analyzer with the requirement-analyzer output filtered to the relevant layer's affected files. Pass the codebase-analyzer output to the corresponding technical-designer invocation as additional context.

### Layer Context in Design Doc Creation

When invoking technical-designer for each layer, pass explicit context. Template varies by scale:

**Large Scale (PRD available)** — Service/Backend Design Doc:
```
Create a service/backend Design Doc from PRD at [path].
Codebase analysis: [JSON from codebase-analyzer for service/backend layer]
Focus on: API contracts, data layer, business logic, service architecture.
```

**Large Scale (PRD available)** — UI/Client Design Doc:
```
Create a UI/client Design Doc from PRD at [path].
Codebase analysis: [JSON from codebase-analyzer for UI/client layer]
Reference service/backend Design Doc at [path] for API contracts and Integration Points.
Reference UI Spec at [path] for page/component structure and state design.
Focus on: page/component hierarchy, state management, UI interactions, data fetching.
```

**Medium Scale (no PRD)** — Service/Backend Design Doc:
```
Create a service/backend Design Doc based on the following requirements:
[Pass requirement-analyzer output including purpose, affectedFiles, affectedLayers, technicalConsiderations]
Codebase analysis: [JSON from codebase-analyzer for service/backend layer]
Focus on: API contracts, data layer, business logic, service architecture.
```

**Medium Scale (no PRD)** — UI/Client Design Doc:
```
Create a UI/client Design Doc based on the following requirements:
[Pass requirement-analyzer output including purpose, affectedFiles, affectedLayers, technicalConsiderations]
Codebase analysis: [JSON from codebase-analyzer for UI/client layer]
Reference service/backend Design Doc at [path] for API contracts and Integration Points.
Reference UI Spec at [path] for page/component structure and state design.
Focus on: page/component hierarchy, state management, UI interactions, data fetching.
```

### design-sync for Cross-Layer Verification

Call design-sync with `source_design` = UI/client Design Doc (created last, referencing the service/backend Integration Points). design-sync auto-discovers other Design Docs in `docs/design/` for comparison.

## Test Skeleton Generation Phase

Orchestrator passes all Design Docs and UI Spec to acceptance-test-generator:

```
Generate test skeletons from the following documents:
- Design Doc (backend): [path]
- Design Doc (ui/client): [path]
- UI Spec: [path] (if exists)
```

## Work Planning Phase

Orchestrator passes all Design Docs to work-planner:

```
Create a work plan from the following documents:
- PRD: [path] (Large Scale only)
- Design Doc (backend): [path]
- Design Doc (ui/client): [path]

Compose phases as vertical feature slices where possible — each phase should contain
both service/backend and UI/client work for the same feature area, enabling early integration
verification per phase.
```

work-planner's existing Integration Complete criteria naturally covers cross-layer verification when given multiple Design Docs.

## Task Decomposition Phase

task-decomposer follows standard decomposition from the work plan. The key addition is the **layer-aware naming convention**:

| Filename Pattern | Meaning | Executor | Quality Fixer |
|-----------------|---------|----------|---------------|
| `{plan}-backend-task-{n}.md` | Service/backend only | task-executor | quality-fixer |
| `{plan}-frontend-task-{n}.md` | UI/client only | task-executor-frontend | quality-fixer-frontend |

Layer is determined from the task's **Target files** paths — this is a factual determination, not inference.

## Task Cycle

Each task uses the standard 4-step cycle with layer-appropriate agents:

### backend-task
```
1. task-executor → Implementation
2. Escalation check
3. quality-fixer → Quality check and fixes
   - stub_detected → Return to step 1 with incompleteImplementations details
   - blocked → Escalate to user
   - approved → Proceed to step 4
4. git commit (on approved)
```

### frontend-task / ui-task
```
1. task-executor-frontend → Implementation
2. Escalation check
3. quality-fixer-frontend → Quality check and fixes
   - stub_detected → Return to step 1 with incompleteImplementations details
   - blocked → Escalate to user
   - approved → Proceed to step 4
4. git commit (on approved)
```

### integration-test-reviewer Placement

When `requiresTestReview` is `true`:
- Standard flow (integration-test-reviewer after task-executor, before quality-fixer)

## Agent Routing Summary

The orchestrator selects agents by **filename pattern matching** — no conditional inference required:

```
*-backend-task-*   → task-executor + quality-fixer
*-frontend-task-*  → task-executor-frontend + quality-fixer-frontend

Naming note: `frontend-task` remains the canonical filename token for the UI/client layer to preserve existing orchestration compatibility. In `.NET` + `Blazor` plugin combinations, this token maps to the Blazor/UI layer.
```

All other orchestration rules (stop points, structured responses, escalation handling, task management) follow the standard subagents-orchestration-guide.
