# Template Polish Punch List

This document captures a prioritized set of wording and documentation improvements to help this repository present a clearer, more polished template story.

The goal is not to change the template's purpose. The goal is to make the repository's stated intent, security boundary, and level of determinism line up cleanly with what the files actually implement.

## 1. Clarify That This Repo Is a Template

### Issue

The README reads partly like a finished engineering environment and partly like a reusable baseline, but it does not quickly explain that this repo is intended to be used as a GitHub template for new PowerShell projects.

### Recommended Change

Add a short section near the top of the README:

```md
This repository is a GitHub template that provides a baseline development environment for new PowerShell projects.

It is intended to give new repositories a consistent starting point for:
- PowerShell 7.4 development
- containerized local tooling
- formatting and linting standards
- Pester-based testing structure
- secure-by-default development habits

Project-specific scripts, modules, tests, and automation are expected to be added in repositories created from this template.
```

## 2. Soften the Version-Pinning Claim

### Issue

The README currently suggests that versions are pinned in the Dockerfile, but the implementation only clearly pins the base image. Azure CLI and installed PowerShell modules are not version-pinned.

### Recommended Change

Replace the current deterministic-build wording with something more precise:

```md
* **Deterministic Base Runtime:** The development container is built from a pinned PowerShell 7.4 on Ubuntu 22.04 base image to reduce environmental drift.
* **Controlled Tooling Baseline:** Core development tools are installed automatically in the container so that new repositories begin from a consistent baseline, even though not every tool is currently version-pinned.
```

## 3. Reword the Bind-Mount / Isolation Claim

### Issue

The README currently makes a very strong "No Host Bind-Mounts" claim. That statement is stronger than what the visible configuration clearly proves.

### Recommended Change

If the configuration does not explicitly enforce that model, use wording like this instead:

```md
* **Isolation Strategy:** The container is intended to minimize exposure of host credentials and host-resident developer tooling inside the development environment.
    * **Credential Separation:** GitHub Copilot and similar authenticated extensions are intentionally excluded from the container environment.
    * **Ephemeral Cloud Identity:** Cloud authentication is expected to occur inside the container session when needed.
```

If "no bind mounts" is a hard requirement, then the configuration should explicitly prove it.

## 4. Explain the Host-vs-Container Extension Boundary

### Issue

The repo has a deliberate split between host workspace convenience and container isolation, but the README does not explain that boundary clearly enough.

### Recommended Change

Add a section like this:

```md
## Editor vs Container Trust Boundary

This template distinguishes between the host editor experience and the in-container development environment.

VS Code on the host may use convenience extensions such as GitHub Copilot or pull request tooling. The development container intentionally excludes those extensions and their authentication state so that code executed inside the container does not gain access to sensitive host credentials or cached tokens.
```

## 5. Add a "What This Template Does Not Include" Section

### Issue

A reviewer may see empty `src` and `Tests` folders and assume the repo is incomplete instead of intentionally clean.

### Recommended Change

Add a short section like this:

```md
## What This Template Does Not Include

This template does not ship with project-specific module code, public functions, private helpers, or Pester test implementations.

Those are expected to be added in repositories created from this template. The goal is to provide a clean baseline without placeholder business logic that downstream projects must remove.
```

## 6. Add a "Generated Repo Expectations" Section

### Issue

The template structure is present, but the intended downstream shape is not described directly enough.

### Recommended Change

Add a section like this:

```md
## Expected Contents of Repositories Created From This Template

Repositories created from this template are expected to add:
- PowerShell source files under `src`
- Pester tests under `Tests`
- project-specific documentation under `docs`
- optional module manifest and build/validation automation as needed

This template provides the environment, conventions, and structure. Downstream repositories provide the implementation.
```

## 7. Fix Comment Wording in `devcontainer.json`

### Issue

The current comments about GitHub extensions being removed are broad enough to suggest they were removed from the repo generally, when the actual intent is to exclude them from the container environment.

### Recommended Change

Replace:

```jsonc
// GITHUB EXTENSIONS REMOVED: Copilot and Pull Requests purged.
```

With:

```jsonc
// GitHub-authenticated extensions are intentionally excluded from the container.
// They may still be available on the host workspace, but not inside this isolated environment.
```

Also replace:

```jsonc
// MOUNTS REMOVED: No connection to your Windows host .copilot folder.
```

With:

```jsonc
// No Copilot authentication storage is mounted into the container.
// This helps keep host-resident credentials out of the in-container environment.
```

## 8. Explain the `remoteUser: "root"` Tradeoff

### Issue

The container currently runs as `root`. That may be an intentional compatibility choice, but without context it weakens the "hardened" story.

### Recommended Change

Use a comment like this:

```jsonc
// The container currently runs as root for compatibility with existing tooling and scripts.
// If stricter least-privilege behavior becomes a priority, this should be revisited.
```

## 9. Scope the `Write-Host` Rule in `copilot-instructions.md`

### Issue

The repo guidance currently reads as though `Write-Host` is forbidden everywhere, but the actual intent is narrower: it should be avoided in authored project code, while environment/bootstrap messaging may still be acceptable.

### Recommended Change

Add a scope note near the top of the instructions:

```md
These instructions apply to authored PowerShell project code, tests, and automation created in repositories that use this template.

They do not necessarily apply to container bootstrap behavior, editor configuration, or environment initialization messages where limited user-facing console output may be intentional.
```

Then update the rule wording from:

```md
- avoid `Write-Host`
```

To:

```md
- avoid `Write-Host` in authored project code; prefer pipeline output, `Write-Verbose`, `Write-Information`, or structured objects as appropriate
```

And update the stronger prohibition from:

```md
- Never use `Write-Host`.
```

To:

```md
- Do not use `Write-Host` in project code unless there is a documented exception for interactive environment/bootstrap messaging.
```

## 10. Tighten the Security Tone

### Issue

Phrases such as "strictly governed" and "zero-footprint" may sound stronger than the current implementation clearly proves.

### Recommended Change

Prefer language like:

- "designed to reduce credential exposure"
- "intended to isolate development tooling from the host"
- "minimizes sensitive host integration"
- "container-first baseline for safer local PowerShell development"

This keeps the security intent while sounding more precise and credible.

## Recommended Order

1. Fix README framing so the repository is clearly understood as a GitHub template.
2. Fix README wording around version pinning and determinism.
3. Fix README wording around isolation and bind mounts.
4. Fix `devcontainer.json` comments about GitHub extensions and auth storage.
5. Scope the `Write-Host` rule in `.github/copilot-instructions.md`.
6. Add the host-vs-container trust boundary explanation.
7. Add sections describing what generated repositories are expected to contain.
