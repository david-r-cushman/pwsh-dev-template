---
applyTo: "**/*.ps1,**/*.psm1,**/*.psd1"
---

# PowerShell Rules

- Target the repository-supported PowerShell version and use 4-space indentation, same-line braces, and single-quoted strings unless interpolation is required.
- Prefer small advanced functions, terminating errors with useful context, structured output, and `ShouldProcess` around mutations.
- Keep code testable: isolate external effects and avoid live service calls in tests.
- Select the matching PowerShell skill for authoring, testing/review, or external-service details.
