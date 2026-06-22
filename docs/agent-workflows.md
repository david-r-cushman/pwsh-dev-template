# Agent Workflows

This repository includes repo-local agent workflows for repeatable template maintenance tasks.

The workflows are designed around a simple rule: agents may coordinate the work, but deterministic scripts, Pester tests, and human review remain the controls that make the work reliable.

Repo-local skills live under `.codex/skills/`. They tell compatible agents how to use the repository's existing scripts, validation commands, and review expectations. They are not a substitute for reading the repository guidance, inspecting diffs, or opening reviewed pull requests.

## Workflow Index

| Workflow | Use When | Skill | Control | Validation |
| --- | --- | --- | --- | --- |
| Downstream guidance sync | A repository created from this template needs current AI guidance, guardrail docs, and ADR scaffold guidance. | `.codex/skills/downstream-guidance-sync/SKILL.md` | `scripts/Invoke-TemplateGuidanceSync.ps1` | Audit output, downstream diff review, downstream validation |
| Runtime policy update | The template needs coordinated PowerShell, Ubuntu, GitHub Actions runner, or pinned tooling updates. | `.codex/skills/runtime-policy-update/SKILL.md` | `eng/runtime-policy.json` | `scripts/Update-GeneratedMarkdown.ps1 -Check`, `scripts/Test-VersionPolicy.ps1`, `scripts/Invoke-RepoChecks.ps1 -IncludeTemplates` |
| Template version release | The template version, changelog, README badge, release tag, and GitHub Release need to be prepared or finalized. | `.codex/skills/template-version-release/SKILL.md` | `VERSION`, `CHANGELOG.md`, README template badge, annotated `vX.Y.Z` tags, and GitHub Releases | `scripts/Test-TemplateVersion.ps1` and release PR review |

## Operating Model

Use the repo-local skill when the task matches one of the workflow areas above. The skill should guide the agent through the expected branch, script, validation, diff review, commit, and pull request process.

Before planning template maintenance work, agents can run `scripts/Get-TemplateHealth.ps1` for a quick report of generated Markdown, runtime policy, template version metadata, workflow discoverability, and Git release posture.

The agent should not invent a separate process when a deterministic script already exists. If a script reports an error, the correct response is to inspect the failure, fix the cause, and rerun the documented validation. Recovery should still be explicit, reviewable, and consistent with the repository guidance.

Pester is the repository validation standard for repo-local skill behavior and discoverability. When skills or workflow documentation change, update `tests/unit/SkillScaffold.Tests.ps1` so the repository can detect stale skill references, missing metadata, and missing documentation pointers. Codex `quick_validate.py` may still be useful while authoring a skill, but it is not the repository's required validation path.

## Boundaries

Repo-local skills do not make autonomous changes acceptable without review. They should help agents apply known workflows consistently, not broaden the task scope.

The downstream guidance sync workflow is intentionally narrow. It may update AI guidance, guardrail documentation, `docs/decisions/README.md`, and the README template-version badge in downstream repositories. It must not be used to overwrite downstream source code, tests, Pester configuration, PSScriptAnalyzer settings, CI workflows, Dev Container files, runtime policy, module manifests, scaffolds, or numbered project-specific ADRs unless that broader work is requested as a separate repo-specific change.

Runtime policy updates and template version releases are template-repository workflows. Downstream repositories should adopt those changes only through explicit, reviewed project work.
