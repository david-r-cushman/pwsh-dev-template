# GitHub Copilot Instructions For This Repository

This repository is a GitHub template for PowerShell projects. GitHub Copilot should treat these instructions as practical generation and review constraints for authored project code created from this template.

These instructions apply to:

- inline suggestions
- Copilot Chat responses
- pull request review comments
- test generation
- documentation generation

These instructions apply to authored PowerShell project code, tests, and automation. They do not apply to container bootstrap behavior, editor configuration, or environment initialization messages unless this file, `README.md`, `/docs`, or the relevant template explicitly says they do.

When examples in `/examples`, `/templates`, `/docs`, `README.md`, or comment-based help differ from this file, this file takes precedence unless a repository maintainer has documented an exception in `README.md` or `/docs/EXCEPTIONS.md` under a section or bullet explicitly labeled `Exception`, `Compatibility Exception`, or `Template Exception`.

## Priority Order

When instructions compete, GitHub Copilot should apply the highest matching priority from this list. A lower-priority item must not override a higher-priority item. If priorities appear equally applicable, the earlier item in this list wins.

- Preserve safety, security, and deterministic automation behavior.
- Match the repository's documented PowerShell version, platform support, and existing conventions.
- Use the closest repository template or established local pattern.
- Keep generated code testable, documented, and easy to review.
- If a requested change conflicts with these priorities, flag the conflict and suggest the closest compatible approach.

Examples:
- If a repository template conflicts with safe `ShouldProcess` behavior, preserve `ShouldProcess`.
- If a newer syntax conflicts with the documented PowerShell version, use compatible syntax.
- If security conflicts with compatibility, prioritize security and document the compatibility issue.
- If a local convention conflicts with security guidance, choose the secure implementation and flag the convention conflict.

## Core Expectations

GitHub Copilot should:

- generate production-quality PowerShell, not demo-style scripts
- follow repository patterns before introducing new ones
- optimize for clarity, determinism, testability, and safe automation behavior
- avoid placeholder logic, fake implementations, or TODO-heavy output unless requested by the user prompt or repository documentation

## Prompt Handling

- If the user prompt is ambiguous, ask for clarification before making a high-impact change.
- If the user prompt conflicts with repository instructions, flag the conflict and follow the highest matching priority from this file.
- If the user prompt conflicts with repository conventions but is otherwise clear, follow repository conventions and explain the decision.
- If a low-impact detail is unclear, make the smallest reasonable assumption and state it in the response.

## Function Design And Behavior

- Use advanced functions for reusable PowerShell code.
- Include a `param()` block, even when no parameters are currently required.
- Use approved PowerShell verbs and singular, descriptive nouns.
- Prefer one public function per file when the repository is function- or module-oriented.
- Keep public functions small and composable, and move reusable logic into private helpers.
- Do not place executable business logic at module import time. Limit import-time work to required dependency loading, configuration setup, or explicit module initialization needed before exported functions can run.
- State-changing functions must use `[CmdletBinding(SupportsShouldProcess = $true)]`.
- Read-only functions should use `CmdletBinding()` without `SupportsShouldProcess`.
- Any function that creates, updates, deletes, enables, disables, assigns, revokes, imports, exports, or otherwise changes state must support `-WhatIf` and `-Confirm`.
- Use `if ($PSCmdlet.ShouldProcess(...))` around the actual mutation only.
- Do not wrap validation, lookups, or harmless preparation steps in `ShouldProcess`.
- Use PascalCase parameter names.
- Use descriptive names and avoid unclear abbreviations.
- Use appropriate parameter attributes and validation where relevant.
- Prefer strongly typed parameters over loosely structured input where practical.
- Support pipeline input only when it meaningfully improves usability.
- If pipeline input is supported, implement `begin`, `process`, and `end` blocks correctly.
- Emit one output object per input object unless the contract explicitly requires something else.

## Output, Errors, And Security

- Return structured objects, preferably `[PSCustomObject]` or other stable object shapes.
- Do not return formatted text intended for humans as the primary output.
- Avoid `Write-Host` in authored project code unless there is a documented exception for interactive environment or bootstrap messaging.
- Use terminating errors for unrecoverable failures.
- Use `try/catch` around operations that can fail, including network calls, file I/O, deserialization, and service operations.
- Error messages must be descriptive, actionable, and include relevant context.
- Do not swallow exceptions without adding value.
- Use `Write-Verbose` for diagnostic output and `Write-Information` for user-facing informational messages when appropriate.
- Never log secrets, tokens, credentials, or other sensitive values.
- Never hardcode credentials, secrets, tenant IDs, or environment-specific sensitive values.
- Validate external input, especially file paths, identifiers, and query values.
- Prefer least-privilege access patterns and minimize persisted sensitive data.

## Testing And Documentation

- Generate Pester tests for new public functions.
- Test files should use the naming convention `<FunctionName>.Tests.ps1`.
- Use `Describe`, `Context`, and `It` blocks.
- Mock external dependencies including file I/O, network calls, service interactions, time-dependent behavior, and environment access.
- Tests should cover parameter validation, error handling, output shape, edge cases, and `ShouldProcess` behavior where relevant.
- Tests must not depend on live external systems.
- Public functions should include comment-based help.
- At minimum, include `.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`, `.EXAMPLE`, and `.OUTPUTS` for public functions.
- Examples should be realistic and aligned with the function's actual contract.
- Update documentation when behavior changes.

## Repository Structure And Templates

- Source code should normally reside in `/src`.
- Tests should normally reside in `/Tests`.
- Documentation should normally reside in `/docs`.
- Example scripts, if included, should reside in `/examples`.
- Module manifests and explicit exports should be maintained when the repository is module-based.
- Do not place executable business logic in the repository root.
- This repository includes approved templates under `/templates` for common PowerShell development patterns.
- GitHub Copilot should prefer these templates as the starting point for new authored code and tests when they match the requested task.

Available templates include:
- `/templates/functions/read-only-function-template.ps1`
- `/templates/functions/state-changing-function-template.ps1`
- `/templates/patterns/retry-pattern-template.ps1`
- `/templates/tests/read-only-function-tests-template.ps1`
- `/templates/tests/state-changing-function-tests-template.ps1`
- `/templates/module/ModuleName/ModuleName.psd1`
- `/templates/module/ModuleName/ModuleName.psm1`
- `/templates/scripts/advanced-script-template.ps1`

Expectations:
- Prefer aligning new functions and tests to the closest matching template rather than inventing a new structure.
- Preserve the intent of the selected template while adapting parameters, output contract, dependency usage, and naming to the requested task.
- Do not copy placeholder names or example values into final authored code without replacing them.
- If a matching template is missing or incomplete, follow repository conventions and suggest adding or updating a template when the gap is reusable.
- When no template is a strong fit, follow repository conventions and established patterns instead of forcing an inappropriate template.
- If a task involves transient operations, prefer the retry pattern template rather than generating ad hoc retry logic.

## PowerShell Version And Compatibility

- Default target is PowerShell 7.4.x unless `README.md`, `/docs`, or the relevant template declares a different target in a section or bullet labeled `PowerShell Version`, `Requirements`, or `Compatibility`.
- Ensure generated code is compatible with the repository's documented PowerShell version and platform support.
- If the documented PowerShell version is invalid, unsupported, not explicitly stated, or conflicts across documentation, flag the issue and suggest the closest supported PowerShell version. When clarification is unavailable in the current task, default to PowerShell 7.4.x and document that assumption in the response or review note.
- If a requested implementation conflicts with the documented PowerShell version, flag the conflict and choose the compatible approach when possible.
- Avoid using deprecated cmdlets or modules unless explicitly required. If deprecated behavior is unavoidable, keep it isolated, add a nearby warning comment explaining why, and provide a supported alternative or future migration note in documentation or review notes. If no supported alternative exists, document that limitation and justify the deprecated usage.
- Prefer cross-platform compatible approaches unless a Windows-only dependency is intentional and documented.
- When platform-specific behavior is necessary, isolate it behind clear checks such as `$IsWindows`, `$IsLinux`, or `$IsMacOS`. Tests should cover each supported path and mock or skip unsupported platform behavior explicitly.
- Do not introduce syntax or APIs that conflict with the repository's supported PowerShell version.

## Microsoft Graph And External Services

- Prefer the Microsoft Graph PowerShell SDK over raw REST calls when the SDK supports the required operation.
- If raw REST is required, document why.
- Wrap service interactions in helper functions when doing so improves consistency, mockability, and testability.
- Generated code for external services must support mocking and unit testing without live service calls.

## Formatting And Style

- Use 4 spaces for indentation in PowerShell files.
- Follow repository formatting rules for other file types such as JSON, YAML, and Markdown.
- Keep opening braces on the same line as the statement.
- Prefer single quotes unless interpolation is required.
- Place comments above the line they describe, not at end of line.
- Avoid trailing whitespace.
- Use LF line endings.

## What Copilot Should Flag In Review

- missing tests
- missing comment-based help for public functions
- analyzer violations
- weak or missing parameter validation
- missing `ShouldProcess` for state-changing functions
- unsafe secret handling
- unmockable external calls
- unstable or human-only output contracts
- speculative refactors outside the requested scope

## Forbidden By Default

Unless explicitly requested and justified, do not generate:

- `Invoke-Expression`
- empty catch blocks
- plaintext secret handling
- hardcoded credentials
- live external service calls in tests
- silent breaking changes to established output contracts
- formatting-only refactors unrelated to the task

## General Expectation

Consistency is more important than novelty. Generated code should align with PowerShell best practices, repository conventions, and the standards defined in this file. If a requested implementation conflicts with repository conventions, flag the conflict and provide a short justification or compatible alternative.
