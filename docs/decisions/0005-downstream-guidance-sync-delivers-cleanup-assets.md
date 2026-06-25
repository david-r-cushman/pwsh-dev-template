# 0005 - Downstream Guidance Sync Delivers Cleanup Assets

## Status

Accepted

## Context

The original downstream guidance sync workflow was intentionally narrow. It existed to update AI guidance and closely related documentation in downstream repositories without overwriting project-owned implementation, tooling, or workflow choices.

A later template capability added first-run downstream cleanup through `scripts/Initialize-DownstreamRepo.ps1` and the repo-local cleanup skill. Newly created downstream repositories receive those assets automatically because they are created from the current template contents.

Older downstream repositories created before that cleanup workflow existed do not have those assets. Without a migration path, they cannot run the cleanup workflow locally unless those files are copied in manually. That would undermine the deterministic downstream sync model and make adoption inconsistent across existing repositories.

## Decision

Expand downstream guidance sync so it may deliver the downstream cleanup workflow assets into older downstream repositories while still remaining intentionally narrow compared to a full template resync.

The expanded sync workflow may deliver `scripts/Initialize-DownstreamRepo.ps1`, `.codex/skills/downstream-repo-cleanup/`, and the workflow documentation needed to explain how those assets are used. Cleanup itself still runs from the downstream repository via `scripts/Initialize-DownstreamRepo.ps1`.

This decision is a later evolution of the original downstream guidance sync decision in `0001-downstream-guidance-sync.md`. It does not replace the downstream cleanup decision in `0004-downstream-repo-cleanup.md`; it adds the migration path that lets older downstream repositories receive the cleanup workflow safely.

## Alternatives Considered

- Keep sync limited to AI guidance only and require manual cleanup asset copy: rejected because it creates an inconsistent migration path and bypasses the deterministic script-based workflow.
- Expand sync into a broad template resync: rejected because it would blur ownership boundaries and risk overwriting project-owned downstream choices.
- Make guidance sync perform cleanup directly: rejected because cleanup must remain a downstream-repository action that is intentionally run in the local downstream context.

## Consequences

Existing downstream repositories can adopt the cleanup workflow through the same audited sync mechanism they already use for AI guidance alignment.

Downstream guidance sync remains bounded: it can deliver cleanup workflow assets, but it does not become a general-purpose repo rewrite tool.

The template now has an additional durable relationship between the sync and cleanup workflows that must remain aligned across the sync script, cleanup script, skills, documentation, and tests.