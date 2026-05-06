<#
.SYNOPSIS
    Template for a reusable read-only PowerShell function.

.DESCRIPTION
    Use this template for functions that retrieve, inspect, validate, compare,
    or report on state without changing anything.

    This template is intended for public functions in a repository-oriented
    PowerShell project. It emphasizes:
    - advanced function structure
    - typed parameters and validation
    - stable structured output
    - descriptive terminating errors
    - mockable external interactions

    Execution Model:
    This template uses a single execution flow by default.

    Introduce begin/process/end only when the function is intentionally designed
    for pipeline input or clearly benefits from one-time setup, per-item
    processing, or end-of-stream cleanup.

    Do not add SupportsShouldProcess to read-only functions.

.PARAMETER InputObject
    Example parameter. Replace or remove as needed.

.EXAMPLE
    PS> Get-TargetState -InputObject 'Server01'

    Demonstrates the standard structure for a read-only function.

.OUTPUTS
    [PSCustomObject]
#>
function Get-TargetState {
    [CmdletBinding()]
    param (
        # Replace example parameters with the real function contract.
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$InputObject
    )

    try {
        Write-Verbose ('Starting {0}.' -f $MyInvocation.MyCommand.Name)
        Write-Verbose ('Inspecting input [{0}].' -f $InputObject)

        # Isolate external dependencies and read operations so they are easy to mock in tests.
        # Examples:
        # - query a service
        # - read a file
        # - retrieve current configuration
        # - compare expected and actual state

        $result = [PSCustomObject]@{
            Name = $InputObject
            Status = 'Unknown'
            IsCompliant = $false
        }

        Write-Verbose ('Completed {0}.' -f $MyInvocation.MyCommand.Name)
        return $result
    }
    catch {
        $message = 'Failed to execute {0} for input [{1}]. {2}' -f @(
            $MyInvocation.MyCommand.Name,
            $InputObject,
            $_.Exception.Message
        )

        $record = [System.Management.Automation.ErrorRecord]::new(
            $_.Exception,
            'ReadOnlyFunctionFailure',
            [System.Management.Automation.ErrorCategory]::NotSpecified,
            $InputObject
        )
        $record.ErrorDetails = [System.Management.Automation.ErrorDetails]::new($message)
        throw $record
    }
}
