# GitHub Copilot Instructions For This Repository

This repository is a GitHub template for PowerShell projects. Use these instructions for authored PowerShell project code, tests, automation, pull request review comments, and documentation. Do not use these instructions for container bootstrap behavior, editor configuration, or environment initialization unless this file, `README.md`, `/docs`, or the task-specific template explicitly includes that area.

When examples in `/examples`, `/templates`, `/docs`, `README.md`, or comment-based help differ from this file, this file wins unless `README.md` or `/docs/EXCEPTIONS.md` documents a maintainer-approved exception. PowerShell version requirements are resolved by the rule in `PowerShell Compatibility`.

## Conflict Handling

- Preserve safety, security, and deterministic automation behavior before compatibility, convention, or user preference.
- Follow the documented PowerShell version and supported platforms unless doing so would create unsafe behavior.
- Follow repository conventions and the closest matching template unless they conflict with safety or documented compatibility.
- Ask for clarification when a prompt is too ambiguous for a safe implementation.
- If clarification is unavailable, make the assumption that requires the least deviation from this file and state it.
- Briefly explain any decision that rejects compatibility, convention, template guidance, or user preference.

## Generation Checklist

For new or changed PowerShell code, prefer this checklist over adding one-off patterns:

- Use production-quality PowerShell, not placeholder or demo code.
- Use advanced functions with `CmdletBinding()`, a `param()` block, approved verbs, PascalCase parameters, and clear names.
- Add `SupportsShouldProcess` and wrap only the mutation when a function changes state.
- Return structured objects rather than display-formatted text.
- Use terminating errors for unrecoverable failures and descriptive messages with useful context.
- Avoid `Write-Host` in authored project code unless an exception is documented.
- Never hardcode or log secrets, credentials, tenant IDs, tokens, or other sensitive values.
- Validate external input such as paths, identifiers, and query values.
- Keep public functions small, composable, and covered by comment-based help.
- Add focused Pester tests for public functions and mock file I/O, network calls, service calls, time, and environment access.

## Repository Structure And Templates

Place source code in `/src`, tests in `/Tests`, docs in `/docs`, and examples in `/examples` unless an existing project structure clearly uses another convention. Do not place executable business logic in the repository root or at module import time, except for required dependency loading, configuration setup, or module initialization.

Start from the closest matching template in `/templates` when it fits the task:

- `/templates/functions/read-only-function-template.ps1`
- `/templates/functions/state-changing-function-template.ps1`
- `/templates/patterns/retry-pattern-template.ps1`
- `/templates/tests/read-only-function-tests-template.ps1`
- `/templates/tests/state-changing-function-tests-template.ps1`
- `/templates/module/ModuleName/ModuleName.psd1`
- `/templates/module/ModuleName/ModuleName.psm1`
- `/templates/scripts/advanced-script-template.ps1`

If multiple templates apply or conflict, choose in this order: state-changing function, read-only function, tests, retry pattern, module, script. Document deviations from any template considered for the task. If no applicable template exists, follow clear repository conventions. If no applicable template exists and conventions are unclear, ask for maintainer guidance; when guidance is unavailable, base the implementation on the most similar existing code and document that choice.

## PowerShell Compatibility

Target PowerShell 7.4.x unless `README.md`, `/docs`, or the task-specific template declares another version under `PowerShell Version`, `Requirements`, or `Compatibility`. For version conflicts, use this precedence: `README.md`, then `/docs`, then task-specific template. If version requirements are missing, invalid, outdated, or unsupported, provide a PowerShell 7.4.x-compatible fallback and document the assumption.

Avoid syntax, APIs, cmdlets, or modules that conflict with the supported PowerShell version or platform support. Prefer cross-platform approaches; when platform-specific behavior is required, isolate it with `$IsWindows`, `$IsLinux`, or `$IsMacOS`, and test or explicitly mock/skip each supported path.

Avoid deprecated cmdlets, modules, and features. If deprecated behavior is unavoidable, isolate it, add a nearby warning comment, justify the limitation, and include a supported alternative, workaround, or future migration note when one exists.

## External Services

Prefer the Microsoft Graph PowerShell SDK over raw REST calls when the SDK provides equivalent functionality for the required operation. If raw REST is required, document why.

Wrap external service interactions in helper functions when it improves consistency, mocking, or testability. Generated external-service code must support unit tests without live service calls.

## Formatting And Review

Use 4 spaces for PowerShell indentation, same-line opening braces, single quotes unless interpolation is required, comments above the code they describe, no trailing whitespace, and LF line endings.

In review, flag missing tests, missing comment-based help, analyzer violations, weak validation, missing `ShouldProcess`, unsafe secret handling, unmockable external calls, unstable output contracts, and speculative refactors outside the requested scope.

Unless explicitly requested and justified, do not generate `Invoke-Expression`, empty catch blocks, plaintext secret handling, hardcoded credentials, live external service calls in tests, silent breaking changes, or unrelated formatting-only refactors.
