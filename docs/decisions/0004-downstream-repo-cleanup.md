# 0004 - Downstream Repo Cleanup

## Status

Accepted

## Context

Repositories created from this template inherit both a useful engineering baseline and a set of files that only make sense while maintaining `pwsh-dev-template` itself. Examples include template release metadata, template-maintainer decision records, maintainer-only repo-local skills, and guidance phrasing that still describes the repository as the template rather than as an independent project.

That mixed starting state creates friction when a new downstream repository begins real work. If cleanup is delayed, it becomes harder to distinguish untouched template leftovers from legitimate downstream customizations. Agents and humans also have less clarity about which inherited files are safe to remove, which should be rewritten, and which should remain downstream-owned from day one.

The template already has a narrow downstream guidance sync workflow for updating AI guidance after a repository is established. That workflow is not intended to normalize a fresh repository immediately after creation.

## Decision

Provide a first-run downstream cleanup workflow that is intended to run immediately after a repository is created from `pwsh-dev-template` and before project-specific implementation work begins.

The cleanup workflow is implemented by `scripts/Initialize-DownstreamRepo.ps1` and documented in `README.md`, `AGENTS.md`, `.github/copilot-instructions.md`, and `docs/agent-workflows.md`. A repo-local Codex skill at `.codex/skills/downstream-repo-cleanup/SKILL.md` defines how agents should operate that workflow safely.

The workflow removes template-maintainer artifacts, rewrites inherited guidance into downstream form, preserves the README template version badge, and stops when the repository appears to have moved beyond the immediate post-create window. Runtime policy files, CI scaffolding, validation entrypoints, templates, and the downstream guidance sync workflow become downstream-owned after cleanup.

## Alternatives Considered

- Leave cleanup manual and ad hoc: rejected because it would be inconsistent and make it too easy to miss template-maintainer artifacts or over-delete downstream-owned files.
- Treat cleanup as a later maintenance step: rejected because delayed cleanup blurs the ownership boundary between untouched template content and project-specific changes.
- Expand downstream guidance sync to perform cleanup: rejected because guidance sync is intentionally narrow and should remain safe for established repositories.
- Keep all template-maintainer artifacts in downstream repositories: rejected because it leaves unnecessary release/versioning surfaces and template-only workflow content in repos that should become independent projects quickly.

## Consequences

New downstream repositories have a clear, documented normalization step that establishes their initial ownership boundary before meaningful project work begins.

The README template version badge remains as a visible signal of inherited guidance and baseline alignment, but it does not imply full downstream parity with the template.

The template gains another durable workflow surface that must stay aligned across the script, skill, documentation, and tests. Changes to that workflow should be treated as template capability changes, not as one-off documentation edits.
