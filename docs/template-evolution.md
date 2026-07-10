# Template Evolution Notes

This repository is intended to be a living baseline for new PowerShell projects rather than a permanently frozen artifact.

Its purpose is to provide a consistent starting point for development environments, project structure, tooling, and workflow conventions. As those surrounding tools and practices change, the template may also need to change.

## Why This Template Evolves

Development templates age in several dimensions:

- PowerShell and base container images change
- tooling and extensions change
- security assumptions change
- linting and testing conventions mature
- local and cloud development workflows evolve

For that reason, this template is maintained as an intentionally evolving baseline rather than a one-time setup.

## Stability Still Matters

Ongoing maintenance does not mean the template should feel unfinished or inconsistent.

The goal is to keep the template:

- clear enough to understand quickly
- stable enough to trust as a starting point
- flexible enough to support real project work
- maintained enough to remain relevant over time

Changes to the template should improve clarity, usability, safety, or maintainability. They should not create unnecessary churn.

## Design Principles For Changes

Updates to this template should generally follow these principles:

- keep README claims aligned with what the repository actually implements
- prefer deliberate tradeoffs over overstated guarantees
- optimize for practical day-to-day development use
- preserve a clean starting point for repositories created from the template
- separate durable guidance from temporary working notes
- keep security boundaries explicit

## Decision Records

Use Architecture Decision Records under `docs/decisions/` for durable template decisions that future maintainers should understand without reconstructing pull request discussion.

ADRs are for significant capabilities, workflow policies, ownership boundaries, or non-obvious tradeoffs. They are not required for routine plans, patch fixes, or release metadata updates. Pull requests remain the place for implementation plans and review discussion, and `CHANGELOG.md` remains outcome-focused.

## Template Versioning

This repository versions the template itself with Semantic Versioning. The version describes the reusable baseline maintained by this repository, not the version of any downstream project created from it.

Use version changes to communicate the impact of template evolution:

- Major versions: breaking changes to template structure, workflows, supported runtime compatibility, generated project expectations, or migration assumptions.
- Minor versions: new template capabilities, scaffolds, workflows, tooling support, or conventions that add value without intentionally breaking existing template consumers.
- Patch versions: corrections, documentation clarifications, policy wording updates, validation fixes, and low-risk maintenance that preserve the current template contract.

Update `VERSION`, the README template-version badge, and `CHANGELOG.md` together when preparing a release. Keep unreleased maintenance notes under the `Unreleased` heading until a release version is chosen. Use `scripts/Test-TemplateVersion.ps1` to verify release metadata before opening a PR. After the release PR is merged, create a lightweight `vX.Y.Z` tag on `main`, push the tag, validate that it points at the merged release commit, and publish a GitHub Release from that tag using the matching changelog section as the release body. Agents should use `.codex/skills/template-version-release/SKILL.md` when coordinating this workflow.

### Lightweight Release Tags

Template releases use lightweight tags created on merged `main` commits. This matches the historical release behavior more closely than a signed-tag requirement, while the repository ruleset that permits only merge commits remains part of the release guardrail.

`scripts/Test-TemplateVersion.ps1 -CheckTag` validates that the expected lightweight tag exists and points at `HEAD`. The final release check is still to confirm GitHub shows the pushed tag as verified.

## Runtime Update Workflow

Dependabot Docker pull requests are treated as runtime upgrade notifications, not as ordinary one-file dependency bumps.

The source of truth for the current runtime, CI runner, and pinned PowerShell tooling versions is `eng/runtime-policy.json`. Files such as the Dockerfile, GitHub Actions workflow, and generated Markdown blocks should agree with that policy.

Agents should use `.codex/skills/runtime-policy-update/SKILL.md` when coordinating this workflow.

When the pinned PowerShell or Ubuntu runtime changes:

- update `eng/runtime-policy.json` first
- update the Dockerfile, CI runner, and pinned tooling only as part of the same deliberate runtime change
- run `scripts/Update-GeneratedMarkdown.ps1` to refresh managed documentation blocks
- run `scripts/Invoke-RepoChecks.ps1 -IncludeTemplates` before merging
- leave historical version references in `CHANGELOG.md` unchanged unless a release note is being added

### Generated Markdown Blocks

Some Markdown content is managed by generated block markers:

```markdown
<!-- BEGIN generated:block-name -->
...
<!-- END generated:block-name -->
```

Do not edit the content inside those blocks by hand. Update `eng/runtime-policy.json`, then run:

```powershell
pwsh -NoProfile -File ./scripts/Update-GeneratedMarkdown.ps1
```

To check whether generated blocks are current without changing files, run:

```powershell
pwsh -NoProfile -File ./scripts/Update-GeneratedMarkdown.ps1 -Check
```

### Version Policy Validation

The repository checks validate that policy-managed values stay aligned across configuration and documentation:

```powershell
pwsh -NoProfile -File ./scripts/Invoke-RepoChecks.ps1 -IncludeTemplates
```

For focused troubleshooting, run the version policy check directly:

```powershell
pwsh -NoProfile -File ./scripts/Test-VersionPolicy.ps1
```

The validation intentionally focuses on the development environment, CI runner, and pinned tooling. PowerShell module compatibility metadata, such as `PowerShellVersion` in module manifests, remains a compatibility decision for each project and is not automatically changed by this workflow.

## What This Means For Downstream Repositories

Repositories created from this template should be treated as their own projects.

This template may continue to evolve after a downstream repository is created, but that does not mean every downstream repository must continuously adopt every template change. Future updates should be evaluated intentionally based on project needs.

### Downstream Guidance Sync

AI guidance and guardrail documentation are the default downstream sync targets because they describe how AI-assisted changes should be generated, reviewed, and validated. Keeping those files aligned helps downstream repositories inherit the current operating model without replacing project-specific implementation choices. For repositories that predate the cleanup workflow, sync may also deliver the cleanup script, cleanup skill, shared downstream README skeleton, README alignment workflow assets, and the runtime-policy README-generation assets that support that README workflow.

The downstream guidance sync process is intentionally narrow. It may update:

- `AGENTS.md`
- `.github/copilot-instructions.md`
- AI governance and operating-model documents under `docs`
- `docs/decisions/README.md` as the ADR scaffold
- the README template-version badge

It does not update source code, tests, Pester configuration, PSScriptAnalyzer settings, GitHub Actions workflows, Dev Container files, module manifests, scaffolds other than the cleanup and README workflow assets, or numbered project-specific ADRs. The one runtime-policy exception is the narrow set of README-generation assets required to keep the shared downstream README skeleton functional in older downstream repositories. Those files become downstream-owned after repository creation or, for cleanup-owned guidance surfaces, after the immediate cleanup step.

Cleanup itself remains a downstream-repository action performed through `scripts/Initialize-DownstreamRepo.ps1`. Any broader synchronization should be explicit, repo-specific, and reviewed as normal project work.

## Maintenance Mindset

For a quick maintainer posture check, run:

```powershell
pwsh -NoProfile -File ./scripts/Get-TemplateHealth.ps1
```

The health report summarizes generated Markdown, runtime policy, template version metadata, repo-local agent workflow discoverability, and Git release posture. It is a report by default, not a replacement for the full repository checks.

The template should be reviewed periodically with questions such as:

- does the documentation still match the implementation
- do the container and editor configurations still reflect current intent
- are the security assumptions still valid
- are the default tools and conventions still useful
- has the template become clearer or more confusing over time

The goal is not to make the template perfect. The goal is to keep it owned, coherent, and useful.
