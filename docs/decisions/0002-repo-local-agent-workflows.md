# 0002 - Repo-Local Agent Workflows

## Status

Accepted

## Context

This template includes maintenance workflows that require more judgment than a single command, but should still be repeatable across agents and sessions. Examples include syncing downstream AI guidance, coordinating runtime policy updates, and preparing template releases.

Generic AI instructions are useful for broad behavior, but they do not give agents enough workflow-specific structure for these recurring tasks. At the same time, relying on agents to infer the correct sequence from scripts and documentation can lead to inconsistent decisions, skipped validation, or changes outside the intended boundary.

The template already favors deterministic automation, Pester validation, and reviewed pull requests. Agent workflow guidance should reinforce that model rather than replace it.

## Decision

Maintain repo-local Codex skills under `.codex/skills/` for significant template workflows that need agent orchestration.

The current repo-local skills cover:

- downstream guidance sync
- runtime policy updates
- template version release management

Skills define when a workflow applies, which deterministic script or source of truth to use, the required validation sequence, success criteria, and stop conditions. They are an orchestration layer for agents, not the source of deterministic behavior.

Repo-local skill changes should be backed by Pester coverage in `tests/unit/SkillScaffold.Tests.ps1`. The Codex `quick_validate.py` helper may be used while authoring skills, but Pester is the repository validation standard.

## Alternatives Considered

- Only use `.github/copilot-instructions.md`: rejected because a single broad instruction file becomes too dense when it tries to encode every workflow.
- Only document scripts and let agents infer the process: rejected because agents may skip audit, branch, validation, or review steps that are essential to safe operation.
- Use scripts without agent workflow guidance: rejected because scripts handle deterministic behavior, but agents still need task-level direction about when to run them and where to stop.
- Add skills without Pester coverage: rejected because skill discoverability and required references should be validated like other template behavior.
- Build heavier automation or CI gates for every maintenance workflow: rejected because some workflows are maintainer-facing and should remain explicit, reviewed actions rather than automatic gates.

## Consequences

Repo-local skills make significant template workflows easier for agents and humans to find, follow, and review.

The approach keeps agents aligned with deterministic scripts, source-of-truth files, Pester tests, and human pull request review. This reduces freestyle repo mutation while preserving enough flexibility for agents to inspect output, explain drift, and prepare useful PR summaries.

Skills add a small maintenance surface. They must stay concise, outcome-focused, and aligned with the scripts and documentation they reference.

Repo-local skills are not a replacement for validation, code review, or maintainer judgment. When a skill conflicts with deterministic script behavior or repository guidance, the script behavior, repository guidance, and explicit maintainer direction take precedence.
