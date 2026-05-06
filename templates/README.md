# Repository Templates

This folder contains approved starting-point templates for common PowerShell development patterns.

These are intended to be copied into real project locations (typically `src/`, `tests/`, or `scripts/`) and then adapted.

## Conventions

- Replace placeholder names and example values before using templates in production code.
- Keep function files named after the function they contain (one public function per file).
- State-changing functions should support `-WhatIf` / `-Confirm` (`SupportsShouldProcess`).

## Contents

- `functions/`: public function scaffolds (read-only and state-changing)
- `patterns/`: reusable implementation patterns (e.g., retries for transient operations)
- `tests/`: Pester test scaffolds aligned with the function templates
- `module/`: a minimal module folder scaffold (Public/Private + module manifest + entrypoint)
- `scripts/`: script scaffolds for repo automation or one-off tooling
