<#
.SYNOPSIS
    Reusable retry pattern for transient operations.

.DESCRIPTION
    Use this pattern when an operation may fail temporarily and a bounded retry
    strategy is safer than immediate failure.

    Typical examples include:
    - network requests
    - API calls
    - service operations
    - file access with transient locks

    Do not use retry as a substitute for proper validation, input checking,
    or error handling. Retry only when a failure is plausibly temporary.

    Pattern expectations:
    - bounded retry count
    - explicit delay strategy
    - descriptive logging for each attempt
    - clear separation between retryable and non-retryable failures
    - terminating error when retry attempts are exhausted

    Default retry classification is intentionally conservative. Override
    -IsRetryable when the calling context can classify transient failures more
    precisely.

.PARAMETER Operation
    The scriptblock to execute.

.PARAMETER MaxAttempts
    The maximum number of attempts before the operation fails.

.PARAMETER InitialDelaySeconds
    The initial delay before the first retry.

.PARAMETER BackoffMultiplier
    The exponential backoff multiplier applied after each failed retryable attempt.

.PARAMETER MaxDelaySeconds
    The maximum delay allowed between attempts.

.PARAMETER OperationName
    A descriptive name used in verbose and error messages.

.PARAMETER IsRetryable
    Optional scriptblock used to classify whether a caught error should be retried.
    It receives the current error record as input and must return $true or $false.

.PARAMETER IncludeAttemptMetadata
    When specified, returns a wrapper object containing the operation result plus
    retry metadata.

.PARAMETER UseJitter
    When specified, adds a small random jitter to retry delays to reduce synchronized
    retry behavior.

.EXAMPLE
    PS> Invoke-OperationWithRetry -OperationName 'Get device state' -Operation { Get-Thing }

    Executes a transient operation using the default conservative retry classifier.

.EXAMPLE
    PS> Invoke-OperationWithRetry -OperationName 'Update device state' -Operation { Set-Thing } -IsRetryable {
    >>     param($ErrorRecord)
    >>     $ErrorRecord.Exception -is [System.Net.Http.HttpRequestException]
    >> }

    Executes an operation with a caller-defined retry classification rule.

.OUTPUTS
    The direct operation result by default, or a [PSCustomObject] wrapper when
    IncludeAttemptMetadata is specified.
#>
function Invoke-OperationWithRetry {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [scriptblock]$Operation,

        [Parameter()]
        [ValidateRange(1, 10)]
        [int]$MaxAttempts = 3,

        [Parameter()]
        [ValidateRange(0, 300)]
        [int]$InitialDelaySeconds = 2,

        [Parameter()]
        [ValidateRange(1, 10)]
        [int]$BackoffMultiplier = 2,

        [Parameter()]
        [ValidateRange(1, 3600)]
        [int]$MaxDelaySeconds = 30,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$OperationName = 'Operation',

        [Parameter()]
        [scriptblock]$IsRetryable = {
            param($ErrorRecord)

            $exception = $ErrorRecord.Exception

            if (
                $exception -is [System.Net.Http.HttpRequestException] -or
                $exception -is [System.TimeoutException] -or
                $exception -is [System.IO.IOException]
            ) {
                return $true
            }

            return $false
        },

        [Parameter()]
        [switch]$IncludeAttemptMetadata,

        [Parameter()]
        [switch]$UseJitter
    )

    $attempt = 0
    $delaySeconds = $InitialDelaySeconds
    $lastError = $null

    while ($attempt -lt $MaxAttempts) {
        $attempt++

        try {
            Write-Verbose ('Starting {0}. Attempt {1} of {2}.' -f $OperationName, $attempt, $MaxAttempts)

            $result = & $Operation

            Write-Verbose ('Completed {0} successfully on attempt {1}.' -f $OperationName, $attempt)

            if ($IncludeAttemptMetadata) {
                return [PSCustomObject]@{
                    OperationName = $OperationName
                    Attempts = $attempt
                    Succeeded = $true
                    Result = $result
                }
            }

            return $result
        }
        catch {
            $lastError = $_
            $isRetryable = & $IsRetryable $_

            if (-not $isRetryable) {
                $message = '{0} failed on attempt {1} and was classified as non-retryable. {2}' -f @(
                    $OperationName,
                    $attempt,
                    $_.Exception.Message
                )

                $record = [System.Management.Automation.ErrorRecord]::new(
                    $_.Exception,
                    'NonRetryableFailure',
                    [System.Management.Automation.ErrorCategory]::NotSpecified,
                    $null
                )
                $record.ErrorDetails = [System.Management.Automation.ErrorDetails]::new($message)
                throw $record
            }

            if ($attempt -ge $MaxAttempts) {
                break
            }

            $actualDelaySeconds = $delaySeconds
            if ($UseJitter -and $delaySeconds -gt 0) {
                $actualDelaySeconds = Get-Random -Minimum $delaySeconds -Maximum ($delaySeconds + 2)
            }

            Write-Verbose (
                '{0} failed on attempt {1} of {2}. Waiting {3} second(s) before retry. {4}' -f @(
                    $OperationName,
                    $attempt,
                    $MaxAttempts,
                    $actualDelaySeconds,
                    $_.Exception.Message
                )
            )

            if ($actualDelaySeconds -gt 0) {
                Start-Sleep -Seconds $actualDelaySeconds
            }

            $delaySeconds = [Math]::Min($delaySeconds * $BackoffMultiplier, $MaxDelaySeconds)
        }
    }

    $finalMessage = '{0} failed after {1} attempt(s). {2}' -f @(
        $OperationName,
        $MaxAttempts,
        $lastError.Exception.Message
    )

    $finalRecord = [System.Management.Automation.ErrorRecord]::new(
        $lastError.Exception,
        'RetryAttemptsExhausted',
        [System.Management.Automation.ErrorCategory]::OperationStopped,
        $null
    )
    $finalRecord.ErrorDetails = [System.Management.Automation.ErrorDetails]::new($finalMessage)
    throw $finalRecord
}
