# Changelog

All notable changes to this template are documented in this file.

This project uses Semantic Versioning for the *template itself* (structure, tooling, workflows, devcontainer, and templates).

## Unreleased

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
