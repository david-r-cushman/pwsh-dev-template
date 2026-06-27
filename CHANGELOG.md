# Changelog

All notable changes to this template are documented in this file.

This project uses Semantic Versioning for the *template itself* (structure, tooling, workflows, devcontainer, and templates).

## Unreleased

### Changed

- Corrected the template release guidance to use lightweight `vX.Y.Z` tags on merged main commits so release tags can continue matching the previously verified GitHub behavior without adding signing-key requirements.


## 0.13.0 - 2026-06-26

### Added

- Added a repo-local change delivery workflow skill for ordinary repository work, including sandbox escalation guidance, non-`main` branch discipline, changelog expectations, release-decision guidance, and PR-first delivery workflow.

### Changed

- Expanded workflow documentation, template guidance sync, downstream cleanup guidance, template health checks, and skill validation so downstream repositories can adopt and discover the change delivery workflow consistently.

### Fixed

- Hardened the GitHub Actions CI module-install step to recover when `PSGallery` is missing from the runner before installing pinned PowerShell modules.

## 0.12.0 - 2026-06-25

### Added

- Added a first-run downstream cleanup workflow for repositories created from this template, including `scripts/Initialize-DownstreamRepo.ps1`, a repo-local cleanup skill, and validation coverage.
- Added manual GitHub Release publishing to the template release process and documented the decision in an ADR.
- Added an ADR that records the expansion of downstream guidance sync to deliver cleanup workflow assets into older downstream repositories.

### Changed

- Expanded downstream guidance sync so existing downstream repositories can receive the downstream cleanup workflow assets and updated workflow guidance before running cleanup locally.

## 0.11.0 - 2026-06-21

### Added

- Added an Architecture Decision Record convention and the first ADR for downstream guidance sync boundaries.
- Added an ADR for repo-local agent workflows as an orchestration layer over deterministic scripts, Pester validation, and human review.
- Added downstream guidance sync support for the ADR scaffold README without syncing numbered project-specific ADRs.

### Changed

- Added a README pointer to the Architecture Decision Records for durable template decisions.
- Added text-editing guidance for preserving line endings and running whitespace checks before commits.
- Clarified README wording that distinguishes template validation tests from downstream project test implementations.
- Moved the README engineering philosophy section higher for earlier reader context.

## 0.10.1 - 2026-06-19

### Changed

- Aligned the Dev Container base image tag with the PowerShell 7.4 LTS Ubuntu 22.04 image published in Microsoft Artifact Registry.
- Updated Dev Container profile setup to use PowerShell's all-users profile path instead of a hardcoded installation directory.
- Clarified why repo-local sync and runtime policy workflows exist and where their boundaries come from.
- Added success criteria to repo-local skills so agents can identify completed workflows more clearly.

## 0.10.0 - 2026-06-19

### Added

- Added a maintainer-facing template health report for generated Markdown, runtime policy, template version metadata, repo-local agent workflow discoverability, and Git release posture.
- Added a human-readable guide for repo-local agent workflows.

### Changed

- Clarified that repo-local skill changes should use Pester as the repository validation standard, with Codex `quick_validate.py` as an optional authoring check.

## 0.9.0 - 2026-06-19

### Added

- Added a repo-local Codex skill and version metadata validator for template release preparation and tagging.

## 0.8.0 - 2026-06-19

### Added

- Added a repo-local Codex skill that guides agents through the runtime and tooling policy update workflow.

## 0.7.0 - 2026-06-19

### Added

- Added a repo-local Codex skill that guides agents through the downstream AI guidance sync workflow.

## 0.6.2 - 2026-06-18

### Added

- Added a template-owned downstream guidance sync script for auditing and updating AI guidance files and README template-version badges.
- Added Pester coverage for downstream guidance sync behavior and safety checks.
- Added README documentation for the downstream guidance sync workflow.

### Changed

- Clarified downstream sync boundaries so project-owned tooling, CI, source, tests, and scaffolds are not treated as default sync targets.

## 0.6.1 - 2026-06-18

### Changed

- Clarified template versioning documentation and reduced duplicated AI instruction guidance.

## 0.6.0 - 2026-06-06

### Added

- Added root-level `AGENTS.md` to direct coding agents to the repository's authoritative AI guidance.
- Added complexity management guidance to Copilot instructions to discourage unnecessary abstractions, speculative architecture, and unsolicited refactoring.
- Added Conventional Commits guidance for AI-generated commit messages.
- Added `README.md` guidance to review `AGENTS.md` and `.github/copilot-instructions.md` before using AI-generated changes.

### Changed

- Clarified AI generation expectations for simplicity, maintainability, and commit message quality.
- Clarified `README.md` template usage guidance for adapting scaffolds for functions, scripts, modules, and tests.

## 0.5.0 - 2026-05-09

### Added

- Added `eng/runtime-policy.json` as the source of truth for pinned PowerShell, Ubuntu, GitHub Actions runner, and baseline tooling versions.
- Added version policy validation for Dev Container, CI, tooling, and documentation references.
- Added generated Markdown block support for policy-managed runtime and tooling documentation.
- Added runtime update workflow documentation for coordinated policy, container, CI, tooling, and generated documentation changes.

### Changed

- Updated CI triggers to remove the retired `Dev` branch and add manual `workflow_dispatch` runs for validating short-lived branches before opening a pull request.
- Updated repo checks to validate generated Markdown freshness and runtime policy alignment.
- Updated README and environment setup documentation to use generated blocks for runtime and tooling version references.
- Removed runtime versions from live documentation headings so versions stay in policy-managed content.
- Classified Dependabot Docker image updates as runtime upgrade candidates with conventional commit prefixes.
- Pinned the GitHub Actions runner image to `ubuntu-22.04`.
- Pinned CI PSScriptAnalyzer installation to `1.25.0`.

### Fixed

- Fixed generated Markdown replacement so only the intended block is updated.
- Fixed generated Markdown writes to preserve LF line endings and a final newline.
- Fixed repo check orchestration to avoid forwarding verbose preferences as switch values.

## 0.4.0 - 2026-05-06

### Added

- Added portfolio context and practical usage guidance to `README.md`.
- Added CI, PowerShell version, and template version badges to `README.md`.
- Added scaffold smoke tests that validate PowerShell script templates parse and PowerShell data files import.
- Added ignore rules for local validation artifacts and environment files.

### Changed

- Simplified GitHub Actions validation to a single CI workflow.
- Updated CI to run `Invoke-RepoChecks.ps1` with template validation enabled.
- Updated GitHub Actions workflow dependencies to Node 24-compatible major versions.
- Pinned CI and Dev Container PowerShell tooling versions for more predictable validation.
- Reworked `docs/copilot-instructions-reference.md` into a maintainer reference instead of duplicating the canonical Copilot instructions.
- Updated `CODEOWNERS` to identify the portfolio template maintainer while noting that downstream repositories should customize ownership.
- Aligned AI governance path guidance with the lowercase `tests` folder.

### Fixed

- Fixed invalid Bash-style line continuation syntax in PowerShell templates.
- Fixed PSScriptAnalyzer result accumulation in `Invoke-RepoChecks.ps1`.
- Cleaned template analyzer warnings so shipped scaffolds validate cleanly.

## 0.3.0 - 2026-05-03

### Added

- Added AI Behavioral Contract documenting expected AI behavior for truthfulness, transparency, verifiability, risk awareness, integrity, and data reliability.
- Added AI Interaction Loop documenting a repeatable workflow for defining, generating, evaluating, challenging, refining, validating, and accepting AI-assisted work.
- Added AI governance alignment to Copilot instructions, linking repository-wide generation behavior to the AI Behavioral Contract and AI Interaction Loop.
- Added Copilot instructions reference updates documenting the layered AI governance model.

### Changed

- Clarified that Copilot instructions act as the enforcement layer for repository AI governance expectations.
- Reorganized and simplified copilot-instructions.md as well as updated the "AI Governance Model."
- Expanded AI usage guidance from code generation standards into a broader governance model for AI-assisted PowerShell development.

## 0.2.0 - 2026-04-15

### Added

- Local repo checks entrypoint (`scripts/Invoke-RepoChecks.ps1`)
- CI + Pester workflows under `.github/workflows/`
- Dependabot configuration (`.github/dependabot.yml`)
- Repo hygiene templates (PR + issue forms, `CONTRIBUTING.md`, `SECURITY.md`, `CODEOWNERS`)
- Expanded templates (module/script scaffolds) and template index

### Changed

- Standardized test folder casing to `tests/` (lowercase)
- Improved Copilot instructions to reference templates consistently

## 0.1.0 - 2026-04-09

### Added

- Stable baseline devcontainer + repository structure and documentation
