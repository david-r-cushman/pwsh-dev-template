# Template Polish Punch List

This document tracks the main polish and alignment work identified during review of this repository as a GitHub template for PowerShell development.

Several items from the original review have now been completed. This file has been updated to reflect the current state of the repository and to leave a smaller set of focused follow-up items.

## Completed In Recent Passes

The following areas have already been addressed:

- The README now clearly frames the repository as a GitHub template rather than a finished PowerShell project.
- The README now uses more precise wording around determinism, isolation intent, and host-vs-container trust boundaries.
- The README now explains what the template does not include and what downstream repositories are expected to add.
- `devcontainer.json` now has clearer comments explaining why GitHub-authenticated extensions are excluded from the container environment.
- `devcontainer.json` now documents the current `remoteUser: "root"` tradeoff.
- `.github/copilot-instructions.md` has been rewritten into a more practical governance document.
- The Copilot guidance now scopes `Write-Host` appropriately and no longer treats bootstrap UX the same as authored project code.
- The Copilot guidance no longer contains the previous `SupportsShouldProcess` contradiction.
- The Copilot guidance is now less rigidly module-only and better fits a general PowerShell project template.

## Remaining Review Items

## 1. Decide Whether To Enforce Stronger Container Isolation In Configuration

### Current State

The README now describes isolation more carefully, but the repository still relies mostly on intent and documented boundary choices rather than explicit enforcement of a stronger isolation model.

### Follow-Up Question

Decide whether the current design is sufficient, or whether the template should explicitly enforce stricter separation such as:

- a custom workspace mount strategy
- a non-root container user
- additional restrictions around mounted host content

### Recommendation

If stricter isolation is a core design requirement, implement it in configuration and then document it precisely. If not, keep the current wording modest and accurate.

## 2. Decide Whether Tool Versions Should Be Further Pinned

### Current State

The README now accurately distinguishes between the pinned base runtime and the not-fully-pinned tooling baseline.

### Follow-Up Question

Decide whether the template should remain flexible or whether it should pin more of the installed toolchain, especially:

- Azure CLI installation behavior
- PowerShell module versions installed in the Dockerfile

### Recommendation

If reproducibility is one of the main selling points of the template, consider pinning additional tools and modules. If convenience matters more, keep the current implementation and wording aligned.

## 3. Review Whether Additional Human-Facing Engineering Standards Belong Outside Copilot Instructions

### Current State

`.github/copilot-instructions.md` has been simplified to focus on practical Copilot behavior. That is an improvement, but it also means broader human engineering conventions may now live only implicitly in the repository.

### Follow-Up Question

Decide whether you want a separate human-facing standards document for things such as:

- repository conventions
- review expectations
- PowerShell engineering philosophy
- testing and documentation norms

### Recommendation

Only add a separate standards document if you want to preserve those conventions for human collaborators. Keep Copilot instructions focused on actionable AI guidance.

## 4. Re-Read The README With A "Stranger To The Repo" Lens

### Current State

The README is much more aligned than before, but it should still be read again as if by someone encountering the repository for the first time.

### Follow-Up Question

Check whether a new reader can quickly answer:

- what this repo is
- what it gives a new project
- what is intentionally excluded
- what security boundary the container is trying to preserve
- what is expected to happen in downstream repos

### Recommendation

If any of those answers still require inference, tighten the wording further.

## 5. Review The Dockerfile Comments For Tone And Precision

### Current State

The Dockerfile still contains a mix of practical build steps and commentary from earlier decision-making.

### Follow-Up Question

Check whether the comments in `.devcontainer/Dockerfile` still reflect current intent cleanly, especially around:

- the security story
- user experience choices
- tool installation rationale

### Recommendation

Keep comments that explain why a choice exists. Remove or revise comments that reflect old iterations rather than the current design.

## Suggested Next Order

1. Re-read the README from a first-time reader's perspective.
2. Review `.devcontainer/Dockerfile` comments and tone.
3. Decide whether stronger isolation should be implemented in configuration.
4. Decide whether more tool and module versions should be pinned.
5. Decide whether broader human engineering standards deserve their own document outside Copilot instructions.
