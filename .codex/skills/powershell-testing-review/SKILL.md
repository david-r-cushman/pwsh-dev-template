---
name: powershell-testing-review
description: Test or review PowerShell changes using comment-based help, Pester, mocks, analyzer expectations, and repository validation.
---

# PowerShell Testing And Review

Use this skill for Pester tests, review, and validation of PowerShell changes.

- Public functions and scripts need focused comment-based help; tests should prove observable contracts and failure behavior.
- Mock filesystem, network, service, time, and environment access. Do not require live services or credentials in unit tests.
- Review `ShouldProcess`, validation, terminating errors, secret handling, stable structured output, cross-platform behavior, and unverified assumptions.
- Run the relevant Pester and analyzer entrypoints. For repository changes, use `scripts/Invoke-RepoChecks.ps1 -IncludeTemplates` when the scope requires full validation.
- Raise actionable findings rather than speculative refactoring requests.
