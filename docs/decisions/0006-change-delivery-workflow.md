# 0006 - Change Delivery Workflow

## Status

Accepted

## Context

Routine repository work across this template and downstream portfolio repositories was already following a repeated pattern: inspect repo guidance, avoid working on `main`, update `CHANGELOG.md`, decide whether the change should remain under `Unreleased` or become part of a versioned release, open a normal PR to `main`, and clean up local state after merge.

That pattern was important, but it was not captured in one reusable workflow. As a result, branch discipline, changelog updates, release-decision behavior, and post-merge cleanup had to be re-explained repeatedly. The recurring Windows sandbox failure pattern also needed explicit treatment so agents would recognize errors such as `helper_sid_resolve_failed` and `LookupAccountNameW ... CodexSandboxOffline` as environment/runtime failures that require scoped escalation, not repository changes.

The existing repo-local skills already cover narrower workflows such as downstream cleanup, downstream guidance sync, runtime policy updates, and template version release. None of those skills is the right place to own the normal day-to-day repository change process.

## Decision

Add a separate repo-local change delivery workflow skill at `.codex/skills/change-delivery-workflow/SKILL.md`.

This workflow standardizes ordinary repository change delivery by requiring agents to read repo guidance first, work from a non-`main` branch, update `CHANGELOG.md` for meaningful changes, use `Unreleased` by default, respect any existing repo-specific release/version contract instead of inventing one, validate with the repository's existing checks, open a ready PR to `main`, and perform post-merge local cleanup only after syncing `main`.

The workflow also documents the Windows sandbox recovery pattern so important blocked commands are retried with scoped escalation, narrow justification, and the smallest reasonable `prefix_rule`.

This capability is distributed through the template guidance sync and downstream cleanup surfaces so downstream repositories can inherit the workflow without adopting template-maintainer release metadata.

## Alternatives Considered

- Leave the workflow implicit in general guidance: rejected because the repeated process was important enough to deserve one discoverable, reusable workflow surface.
- Expand `template-version-release` to cover ordinary repository work: rejected because release finalization is narrower and template-specific, while day-to-day change delivery applies more broadly.
- Fold the workflow into downstream guidance sync or cleanup: rejected because those workflows are scoped to setup and guidance propagation, not normal repository changes.
- Introduce a shared downstream versioning contract at the same time: rejected for now because workflow standardization can be adopted immediately, while release metadata remains repo-specific unless a repository already defines it.

## Consequences

Agents now have one reusable workflow for ordinary repository changes that complements the more specialized skills instead of overloading them.

Branch discipline, changelog expectations, release-decision behavior, PR creation, and post-merge cleanup become more consistent across template-maintainer and downstream-repository work.

The template gains another durable workflow capability that must remain aligned across the skill, repo guidance, downstream sync/cleanup surfaces, tests, and release metadata.
