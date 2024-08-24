<#
.SYNOPSIS
returns true if the current log level is less than or equal to the input severity (ie it should render the log message)

.DESCRIPTION
returns true if the current log level is less than or equal to the input severity. used to check if i should render a log message or not.

.PARAMETER LogSeverity
severitynumber of log message
#>
function Test-WotelShouldRenderLog {
    [CmdletBinding()]
    param (
        [ValidateNotNullOrEmpty()]
        [ValidateRange(1,24)]
        [int]$LogSeverity
    )

    $CurrentLogLevel = [int](Get-WotelLogLevel)
    return ($CurrentLogLevel -le $LogSeverity)
}