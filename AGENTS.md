# AGENTS.md

## Entry Point

Read this file before repository work. It supplies cross-agent rules; use the layered guidance below for task detail.

Precedence is: safety and security, explicit user direction, deterministic repository behavior and supported platforms, then local convention. Stop and ask when requirements are materially ambiguous. Keep changes scoped, protect secrets, and verify claims with the relevant validation.

## Mandatory Freshness Gate

Before any modification, confirm the working tree is clean, fetch and prune the tracking remote, and verify the branch contains the latest `origin/main`. Stop without pulling, rebasing, merging, or editing if no usable tracking remote exists, the tree is dirty, the branch is behind or diverged, or it lacks the latest `origin/main`.

## Guidance Layers

- `.github/copilot-instructions.md` contains Copilot-compatible always-on rules.
- `.github/instructions/` contains path-specific Markdown and PowerShell rules.
- `.codex/skills/` contains task-scoped detail; read the matching skill before conditional work.

## Skill Routing

- `powershell-authoring`: production PowerShell functions, modules, and scripts.
- `powershell-testing-review`: Pester, analyzer, help, review, and validation.
- `powershell-external-services`: Graph, REST, credentials, deprecation, and integration boundaries.
- Workflow skills: `.codex/skills/change-delivery-workflow/SKILL.md`, `.codex/skills/downstream-repo-cleanup/SKILL.md`, `.codex/skills/downstream-guidance-sync/SKILL.md`, `.codex/skills/readme-alignment/SKILL.md`, `.codex/skills/runtime-policy-update/SKILL.md`, and `.codex/skills/template-version-release/SKILL.md`.
- Their deterministic entrypoints include `scripts/Initialize-DownstreamRepo.ps1`, `scripts/Invoke-TemplateGuidanceSync.ps1`, `scripts/Invoke-ReadmeAlignment.ps1`, and `eng/runtime-policy.json`.
- Template releases use the matching workflow skill; create tags and GitHub Releases only after the release PR merges.

If `.github/copilot-instructions.md` is unavailable, stop and report that repository guidance cannot be loaded.
