# 0003 - Manual GitHub Releases

## Status

Accepted

## Context

This template has used SemVer, `CHANGELOG.md`, and `vX.Y.Z` Git tags to identify release points. That gives maintainers a reliable Git history, but it leaves GitHub's Releases page empty and makes the human-readable summary less visible to downstream users and future maintainers.

The repository already keeps release notes in `CHANGELOG.md` and validates release metadata with `scripts/Test-TemplateVersion.ps1`. The question is whether to add GitHub Releases, and if so, whether release publishing should be manual, script-assisted, or CI-driven.

## Decision

Publish GitHub Releases manually after release PRs are merged and annotated `vX.Y.Z` tags are pushed.

Each GitHub Release should use:

- the existing `vX.Y.Z` tag
- the title `vX.Y.Z`
- the matching `CHANGELOG.md` section as the release body
- `draft: false`
- `prerelease: false` unless explicitly requested

`CHANGELOG.md` remains the source text for release notes. GitHub Releases are the public summary layer for the same release information, not a replacement for the changelog and not a binary artifact publication mechanism.

Backfill starts with the latest current release only. Older historical tags remain tag-only unless there is a separate reviewed reason to curate them.

## Alternatives Considered

- Keep tag-only releases: rejected because the Releases page is useful as a visible release summary for maintainers and downstream users.
- Create a helper script now: deferred because the current release cadence does not yet justify extra automation and validation surface.
- Create Releases automatically from CI when tags are pushed: deferred because this repo prefers explicit, reviewed maintainer actions for release finalization.
- Backfill every historical tag: rejected because it adds curation work without changing the current template contract.

## Consequences

Release finalization now has one more manual step after tag validation: publish the GitHub Release from the matching changelog section.

The process remains lightweight and reviewable. If manual release publishing becomes repetitive or error-prone, a future ADR can revisit script-assisted or CI-driven publication.