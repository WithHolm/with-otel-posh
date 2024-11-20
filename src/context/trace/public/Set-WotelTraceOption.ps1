<#
.SYNOPSIS
Set Options for the current trace

.DESCRIPTION
Set Options for the current trace

.PARAMETER OutputToConsole
If you want to preserve the logs, but not for consumption at runtime, set this to "Disabled"

.PARAMETER OutputToLogs
Will ignore all the logs for the span. This is generally the same as totally disabling the logs.
#>
function Set-WotelTraceOption {
    [CmdletBinding()]
    param (
        [WotelEnabled]$OutputToConsole,
        [WotelEnabled]$OutputToLogs
    )
    begin {
        New-WotelTrace
    }
    process {
        $Trace = Get-WotelTrace
        if(![String]::isNullOrEmpty($OutputToConsole)){
            $trace.attributes.OutputToConsole = [bool]$OutputToConsole
        }
        if(![String]::isNullOrEmpty($OutputToLogs)){
            $Trace.attributes.OutputToLogs = [bool]$OutputToLogs
        }
    }
    end {}
}