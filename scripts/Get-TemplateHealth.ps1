<#
.SYNOPSIS
    Reports template maintenance health signals.

.DESCRIPTION
    Summarizes repository health areas that are useful before planning template
    maintenance work. This script is a report by default; use FailOnIssue when
    a non-healthy health item should fail automation.

.PARAMETER RepoRoot
    Repository root to inspect. Defaults to the parent of the scripts folder.

.PARAMETER AsJson
    Emits a structured JSON report instead of readable text.

.PARAMETER FailOnIssue
    Throws when any health item is not healthy.
#>
[CmdletBinding()]
param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$RepoRoot = (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '..')).Path,

    [Parameter()]
    [switch]$AsJson,

    [Parameter()]
    [switch]$FailOnIssue
)

$ErrorActionPreference = 'Stop'

$resolvedRepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path
$items = [System.Collections.Generic.List[object]]::new()

function Add-HealthItem {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Area,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory)]
        [ValidateSet('Healthy', 'Issue')]
        [string]$Status,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Message,

        [Parameter()]
        [string]$Details
    )

    $item = [pscustomobject]@{
        Area = $Area
        Name = $Name
        Status = $Status
        Message = $Message
        Details = $Details
    }

    $items.Add($item)
}

function Get-RelativePath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$RelativePath
    )

    return (Join-Path -Path $resolvedRepoRoot -ChildPath $RelativePath)
}

function Get-TemplateFileContent {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$RelativePath
    )

    $path = Get-RelativePath -RelativePath $RelativePath
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        return $null
    }

    return Get-Content -Raw -LiteralPath $path
}

function Invoke-TemplateHealthScript {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Area,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$RelativePath,

        [Parameter()]
        [hashtable]$Parameters = @{}
    )

    $path = Get-RelativePath -RelativePath $RelativePath
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        Add-HealthItem -Area $Area -Name $Name -Status Issue -Message ('Script not found: {0}' -f $RelativePath)
        return
    }

    try {
        $output = & $path @Parameters 2>&1
        Add-HealthItem -Area $Area -Name $Name -Status Healthy -Message 'Check passed.' -Details (($output | Out-String).Trim())
    }
    catch {
        Add-HealthItem -Area $Area -Name $Name -Status Issue -Message $_.Exception.Message
    }
}

function Test-RequiredFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Area,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$RelativePath
    )

    $path = Get-RelativePath -RelativePath $RelativePath
    if (Test-Path -LiteralPath $path -PathType Leaf) {
        Add-HealthItem -Area $Area -Name $Name -Status Healthy -Message ('File found: {0}' -f $RelativePath)
    }
    else {
        Add-HealthItem -Area $Area -Name $Name -Status Issue -Message ('File missing: {0}' -f $RelativePath)
    }
}

function Test-RequiredText {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Area,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$RelativePath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ExpectedText
    )

    $content = Get-TemplateFileContent -RelativePath $RelativePath
    if ($null -eq $content) {
        Add-HealthItem -Area $Area -Name $Name -Status Issue -Message ('File missing: {0}' -f $RelativePath)
        return
    }

    if ($content.Contains($ExpectedText)) {
        Add-HealthItem -Area $Area -Name $Name -Status Healthy -Message ('Reference found in {0}' -f $RelativePath)
    }
    else {
        Add-HealthItem -Area $Area -Name $Name -Status Issue -Message ('Reference missing from {0}: {1}' -f $RelativePath, $ExpectedText)
    }
}

function Invoke-GitText {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string[]]$Arguments
    )

    $result = & git -C $resolvedRepoRoot @Arguments 2>&1
    return [pscustomobject]@{
        ExitCode = $LASTEXITCODE
        Text = ($result | Out-String).Trim()
    }
}

Invoke-TemplateHealthScript -Area 'Generated Markdown' -Name 'Generated Markdown blocks' -RelativePath 'scripts/Update-GeneratedMarkdown.ps1' -Parameters @{ Check = $true }
Invoke-TemplateHealthScript -Area 'Runtime Policy' -Name 'Runtime policy alignment' -RelativePath 'scripts/Test-VersionPolicy.ps1'
Invoke-TemplateHealthScript -Area 'Template Version' -Name 'Template version metadata' -RelativePath 'scripts/Test-TemplateVersion.ps1'

$agentArea = 'Agent Workflows'
$agentFiles = @(
    @{ Name = 'Change delivery workflow skill'; Path = '.codex/skills/change-delivery-workflow/SKILL.md' },
    @{ Name = 'Downstream repo cleanup skill'; Path = '.codex/skills/downstream-repo-cleanup/SKILL.md' },
    @{ Name = 'Downstream guidance sync skill'; Path = '.codex/skills/downstream-guidance-sync/SKILL.md' },
    @{ Name = 'README alignment skill'; Path = '.codex/skills/readme-alignment/SKILL.md' },
    @{ Name = 'Runtime policy update skill'; Path = '.codex/skills/runtime-policy-update/SKILL.md' },
    @{ Name = 'Template version release skill'; Path = '.codex/skills/template-version-release/SKILL.md' },
    @{ Name = 'Agent workflow documentation'; Path = 'docs/agent-workflows.md' }
)

foreach ($agentFile in $agentFiles) {
    Test-RequiredFile -Area $agentArea -Name $agentFile.Name -RelativePath $agentFile.Path
}

$agentReferences = @(
    @{ Name = 'README workflow pointer'; Path = 'README.md'; Text = 'docs/agent-workflows.md' },
    @{ Name = 'Workflow health pointer'; Path = 'docs/agent-workflows.md'; Text = 'scripts/Get-TemplateHealth.ps1' },
    @{ Name = 'Change delivery skill reference'; Path = 'docs/agent-workflows.md'; Text = '.codex/skills/change-delivery-workflow/SKILL.md' },
    @{ Name = 'Cleanup skill reference'; Path = 'docs/agent-workflows.md'; Text = '.codex/skills/downstream-repo-cleanup/SKILL.md' },
    @{ Name = 'Cleanup script reference'; Path = 'docs/agent-workflows.md'; Text = 'scripts/Initialize-DownstreamRepo.ps1' },
    @{ Name = 'Downstream skill reference'; Path = 'docs/agent-workflows.md'; Text = '.codex/skills/downstream-guidance-sync/SKILL.md' },
    @{ Name = 'Downstream sync script reference'; Path = 'docs/agent-workflows.md'; Text = 'scripts/Invoke-TemplateGuidanceSync.ps1' },
    @{ Name = 'README alignment skill reference'; Path = 'docs/agent-workflows.md'; Text = '.codex/skills/readme-alignment/SKILL.md' },
    @{ Name = 'README alignment script reference'; Path = 'docs/agent-workflows.md'; Text = 'scripts/Invoke-ReadmeAlignment.ps1' },
    @{ Name = 'README skeleton reference'; Path = 'docs/agent-workflows.md'; Text = 'templates/downstream/README.md' },
    @{ Name = 'Runtime skill reference'; Path = 'docs/agent-workflows.md'; Text = '.codex/skills/runtime-policy-update/SKILL.md' },
    @{ Name = 'Runtime policy reference'; Path = 'docs/agent-workflows.md'; Text = 'eng/runtime-policy.json' },
    @{ Name = 'Release skill reference'; Path = 'docs/agent-workflows.md'; Text = '.codex/skills/template-version-release/SKILL.md' },
    @{ Name = 'Template version check reference'; Path = 'docs/agent-workflows.md'; Text = 'scripts/Test-TemplateVersion.ps1' }
)

foreach ($agentReference in $agentReferences) {
    Test-RequiredText -Area $agentArea -Name $agentReference.Name -RelativePath $agentReference.Path -ExpectedText $agentReference.Text
}

$gitArea = 'Git Release Posture'
$versionContent = Get-TemplateFileContent -RelativePath 'VERSION'
if ($null -eq $versionContent) {
    Add-HealthItem -Area $gitArea -Name 'Template version' -Status Issue -Message 'VERSION file is missing.'
    $version = $null
}
else {
    $version = $versionContent.Trim()
    if ($version -match '^\d+\.\d+\.\d+$') {
        Add-HealthItem -Area $gitArea -Name 'Template version' -Status Healthy -Message ('Template version is {0}.' -f $version)
    }
    else {
        Add-HealthItem -Area $gitArea -Name 'Template version' -Status Issue -Message ('VERSION is not SemVer X.Y.Z: {0}' -f $version)
    }
}

try {
    $branch = Invoke-GitText -Arguments @('rev-parse', '--abbrev-ref', 'HEAD')
    if ($branch.ExitCode -eq 0) {
        Add-HealthItem -Area $gitArea -Name 'Current branch' -Status Healthy -Message ('Current branch is {0}.' -f $branch.Text)
    }
    else {
        Add-HealthItem -Area $gitArea -Name 'Current branch' -Status Issue -Message $branch.Text
    }

    $status = Invoke-GitText -Arguments @('status', '--porcelain')
    if ($status.ExitCode -ne 0) {
        Add-HealthItem -Area $gitArea -Name 'Working tree' -Status Issue -Message $status.Text
    }
    elseif ([string]::IsNullOrWhiteSpace($status.Text)) {
        Add-HealthItem -Area $gitArea -Name 'Working tree' -Status Healthy -Message 'Working tree is clean.'
    }
    else {
        Add-HealthItem -Area $gitArea -Name 'Working tree' -Status Issue -Message 'Working tree has uncommitted changes.' -Details $status.Text
    }

    if ($version) {
        $head = Invoke-GitText -Arguments @('rev-parse', 'HEAD')
        $tagName = 'v{0}' -f $version
        $tag = Invoke-GitText -Arguments @('rev-list', '-n', '1', $tagName)

        if ($head.ExitCode -ne 0) {
            Add-HealthItem -Area $gitArea -Name 'Release tag' -Status Issue -Message ('Unable to resolve HEAD: {0}' -f $head.Text)
        }
        elseif ($tag.ExitCode -ne 0) {
            Add-HealthItem -Area $gitArea -Name 'Release tag' -Status Issue -Message ('Expected tag is not present yet: {0}' -f $tagName)
        }
        elseif ($tag.Text -ne $head.Text) {
            Add-HealthItem -Area $gitArea -Name 'Release tag' -Status Issue -Message ('{0} does not point at HEAD.' -f $tagName) -Details ('Tag: {0}; HEAD: {1}' -f $tag.Text, $head.Text)
        }
        else {
            Add-HealthItem -Area $gitArea -Name 'Release tag' -Status Healthy -Message ('{0} points at HEAD.' -f $tagName)
        }
    }
}
catch {
    Add-HealthItem -Area $gitArea -Name 'Git status' -Status Issue -Message $_.Exception.Message
}

$issueCount = @($items | Where-Object { $_.Status -ne 'Healthy' }).Count
$report = [pscustomobject]@{
    Repository = $resolvedRepoRoot
    GeneratedAt = (Get-Date).ToString('o')
    Summary = [pscustomobject]@{
        Total = $items.Count
        Healthy = @($items | Where-Object { $_.Status -eq 'Healthy' }).Count
        Issues = $issueCount
    }
    Items = @($items)
}

if ($AsJson) {
    $report | ConvertTo-Json -Depth 5
}
else {
    Write-Output 'Template Health'
    Write-Output ('Repository: {0}' -f $report.Repository)
    Write-Output ('Healthy: {0}; Issues: {1}; Total: {2}' -f $report.Summary.Healthy, $report.Summary.Issues, $report.Summary.Total)

    foreach ($group in ($items | Group-Object -Property Area)) {
        Write-Output ''
        Write-Output ('[{0}]' -f $group.Name)
        $group.Group | Select-Object Name, Status, Message | Format-Table -AutoSize | Out-String -Width 180 | Write-Output
    }
}

if ($FailOnIssue -and $issueCount -gt 0) {
    throw ('Template health found {0} issue(s).' -f $issueCount)
}