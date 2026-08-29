# 0009 - Task-Scoped AI Guidance

## Status

Accepted

## Context

Broad universal instructions had accumulated detailed PowerShell authoring, testing, review, and service-integration rules. That made always-on guidance difficult to scan while still failing to distinguish file-specific rules from conditional task knowledge.

## Decision

Keep `AGENTS.md` as the concise cross-agent entrypoint, retain only Copilot-compatible universal rules in `.github/copilot-instructions.md`, and use `.github/instructions/` for Markdown and PowerShell path-specific rules. Place conditional PowerShell detail in Codex-first `powershell-authoring`, `powershell-testing-review`, and `powershell-external-services` skills, while retaining GitHub Copilot compatibility through the always-on and path-specific layers.

Every mutable workflow requires a remote-freshness preflight: inspect the tree, fetch and prune remotes, require a usable tracking remote, and verify that the working branch contains the latest `origin/main`. The workflow stops without pulling, rebasing, merging, or editing when the tree is dirty, the remote is unavailable, or the branch is behind or diverged.

## Alternatives Considered

Keep detailed PowerShell guidance in universal instructions: rejected because it burdens every task and obscures the rules that apply only to PowerShell authoring, testing, or service integrations.

Use only Codex skills: rejected because GitHub Copilot still needs a compact always-on baseline and path-specific instructions it can apply without task routing.

Allow mutable workflows to refresh or reconcile Git state automatically: rejected because implicit pulls, rebases, or merges can change repository history or working state outside the requested task.

## Consequences

Agents load detailed guidance only when it applies, downstream repositories receive the new PowerShell baseline through guidance sync and cleanup, and changes cannot begin from stale repository state.
