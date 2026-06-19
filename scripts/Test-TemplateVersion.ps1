<#
.SYNOPSIS
    Validates template release version metadata.

.DESCRIPTION
    Checks that VERSION, the README template-version badge, and CHANGELOG.md
    agree on the current template version. Optionally verifies that the matching
    Git tag points at HEAD.
#>
[CmdletBinding()]
param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$RepoRoot = (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '..')).Path,

    [Parameter()]
    [switch]$CheckTag
)

$ErrorActionPreference = 'Stop'

$resolvedRepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path
$failures = [System.Collections.Generic.List[object]]::new()

function Add-VersionFailure {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Description,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Expected,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Reason,

        [Parameter()]
        [string]$Actual
    )

    $failure = [pscustomobject]@{
        Path = $Path
        Description = $Description
        Expected = $Expected
        Actual = $Actual
        Reason = $Reason
    }

    $failures.Add($failure)
}

function Get-TemplateFileContent {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$RelativePath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Description,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Expected
    )

    $path = Join-Path -Path $resolvedRepoRoot -ChildPath $RelativePath

    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        Add-VersionFailure -Path $RelativePath -Description $Description -Expected $Expected -Reason 'File not found'
        return
    }

    return Get-Content -Raw -LiteralPath $path
}

$versionContent = Get-TemplateFileContent -RelativePath 'VERSION' -Description 'Template version file' -Expected 'SemVer X.Y.Z value'
if ($null -ne $versionContent) {
    $version = $versionContent.Trim()
    if ($version -notmatch '^\d+\.\d+\.\d+$') {
        Add-VersionFailure -Path 'VERSION' -Description 'Template version file' -Expected 'SemVer X.Y.Z value' -Actual $version -Reason 'Invalid version format'
    }
}

if ($failures.Count -eq 0) {
    $readmeContent = Get-TemplateFileContent -RelativePath 'README.md' -Description 'README template-version badge' -Expected ('template-{0}' -f $version)
    if ($null -ne $readmeContent) {
        $badgePattern = '!\[Template Version\]\(https://img\.shields\.io/badge/template-(?<Version>\d+\.\d+\.\d+)-blue\)'
        $badgeMatch = [regex]::Match($readmeContent, $badgePattern)

        if (-not $badgeMatch.Success) {
            Add-VersionFailure -Path 'README.md' -Description 'README template-version badge' -Expected ('template-{0}' -f $version) -Reason 'Template version badge not found'
        }
        elseif ($badgeMatch.Groups['Version'].Value -ne $version) {
            Add-VersionFailure -Path 'README.md' -Description 'README template-version badge' -Expected $version -Actual $badgeMatch.Groups['Version'].Value -Reason 'Value mismatch'
        }
    }

    $changelogContent = Get-TemplateFileContent -RelativePath 'CHANGELOG.md' -Description 'Changelog release heading' -Expected ('## {0} - YYYY-MM-DD' -f $version)
    if ($null -ne $changelogContent) {
        $headingPattern = '(?m)^##\s+{0}\s+-\s+\d{{4}}-\d{{2}}-\d{{2}}\s*$' -f [regex]::Escape($version)
        if (-not [regex]::IsMatch($changelogContent, $headingPattern)) {
            Add-VersionFailure -Path 'CHANGELOG.md' -Description 'Changelog release heading' -Expected ('## {0} - YYYY-MM-DD' -f $version) -Reason 'Release heading not found'
        }
    }

    if ($CheckTag) {
        $tagName = 'v{0}' -f $version
        $headResult = & git -C $resolvedRepoRoot rev-parse HEAD 2>&1
        if ($LASTEXITCODE -ne 0) {
            Add-VersionFailure -Path '.git' -Description 'Current HEAD' -Expected 'Git repository with HEAD' -Actual ($headResult | Out-String).Trim() -Reason 'Unable to resolve HEAD'
        }
        else {
            $tagResult = & git -C $resolvedRepoRoot rev-list -n 1 $tagName 2>&1
            if ($LASTEXITCODE -ne 0) {
                Add-VersionFailure -Path '.git' -Description 'Release tag' -Expected $tagName -Actual ($tagResult | Out-String).Trim() -Reason 'Tag not found'
            }
            elseif ($tagResult.Trim() -ne $headResult.Trim()) {
                Add-VersionFailure -Path '.git' -Description 'Release tag' -Expected $headResult.Trim() -Actual $tagResult.Trim() -Reason ('{0} does not point at HEAD' -f $tagName)
            }
        }
    }
}

if ($failures.Count -gt 0) {
    $failures | Format-Table -AutoSize | Out-String | Write-Output
    throw ('Template version validation failed in {0} location(s).' -f $failures.Count)
}

Write-Verbose ('Template version validated: {0}' -f $version)
