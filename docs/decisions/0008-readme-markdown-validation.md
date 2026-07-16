# 0008 - README Markdown Validation

## Status

Accepted

## Context

`git diff --check` detects whitespace errors but cannot enforce Markdown structure such as the blank lines surrounding headings and lists. README workflow edits were drifting in those areas, including the shared downstream README that is delivered through cleanup and guidance sync.

The template needs a deterministic validation control that preserves readable README structure without making every Markdown file part of the default repository-check scope.

## Decision

Provide a repository-owned Markdown validator that uses `.markdownlint.json` as its rule-toggle source and enforces MD022 and MD032 by default for the root `README.md` and `templates/downstream/README.md`. Other Markdown files remain opt-in through the validator's `-Path` parameter.

Run the validator from `scripts/Invoke-RepoChecks.ps1` by default. Callers that intentionally need to bypass this check must do so explicitly with `-SkipMarkdownLint`.

Treat the validator as a template-owned downstream baseline: first-run cleanup retains it, and downstream guidance sync can deliver it to established repositories. The downstream delivery remains limited to workflow and validation assets; it does not authorize overwriting project-owned documentation or numbered ADRs.

## Alternatives Considered

Continue relying on visual review and `git diff --check` alone.

Apply Markdown validation to every Markdown file by default.

Keep the validation only in this template and require downstream repositories to recreate it independently.

## Consequences

Repository checks now fail when either default README violates the selected heading or list spacing rules. Maintainers can validate other Markdown documents explicitly without broadening the default gate.

Downstream repositories can receive the same README validation baseline through the established cleanup and guidance-sync workflows, while retaining ownership of project-specific documentation and decisions.
