# 0001 - Downstream Guidance Sync

## Status

Accepted

## Context

Repositories created from this template become independent projects. They will usually develop their own source code, tests, analyzer settings, CI workflows, runtime policy, module metadata, and scaffolding choices.

At the same time, this template continues to evolve its AI guidance and guardrails. Those files describe how AI-assisted changes should be generated, reviewed, validated, and kept within project boundaries. If downstream repositories never receive those guidance updates, their AI-assisted workflow can drift away from the current operating model.

## Decision

Provide a template-owned downstream guidance sync workflow that updates only AI guidance and guardrail documentation plus the README template-version badge.

The sync workflow is implemented by `scripts/Invoke-TemplateGuidanceSync.ps1` and documented in `docs/template-evolution.md` and `docs/agent-workflows.md`.

The sync allowlist is intentionally narrow. It may update guidance surfaces such as `AGENTS.md`, `.github/copilot-instructions.md`, AI governance documents, operating-model documents, and the README template-version badge. It must not update downstream source code, tests, Pester configuration, PSScriptAnalyzer settings, CI workflows, Dev Container files, runtime policy, module manifests, or scaffolds.

## Alternatives Considered

- Full template resync: rejected because it could overwrite project-owned implementation, tests, CI, tooling, and runtime decisions.
- Manual copy and paste: rejected because it is error-prone, hard to audit, and inconsistent across downstream repositories.
- Git subtree or submodule: rejected because it would add structural complexity to repositories that should remain ordinary PowerShell projects.
- No sync support: rejected because downstream AI guidance would drift and users would have no repeatable way to adopt updated guardrails.

## Consequences

Downstream repositories can adopt updated AI guidance without losing project ownership of their implementation and tooling.

The template version badge in downstream README files communicates guidance alignment only. It does not mean the downstream repository fully matches the template's runtime, scaffolds, CI, tests, or analyzer configuration.

Any broader downstream synchronization must be handled as explicit, repo-specific project work with normal review.
