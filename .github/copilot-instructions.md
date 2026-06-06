# GitHub Copilot Instructions For This Repository

## AI Governance Model

This repository follows a structured AI governance approach defined in:

- `/docs/ai-behavioral-contract.md`
- `/docs/ai-interaction-loop.md`

These documents define:

- expected AI behavior (truthfulness, transparency, verifiability, risk awareness, and integrity)
- the interaction model used to evaluate and refine AI-generated output

The instructions in this file translate those principles into concrete generation constraints.

AI must prioritize:

- correctness over fluency
- transparency over completeness
- verifiability over abstraction

When uncertain, incomplete, or potentially unsafe, explicitly state assumptions, limitations, and risks rather than presenting information as fact.

---

This repository is a GitHub template for PowerShell projects. Use these instructions for authored PowerShell project code, tests, automation, pull request review comments, and documentation. Do not use these instructions for container bootstrap behavior, editor configuration, or environment initialization unless this file, `README.md`, `/docs`, or the task-specific template explicitly includes that area.

When examples in `/examples`, `/templates`, `/docs`, `README.md`, or comment-based help differ from this file, this file wins unless `README.md` or `/docs/EXCEPTIONS.md` documents a maintainer-approved exception. PowerShell version requirements are resolved by the rule in `PowerShell Compatibility`.

## Conflict Handling

Resolve conflicts in this order:

1. Safety and security.
2. Deterministic automation behavior.
3. Documented PowerShell version and supported platforms.
4. Repository conventions and closest matching template.
5. User preference.

- Ask the user or maintainer for clarification when a prompt is too ambiguous for a safe implementation.
- If clarification is unavailable, make the assumption that requires the least deviation from this file and state it.
- Do not resolve ambiguity by guessing. State assumptions explicitly when required.
- Briefly explain any decision that rejects compatibility, convention, template guidance, or user preference.

## Simplicity And Complexity Management

Code is a liability. Every line of codee adds maintenance cost, testing requirements, and potential failure modes.

When generating code:

- Prefer the simplest solution that safely satisfies the requirement.
- Prefer native PowerShell features and standard language capabilities over additional abstractions, wrappers, frameworks, or dependencies.
- Do note introduct helper functions, classes, configuration layers, design patters, or reusable abstractions unless they provide clear value for the stated requirement.
- Optimize for readability and maintainability over cleverness or theoretical extensibility.
- Keep the happy path easy to follow.
- Apply error handling and validation where risk exists, but avoid uneccessary defensive code that obscures intent.
- When modifying existing code, solve the requested problem with the smallest reasonable change and avoid unreleated refactoring.
- Do not create future-proofing, scalability mechanisesm or architectural layers unless explicitly requested or clearly justified by the requirement.

When multiple valid implementations exist, prefer the solution with the lowest operational and cognitive complexity.

## Generation Checklist

For new or changed PowerShell code, prefer this checklist over adding one-off patterns:

- Function shape: use production-quality advanced functions with `CmdletBinding()`, a `param()` block, approved verbs, PascalCase parameters, clear names, and small composable public functions.
- State and output: add `SupportsShouldProcess` for mutations, wrap only the mutation, and return structured objects rather than display-formatted text.
- Errors and security: use terminating errors with useful context, avoid undocumented `Write-Host`, validate external input, and never hardcode or log secrets, credentials, tenant IDs, or tokens.
- Tests and help: include comment-based help for public functions and focused Pester tests that mock file I/O, network calls, service calls, time, and environment access.
- Transparency and verifiability: clearly state assumptions, avoid fabricated or speculative behavior, and prefer outputs that can be tested or validated.

## Repository Structure And Templates

Place source code in `/src`, tests in `/tests`, docs in `/docs`, and examples in `/examples` unless an existing project structure clearly uses another convention. Do not place executable business logic in the repository root or at module import time, except for required dependency loading, configuration setup, or module initialization.

Start from the closest matching template in `/templates` when it fits the task:

- `/templates/functions/read-only-function-template.ps1`
- `/templates/functions/state-changing-function-template.ps1`
- `/templates/patterns/retry-pattern-template.ps1`
- `/templates/tests/read-only-function-tests-template.ps1`
- `/templates/tests/state-changing-function-tests-template.ps1`
- `/templates/module/ModuleName/ModuleName.psd1`
- `/templates/module/ModuleName/ModuleName.psm1`
- `/templates/scripts/advanced-script-template.ps1`

If multiple templates apply or conflict, choose in this order: state-changing function, read-only function, tests, retry pattern, module, script. Document deviations from any template considered for the task. If no applicable template exists, follow clear repository conventions. If no applicable template exists and conventions are unclear, ask for maintainer guidance; when guidance is unavailable, base the implementation on the most similar existing code and document the reasoning for that choice.

## PowerShell Compatibility

Target PowerShell 7.4.x unless `README.md`, `/docs`, or the task-specific template declares another version under `PowerShell Version`, `Requirements`, or `Compatibility`. For version conflicts, use this precedence: `README.md`, then `/docs`, then task-specific template. If version requirements are missing, invalid, outdated, or unsupported, provide a PowerShell 7.4.x-compatible fallback and document the assumption.

Avoid syntax, APIs, cmdlets, or modules that conflict with the supported PowerShell version or platform support. Prefer cross-platform approaches; when platform-specific behavior is required, isolate it with `$IsWindows`, `$IsLinux`, or `$IsMacOS`, and test or explicitly mock/skip each supported path.

Avoid deprecated cmdlets, modules, and features. If deprecated behavior is unavoidable, isolate it, add a nearby warning comment, justify the limitation, and include a supported alternative, workaround, or future migration note when one exists.

## External Services

Prefer the Microsoft Graph PowerShell SDK over raw REST calls when the SDK provides equivalent functionality for the required operation. If raw REST is required, document why.

Do not assume API behavior or parameters without confirmation. If uncertain, state limitations or provide a verifiable approach.

Wrap external service interactions in helper functions when it improves consistency, mocking, or testability. Generated external-service code must support unit tests without live service calls.

Apply the deprecation guidance in `PowerShell Compatibility` to external service modules and service-specific cmdlets. Keep unavoidable deprecated service interactions behind helper functions and document the migration path or limitation.

## Formatting And Review

Use 4 spaces for PowerShell indentation, same-line opening braces, single quotes unless interpolation is required, comments above the code they describe, no trailing whitespace, and LF line endings.

In review, flag missing tests, missing comment-based help, analyzer violations, weak validation, missing `ShouldProcess`, unsafe secret handling, unmockable external calls, unstable output contracts, and speculative refactors outside the requested scope.

Flag responses that appear correct but are not verifiable, or that present uncertain information as fact.

Unless explicitly requested and justified, do not generate `Invoke-Expression`, empty catch blocks, plaintext secret handling, hardcoded credentials, live external service calls in tests, silent breaking changes, or unrelated formatting-only refactors.
