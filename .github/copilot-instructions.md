# GitHub Copilot Instructions for This Repository

This repository follows strict PowerShell engineering standards.
GitHub Copilot must follow these rules when generating code, tests, documentation, refactoring suggestions, or pull request review comments.

These instructions apply to:

- inline code suggestions
- Copilot Chat responses
- pull request review comments
- refactoring suggestions
- test generation
- documentation generation

When repository examples and this file differ, this file takes precedence unless the repository explicitly documents an approved exception.

## Non-Negotiable Rules

GitHub Copilot must always:

- generate advanced functions, not basic functions
- use approved PowerShell verbs
- include `param()` blocks
- support `ShouldProcess` for state-changing functions
- avoid `Write-Host`
- return structured objects
- generate Pester tests for new public functions
- avoid live external service calls in tests
- prefer Microsoft Graph PowerShell SDK over raw REST calls

---

## 1. Core Principles

- Prefer clarity, determinism, and testability over brevity.
- Follow established repository patterns before introducing new ones.
- Generate production-quality PowerShell, not demo-style scripts.
- Avoid hidden side effects.
- Keep public behavior consistent and automation-friendly.
- Do not generate placeholder logic, fake implementations, or “TODO” code unless explicitly requested.

---

## 2. PowerShell Version and Compatibility

- Default target is PowerShell 7.4.x (LTS). Do not use features deprecated in 7.4+ or experimental features unless requested.
- Do not use commands, syntax, or .NET APIs that break the repository’s supported PowerShell versions.
- Prefer cross-platform compatible approaches unless a Windows-only dependency is intentional and documented.
- If compatibility tradeoffs are necessary, explain them in comments or review feedback.

---

## 3. Function Design Standards

- All PowerShell functions must be advanced functions.
- Every advanced function must include `[CmdletBinding(SupportsShouldProcess = $true)]`.
- All state-changing functions must support `-WhatIf` and `-Confirm`.
- Read-only functions may still use `CmdletBinding()`, but must not claim `SupportsShouldProcess` unless they perform state changes.
- All functions must include a `param()` block, even when no parameters are currently required.
- Use approved PowerShell verbs only.
- Use singular, descriptive nouns.
- Prefer one public function per file.
- Public functions must be small, composable, and delegate reusable logic to private helper functions.
- Do not place executable logic at module import time unless explicitly required for module initialization.

---

## 4. ShouldProcess Standards

- Any function that creates, updates, deletes, enables, disables, assigns, revokes, imports, exports, or otherwise changes state must use `ShouldProcess`.
- Use `if ($PSCmdlet.ShouldProcess(...))` around the actual mutation only.
- Do not wrap validation, lookups, or harmless preparation steps in `ShouldProcess`.
- `-WhatIf` must prevent all state changes.
- `-Confirm` must work naturally without custom confirmation prompts unless there is a documented exception.

---

## 5. Parameter Standards

- Use PascalCase for all parameter names.
- Use descriptive names; avoid abbreviations except well-known industry terms such as `Id`, `Uri`, `Api`.
- Every parameter must include appropriate attributes such as `[Parameter()]`, validation attributes, and pipeline attributes when relevant.
- Use `[ValidateNotNullOrEmpty()]` for required string and collection inputs where appropriate.
- Use `[ValidateSet()]` only when the allowed values are stable and intentional.
- Use parameter sets when a function supports multiple distinct invocation patterns.
- Prefer strongly typed parameters over untyped `object`, raw hashtables, or loosely structured input.
- Use `SwitchParameter` for flags.
- Do not accept secrets as plain text unless there is no supported alternative and the reason is documented.
- Do not rely on implicit type conversion when it harms readability or predictability.

---

## 6. Pipeline Standards

- Support pipeline input only when it meaningfully improves usability.
- If pipeline input is supported, implement `begin`, `process`, and `end` blocks correctly.
- Functions accepting pipeline input must process one input object at a time in `process`.
- Emit one output object per input object unless the function contract explicitly states otherwise.
- Prefer meaningful variable names over `$_` except in trivial expressions.
- Do not collect pipeline input into arrays unless batching is intentional and documented.

---

## 7. Naming and Variable Standards

### Function Names

- Use PascalCase with Verb-Noun naming.
- Verbs must be approved PowerShell verbs.
- Nouns must be singular, descriptive, and repository-consistent.

### Parameter Names

- Use PascalCase.

### Local Variables

- Use camelCase.
- Names must be descriptive and meaningful.
- Avoid single-letter variable names except for trivial loop counters.

### Constants

- Use ALL_CAPS with underscores.
- Define constants near the top of the script, module, or scope where they are needed.

### Scope

- Prefer local scope.
- Avoid `global:` and `script:` scope unless explicitly required.
- Script-scoped state may be used only for intentional module initialization or controlled caching.
- Do not rely on implicit variable creation.
- Avoid `$env:` inside functions unless the function is specifically responsible for environment interaction.

---

## 8. Output Standards

- Functions must return structured objects, preferably `[PSCustomObject]` or well-defined typed objects.
- Do not return formatted text intended for humans as the primary output.
- Do not use `Write-Host`.
- Output object property names must use PascalCase.
- Output shape must be stable and consistent across success paths.
- Document output using `[OutputType()]` where practical.
- Return nothing for no-result scenarios unless the function contract explicitly requires a status object.
- Avoid mixing incompatible object types in a single output stream.
- Do not emit unintentional pipeline output.

---

## 9. Error Handling Standards

- Use terminating errors for unrecoverable failures.
- Use `throw` for terminating errors and `Write-Error` for non-terminating errors when continuation is intentional.
- Use `try/catch` around operations that can fail, including network calls, file I/O, deserialization, and Graph operations.
- Catch specific exception types where practical.
- Do not use empty catch blocks.
- Do not suppress errors with `-ErrorAction SilentlyContinue` unless there is a documented reason.
- Do not depend on global `$ErrorActionPreference`.
- Error messages must be descriptive, actionable, and include relevant context.
- Do not swallow exceptions without adding value.

---

## 10. Logging and Diagnostic Output

- Use `Write-Verbose` for diagnostic progress details.
- Use `Write-Information` for user-facing informational messages when appropriate.
- Use `Write-Debug` only for deep troubleshooting scenarios.
- Never log secrets, access tokens, refresh tokens, client secrets, authorization headers, or personally sensitive data.
- Verbose messages must describe actions and context, not dump raw objects unnecessarily.

---

## 11. Security Standards

- Never use `Write-Host`.
- Never log secrets or tokens.
- Never hardcode credentials, secrets, tenant IDs, or environment-specific sensitive values.
- Avoid plaintext secret handling.
- Validate external input, especially file paths, identifiers, and query values.
- Do not disable TLS, certificate validation, or security protections unless explicitly required and documented.
- Prefer least-privilege access patterns.
- Minimize persisted sensitive data.

---

## 12. Microsoft Graph Standards

- Use the Microsoft Graph PowerShell SDK for Graph operations whenever supported.
- Do not use `Invoke-RestMethod` for Graph unless the SDK does not support the required endpoint.
- If a beta endpoint is required, include a comment explaining why.
- Wrap Graph interactions in helper functions to improve consistency, mockability, and testability.
- Implement retry handling for throttling and transient failures where appropriate, especially HTTP 429 and related retry scenarios.
- Do not hardcode Graph URLs when SDK cmdlets or approved helpers are available.
- Graph-related code must be testable without live service calls.

---

## 13. Pester Testing Standards

- Every new public function must include a corresponding Pester test file.
- Test files must use the naming convention: `<FunctionName>.Tests.ps1`.
- Each test file must include `Describe`, `Context`, and `It` blocks.
- Use `BeforeAll` for shared setup and `AfterAll` for cleanup when needed.
- Mock all external dependencies including Graph calls, file I/O, network operations, time-dependent behavior, and environment access.
- Tests must validate:
  - parameter validation
  - parameter sets
  - error handling
  - ShouldProcess and `-WhatIf` behavior
  - output type and structure
  - edge cases
  - dependency call expectations where relevant
- Tests must not depend on live external systems.
- Prefer testing the public contract over internal implementation details.

---

## 14. Documentation Standards

- Every public function must include comment-based help.
- At minimum include:
  - `.SYNOPSIS`
  - `.DESCRIPTION`
  - `.PARAMETER`
  - `.EXAMPLE`
  - `.OUTPUTS`
- Help content must explain purpose, behavior, side effects, and expected output.
- Examples must be realistic and aligned with the function’s actual contract.
- Documentation must be updated when behavior changes.
- Avoid boilerplate help that repeats parameter names without explaining them.

---

## 15. Module and Repository Structure

- Source code must reside in `/src`.
- Tests must reside in `/tests`.
- Documentation must reside in `/docs`.
- Example scripts must reside in `/examples`.
- Public functions must be exported explicitly in the module manifest.
- Private functions must not be exported.
- Private helper functions should reside in a dedicated private location such as `/Private`.
- Keep module manifest files current.
- Do not place executable business logic in the module root.

---

## 16. Formatting Standards

- Indentation must use 4 spaces. Tabs are not permitted.
- Opening braces must be on the same line as the statement.
- Closing braces must align with the opening statement.
- Separate function definitions with one blank line.
- Do not use trailing whitespace.
- Keep lines at 120 characters or fewer unless unavoidable.
- When a pipeline spans multiple lines, place the pipe operator at the beginning of the continued line.
- Use one parameter per line in multi-parameter blocks.
- Format arrays and hashtables with one item per line when readability benefits.
- Do not vertically align assignment operators.
- Prefer single quotes unless interpolation is required.
- Place comments above the line they describe, not at the end of the line.
- Always use LF (Line Feed) for end-of-line characters to ensure compatibility with the repository's Linux-based Dev Container.

---

## 17. PSScriptAnalyzer Standards

All PowerShell code must pass PSScriptAnalyzer using the repository’s configured rules.

### Required Rules

- PSUseConsistentIndentation
- PSUseConsistentWhitespace
- PSUseCorrectCasing
- PSUseDeclaredVarsMoreThanAssignments
- PSUseLiteralInitializerForHashtable
- PSUseShouldProcessForStateChangingFunctions
- PSUseSingularNouns
- PSUseApprovedVerbs
- PSUseBOMForUnicodeEncodedFile
- PSUseCompatibleCmdlets
- PSUseCompatibleSyntax
- PSUseCompatibleTypes
- PSUseToExportFieldsInManifest
- PSUseUTF8Encoding
- PSUseSupportsShouldProcess
- PSUsePSCredentialType
- PSUseCmdletCorrectly
- PSUseOutputTypeCorrectly
- PSUseProcessBlockForPipelineCommand

### Recommended Rules

- PSAvoidUsingWriteHost
- PSAvoidUsingEmptyCatchBlock
- PSAvoidUsingPositionalParameters
- PSAvoidUsingInvokeExpression
- PSAvoidUsingPlainTextForPassword
- PSAvoidUsingWMICmdlet
- PSAvoidUsingDeprecatedManifestFields
- PSAvoidGlobalVars
- PSAvoidUsingComputerNameHardcoded
- PSAvoidUsingUsernameAndPasswordParams
- PSAvoidUsingConvertToSecureStringWithPlainText

### Suppressions

Suppress analyzer rules only when there is a documented, repository-approved justification.

---

## 18. Pull Request Standards

- All changes must include tests when behavior changes or new functionality is introduced.
- Documentation must be updated when applicable.
- Pull requests must not include unrelated changes.
- Formatting-only commits are discouraged.
- Pull requests must pass automated validation before review.
- Copilot review comments should identify missing tests, missing help, analyzer issues, unsafe patterns, breaking output contracts, and repository convention violations.

---

## 19. Copilot-Specific Behavior

### When generating code, Copilot must

- follow repository patterns first
- generate advanced functions instead of basic functions
- include comment-based help for public functions
- include parameter validation
- honor `ShouldProcess` for state-changing functions
- return structured output
- avoid `Write-Host`
- generate Pester tests alongside new public functions
- prefer mockable helper functions for external dependencies
- avoid introducing undocumented dependencies
- avoid speculative refactors outside the requested scope

### When reviewing code, Copilot should flag

- missing tests
- missing help
- analyzer violations
- weak or absent parameter validation
- missing `ShouldProcess`
- raw string output where structured output is expected
- unmockable external calls
- unsafe secret handling
- use of `Invoke-RestMethod` for Graph without justification

---

## 20. Forbidden Practices

Copilot must not generate the following unless explicitly requested and justified:

- `Write-Host`
- global mutable state
- live Graph calls in tests
- `Invoke-Expression`
- empty catch blocks
- plaintext secrets
- hardcoded credentials
- formatting-only refactors unrelated to the task
- output contracts that change silently
- REST-based Graph calls when supported SDK commands exist

---

## 21. General Expectation

Consistency is more important than novelty.
All generated code must align with PowerShell best practices, repository conventions, and the standards defined in this file.
