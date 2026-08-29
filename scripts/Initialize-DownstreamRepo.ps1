<#
.SYNOPSIS
    Normalizes a newly created downstream repository from pwsh-dev-template.

.DESCRIPTION
    Audits or applies the first-run cleanup workflow intended for repositories
    created from pwsh-dev-template. The workflow removes template-maintainer
    artifacts, rewrites inherited guidance into downstream form, and preserves
    the README template version badge as a visible baseline marker.
#>
[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$RepoRoot = (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '..')).Path,

    [Parameter()]
    [ValidateSet('script', 'module', 'hybrid')]
    [string]$ProjectType = 'script',

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$RepositoryName,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$ModuleName,

    [Parameter()]
    [switch]$Apply,

    [Parameter()]
    [ValidateSet('Text', 'Json')]
    [string]$OutputFormat = 'Text'
)

$ErrorActionPreference = 'Stop'

function Resolve-AbsolutePath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    return (Resolve-Path -LiteralPath $Path).Path
}

function Get-RepoPath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$BasePath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$RelativePath
    )

    return (Join-Path -Path $BasePath -ChildPath $RelativePath)
}

function Test-GitRepository {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    & git -C $Path rev-parse --show-toplevel 2>$null | Out-Null
    return ($LASTEXITCODE -eq 0)
}

function Assert-RemoteFreshness {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$RepoPath
    )

    $status = @(& git -C $RepoPath status --porcelain)
    if ($LASTEXITCODE -ne 0 -or $status.Count -gt 0) {
        throw ('Refusing to apply changes because the working tree is dirty: {0}' -f $RepoPath)
    }

    $origin = & git -C $RepoPath remote get-url origin 2>$null
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($origin)) {
        throw ('Refusing to apply changes because origin is not configured: {0}' -f $RepoPath)
    }

    & git -C $RepoPath fetch --prune origin
    if ($LASTEXITCODE -ne 0) {
        throw ('Refusing to apply changes because origin cannot be fetched: {0}' -f $RepoPath)
    }

    $upstream = & git -C $RepoPath rev-parse --abbrev-ref '@{upstream}' 2>$null
    if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($upstream)) {
        throw ('Refusing to apply changes because the current branch has no upstream: {0}' -f $RepoPath)
    }

    $counts = @((& git -C $RepoPath rev-list --left-right --count HEAD...$upstream) -split '\s+')
    if ($LASTEXITCODE -ne 0 -or $counts.Count -ne 2) {
        throw ('Refusing to apply changes because upstream freshness cannot be determined: {0}' -f $RepoPath)
    }

    if ([int]$counts[0] -gt 0 -and [int]$counts[1] -gt 0) {
        throw ('Refusing to apply changes because the branch has diverged from its upstream: {0}' -f $RepoPath)
    }

    if ([int]$counts[1] -gt 0) {
        throw ('Refusing to apply changes because the branch is behind its upstream: {0}' -f $RepoPath)
    }

    & git -C $RepoPath merge-base --is-ancestor origin/main HEAD
    if ($LASTEXITCODE -ne 0) {
        throw ('Refusing to apply changes because the branch does not contain the latest origin/main: {0}' -f $RepoPath)
    }
}

function Get-FileContent {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return $null
    }

    return Get-Content -Raw -LiteralPath $Path
}

function Write-Utf8File {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string]$Content
    )

    $parent = Split-Path -Path $Path -Parent
    if ($parent -and (-not (Test-Path -LiteralPath $parent))) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    [System.IO.File]::WriteAllText($Path, $Content, [System.Text.UTF8Encoding]::new($false))
}

function Add-ReportItem {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [System.Collections.Generic.List[object]]$Items,

        [Parameter(Mandatory)]
        [ValidateSet('Remove', 'Rewrite', 'Rename', 'Keep', 'ManualFollowUp')]
        [string]$Action,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Reason,

        [Parameter()]
        [AllowEmptyString()]
        [string]$Status = ''
    )

    $Items.Add([pscustomobject]@{
            Action = $Action
            Path = $Path
            Reason = $Reason
            Status = $Status
        })
}

function Remove-RepoItem {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        return
    }

    if ($PSCmdlet.ShouldProcess($Path, 'Remove template-maintainer artifact')) {
        Remove-Item -LiteralPath $Path -Recurse -Force
    }
}

function Rename-RepoItem {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Destination
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return
    }

    $destinationParent = Split-Path -Path $Destination -Parent
    if ($destinationParent -and (-not (Test-Path -LiteralPath $destinationParent))) {
        New-Item -ItemType Directory -Path $destinationParent -Force | Out-Null
    }

    if ($PSCmdlet.ShouldProcess($Path, ('Rename to {0}' -f $Destination))) {
        Move-Item -LiteralPath $Path -Destination $Destination -Force
    }
}

function Get-TemplateVersion {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$RepoPath
    )

    $versionPath = Get-RepoPath -BasePath $RepoPath -RelativePath 'VERSION'
    if (Test-Path -LiteralPath $versionPath -PathType Leaf) {
        return (Get-Content -Raw -LiteralPath $versionPath).Trim()
    }

    $readmePath = Get-RepoPath -BasePath $RepoPath -RelativePath 'README.md'
    $readmeContent = Get-FileContent -Path $readmePath
    if ($null -eq $readmeContent) {
        return $null
    }

    $match = [regex]::Match($readmeContent, '!\[Template Version\]\(https://img\.shields\.io/badge/template-(?<Version>[^)]+)-blue\)')
    if ($match.Success) {
        return $match.Groups['Version'].Value
    }

    return $null
}

function Get-TemplateVersionBadgeLine {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]$TemplateVersion
    )

    if ([string]::IsNullOrWhiteSpace($TemplateVersion)) {
        return $null
    }

    return '![Template Version](https://img.shields.io/badge/template-{0}-blue)' -f $TemplateVersion
}

function Get-SafeHelperName {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )

    $safe = ($Name -replace '[^A-Za-z0-9]', '')
    if ([string]::IsNullOrWhiteSpace($safe)) {
        return 'Module'
    }

    return $safe
}

function Get-DownstreamReadmeContent {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$RepoRoot,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$RepoName,

        [Parameter()]
        [string]$TemplateVersion
    )

    $skeletonPath = Get-RepoPath -BasePath $RepoRoot -RelativePath 'templates/downstream/README.md'
    $skeletonContent = Get-FileContent -Path $skeletonPath
    if ($null -eq $skeletonContent) {
        throw ('Downstream README skeleton not found: {0}' -f $skeletonPath)
    }

    $badgeLine = Get-TemplateVersionBadgeLine -TemplateVersion $TemplateVersion
    $rendered = $skeletonContent.Replace('{{REPOSITORY_NAME}}', $RepoName)
    $rendered = $rendered.Replace('{{TEMPLATE_VERSION_BADGE}}', $badgeLine)
    $rendered = $rendered.Replace('{{REPOSITORY_SUMMARY}}', 'Add a concise repository summary that explains what this project does and why it exists.')

    return ($rendered.TrimEnd("`r", "`n") + "`n")
}

function Get-DownstreamAgentsContent {
    [CmdletBinding()]
    param()

    return @'
# AGENTS.md

## Entry Point

Read this file before repository work. It supplies cross-agent rules; use the layered guidance below for task detail.

Precedence is: safety and security, explicit user direction, deterministic repository behavior and supported platforms, then local convention. Stop and ask when requirements are materially ambiguous. Keep changes scoped, protect secrets, and verify claims with the relevant validation.

## Mandatory Freshness Gate

Before any modification, confirm the working tree is clean, fetch and prune the tracking remote, and verify the branch contains the latest `origin/main`. Stop without pulling, rebasing, merging, or editing if no usable tracking remote exists, the tree is dirty, the branch is behind or diverged, or it lacks the latest `origin/main`.

## Guidance Layers

- `.github/copilot-instructions.md` contains Copilot-compatible always-on rules.
- `.github/instructions/` contains path-specific Markdown and PowerShell rules.
- `.codex/skills/` contains task-scoped detail; read the matching skill before conditional work.

## Skill Routing

- `powershell-authoring`: production PowerShell functions, modules, and scripts.
- `powershell-testing-review`: Pester, analyzer, help, review, and validation.
- `powershell-external-services`: Graph, REST, credentials, deprecation, and integration boundaries.
- Downstream workflows: `.codex/skills/downstream-repo-cleanup/SKILL.md`, `.codex/skills/downstream-guidance-sync/SKILL.md`, and `.codex/skills/readme-alignment/SKILL.md`.
- Their deterministic entrypoints include `scripts/Initialize-DownstreamRepo.ps1`, `scripts/Invoke-TemplateGuidanceSync.ps1`, and `scripts/Invoke-ReadmeAlignment.ps1`.

If `.github/copilot-instructions.md` is unavailable, stop and report that repository guidance cannot be loaded.
'@
}

function Get-DownstreamAgentWorkflowsContent {
    [CmdletBinding()]
    param()

    return @'
# Agent Workflows

This repository includes repo-local agent workflows for downstream setup and ongoing template guidance alignment.

The workflows are designed around a simple rule: agents may coordinate the work, but deterministic scripts, Pester tests, and human review remain the controls that make the work reliable.

Repo-local skills live under `.codex/skills/`. They tell compatible agents how to use the repository's existing scripts, validation commands, and review expectations. They are not a substitute for reading the repository guidance, inspecting diffs, or opening reviewed pull requests.

For production PowerShell, Pester or review work, and external-service integrations, use the task-scoped `powershell-authoring`, `powershell-testing-review`, and `powershell-external-services` skills respectively. Complete the mandatory remote-freshness preflight before any mutable workflow.

## Workflow Index

| Workflow | Use When | Skill | Control | Validation |
| --- | --- | --- | --- | --- |
| Change delivery workflow | Ordinary repository work needs consistent branch, changelog, validation, PR, and post-merge cleanup discipline. | .codex/skills/change-delivery-workflow/SKILL.md | Repository guidance, Git state, repo-specific validators, diff review, and human review | Repo-specific validation, staged diff review, and PR review |
| Downstream repo cleanup | A repository was just created from `pwsh-dev-template` and needs immediate first-run normalization before project-specific work begins. | `.codex/skills/downstream-repo-cleanup/SKILL.md` | `scripts/Initialize-DownstreamRepo.ps1` | Audit output, downstream diff review, `scripts/Invoke-RepoChecks.ps1` |
| Downstream guidance sync | A downstream repository needs current AI guidance, guardrail docs, README workflow assets, and ADR scaffold guidance from `pwsh-dev-template`. | `.codex/skills/downstream-guidance-sync/SKILL.md` | `scripts/Invoke-TemplateGuidanceSync.ps1` | Audit output, downstream diff review, downstream validation |
| README alignment | A downstream repository README needs to be audited or realigned to the shared portfolio skeleton after cleanup. | `.codex/skills/readme-alignment/SKILL.md` | `scripts/Invoke-ReadmeAlignment.ps1` | README audit output, downstream diff review, `scripts/Invoke-RepoChecks.ps1` with Markdown validation |

## Operating Model

Use the repo-local skill when the task matches one of the workflow areas above. The skill should guide the agent through the expected audit, apply, validation, diff review, commit, and pull request process.

The change delivery workflow is intentionally process-oriented. It standardizes branch, changelog, release-decision, pull request, and cleanup behavior for everyday downstream work while still relying on repo guidance, repo validators, diff review, and human review as the controls.

The agent should not invent a separate process when a deterministic script already exists. If a script reports an error, the correct response is to inspect the failure, fix the cause, and rerun the documented validation. Recovery should still be explicit, reviewable, and consistent with the repository guidance.

## Boundaries

Repo-local skills do not make autonomous changes acceptable without review. They should help agents apply known workflows consistently, not broaden the task scope.

The downstream cleanup workflow is intentionally a first-run normalization step. It may remove template-maintainer artifacts and rewrite inherited guidance into downstream form, but it must not invent business logic, project-specific tests, repo-specific documentation, or unrelated CI changes.

The downstream guidance sync workflow is intentionally narrow. It may update AI guidance, guardrail documentation, `docs/decisions/README.md`, the README template-version badge, the shared downstream README skeleton, the README alignment workflow assets, and the runtime-policy README-generation assets required by that workflow. It must not be used to overwrite downstream source code, tests, Pester configuration, PSScriptAnalyzer settings, CI workflows, Dev Container files, module manifests, scaffolds outside the README workflow assets, or numbered project-specific ADRs unless that broader work is requested as a separate repo-specific change.
'@
}

function Get-DownstreamDecisionsReadmeContent {
    [CmdletBinding()]
    [OutputType([string])]
    param()

    return @'
# Architecture Decision Records

This directory captures durable repository decisions that future maintainers should be able to understand without reconstructing pull request discussion.

ADRs are not required for routine documentation updates, patch fixes, or implementation plans that are fully explained by the pull request. Use a decision record when a change introduces or changes a durable repository capability, workflow policy, ownership boundary, or non-obvious tradeoff.

Good ADR candidates include decisions that affect:

- repository-specific architecture or operational boundaries
- AI-assisted development workflow or governance
- validation and CI expectations
- runtime or tooling policy
- release policy
- ownership boundaries between this repository and external systems

## Format

Use a short, numbered Markdown file with this structure:

```markdown
# 0001 - Decision Title

## Status

Accepted

## Context

## Decision

## Alternatives Considered

## Consequences
```

Keep ADRs brief and outcome-focused. They should explain durable reasoning, not replay every implementation step.
'@
}

function Get-DownstreamCopilotInstruction {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ExistingContent
    )

    $updatedContent = $ExistingContent
    $updatedContent = $updatedContent -replace 'This repository is a GitHub template for PowerShell projects\.', 'This repository was created from the pwsh-dev-template GitHub template and is now treated as its own PowerShell project.'
    $updatedContent = $updatedContent -replace ', `\.codex/skills/runtime-policy-update/SKILL\.md`', ''
    $updatedContent = $updatedContent -replace ', `\.codex/skills/template-version-release/SKILL\.md`', ''
    $updatedContent = $updatedContent -replace ' and `\.codex/skills/template-version-release/SKILL\.md`', ''

    $pattern = '(?s)## Repo-Local Skills\r?\n.*?\r?\n## PowerShell Compatibility'
    $replacement = @'
## Repo-Local Skills

Repo-local Codex skills are stored under `.codex/skills/`. When asked to normalize a newly created downstream repository from `pwsh-dev-template`, use `.codex/skills/downstream-repo-cleanup/SKILL.md` and operate `scripts/Initialize-DownstreamRepo.ps1` through the documented audit, apply, validation, and diff-review workflow. Use this only as an immediate post-create cleanup step before project-specific work begins.

When asked to synchronize downstream AI guidance from `pwsh-dev-template`, use `.codex/skills/downstream-guidance-sync/SKILL.md` and operate `scripts/Invoke-TemplateGuidanceSync.ps1` through the documented audit, branch, validation, commit, and pull request workflow. Do not manually edit downstream guidance files outside the sync script allowlist unless the user explicitly asks for manual repair after a script failure.

When asked to audit or align a downstream README to the shared portfolio skeleton, use `.codex/skills/readme-alignment/SKILL.md` and operate `scripts/Invoke-ReadmeAlignment.ps1` through the documented audit, branch, validation, diff-review, and commit workflow.

Runtime policy, generated Markdown, CI, tests, scaffolds, and release metadata become downstream-owned after cleanup. Treat changes to those surfaces as normal repository work, except when downstream guidance sync is intentionally delivering the README workflow assets that depend on `eng/runtime-policy.json` and `scripts/Update-GeneratedMarkdown.ps1`.

For ordinary downstream repository changes after cleanup, use .codex/skills/change-delivery-workflow/SKILL.md to coordinate sandbox escalation, non-main branches, changelog updates, release decisions, commits, pull requests, and post-merge cleanup.

When adding or updating repo-local skills, add or update Pester coverage in `tests/unit/SkillScaffold.Tests.ps1` for the skill file, metadata, required references, and agent discoverability. The Codex `quick_validate.py` helper may be used as an optional authoring check, but Pester is the repository validation standard.

## PowerShell Compatibility
'@

    if (-not [regex]::IsMatch($updatedContent, $pattern)) {
        return ($updatedContent.TrimEnd("`r", "`n") + "`n`nThis repository was created from the pwsh-dev-template GitHub template and is now treated as its own PowerShell project. Use `.codex/skills/downstream-repo-cleanup/SKILL.md`, `.codex/skills/downstream-guidance-sync/SKILL.md`, and `.codex/skills/readme-alignment/SKILL.md` for their matching downstream workflows.`n")
    }

    $updatedContent = [regex]::Replace($updatedContent, $pattern, $replacement)
    return ($updatedContent.TrimEnd("`r", "`n") + "`n")
}

function Get-DownstreamModuleManifestContent {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ExistingContent,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ModuleFileName,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$RepoName
    )

    $updated = $ExistingContent
    $updated = $updated -replace "RootModule = 'TemplateModule\.psm1'", ("RootModule = '{0}'" -f $ModuleFileName)
    $updated = $updated -replace "Author = 'Template Author'", "Author = 'Repository Maintainer'"
    $updated = $updated -replace "CompanyName = 'Template Company'", "CompanyName = ''"
    $updated = $updated.Replace("Copyright = '(c) Template Author. All rights reserved.'", ("Copyright = '(c) {0}. Update ownership before release.'" -f $RepoName))
    $updated = $updated -replace "Description = 'Module scaffold for repositories created from this template\. Rename and update metadata\.'", ("Description = 'PowerShell module for {0}. Update metadata before release.'" -f $RepoName)
    $updated = $updated -replace "Tags = @\('PowerShell', 'Template'\)", ("Tags = @('PowerShell', '{0}')" -f $RepoName)

    return ($updated.TrimEnd("`r", "`n") + "`n")
}

function Get-DownstreamModuleEntryPointContent {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ExistingContent,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ModuleNameValue
    )

    $helperName = Get-SafeHelperName -Name $ModuleNameValue
    $updated = $ExistingContent -replace 'Import-TemplateModuleScript', ('Import-{0}Script' -f $helperName)
    $updated = $updated -replace 'TemplateModule', $ModuleNameValue
    return ($updated.TrimEnd("`r", "`n") + "`n")
}

function Remove-StaleGitKeepFile {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$RepoPath
    )

    $gitKeepFiles = Get-ChildItem -LiteralPath $RepoPath -Filter '.gitkeep' -Recurse -File -ErrorAction SilentlyContinue
    foreach ($gitKeepFile in $gitKeepFiles) {
        $siblings = Get-ChildItem -LiteralPath $gitKeepFile.Directory.FullName -Force | Where-Object { $_.Name -ne '.gitkeep' }
        if ($siblings.Count -gt 0 -and $PSCmdlet.ShouldProcess($gitKeepFile.FullName, 'Remove stale .gitkeep')) {
            Remove-Item -LiteralPath $gitKeepFile.FullName -Force
        }
    }
}

if (($ProjectType -in @('module', 'hybrid')) -and [string]::IsNullOrWhiteSpace($ModuleName)) {
    throw ('ModuleName is required when ProjectType is "{0}".' -f $ProjectType)
}

$resolvedRepoRoot = Resolve-AbsolutePath -Path $RepoRoot
if (-not (Test-GitRepository -Path $resolvedRepoRoot)) {
    throw ('Cleanup workflow requires a Git repository: {0}' -f $resolvedRepoRoot)
}

if ([string]::IsNullOrWhiteSpace($RepositoryName)) {
    $RepositoryName = Split-Path -Path $resolvedRepoRoot -Leaf
}

$reportItems = [System.Collections.Generic.List[object]]::new()
$manualFollowUp = [System.Collections.Generic.List[string]]::new()
$stopReasons = [System.Collections.Generic.List[string]]::new()

$knownTemplateTests = @(
    'tests/unit/Invoke-TemplateGuidanceSync.Tests.ps1'
    'tests/unit/TemplateHealth.Tests.ps1'
    'tests/unit/TemplateScaffold.Tests.ps1'
    'tests/unit/TemplateVersion.Tests.ps1'
    'tests/unit/SkillScaffold.Tests.ps1'
    'tests/unit/Initialize-DownstreamRepo.Tests.ps1'
    'tests/unit/Invoke-MarkdownValidation.Tests.ps1'
    'tests/unit/Invoke-ReadmeAlignment.Tests.ps1'
    'tests/unit/Invoke-RepoChecks.Tests.ps1'
)

$expectedSourceFiles = @(
    'src/.gitkeep'
    'src/README.md'
    'src/TemplateModule.psd1'
    'src/TemplateModule.psm1'
    'src/Public/.gitkeep'
    'src/Private/.gitkeep'
    'src/Classes/.gitkeep'
)

$customTestFiles = Get-ChildItem -LiteralPath (Get-RepoPath -BasePath $resolvedRepoRoot -RelativePath 'tests') -Filter '*.Tests.ps1' -Recurse -File -ErrorAction SilentlyContinue |
    ForEach-Object {
        [System.IO.Path]::GetRelativePath($resolvedRepoRoot, $_.FullName).Replace('\', '/')
    } |
    Where-Object { $_ -notin $knownTemplateTests }

if ($customTestFiles) {
    $stopReasons.Add('Repository contains project-specific test files. Run cleanup before adding downstream tests.')
}

$customAdrFiles = Get-ChildItem -LiteralPath (Get-RepoPath -BasePath $resolvedRepoRoot -RelativePath 'docs/decisions') -Filter '*.md' -File -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -match '^\d{4}-' -and $_.Name -notmatch '^000[1-7]-' } |
    Select-Object -ExpandProperty Name

if ($customAdrFiles) {
    $stopReasons.Add('Repository contains numbered ADRs outside the template seed set. Run cleanup before adding repository-specific ADRs.')
}

$customSourceFiles = Get-ChildItem -LiteralPath (Get-RepoPath -BasePath $resolvedRepoRoot -RelativePath 'src') -Recurse -File -ErrorAction SilentlyContinue |
    ForEach-Object {
        [System.IO.Path]::GetRelativePath($resolvedRepoRoot, $_.FullName).Replace('\', '/')
    } |
    Where-Object {
        $_ -notin $expectedSourceFiles -and
        $_ -notmatch '^src/(Public|Private|Classes)/\.gitkeep$'
    }

if ($customSourceFiles) {
    $stopReasons.Add('Repository contains source files beyond the template scaffold. Run cleanup before adding downstream implementation files.')
}

$readmePath = Get-RepoPath -BasePath $resolvedRepoRoot -RelativePath 'README.md'
$readmeContent = Get-FileContent -Path $readmePath
if ($null -eq $readmeContent -or $readmeContent -notmatch 'PowerShell Development Template: Available Anywhere') {
    $stopReasons.Add('README.md no longer appears to be in the expected immediate post-create state.')
}

$agentsPath = Get-RepoPath -BasePath $resolvedRepoRoot -RelativePath 'AGENTS.md'
$agentsContent = Get-FileContent -Path $agentsPath
if ($null -eq $agentsContent -or $agentsContent -notmatch 'Mandatory Freshness Gate') {
    $stopReasons.Add('AGENTS.md no longer appears to be in the expected immediate post-create state.')
}

if ($stopReasons.Count -gt 0) {
    foreach ($reason in $stopReasons) {
        Add-ReportItem -Items $reportItems -Action ManualFollowUp -Path '.' -Reason $reason -Status 'Blocked'
    }

    if ($OutputFormat -eq 'Json') {
        [pscustomobject]@{
            RepoRoot = $resolvedRepoRoot
            RepositoryName = $RepositoryName
            ProjectType = $ProjectType
            Applied = $false
            Blocked = $true
            TemplateVersion = $null
            Report = $reportItems
            ManualFollowUp = @()
        } | ConvertTo-Json -Depth 5
        return
    }

    $message = ($stopReasons -join ' ')
    throw ('Cleanup workflow can only run during the immediate post-create window. {0}' -f $message)
}

$templateVersion = Get-TemplateVersion -RepoPath $resolvedRepoRoot

$removePaths = @(
    'VERSION'
    'CHANGELOG.md'
    'TestResults.xml'
    'docs/template-evolution.md'
    'scripts/Get-TemplateHealth.ps1'
    'scripts/Test-TemplateVersion.ps1'
    '.codex/skills/runtime-policy-update'
    '.codex/skills/template-version-release'
    'docs/decisions/0001-downstream-guidance-sync.md'
    'docs/decisions/0002-repo-local-agent-workflows.md'
    'docs/decisions/0003-manual-github-releases.md'
    'docs/decisions/0004-downstream-repo-cleanup.md'
    'docs/decisions/0005-downstream-guidance-sync-delivers-cleanup-assets.md'
    'docs/decisions/0006-change-delivery-workflow.md'
    'docs/decisions/0007-readme-alignment-workflow.md'
    'tests/unit/TemplateHealth.Tests.ps1'
    'tests/unit/TemplateVersion.Tests.ps1'
    'tests/unit/SkillScaffold.Tests.ps1'
    'tests/unit/Initialize-DownstreamRepo.Tests.ps1'
    'tests/unit/Invoke-MarkdownValidation.Tests.ps1'
    'tests/unit/Invoke-ReadmeAlignment.Tests.ps1'
    'tests/unit/Invoke-RepoChecks.Tests.ps1'
)

if ($ProjectType -eq 'script') {
    $removePaths += @(
        'src/TemplateModule.psd1'
        'src/TemplateModule.psm1'
    )
}

$rewritePaths = @(
    'README.md'
    'AGENTS.md'
    '.github/copilot-instructions.md'
    'docs/agent-workflows.md'
    'docs/decisions/README.md'
)

$keepPaths = @(
    '.devcontainer'
    '.github/workflows/ci.yml'
    'scripts/Initialize-DownstreamRepo.ps1'
    'scripts/Invoke-RepoChecks.ps1'
    'scripts/Invoke-MarkdownValidation.ps1'
    'scripts/Test-VersionPolicy.ps1'
    'scripts/Update-GeneratedMarkdown.ps1'
    'scripts/Invoke-TemplateGuidanceSync.ps1'
    'scripts/Invoke-ReadmeAlignment.ps1'
    'eng/runtime-policy.json'
    'templates'
    'templates/downstream/README.md'
    'PesterConfiguration.psd1'
    'PSScriptAnalyzerSettings.psd1'
    '.codex/skills/change-delivery-workflow'
    '.codex/skills/downstream-guidance-sync'
    '.codex/skills/downstream-repo-cleanup'
    '.codex/skills/readme-alignment'
    '.codex/skills/powershell-authoring'
    '.codex/skills/powershell-testing-review'
    '.codex/skills/powershell-external-services'
)

foreach ($path in $removePaths) {
    $absolutePath = Get-RepoPath -BasePath $resolvedRepoRoot -RelativePath $path
    $status = if (Test-Path -LiteralPath $absolutePath) { 'Pending' } else { 'Absent' }
    Add-ReportItem -Items $reportItems -Action Remove -Path $path -Reason 'Template-maintainer artifact is not part of the downstream baseline.' -Status $status
}

foreach ($path in $rewritePaths) {
    Add-ReportItem -Items $reportItems -Action Rewrite -Path $path -Reason 'Rewrite inherited guidance into downstream form while preserving the template version badge contract.' -Status 'Pending'
}

if ($ProjectType -in @('module', 'hybrid')) {
    Add-ReportItem -Items $reportItems -Action Rename -Path 'src/TemplateModule.psd1' -Reason ('Rename the scaffold manifest to {0}.psd1.' -f $ModuleName) -Status 'Pending'
    Add-ReportItem -Items $reportItems -Action Rename -Path 'src/TemplateModule.psm1' -Reason ('Rename the scaffold module entry point to {0}.psm1.' -f $ModuleName) -Status 'Pending'
}

foreach ($path in $keepPaths) {
    Add-ReportItem -Items $reportItems -Action Keep -Path $path -Reason 'Retain as downstream-owned baseline infrastructure or workflow guidance.' -Status 'Keep'
}

$manualFollowUp.Add('Replace the placeholder README summary for the repository with project-specific content.')
$manualFollowUp.Add('Add repository-specific ADRs only after cleanup is complete.')
$manualFollowUp.Add('Update module manifest metadata beyond safe placeholders before release.') | Out-Null
$manualFollowUp.Add('Review project-specific docs and issue templates once the repository scope is clear.') | Out-Null

foreach ($item in $manualFollowUp) {
    Add-ReportItem -Items $reportItems -Action ManualFollowUp -Path '.' -Reason $item -Status 'Manual'
}

if ($Apply) {
    Assert-RemoteFreshness -RepoPath $resolvedRepoRoot

    foreach ($path in $removePaths) {
        Remove-RepoItem -Path (Get-RepoPath -BasePath $resolvedRepoRoot -RelativePath $path)
    }

    $newReadme = Get-DownstreamReadmeContent -RepoRoot $resolvedRepoRoot -RepoName $RepositoryName -TemplateVersion $templateVersion
    if ($PSCmdlet.ShouldProcess($readmePath, 'Rewrite downstream README')) {
        Write-Utf8File -Path $readmePath -Content $newReadme
    }

    if ($PSCmdlet.ShouldProcess($agentsPath, 'Rewrite downstream AGENTS.md')) {
        Write-Utf8File -Path $agentsPath -Content (Get-DownstreamAgentsContent)
    }

    $copilotInstructionsPath = Get-RepoPath -BasePath $resolvedRepoRoot -RelativePath '.github/copilot-instructions.md'
    $copilotContent = Get-FileContent -Path $copilotInstructionsPath
    if ($null -eq $copilotContent) {
        throw '.github/copilot-instructions.md is required for downstream cleanup.'
    }

    if ($PSCmdlet.ShouldProcess($copilotInstructionsPath, 'Rewrite downstream Copilot instructions')) {
        Write-Utf8File -Path $copilotInstructionsPath -Content (Get-DownstreamCopilotInstruction -ExistingContent $copilotContent)
    }

    $agentWorkflowsPath = Get-RepoPath -BasePath $resolvedRepoRoot -RelativePath 'docs/agent-workflows.md'
    if ($PSCmdlet.ShouldProcess($agentWorkflowsPath, 'Rewrite downstream agent workflows guide')) {
        Write-Utf8File -Path $agentWorkflowsPath -Content (Get-DownstreamAgentWorkflowsContent)
    }

    $decisionsReadmePath = Get-RepoPath -BasePath $resolvedRepoRoot -RelativePath 'docs/decisions/README.md'
    if ($PSCmdlet.ShouldProcess($decisionsReadmePath, 'Rewrite downstream ADR README')) {
        Write-Utf8File -Path $decisionsReadmePath -Content (Get-DownstreamDecisionsReadmeContent)
    }

    if ($ProjectType -in @('module', 'hybrid')) {
        $manifestPath = Get-RepoPath -BasePath $resolvedRepoRoot -RelativePath 'src/TemplateModule.psd1'
        $modulePath = Get-RepoPath -BasePath $resolvedRepoRoot -RelativePath 'src/TemplateModule.psm1'
        $newManifestPath = Get-RepoPath -BasePath $resolvedRepoRoot -RelativePath ('src/{0}.psd1' -f $ModuleName)
        $newModulePath = Get-RepoPath -BasePath $resolvedRepoRoot -RelativePath ('src/{0}.psm1' -f $ModuleName)

        $manifestContent = Get-FileContent -Path $manifestPath
        $moduleContent = Get-FileContent -Path $modulePath

        if ($manifestContent) {
            if ($PSCmdlet.ShouldProcess($manifestPath, ('Rewrite module manifest for {0}' -f $ModuleName))) {
                Write-Utf8File -Path $manifestPath -Content (Get-DownstreamModuleManifestContent -ExistingContent $manifestContent -ModuleFileName ('{0}.psm1' -f $ModuleName) -RepoName $RepositoryName)
            }

            Rename-RepoItem -Path $manifestPath -Destination $newManifestPath
        }

        if ($moduleContent) {
            if ($PSCmdlet.ShouldProcess($modulePath, ('Rewrite module entry point for {0}' -f $ModuleName))) {
                Write-Utf8File -Path $modulePath -Content (Get-DownstreamModuleEntryPointContent -ExistingContent $moduleContent -ModuleNameValue $ModuleName)
            }

            Rename-RepoItem -Path $modulePath -Destination $newModulePath
        }
    }

    Remove-StaleGitKeepFile -RepoPath $resolvedRepoRoot
}

$result = [pscustomobject]@{
    RepoRoot = $resolvedRepoRoot
    RepositoryName = $RepositoryName
    ProjectType = $ProjectType
    Applied = [bool]$Apply
    Blocked = $false
    TemplateVersion = $templateVersion
    Report = $reportItems
    ManualFollowUp = @($manualFollowUp)
}

if ($OutputFormat -eq 'Json') {
    $result | ConvertTo-Json -Depth 6
    return
}

Write-Output ('Repository: {0}' -f $resolvedRepoRoot)
Write-Output ('RepositoryName: {0}' -f $RepositoryName)
Write-Output ('ProjectType: {0}' -f $ProjectType)
Write-Output ('TemplateVersion: {0}' -f $(if ($templateVersion) { $templateVersion } else { 'Unknown' }))
Write-Output ('Applied: {0}' -f $Apply.IsPresent)
Write-Output ''

foreach ($group in 'Remove', 'Rewrite', 'Rename', 'Keep', 'ManualFollowUp') {
    $groupItems = $reportItems | Where-Object { $_.Action -eq $group }
    if (-not $groupItems) {
        continue
    }

    Write-Output ('{0}:' -f $group)
    foreach ($item in $groupItems) {
        Write-Output ('- {0} [{1}] - {2}' -f $item.Path, $item.Status, $item.Reason)
    }

    Write-Output ''
}
