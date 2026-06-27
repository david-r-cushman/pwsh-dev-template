# 0007 - Signed Template Release Tags

## Status

Accepted

## Context

`pwsh-dev-template` already validates release metadata through `VERSION`, `CHANGELOG.md`, the README template-version badge, and `scripts/Test-TemplateVersion.ps1`. It also uses Git tags and GitHub Releases to mark template release points.

That workflow has been sufficient for finding release commits, but it has not guaranteed that the resulting release tags appear as verified in GitHub. Unsigned annotated tags are easy to create and validate locally, yet they do not provide the same visible provenance signal as a GitHub-verified signed tag.

The template now has a clearer release-management contract, so the remaining gap is how to make release tags reliably verifiable without turning release finalization into a complex or platform-fragile workflow.

## Decision

Future template releases will use signed annotated `vX.Y.Z` tags, with SSH signing as the default maintainer path.

The release workflow will:

- prepare release metadata in the PR as before
- create the signed tag only after the release PR is merged to `main`
- validate local tag existence, tag shape, tag placement, and signature presence through `scripts/Test-TemplateVersion.ps1 -CheckTag`
- require a final human confirmation that GitHub shows the pushed tag as verified

SSH signing is the default because it fits the existing Git/GitHub workflow more naturally than adding a separate GPG-based release-signing setup.

## Alternatives Considered

Continue using unsigned annotated tags.

- Rejected because it preserves the current gap where release tags do not show as verified in GitHub.

Standardize on GPG signing.

- Rejected as the default because it adds more maintainer setup complexity for this repository than necessary to achieve verified tags.

Attempt to make the validator prove GitHub verification status directly.

- Rejected because the local validator should remain deterministic and focused on repository state plus local Git tag metadata. GitHub UI verification is still an external-state confirmation step.

## Consequences

Template release preparation now includes signing guidance as part of the documented maintainer workflow.

Release validation becomes stricter: a tag must not only exist and point at `HEAD`, but also be an annotated tag with a signature.

The first release after this change should be used as the proof point that the workflow produces a GitHub-verified tag in practice.
