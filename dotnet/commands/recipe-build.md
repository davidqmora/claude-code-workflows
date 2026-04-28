---
description: Execute decomposed .NET tasks in autonomous execution mode
argument-hint: Task batch, work plan, or continuation directive
allowed-tools: ["Read", "Write", "Edit", "MultiEdit", "Glob", "Grep", "Bash", "TodoWrite", "AskUserQuestion", "Skill", "Task"]
---

Load the `recipe-build` skill from this plugin using the Skill tool, then execute it for this request:

`$ARGUMENTS`

Follow that skill's execution rules, quality gates, and stop conditions exactly.
