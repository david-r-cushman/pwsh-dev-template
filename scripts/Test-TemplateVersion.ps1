<#
.SYNOPSIS
    Validates template release version metadata.

.DESCRIPTION
    Checks that VERSION, the README template-version badge, and CHANGELOG.md
    agree on the current template version. Optionally verifies that the matching
    Git tag points at HEAD and remains a lightweight tag.
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
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$Path,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$Description,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$Expected,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$Reason,
        [Parameter()][string]$Actual
    )

    $failures.Add([pscustomobject]@{ Path = $Path; Description = $Description; Expected = $Expected; Actual = $Actual; Reason = $Reason })
}

function Get-TemplateFileContent {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$RelativePath,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$Description,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$Expected
    )

    $path = Join-Path -Path $resolvedRepoRoot -ChildPath $RelativePath
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        Add-VersionFailure -Path $RelativePath -Description $Description -Expected $Expected -Reason 'File not found'
        return
    }

    Get-Content -Raw -LiteralPath $path
}

function Invoke-GitCommand {
    [CmdletBinding()]
    param([Parameter(Mandatory)][ValidateNotNullOrEmpty()][string[]]$Arguments)

    $output = & git -C $resolvedRepoRoot @Arguments 2>&1
    [pscustomobject]@{ ExitCode = $LASTEXITCODE; Output = ($output | Out-String).Trim() }
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
        $headResult = Invoke-GitCommand -Arguments @('rev-parse', 'HEAD')
        if ($headResult.ExitCode -ne 0) {
            Add-VersionFailure -Path '.git' -Description 'Current HEAD' -Expected 'Git repository with HEAD' -Actual $headResult.Output -Reason 'Unable to resolve HEAD'
        }
        else {
            $tagResult = Invoke-GitCommand -Arguments @('rev-list', '-n', '1', $tagName)
            if ($tagResult.ExitCode -ne 0 -or [string]::IsNullOrWhiteSpace($tagResult.Output)) {
                Add-VersionFailure -Path '.git' -Description 'Release tag' -Expected $tagName -Actual $tagResult.Output -Reason 'Tag not found'
            }
            else {
                if ($tagResult.Output.Trim() -ne $headResult.Output.Trim()) {
                    Add-VersionFailure -Path '.git' -Description 'Release tag' -Expected $headResult.Output.Trim() -Actual $tagResult.Output.Trim() -Reason ('{0} does not point at HEAD' -f $tagName)
                }

                $tagTypeResult = Invoke-GitCommand -Arguments @('cat-file', '-t', $tagName)
                if ($tagTypeResult.ExitCode -ne 0) {
                    Add-VersionFailure -Path '.git' -Description 'Release tag type' -Expected 'lightweight tag on a commit' -Actual $tagTypeResult.Output -Reason 'Unable to inspect tag object type'
                }
                elseif ($tagTypeResult.Output.Trim() -ne 'commit') {
                    Add-VersionFailure -Path '.git' -Description 'Release tag type' -Expected 'lightweight tag on a commit' -Actual $tagTypeResult.Output.Trim() -Reason 'Tag is not lightweight'
                }
            }
        }
    }
}

if ($failures.Count -gt 0) {
    $failures | Format-Table -AutoSize | Out-String | Write-Output
    throw ('Template version validation failed in {0} location(s).' -f $failures.Count)
}

Write-Verbose ('Template version validated: {0}' -f $version)
