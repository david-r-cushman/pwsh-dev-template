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
        [string]$RepoName,

        [Parameter()]
        [string]$TemplateVersion
    )

    $badgeLine = Get-TemplateVersionBadgeLine -TemplateVersion $TemplateVersion
    $lines = [System.Collections.Generic.List[string]]::new()

    $lines.Add('# {0}' -f $RepoName)
    $lines.Add('')
    $lines.Add('<!-- BEGIN generated:readme-powershell-badge -->')
    $lines.Add('![PowerShell 7.4](https://img.shields.io/badge/PowerShell-7.4-blue)')
    $lines.Add('<!-- END generated:readme-powershell-badge -->')
    if ($badgeLine) {
        $lines.Add($badgeLine)
    }
    $lines.Add('')
    $lines.Add('PowerShell automation repository created from `pwsh-dev-template` and normalized for downstream development.')
    $lines.Add('')
    $lines.Add('The template version badge tracks inherited guidance and baseline workflow alignment. It does not mean this repository remains fully identical to the source template.')
    $lines.Add('')
    $lines.Add('## Repository Focus')
    $lines.Add('')
    $lines.Add('This repository starts with a validated PowerShell engineering baseline and is expected to add project-specific implementation, tests, and documentation over time.')
    $lines.Add('')
    $lines.Add('<!-- BEGIN generated:readme-runtime-focus -->')
    $lines.Add('- PowerShell 7.4 development')
    $lines.Add('<!-- END generated:readme-runtime-focus -->')
    $lines.Add('- Pester testing')
    $lines.Add('- PSScriptAnalyzer validation')
    $lines.Add('- GitHub Actions CI')
    $lines.Add('- Dev Containers and GitHub Codespaces')
    $lines.Add('- reusable script, function, module, and test scaffolds')
    $lines.Add('- AI governance and GitHub Copilot guidance')
    $lines.Add('- downstream AI guidance sync from `pwsh-dev-template`')
    $lines.Add('')
    $lines.Add('## Initial Repository Setup')
    $lines.Add('')
    $lines.Add('1. Run the downstream cleanup workflow immediately after creating the repository from the template.')
    $lines.Add('2. Replace the placeholder repository description in this README.')
    $lines.Add('3. Add project-specific scripts, modules, or automation under `src`.')
    $lines.Add('4. Add project-specific Pester tests under `tests`.')
    $lines.Add('5. Copy and adapt scaffolds from `templates` when they fit the work.')
    $lines.Add('6. Review `AGENTS.md` and `.github/copilot-instructions.md` before using AI-generated changes.')
    $lines.Add('7. Run local validation:')
    $lines.Add('')
    $lines.Add('   ```powershell')
    $lines.Add('   pwsh -NoProfile -File ./scripts/Invoke-RepoChecks.ps1 -IncludeTemplates')
    $lines.Add('   ```')
    $lines.Add('')
    $lines.Add('## Architecture And Stack')
    $lines.Add('')
    $lines.Add('<!-- BEGIN generated:readme-runtime-stack -->')
    $lines.Add('- **Runtime:** PowerShell 7.4.x (LTS) on Ubuntu 22.04')
    $lines.Add('<!-- END generated:readme-runtime-stack -->')
    $lines.Add('- **Development Modes:** Local VS Code, Docker Dev Containers, and GitHub Codespaces')
    $lines.Add('- **Isolation Strategy:** Use the container to reduce host tooling and credential exposure during development work')
    $lines.Add('- **Governance:** Integrated `PSScriptAnalyzer`, `EditorConfig`, and Markdown linting support')
    $lines.Add('')
    $lines.Add('## Tooling Baseline')
    $lines.Add('')
    $lines.Add('<!-- BEGIN generated:readme-tooling-list -->')
    $lines.Add('- **Pester 5.7.1:** For unit and integration testing')
    $lines.Add('- **PSScriptAnalyzer 1.25.0:** To enforce PowerShell best practices and security rules')
    $lines.Add('- **Azure CLI:** Pre-installed for cloud resource management')
    $lines.Add('- **PSReadLine 2.4.5:** Configured for a more efficient terminal experience')
    $lines.Add('<!-- END generated:readme-tooling-list -->')
    $lines.Add('')
    $lines.Add('## Engineering Guidance')
    $lines.Add('')
    $lines.Add('<!-- BEGIN generated:readme-runtime-philosophy -->')
    $lines.Add('- **Deterministic Base Runtime:** The development container is built from a pinned PowerShell 7.4 on Ubuntu 22.04 base image to reduce environmental drift')
    $lines.Add('<!-- END generated:readme-runtime-philosophy -->')
    $lines.Add('- **Process Integrity:** Validation, review, and explicit ownership remain part of normal development work')
    $lines.Add('- **Respect For State:** State-changing functions should support `-WhatIf` and `-Confirm` where appropriate')
    $lines.Add('- **AI Governance:** AI assistance is a drafting accelerator, not a substitute for engineering accountability')
    $lines.Add('')
    $lines.Add('For the deeper operating model behind that approach, see [docs/powershell-ai-operating-model.md](docs/powershell-ai-operating-model.md).')
    $lines.Add('')
    $lines.Add('## Ongoing Template Alignment')
    $lines.Add('')
    $lines.Add('Use `.codex/skills/downstream-guidance-sync/SKILL.md` with `scripts/Invoke-TemplateGuidanceSync.ps1` when you want to adopt newer AI guidance from `pwsh-dev-template` without overwriting downstream-owned source, tests, CI, or runtime decisions.')
    $lines.Add('')
    $lines.Add('## Next Steps')
    $lines.Add('')
    $lines.Add('- Replace this placeholder README summary with a repository-specific description.')
    $lines.Add('- Add repository-specific ADRs under `docs/decisions/` when durable engineering decisions need to be captured.')
    $lines.Add('- Update issue templates, docs, and module metadata only when the project requirements are clear.')

    return (($lines -join "`n").TrimEnd() + "`n")
}

function Get-DownstreamAgentsContent {
    [CmdletBinding()]
    param()

    return @'
# AGENTS.md

## Repository Instructions

This repository's primary AI guidance is maintained in:

```text
.github/copilot-instructions.md
```

Before performing coding, review, documentation, test, automation, or repository-maintenance work, coding agents must read and follow `.github/copilot-instructions.md`.

That file is the authoritative instruction source for:

- AI governance requirements
- conflict resolution rules
- code generation standards
- complexity management guidance
- PowerShell compatibility requirements
- external service guidance
- commit message conventions
- review expectations

If `.github/copilot-instructions.md` is missing or unavailable, stop and report that the repository guidance cannot be loaded rather than guessing.

If guidance in this file conflicts with `.github/copilot-instructions.md`, `.github/copilot-instructions.md` is authoritative.

## Repo-Local Skills

Repo-local Codex skills are stored under `.codex/skills/`.

For immediate post-create normalization of this downstream repository, agents should use `.codex/skills/downstream-repo-cleanup/SKILL.md` together with `scripts/Initialize-DownstreamRepo.ps1`.

For downstream AI guidance synchronization from `pwsh-dev-template`, agents should use `.codex/skills/downstream-guidance-sync/SKILL.md` together with `scripts/Invoke-TemplateGuidanceSync.ps1` instead of manually copying guidance files.
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

## Workflow Index

| Workflow | Use When | Skill | Control | Validation |
| --- | --- | --- | --- | --- |
| Change delivery workflow | Ordinary repository work needs consistent branch, changelog, validation, PR, and post-merge cleanup discipline. | .codex/skills/change-delivery-workflow/SKILL.md | Repository guidance, Git state, repo-specific validators, diff review, and human review | Repo-specific validation, staged diff review, and PR review |
| Downstream repo cleanup | A repository was just created from `pwsh-dev-template` and needs immediate first-run normalization before project-specific work begins. | `.codex/skills/downstream-repo-cleanup/SKILL.md` | `scripts/Initialize-DownstreamRepo.ps1` | Audit output, downstream diff review, `scripts/Invoke-RepoChecks.ps1` |
| Downstream guidance sync | A downstream repository needs current AI guidance, guardrail docs, and ADR scaffold guidance from `pwsh-dev-template`. | `.codex/skills/downstream-guidance-sync/SKILL.md` | `scripts/Invoke-TemplateGuidanceSync.ps1` | Audit output, downstream diff review, downstream validation |

## Operating Model

Use the repo-local skill when the task matches one of the workflow areas above. The skill should guide the agent through the expected audit, apply, validation, diff review, commit, and pull request process.

The change delivery workflow is intentionally process-oriented. It standardizes branch, changelog, release-decision, pull request, and cleanup behavior for everyday downstream work while still relying on repo guidance, repo validators, diff review, and human review as the controls.

The agent should not invent a separate process when a deterministic script already exists. If a script reports an error, the correct response is to inspect the failure, fix the cause, and rerun the documented validation. Recovery should still be explicit, reviewable, and consistent with the repository guidance.

## Boundaries

Repo-local skills do not make autonomous changes acceptable without review. They should help agents apply known workflows consistently, not broaden the task scope.

The downstream cleanup workflow is intentionally a first-run normalization step. It may remove template-maintainer artifacts and rewrite inherited guidance into downstream form, but it must not invent business logic, project-specific tests, repo-specific documentation, or unrelated CI changes.

The downstream guidance sync workflow is intentionally narrow. It may update AI guidance, guardrail documentation, `docs/decisions/README.md`, and the README template-version badge in downstream repositories. It must not be used to overwrite downstream source code, tests, Pester configuration, PSScriptAnalyzer settings, CI workflows, Dev Container files, runtime policy, module manifests, scaffolds, or numbered project-specific ADRs unless that broader work is requested as a separate repo-specific change.
'@
}

function Get-DownstreamDecisionsReadmeContent {
    [CmdletBinding()]
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

    $pattern = '(?s)## Repo-Local Skills\r?\n.*?\r?\n## PowerShell Compatibility'
    $replacement = @'
## Repo-Local Skills

Repo-local Codex skills are stored under `.codex/skills/`. When asked to normalize a newly created downstream repository from `pwsh-dev-template`, use `.codex/skills/downstream-repo-cleanup/SKILL.md` and operate `scripts/Initialize-DownstreamRepo.ps1` through the documented audit, apply, validation, and diff-review workflow. Use this only as an immediate post-create cleanup step before project-specific work begins.

When asked to synchronize downstream AI guidance from `pwsh-dev-template`, use `.codex/skills/downstream-guidance-sync/SKILL.md` and operate `scripts/Invoke-TemplateGuidanceSync.ps1` through the documented audit, branch, validation, commit, and pull request workflow. Do not manually edit downstream guidance files outside the sync script allowlist unless the user explicitly asks for manual repair after a script failure.

Runtime policy, generated Markdown, CI, tests, scaffolds, and release metadata become downstream-owned after cleanup. Treat changes to those surfaces as normal repository work, not as template-maintainer workflows.

For ordinary downstream repository changes after cleanup, use .codex/skills/change-delivery-workflow/SKILL.md to coordinate sandbox escalation, non-main branches, changelog updates, release decisions, commits, pull requests, and post-merge cleanup.

When adding or updating repo-local skills, add or update Pester coverage in `tests/unit/SkillScaffold.Tests.ps1` for the skill file, metadata, required references, and agent discoverability. The Codex `quick_validate.py` helper may be used as an optional authoring check, but Pester is the repository validation standard.

## PowerShell Compatibility
'@

    if (-not [regex]::IsMatch($updatedContent, $pattern)) {
        throw 'Unable to rewrite the repo-local skills section in .github/copilot-instructions.md.'
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
    Where-Object { $_.Name -match '^\d{4}-' -and $_.Name -notmatch '^000[1-4]-' } |
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
if ($null -eq $agentsContent -or $agentsContent -notmatch 'template version release') {
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
    'tests/unit/TemplateHealth.Tests.ps1'
    'tests/unit/TemplateVersion.Tests.ps1'
    'tests/unit/SkillScaffold.Tests.ps1'
    'tests/unit/Initialize-DownstreamRepo.Tests.ps1'
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
    'scripts/Test-VersionPolicy.ps1'
    'scripts/Update-GeneratedMarkdown.ps1'
    'scripts/Invoke-TemplateGuidanceSync.ps1'
    'eng/runtime-policy.json'
    'templates'
    'PesterConfiguration.psd1'
    'PSScriptAnalyzerSettings.psd1'
    '.codex/skills/change-delivery-workflow'
    '.codex/skills/downstream-guidance-sync'
    '.codex/skills/downstream-repo-cleanup'
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
    foreach ($path in $removePaths) {
        Remove-RepoItem -Path (Get-RepoPath -BasePath $resolvedRepoRoot -RelativePath $path)
    }

    $newReadme = Get-DownstreamReadmeContent -RepoName $RepositoryName -TemplateVersion $templateVersion
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
