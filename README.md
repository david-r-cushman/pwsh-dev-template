# PowerShell Development Template: Available Anywhere

[![CI](https://github.com/david-r-cushman/pwsh-dev-template/actions/workflows/ci.yml/badge.svg)](https://github.com/david-r-cushman/pwsh-dev-template/actions/workflows/ci.yml)
<!-- BEGIN generated:readme-powershell-badge -->
![PowerShell 7.4](https://img.shields.io/badge/PowerShell-7.4-blue)
<!-- END generated:readme-powershell-badge -->
![Template Version](https://img.shields.io/badge/template-0.10.1-blue)

A repeatable PowerShell Core development template for building scripts, modules, and automation projects.

This template provides a standardized starting point for PowerShell development with:

<!-- BEGIN generated:readme-runtime-focus -->
- PowerShell 7.4 development
<!-- END generated:readme-runtime-focus -->
- Pester testing
- PSScriptAnalyzer validation
- GitHub Actions CI
- Dev Containers and GitHub Codespaces
- reusable script, function, module, and test scaffolds
- AI governance and GitHub Copilot guidance
- downstream AI guidance sync for repositories created from this template
- repo-local agent skills for guidance sync, runtime policy updates, and template release management
- Conventional Commit standards
- repository hygiene for issues, pull requests, security, and dependency updates

Designed for engineers who want a consistent, AI-assisted PowerShell development workflow with validation and review guardrails.

This repository also serves as the baseline template for my PowerShell-focused portfolio projects, where downstream repositories demonstrate these standards applied to real automation work.

## Portfolio Context

The intent is to make the development standard visible in one place, then demonstrate that standard in downstream repositories built from this template.

This repo provides:

- a repeatable PowerShell development environment
- reusable script, function, module, and test scaffolds
- validation through PSScriptAnalyzer and Pester
- GitHub project hygiene for issues, pull requests, security, and dependency updates
- AI-assisted development governance for safe, reviewable, and verifiable engineering work

Downstream portfolio repositories provide the project-specific implementation and show these standards applied to real PowerShell projects.

## Use This Template

1. Create a new repository from this template.
2. Open the repository locally in VS Code or in a Dev Container.
3. Replace placeholder module metadata if the project is module-oriented.
4. Add scripts, functions, modules, or automation under `src`.
5. Add project-specific Pester tests under `tests`.
6. Copy and adapt scaffolds from `templates` for new functions, scripts, modules, and tests when they fit the work.
7. Review the AI-assisted development guidance in `AGENTS.md` and `.github/copilot-instructions.md` before using AI-generated changes.
8. Run local validation:

   ```powershell
   pwsh -NoProfile -File ./scripts/Invoke-RepoChecks.ps1 -IncludeTemplates
   ```

## Mission

This template gives new PowerShell repositories a ready-to-use development baseline that can be used locally, in a Dev Container, or in GitHub Codespaces.

The goal is to reduce credential exposure, improve environmental consistency, and make it easier to work from almost anywhere without rebuilding the same setup each time.

By using Docker-based development environments, third-party module execution, cloud CLI operations, and script testing can be performed inside a Linux-based workspace instead of directly on the host operating system.

## Architecture And Stack

<!-- BEGIN generated:readme-runtime-stack -->
- **Runtime:** PowerShell 7.4.x (LTS) on Ubuntu 22.04
<!-- END generated:readme-runtime-stack -->
- **Development Modes:** Local VS Code, Docker Dev Containers, and GitHub Codespaces
- **Container Runtime:** Docker Desktop via WSL 2 backend for local container use
- **Isolation Strategy:** The container is intended to minimize exposure of host credentials and host-resident developer tooling inside the development environment
- **Credential Separation:** GitHub Copilot and similar authenticated extensions are intentionally excluded from the container environment
- **Ephemeral Cloud Identity:** Cloud authentication is expected to occur inside the container session when needed by using commands such as `az login`
- **Governance:** Integrated `PSScriptAnalyzer`, `EditorConfig`, and Markdown linting support

## Key Features

### Automated Tooling Injection

The `Dockerfile` provisions a professional PowerShell engineering toolkit:

<!-- BEGIN generated:readme-tooling-list -->
- **Pester 5.7.1:** For unit and integration testing
- **PSScriptAnalyzer 1.25.0:** To enforce PowerShell best practices and security rules
- **Azure CLI:** Pre-installed for cloud resource management
- **PSReadLine 2.4.5:** Configured for a more efficient terminal experience
<!-- END generated:readme-tooling-list -->

Core PowerShell tooling is version-pinned in the Dev Container so validation behavior is more predictable across rebuilds.

### Tailored Developer Experience

The environment injects a specialized PowerShell profile that enables:

- **Predictive IntelliSense:** Leveraging local command history
- **ListView Completion:** High-visibility completion menus
- **Visual Feedback:** A clear startup message confirming the container environment has loaded

## Editor Vs Container Trust Boundary

This template distinguishes between the host editor experience and the in-container development environment.

VS Code on the host may use convenience extensions such as GitHub Copilot or pull request tooling. The development container intentionally excludes those extensions and their authentication state so that code executed inside the container does not gain access to sensitive host credentials or cached tokens.

That same repository structure also supports GitHub Codespaces, providing a browser-accessible development environment when local workstation access is not the preferred option.

## What This Template Does Not Include

This template does not ship with project-specific business logic, public functions, private helpers, or Pester test implementations.

It does include optional scaffolding for both script-first and module-first projects, but downstream repositories are expected to replace placeholder module metadata and add real implementation code.

## Expected Contents Of Repositories Created From This Template

Repositories created from this template are expected to add:

- PowerShell source files under `src`
- Pester tests under `tests`
- project-specific documentation under `docs`
- optional module manifest and build or validation automation as needed

This template provides the environment, conventions, and structure. Downstream repositories provide the implementation.

## Repository Templates

This repository includes approved templates under `templates/` for common PowerShell development patterns.

Use these as starting points for new authored code, tests, scripts, and modules:

- `templates/functions/read-only-function-template.ps1`
- `templates/functions/state-changing-function-template.ps1`
- `templates/patterns/retry-pattern-template.ps1`
- `templates/tests/read-only-function-tests-template.ps1`
- `templates/tests/state-changing-function-tests-template.ps1`

See `templates/README.md` for the full template index (including module and script scaffolds).

For AI-assisted development, these templates are referenced by `/.github/copilot-instructions.md`.

## Validation And CI

- Local checks entrypoint: `scripts/Invoke-RepoChecks.ps1`
- Analyzer settings: `PSScriptAnalyzerSettings.psd1`
- Pester settings: `PesterConfiguration.psd1`
- GitHub Actions workflow: `.github/workflows/ci.yml`

The CI workflow runs the same repo check entrypoint with template validation enabled. This verifies both the reusable scaffold and any downstream project tests.

Runtime and tooling pins are managed through `eng/runtime-policy.json`. For the coordinated update workflow, see [`docs/template-evolution.md`](docs/template-evolution.md).

## Template Health

Run the template health report for a quick maintainer view of generated Markdown, runtime policy, template version metadata, repo-local agent workflow discoverability, and Git release posture:

```powershell
pwsh -NoProfile -File ./scripts/Get-TemplateHealth.ps1
```

Use `-AsJson` for agent-readable output or `-FailOnIssue` when a non-healthy item should fail automation.

## Repo-Local Agent Workflows

This template includes repo-local agent skills for repeatable maintenance workflows. See [`docs/agent-workflows.md`](docs/agent-workflows.md) for the human-readable workflow index and validation expectations.

## Downstream Guidance Sync

This template includes a local sync tool for repositories created from it. The sync updates only AI guidance and guardrail documentation, plus the README template-version badge. It does not update project-owned source, tests, PSScriptAnalyzer settings, Pester configuration, CI workflows, Dev Container files, runtime policy, or scaffolds.

A repo-local Codex skill is also provided at `.codex/skills/downstream-guidance-sync/SKILL.md` so agents can operate the sync script through the intended audit, branch, validation, commit, and pull request workflow.

Run the tool from this template repository and pass the downstream repository path:

```powershell
pwsh -NoProfile -File ./scripts/Invoke-TemplateGuidanceSync.ps1 -Path ../downstream-repo
```

Audit mode is the default and reports drift without changing files. To apply the safe sync set, create or switch the downstream repo to a non-main branch first, then run:

```powershell
git -C ../downstream-repo switch -c chore/sync-template-guidance-0.7.0
pwsh -NoProfile -File ./scripts/Invoke-TemplateGuidanceSync.ps1 -Path ../downstream-repo -Apply
```

The README template badge means the downstream repo's AI guidance and guardrails are aligned to that template version. It does not mean the downstream implementation or tooling fully matches this template.

## Prerequisites And Setup

1. **Host OS:** Windows 11 with WSL 2 enabled
2. **Tools:** Docker Desktop and VS Code with the **Dev Containers** extension
3. **Launch:** Open the folder in VS Code and select **Reopen in Container** when prompted

If you are using GitHub Codespaces instead, create a new Codespace from a repository generated from this template and open the project in the browser-based editor.

## Engineering Philosophy

> *"Zero Margin for Error"*

This template carries over a high-consequence operational mindset into Infrastructure as Code and automation work.

<!-- BEGIN generated:readme-runtime-philosophy -->
- **Deterministic Base Runtime:** The development container is built from a pinned PowerShell 7.4 on Ubuntu 22.04 base image to reduce environmental drift
<!-- END generated:readme-runtime-philosophy -->
- **Controlled Tooling Baseline:** Core development tools are installed automatically in the container so that new repositories begin from a consistent baseline, even though not every tool is currently version-pinned
- **Process Integrity:** Code is not just logic. It is a service. Linting, testing, and deliberate structure are used to keep behavior predictable
- **Respect For State:** Any function that changes a system's state should support `-WhatIf` and `-Confirm` parameters
- **Clean Development Boundary:** Development tools should not unnecessarily expose host credentials or host-resident auth state to code running in the container

That same philosophy also shapes how AI assistance is used in this template and in repositories created from it.

AI is treated as a drafting accelerator, not as a substitute for engineering ownership. Constraints, review standards, safety checks, and final accountability remain human responsibilities.

For the deeper operating model behind that approach, see [`docs/powershell-ai-operating-model.md`](docs/powershell-ai-operating-model.md).

## Troubleshooting

- **Rebuilding:** Use `F1 > Dev Containers: Rebuild Container Without Cache` to force a clean layer refresh
- **Line Ending Errors:** Verify your local `git config core.autocrlf` is set to `input` or `false`
- **Identity Issues:** Run `az login` inside the container terminal to authenticate your cloud session for that environment

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

A repo-local Codex skill is provided at `.codex/skills/template-version-release/SKILL.md` for version preparation and post-merge release tagging. Release tags use the `vX.Y.Z` format and are applied to `main` after the release PR is merged.
