---
name: runtime-policy-update
description: Use when asked to update, audit, or align the pwsh-dev-template runtime or tooling policy, including PowerShell, Ubuntu, GitHub Actions runner, Pester, PSScriptAnalyzer, PSReadLine, Dev Container, generated Markdown, or eng/runtime-policy.json version drift. Guides agents through the template-only runtime update workflow.
---

# Runtime Policy Update

## Overview

Use this skill to update the template repository's pinned runtime, CI runner, and baseline PowerShell tooling versions. The source of truth is `eng/runtime-policy.json`.

This skill is for `pwsh-dev-template` itself. Do not apply it to downstream repositories unless the user explicitly asks for a separate repo-specific runtime migration.

## Why This Exists

Runtime and tooling pins appear across the Dockerfile, Dev Container metadata, GitHub Actions workflow, generated documentation, and validation behavior. Updating only one surface can leave the template inconsistent even when the individual file looks correct.

`eng/runtime-policy.json` keeps those values coordinated from one source of truth. Generated Markdown and validation scripts make the update repeatable, reviewable, and easier to audit.

## Required Context

Before acting, identify:

- the requested PowerShell, Ubuntu, runner, or tooling version change
- whether the change came from a Dependabot Docker PR, manual request, or maintenance review
- whether the user wants an audit, a branch/PR workflow, or a direct local update

If the requested target versions are unclear, inspect the current policy and ask for the missing version decisions before editing.

Before any update, complete the mandatory freshness preflight: require a clean tree, fetch and prune the tracking remote, and confirm this branch contains the latest `origin/main`. Stop without pulling, rebasing, merging, or editing if the remote is unusable, the branch is behind or diverged, or the tree is dirty.

## Update Workflow

Use this order for runtime or tooling changes:

1. Update `eng/runtime-policy.json` first.
2. Align policy-managed configuration with the policy:
   - `.devcontainer/Dockerfile`
   - `.devcontainer/devcontainer.json`
   - `.github/workflows/ci.yml`
3. Run the generated Markdown update:

   ```powershell
   pwsh -NoProfile -File ./scripts/Update-GeneratedMarkdown.ps1
   ```

4. Inspect the diff and verify generated blocks changed only as a consequence of the policy values.
5. Update `VERSION` and `CHANGELOG.md` when the runtime/tooling update is part of a template release.

Do not edit generated Markdown block contents by hand. Generated blocks are marked with `<!-- BEGIN generated:... -->` and `<!-- END generated:... -->`; update `eng/runtime-policy.json` and rerun the generator instead.

## Validation Workflow

Run focused checks first when troubleshooting:

```powershell
pwsh -NoProfile -File ./scripts/Update-GeneratedMarkdown.ps1 -Check
pwsh -NoProfile -File ./scripts/Test-VersionPolicy.ps1
```

Before opening or merging a PR, run the full repository check:

```powershell
pwsh -NoProfile -File ./scripts/Invoke-RepoChecks.ps1 -IncludeTemplates
```

Report any validation failure with the policy value, file path, expected value, and actual value when available.

## Success Criteria

The workflow is complete when:

- `eng/runtime-policy.json` remains the source of truth for the requested version changes
- policy-managed files and generated Markdown agree with the policy
- generated Markdown was updated through `scripts/Update-GeneratedMarkdown.ps1`, not by hand
- `scripts/Update-GeneratedMarkdown.ps1 -Check`, `scripts/Test-VersionPolicy.ps1`, and `scripts/Invoke-RepoChecks.ps1 -IncludeTemplates` pass
- the diff is limited to the intended runtime, tooling, generated documentation, and release metadata surfaces

## Stop Conditions

Stop and report instead of improvising when:

- a requested version is missing or ambiguous
- the requested PowerShell and Ubuntu combination does not have a known matching container image
- validation reports drift outside the intended runtime/tooling files
- generated Markdown check fails after rerunning the generator
- the diff changes downstream sync behavior, source templates, tests, or AI guidance without an explicit request

## Agent Role

Treat `eng/runtime-policy.json` and the validation scripts as the deterministic controls. The agent role is to coordinate the update, keep generated content aligned, inspect the diff, run validation, and prepare a conventional commit and PR summary.
