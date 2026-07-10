# 0007 - Downstream README Alignment Workflow

## Status

Accepted

## Context

Downstream repositories created from `pwsh-dev-template` should present a recognizable portfolio structure without forcing every repository into identical prose. Earlier cleanup support rewrote downstream guidance and preserved runtime-policy README-generation assets, but downstream README structure still depended on inline cleanup logic or manual editing.

The template now needs a durable shared downstream README skeleton that can be used in two different situations:

- immediate post-create cleanup for brand new downstream repositories
- later README realignment for existing downstream repositories

Because the downstream README uses generated Markdown blocks, the skeleton cannot be treated as an isolated Markdown file. The runtime-policy assets that drive those blocks must remain aligned as well.

## Decision

Store a shared downstream README skeleton in a template-owned non-root location and treat it as the canonical downstream README structure.

Use that skeleton in two ways:

1. `scripts/Initialize-DownstreamRepo.ps1` replaces the inherited root `README.md` with the skeleton during the immediate post-create cleanup window.
2. `scripts/Invoke-ReadmeAlignment.ps1` audits or aligns existing downstream `README.md` files to the same skeleton while preserving repo-specific sections.

Keep the downstream skeleton generator-driven. It retains generated Markdown blocks for runtime and tooling sections, and it preserves the template version badge contract.

Expand downstream guidance sync so older downstream repositories can receive the README skeleton, the README alignment workflow assets, and the runtime-policy README-generation assets required to keep the generated blocks functional.

For portfolio downstream repositories, `Portfolio Context` and `Template Versioning` remain part of the shared structure and are intended to be customized rather than removed.

## Alternatives Considered

Keep downstream README creation fully manual.

Continue generating downstream README content inline inside cleanup.

Make the downstream skeleton fully static and remove generated Markdown dependencies.

Create a single AI-only workflow that handles both first-run cleanup and later README restructuring.

## Consequences

The shared downstream README structure now has a durable source of truth that future maintainers do not need to rediscover from merged diffs.

Brand new downstream repositories continue to normalize deterministically during cleanup without needing AI assistance.

Existing downstream repositories can adopt the shared structure later through a reviewable script-and-skill workflow.

Downstream guidance sync now has a slightly broader allowlist because the README workflow depends on the skeleton and runtime-policy README-generation assets, but it still does not rewrite downstream `README.md` automatically.
