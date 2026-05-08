<#
.SYNOPSIS
    Validates repository version pins against the central runtime policy.

.DESCRIPTION
    Reports drift between eng/runtime-policy.json and files that intentionally
    pin the development runtime, CI runner, and baseline PowerShell tooling.
#>
[CmdletBinding()]
param(
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$PolicyPath = (Join-Path -Path $PSScriptRoot -ChildPath '..\eng\runtime-policy.json')
)

$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '..')).Path
$resolvedPolicyPath = (Resolve-Path -LiteralPath $PolicyPath).Path
$policy = Get-Content -Raw -LiteralPath $resolvedPolicyPath | ConvertFrom-Json
$failures = [System.Collections.Generic.List[object]]::new()

function Test-PolicyValue {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$RelativePath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ExpectedText,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Description
    )

    $path = Join-Path -Path $repoRoot -ChildPath $RelativePath

    if (-not (Test-Path -LiteralPath $path)) {
        $failure = [pscustomobject]@{
            Path = $RelativePath
            Expected = $ExpectedText
            Description = $Description
            Reason = 'File not found'
        }

        $failures.Add($failure)
        return
    }

    $content = Get-Content -Raw -LiteralPath $path
    if (-not $content.Contains($ExpectedText)) {
        $failure = [pscustomobject]@{
            Path = $RelativePath
            Expected = $ExpectedText
            Description = $Description
            Reason = 'Expected text not found'
        }

        $failures.Add($failure)
    }
}

Test-PolicyValue -RelativePath '.devcontainer/Dockerfile' -ExpectedText ('FROM {0}' -f $policy.runtime.dockerImage) -Description 'Dev container base image'
Test-PolicyValue -RelativePath '.devcontainer/Dockerfile' -ExpectedText ('ARG PESTER_VERSION={0}' -f $policy.tooling.pesterVersion) -Description 'Dev container Pester version'
Test-PolicyValue -RelativePath '.devcontainer/Dockerfile' -ExpectedText ('ARG PSSCRIPTANALYZER_VERSION={0}' -f $policy.tooling.psScriptAnalyzerVersion) -Description 'Dev container PSScriptAnalyzer version'
Test-PolicyValue -RelativePath '.devcontainer/Dockerfile' -ExpectedText ('ARG PSREADLINE_VERSION={0}' -f $policy.tooling.psReadLineVersion) -Description 'Dev container PSReadLine version'
Test-PolicyValue -RelativePath '.devcontainer/Dockerfile' -ExpectedText ('PowerShell {0} Template Environment Loaded' -f $policy.runtime.powershellVersion) -Description 'Dev container profile banner'
Test-PolicyValue -RelativePath '.devcontainer/devcontainer.json' -ExpectedText ('PowerShell {0} Template' -f $policy.runtime.powershellVersion) -Description 'Dev container display name'

Test-PolicyValue -RelativePath '.github/workflows/ci.yml' -ExpectedText ('runs-on: {0}' -f $policy.githubActions.runnerImage) -Description 'GitHub Actions runner image'
Test-PolicyValue -RelativePath '.github/workflows/ci.yml' -ExpectedText ('Install-Module Pester -Scope CurrentUser -Force -RequiredVersion {0}' -f $policy.tooling.pesterVersion) -Description 'CI Pester version'
Test-PolicyValue -RelativePath '.github/workflows/ci.yml' -ExpectedText ('Install-Module PSScriptAnalyzer -Scope CurrentUser -Force -RequiredVersion {0}' -f $policy.tooling.psScriptAnalyzerVersion) -Description 'CI PSScriptAnalyzer version'

Test-PolicyValue -RelativePath 'README.md' -ExpectedText ('PowerShell {0}' -f $policy.runtime.powershellVersion) -Description 'README PowerShell version'
Test-PolicyValue -RelativePath 'README.md' -ExpectedText ('Ubuntu {0}' -f $policy.runtime.ubuntuVersion) -Description 'README Ubuntu version'
Test-PolicyValue -RelativePath '.github/Instructions/environment-setup.md' -ExpectedText ('PowerShell {0}' -f $policy.runtime.powershellVersion) -Description 'Environment setup PowerShell version'
Test-PolicyValue -RelativePath '.github/Instructions/environment-setup.md' -ExpectedText ('Ubuntu {0}' -f $policy.runtime.ubuntuVersion) -Description 'Environment setup Ubuntu version'
Test-PolicyValue -RelativePath '.github/copilot-instructions.md' -ExpectedText ('PowerShell {0}' -f $policy.runtime.powershellVersionLabel) -Description 'Copilot instruction PowerShell compatibility target'

if ($failures.Count -gt 0) {
    $failures | Format-Table -AutoSize | Out-String | Write-Output
    throw ('Version policy drift detected in {0} location(s).' -f $failures.Count)
}

Write-Verbose ('Version policy validated: {0}' -f $resolvedPolicyPath)
