# 0010 - .NET SDK Dev Container Runtime

## Status

Accepted

## Context

The PowerShell team deprecated its container-image distribution in favor of .NET SDK images that include PowerShell. The template previously depended on a PowerShell-owned Ubuntu 22.04 image and a GitHub Actions Ubuntu 22.04 runner. Both no longer provide an appropriate supported baseline.

## Decision

The template uses the PowerShell 7.6 LTS branch from a digest-pinned `mcr.microsoft.com/dotnet/sdk:10.0-noble` image. The Dockerfile verifies the PowerShell major/minor branch during image builds. The runtime policy is the source of truth for this baseline, Ubuntu 24.04, and GitHub Actions runner version.

Dependabot continues to discover Docker image updates. Each proposal remains a reviewed runtime change: a matching PowerShell branch is required, but does not by itself authorize an image update. A dedicated Dev Container workflow builds the complete configuration, including Features, and runs essential tooling smoke tests without publishing an image.

## Alternatives Considered

- Retain the PowerShell-owned image: rejected because the supported distribution path moved to the .NET SDK images.
- Use a floating .NET SDK tag: rejected because the approved image content must remain reviewable and reproducible until a maintainer accepts a digest update.
- Fold Dev Container validation into the existing code-validation workflow: rejected to preserve independent responsibilities and avoid replacing direct runner validation.

## Consequences

The template, generated module manifests, and CI baseline require PowerShell 7.6 and Ubuntu 24.04. Maintainers review Dependabot runtime proposals and use the dedicated workflow as a compatibility signal. Docker and Dev Container validation remain required outside this repository when the local environment cannot run them.
