<#
.SYNOPSIS
    Template for a PowerShell script with parameters and safe defaults.

.DESCRIPTION
    Use this template for repo scripts (e.g., under `scripts/`) or operational scripts
    that benefit from a structured parameter surface, predictable error handling,
    and verbose logging.

    If the script changes state, consider adding SupportsShouldProcess and guarding
    mutations with $PSCmdlet.ShouldProcess.
#>
[CmdletBinding()]
param(
    [Parameter()]
    [switch]$Force
)

$ErrorActionPreference = 'Stop'

try {
    Write-Verbose ('Starting {0}.' -f $MyInvocation.MyCommand.Name)

    if ($Force) {
        Write-Verbose 'Force mode requested.'
    }

    # TODO: Replace with real script logic.

    Write-Verbose ('Completed {0}.' -f $MyInvocation.MyCommand.Name)
}
catch {
    $message = 'Script failed: {0}' -f $_.Exception.Message
    throw $message
}
