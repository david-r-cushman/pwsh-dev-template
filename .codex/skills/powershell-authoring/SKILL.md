---
name: powershell-authoring
description: Author or revise PowerShell functions, modules, and scripts with the template's compatibility, structure, mutation, output, and error-handling conventions.
---

# PowerShell Authoring

Use this skill for production PowerShell authoring.

- Start from the closest `templates/functions`, `templates/module`, or `templates/scripts` scaffold when it fits; state a meaningful deviation.
- Use advanced functions with approved verbs, PascalCase parameters, useful validation, and comment-based help for public functions and scripts.
- Put `SupportsShouldProcess` around only the mutation. Return structured objects rather than formatted display text.
- Use terminating errors with actionable context. Avoid hidden side effects, `Write-Host` for functional output, and unnecessary wrappers.
- For service calls or secrets, also use `powershell-external-services`. For tests, review, or validation, use `powershell-testing-review`.
