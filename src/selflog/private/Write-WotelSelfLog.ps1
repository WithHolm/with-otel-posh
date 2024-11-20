<#
.SYNOPSIS
Self Logging for Wotel.. i cant ironically use my own logging for this.. it could generate roundtrip issues
#>
function Write-WotelSelfLog {
    [CmdletBinding()]
    param (
        [String]$Body,
        [PwshSeverity]$Severity = "info",
        [System.Management.Automation.CallStackFrame[]]$Callstack = (Get-PSCallStack)
    )
    
    $span = Get-WotelSelfSpan -Callstack $Callstack

    #region event
    $event = [WotelLog]@{
        attributes     = @{
            Source       = $Span.name
        }
        resource = $Callstack[0].Command
        severityText = $Severity.ToString()
        severityNumber = [int]$Severity
        body = ($body -join "") -replace "`r", "`r`n"
    }
    $Span.events.Add($event)
    #endregion event
}