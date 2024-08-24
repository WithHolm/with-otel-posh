<#
.SYNOPSIS
Set Options for the current trace

.DESCRIPTION
Set Options for the current trace

.PARAMETER OutputToConsole
If you want to preserve the logs, but not for consumption at runtime, set this to "Disabled"

.PARAMETER IgnoreLogs
Will ignore all the logs for the span. This is generally the same as totally disabling the logs.
#>
function Set-WotelTraceOptions {
    [CmdletBinding()]
    param (
        [ValidateSet("Enabled", "Disabled")]
        [string]$OutputToConsole = "Enabled",
        [ValidateSet("Enabled", "Disabled")]
        [string]$IgnoreLogs = "Enabled"
    )
    begin {
        New-WotelTrace
        $traceId = Get-WotelTraceId
    }
    process {
        $global:wotel.$traceId.options.OutputToConsole = $OutputToConsole
        $global:wotel.$traceId.options.IgnoreLogs = $IgnoreLogs
    }
    end {}
}