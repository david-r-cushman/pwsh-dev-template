<#
.SYNOPSIS
    Template for a reusable state-changing PowerShell function.

.DESCRIPTION
    Use this template for functions that create, update, delete, enable, disable,
    assign, revoke, import, export, or otherwise change state.

    This template is intended for public functions in a repository-oriented
    PowerShell project. It emphasizes:
    - advanced function structure
    - SupportsShouldProcess for all state changes
    - clear separation between read/validate steps and mutation steps
    - stable structured output
    - descriptive terminating errors
    - mockable external interactions

    Execution Model:
    This template uses a single execution flow by default. Introduce begin/process/end
    only when the function is explicitly designed for pipeline input or requires
    one-time setup, per-item processing, or end-of-stream cleanup.

    Validation, lookup, and comparison should happen before the mutation boundary.
    Wrap only the actual state change in $PSCmdlet.ShouldProcess(...).

.PARAMETER InputObject
    Example parameter. Replace or remove as needed.

.EXAMPLE
    PS> Set-ExampleThing -InputObject 'Server01' -WhatIf

    Demonstrates the standard structure for a state-changing function.

.OUTPUTS
    [PSCustomObject]
#>
function Set-ExampleThing {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$InputObject,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$DesiredState = 'Enabled'
    )

    try {
        Write-Verbose ('Starting {0}.' -f $MyInvocation.MyCommand.Name)

        Write-Verbose ('Retrieving current state for [{0}].' -f $InputObject)

        # Retrieve current state before any mutation.
        # Keep external dependencies isolated and easy to mock in tests.
        $currentState = 'Disabled'
        $changeRequired = $currentState -ne $DesiredState

        if (-not $changeRequired) {
            Write-Verbose ('No change required for [{0}].' -f $InputObject)

            return [PSCustomObject]@{
                Name = $InputObject
                PreviousState = $currentState
                DesiredState = $DesiredState
                Changed = $false
            }
        }

        $target = $InputObject
        $action = 'Set state to [{0}]' -f $DesiredState
        $changed = $false

        if ($PSCmdlet.ShouldProcess($target, $action)) {
            Write-Verbose ('Applying change to [{0}].' -f $InputObject)

            # Perform the actual mutation here only.
            # Examples:
            # - call external API
            # - update configuration
            # - write file or registry value
            # - modify service or directory object

            $changed = $true
            $currentState = $DesiredState
        }

        Write-Verbose ('Completed {0}.' -f $MyInvocation.MyCommand.Name)

        return [PSCustomObject]@{
            Name = $InputObject
            PreviousState = if ($changed) { 'Disabled' } else { $currentState }
            DesiredState = $DesiredState
            Changed = $changed
        }
    }
    catch {
        $message = 'Failed to execute {0} for input [{1}]. {2}' -f @(
            $MyInvocation.MyCommand.Name,
            $InputObject,
            $_.Exception.Message
        )

        $record = [System.Management.Automation.ErrorRecord]::new(
            $_.Exception,
            'StateChangingFunctionFailure',
            [System.Management.Automation.ErrorCategory]::NotSpecified,
            $InputObject
        )
        $record.ErrorDetails = [System.Management.Automation.ErrorDetails]::new($message)
        throw $record
    }
}
