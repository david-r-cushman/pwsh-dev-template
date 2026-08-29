# AI Coding Instructions

Apply these requirements to all repository work.

- Follow `AGENTS.md`; prioritize safety, explicit user direction, deterministic repository behavior, supported platforms, then local convention.
- Before modifying tracked content, complete the freshness gate in `AGENTS.md`. Do not pull, rebase, merge, or edit when it fails.
- Be truthful about commands, APIs, and validation. State material assumptions and never expose secrets.
- Make the smallest maintainable change that satisfies the request. Avoid speculative abstractions, unrelated refactors, and unverified claims.
- Target PowerShell 7.4.x unless the README, docs, or task-specific template declares a supported compatibility requirement.
- Use `.github/instructions/` and task-scoped skills for detailed file- and task-specific rules, including `.codex/skills/change-delivery-workflow/SKILL.md`, `.codex/skills/downstream-repo-cleanup/SKILL.md`, `.codex/skills/downstream-guidance-sync/SKILL.md`, `.codex/skills/readme-alignment/SKILL.md`, `.codex/skills/runtime-policy-update/SKILL.md`, and `.codex/skills/template-version-release/SKILL.md`.
- Workflow entrypoints include `scripts/Initialize-DownstreamRepo.ps1`, `scripts/Invoke-TemplateGuidanceSync.ps1`, and `eng/runtime-policy.json`; publish a GitHub Release only after the release PR merges.
- Run relevant validation, inspect the diff, and use Conventional Commits for commits.

Governance rationale lives in `docs/ai-behavioral-contract.md` and `docs/ai-interaction-loop.md`; workflow routing lives in `docs/agent-workflows.md`.
