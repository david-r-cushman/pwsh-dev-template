# PowerShell Development Template: Available Anywhere

[![CI](https://github.com/david-r-cushman/pwsh-dev-template/actions/workflows/ci.yml/badge.svg)](https://github.com/david-r-cushman/pwsh-dev-template/actions/workflows/ci.yml)
<!-- BEGIN generated:readme-powershell-badge -->
![PowerShell 7.4](https://img.shields.io/badge/PowerShell-7.4-blue)
<!-- END generated:readme-powershell-badge -->
![Template Version](https://img.shields.io/badge/template-0.14.0-blue)

A repeatable PowerShell Core development template for building scripts, modules, and automation projects.

This template provides a standardized starting point for PowerShell development with:

<!-- BEGIN generated:readme-runtime-focus -->
- PowerShell 7.4 development
<!-- END generated:readme-runtime-focus -->
- Pester testing and PSScriptAnalyzer validation
- GitHub Actions CI
- Dev Containers and GitHub Codespaces
- reusable script, function, module, and test scaffolds
- AI governance and GitHub Copilot guidance
- downstream AI guidance sync for repositories created from this template
- repo-local agent workflows for change delivery, downstream cleanup, guidance sync, runtime policy updates, and template release management
- Conventional Commit and repository hygiene standards

Designed for engineers who want a consistent, AI-assisted PowerShell development workflow with validation and review guardrails. This repository also serves as the baseline template for my PowerShell-focused portfolio projects, where downstream repositories demonstrate these standards applied to real automation work.

Quick navigation:

- [Portfolio Context](#portfolio-context)
- [Engineering Principles in Practice](#engineering-principles-in-practice)
- [Validation And Maintenance](#validation-and-maintenance)
- [Repository Structure](#repository-structure)

## Portfolio Context

Unlike a traditional project template, this repository is the engineering platform behind my PowerShell portfolio. It establishes the engineering standards, validation workflows, AI guardrails, and governance model used throughout the portfolio, while allowing downstream repositories to adopt template improvements through deliberate, project-specific validation rather than automatic synchronization.

This repo provides:

- a repeatable PowerShell development environment
- reusable script, function, module, and test scaffolds
- validation through PSScriptAnalyzer and Pester
- GitHub project hygiene for issues, pull requests, security, and dependency updates
- AI-assisted development governance for safe, reviewable, and verifiable engineering work

Downstream portfolio repositories provide the project-specific implementation and show these standards applied to real PowerShell projects.

## Engineering Principles in Practice

> *"Zero Margin for Error"*

This template carries over a high-consequence operational mindset into Infrastructure as Code and automation work.

<!-- BEGIN generated:readme-runtime-philosophy -->
- **Deterministic Base Runtime:** The development container is built from a pinned PowerShell 7.4 on Ubuntu 22.04 base image to reduce environmental drift
<!-- END generated:readme-runtime-philosophy -->
- **Controlled Tooling Baseline:** Core development tools are installed automatically in the container so that new repositories begin from a consistent baseline, even though not every tool is currently version-pinned
- **Process Integrity:** Code is not just logic. It is a service. Linting, testing, and deliberate structure are used to keep behavior predictable
- **Respect For State:** Any function that changes a system's state should support `-WhatIf` and `-Confirm` parameters
- **Clean Development Boundary:** Development tools should not unnecessarily expose host credentials or host-resident auth state to code running in the container
- **Human Accountability:** AI assistance accelerates drafting, but review and ownership remain human responsibilities

That same philosophy also shapes how AI assistance is used in this template and in repositories created from it. For the deeper operating model behind that approach, see [`docs/powershell-ai-operating-model.md`](docs/powershell-ai-operating-model.md). For durable engineering decisions behind the template's workflow and ownership boundaries, see [`docs/decisions/`](docs/decisions/).

## Use This Template

1. Create a new repository from this template.
2. Open the repository locally in VS Code or in a Dev Container.
3. Run the downstream cleanup workflow immediately, before adding project-specific docs, tests, ADRs, or CI changes:

   ```powershell
   pwsh -NoProfile -File ./scripts/Initialize-DownstreamRepo.ps1 -Apply -RepositoryName <your-repo-name>
   ```

4. Replace placeholder module metadata if the project is module-oriented.
5. Add scripts, functions, modules, or automation under `src`.
6. Add project-specific Pester tests under `tests`.
7. Copy and adapt scaffolds from `templates` for new functions, scripts, modules, and tests when they fit the work.
8. Review the AI-assisted development guidance in `AGENTS.md` and `.github/copilot-instructions.md` before using AI-generated changes.
9. Run local validation:

   ```powershell
   pwsh -NoProfile -File ./scripts/Invoke-RepoChecks.ps1 -IncludeTemplates
   ```

This template provides the environment, conventions, structure, and reusable scaffolds. Downstream repositories are expected to replace placeholder metadata, add real implementation code, and supply project-specific tests and documentation.

## Runtime And Environment

This template gives new PowerShell repositories a ready-to-use development baseline that can be used locally, in a Dev Container, or in GitHub Codespaces. The goal is to reduce credential exposure, improve environmental consistency, and make it easier to work from almost anywhere without rebuilding the same setup each time.

By using Docker-based development environments, third-party module execution, cloud CLI operations, and script testing can be performed inside a Linux-based workspace instead of directly on the host operating system.

<!-- BEGIN generated:readme-runtime-stack -->
- **Runtime:** PowerShell 7.4.x (LTS) on Ubuntu 22.04
<!-- END generated:readme-runtime-stack -->
- **Development Modes:** Local VS Code, Docker Dev Containers, and GitHub Codespaces
- **Container Runtime:** Docker Desktop via WSL 2 backend for local container use
- **Isolation Strategy:** The container is intended to minimize exposure of host credentials and host-resident developer tooling inside the development environment
- **Credential Separation:** GitHub Copilot and similar authenticated extensions are intentionally excluded from the container environment
- **Ephemeral Cloud Identity:** Cloud authentication is expected to occur inside the container session when needed by using commands such as `az login`
- **Formatting:** UTF-8 text and LF line endings are retained for predictable Git diffs

This template distinguishes between the host editor experience and the in-container development environment. VS Code on the host may use convenience extensions such as GitHub Copilot or pull request tooling, while the development container intentionally excludes those extensions and their authentication state so that code executed inside the container does not gain access to sensitive host credentials or cached tokens.

## Tooling

<!-- BEGIN generated:readme-tooling-list -->
- **Pester 6.0.0:** For unit and integration testing
- **PSScriptAnalyzer 1.25.0:** To enforce PowerShell best practices and security rules
- **Azure CLI:** Pre-installed for cloud resource management
- **PSReadLine 2.4.5:** Configured for a more efficient terminal experience
<!-- END generated:readme-tooling-list -->

The `Dockerfile` provisions a professional PowerShell engineering toolkit, and core PowerShell tooling is version-pinned in the Dev Container so validation behavior is more predictable across rebuilds.

When you work inside the intended Dev Container or Codespaces environment, these tools are already provisioned. If you choose to run validation outside that containerized workflow, install the required modules and CLI tooling separately on the host first.

The environment also injects a specialized PowerShell profile that enables:

- **Predictive IntelliSense:** Leveraging local command history
- **ListView Completion:** High-visibility completion menus
- **Visual Feedback:** A clear startup message confirming the container environment has loaded

## Repository Structure

This repository includes the environment, conventions, and approved templates used to start new PowerShell projects, but it does not ship with downstream project business logic, public functions, private helpers, or project-owned test implementations.

Core repository structure:

- `src/`: project source and optional module scaffold
- `tests/`: Pester tests for the template itself and downstream project tests after repository creation
- `templates/`: approved function, script, module, pattern, and test scaffolds
- `docs/`: operating model, durable decisions, and maintainer guidance
- `scripts/Invoke-RepoChecks.ps1`: local and CI validation entrypoint
- `eng/runtime-policy.json`: runtime, runner, and tooling source of truth
- `.github/copilot-instructions.md`: authoritative AI coding guidance

Template starting points include:

- `templates/functions/read-only-function-template.ps1`
- `templates/functions/state-changing-function-template.ps1`
- `templates/patterns/retry-pattern-template.ps1`
- `templates/tests/read-only-function-tests-template.ps1`
- `templates/tests/state-changing-function-tests-template.ps1`

See `templates/README.md` for the full template index, including module and script scaffolds.

## Validation And Maintenance

Run the complete validation suite:

```powershell
pwsh -NoProfile -File ./scripts/Invoke-RepoChecks.ps1 -IncludeTemplates
```

Run the template health report for a maintainer view of generated Markdown, runtime policy, template version metadata, repo-local agent workflow discoverability, and Git release posture:

```powershell
pwsh -NoProfile -File ./scripts/Get-TemplateHealth.ps1
```

Use `-AsJson` for agent-readable output or `-FailOnIssue` when a non-healthy item should fail automation.

Validation and maintenance also rely on:

- `PSScriptAnalyzerSettings.psd1`
- `PesterConfiguration.psd1`
- `.github/workflows/ci.yml`
- `eng/runtime-policy.json`
- [`docs/template-evolution.md`](docs/template-evolution.md)
- [`docs/agent-workflows.md`](docs/agent-workflows.md)

This template includes repo-local agent skills for repeatable maintenance workflows. For ordinary repository work that does not belong to a more specialized workflow, `.codex/skills/change-delivery-workflow/SKILL.md` keeps branch, changelog, validation, PR, and post-merge cleanup behavior consistent.

New downstream repositories should begin with the README template version badge intact. The cleanup workflow preserves or inserts that badge so inherited guidance and template baseline alignment remain visible even after downstream normalization.

## Downstream Guidance Sync

This template includes a local sync tool for repositories created from it. The sync can refresh AI guidance, guardrail documentation, the ADR scaffold README, the README template-version badge, and the downstream cleanup workflow assets needed by older repositories that were created before cleanup support existed.

Cleanup itself still runs from the downstream repo. For newly created repositories, the intended sequence is to create the repo from the template, run `scripts/Initialize-DownstreamRepo.ps1` locally in the downstream repo, and later use guidance sync from the template repo when guidance drift or missing cleanup assets need to be addressed.

The sync does not update project-owned source, tests, PSScriptAnalyzer settings, Pester configuration, CI workflows, Dev Container files, runtime policy, or project-specific ADRs.

A repo-local Codex skill is also provided at `.codex/skills/downstream-guidance-sync/SKILL.md` so agents can operate the sync script through the intended audit, branch, validation, commit, and pull request workflow.

Run the tool from this template repository and pass the downstream repository path:

```powershell
pwsh -NoProfile -File ./scripts/Invoke-TemplateGuidanceSync.ps1 -Path ../downstream-repo
```

Audit mode is the default and reports drift without changing files. To apply the safe sync set, create or switch the downstream repo to a non-main branch first, then run:

```powershell
git -C ../downstream-repo switch -c chore/sync-template-guidance
pwsh -NoProfile -File ./scripts/Invoke-TemplateGuidanceSync.ps1 -Path ../downstream-repo -Apply
```

If the sync delivered `scripts/Initialize-DownstreamRepo.ps1` and `.codex/skills/downstream-repo-cleanup/` into an older downstream repo, switch into that downstream repo and run cleanup there before doing additional project-specific work.

The README template badge means the downstream repo's AI guidance and guardrails are aligned to that template version. It does not mean the downstream implementation or tooling fully matches this template.

## Prerequisites And Setup

1. **Host OS:** Windows 11 with WSL 2 enabled
2. **Tools:** Docker Desktop and VS Code with the **Dev Containers** extension
3. **Launch:** Open the folder in VS Code and select **Reopen in Container** when prompted

If you are using GitHub Codespaces instead, create a new Codespace from a repository generated from this template and open the project in the browser-based editor.

## Template Versioning

This repository versions the template itself using Semantic Versioning.

- Current version: see `VERSION`
- Version history: see `CHANGELOG.md`
- Version validation: run `scripts/Test-TemplateVersion.ps1`
- Versioning policy: see [`docs/template-evolution.md`](docs/template-evolution.md)

Version changes apply to the template baseline, not to downstream repositories created from it. In general:

- Major versions indicate breaking template, workflow, or compatibility changes.
- Minor versions indicate new template capabilities, tooling, templates, or conventions.
- Patch versions indicate fixes, documentation clarifications, and low-risk maintenance updates.

A repo-local Codex skill is provided at `.codex/skills/template-version-release/SKILL.md` for version preparation, post-merge release tagging, and GitHub Release publishing. Release tags use the lightweight `vX.Y.Z` format and are applied to the merged `main` commit after the release PR is merged. GitHub Releases use the matching changelog section as their public release notes, and GitHub verification should be confirmed in the GitHub UI after the tag is pushed.
