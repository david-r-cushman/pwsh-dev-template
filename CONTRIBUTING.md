# Contributing

This repository is a template for PowerShell projects. Contributions should keep the template clean, safe-by-default, and broadly useful.

## Development

- Keep changes small and scoped.
- Prefer deterministic behavior over convenience.
- Avoid adding project-specific business logic or environment-specific assumptions.

## Local validation

Run the repository checks before opening a PR:

`pwsh -NoProfile -File .\scripts\Invoke-RepoChecks.ps1`

## Style and conventions

- Follow the PowerShell conventions described in `/.github/copilot-instructions.md`.
- Use structured output (objects) as the default, not formatted text.
- State-changing functions must support `-WhatIf` / `-Confirm` (ShouldProcess).
- Add or update Pester tests when behavior changes.

## Pull requests

- Include a brief summary and rationale.
- Call out risks, compatibility impacts, and migration steps (if any).
- Keep documentation in sync with behavior.
