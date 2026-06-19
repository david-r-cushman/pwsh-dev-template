---
name: template-version-release
description: Use when asked to prepare, validate, finalize, tag, or clean up a pwsh-dev-template release version, including SemVer bump decisions, VERSION, CHANGELOG.md, README template badge, Test-TemplateVersion.ps1, vX.Y.Z tags, post-merge release tagging, or merged branch cleanup.
---

# Template Version Release

## Overview

Use this skill to manage template release versioning for `pwsh-dev-template`. The version describes the reusable template baseline, not downstream repositories created from it.

Use `scripts/Test-TemplateVersion.ps1` as the deterministic validator for version metadata.

## Required Context

Before acting, identify:

- the current version from `VERSION`
- the intended next version and whether it is major, minor, or patch
- the release date for the `CHANGELOG.md` heading
- whether the user wants pre-merge release prep or post-merge release finalization

If the next version or bump level is unclear, inspect the change impact and ask before editing release metadata.

## Pre-Merge Release Prep

When preparing a release PR:

1. Update `VERSION` to the chosen `X.Y.Z` value.
2. Update the README template badge to `template-X.Y.Z`.
3. Add a `CHANGELOG.md` heading in this format:

   ```markdown
   ## X.Y.Z - YYYY-MM-DD
   ```

4. Keep historical changelog version references unchanged.
5. Run the version check:

   ```powershell
   pwsh -NoProfile -File ./scripts/Test-TemplateVersion.ps1
   ```

6. Run the full repo check before opening or updating the PR:

   ```powershell
   pwsh -NoProfile -File ./scripts/Invoke-RepoChecks.ps1 -IncludeTemplates
   ```

Use a conventional commit such as `feat(skills): add template version release skill`, `docs(version): prepare 0.9.0 release`, or another message that matches the actual change.

## Post-Merge Release Finalization

After the release PR is merged:

1. Fetch and prune remotes.
2. Switch to `main`.
3. Fast-forward `main` from `origin/main`.
4. Confirm `VERSION`, README badge, and `CHANGELOG.md` match the release version.
5. Create an annotated tag:

   ```powershell
   git tag -a vX.Y.Z -m "Release vX.Y.Z"
   ```

6. Push the tag:

   ```powershell
   git push origin vX.Y.Z
   ```

7. Optionally validate tag placement:

   ```powershell
   pwsh -NoProfile -File ./scripts/Test-TemplateVersion.ps1 -CheckTag
   ```

8. Delete the merged local branch only after the remote branch is deleted or the merge is confirmed.

## Stop Conditions

Stop and report instead of improvising when:

- `VERSION`, README badge, and `CHANGELOG.md` disagree
- the requested version is not a SemVer `X.Y.Z` value
- the changelog entry for the release is missing
- `vX.Y.Z` already exists on a different commit
- `main` is not fast-forwardable after merge
- the working tree is dirty before tagging or branch cleanup

## Agent Role

Treat the validator and Git state as the source of truth. The agent role is to coordinate release metadata updates, inspect diffs, run validation, prepare PR text, tag the merged release, and clean up local branches.
