
<#
.SYNOPSIS
Get trace and span for self logging
#>
function Get-WotelSelfSpan {
    [CmdletBinding()]
    param (
        [System.Management.Automation.CallStackFrame[]]$Callstack = (Get-PSCallStack)
    )
    
    #region Trace
    $Root = ($Callstack | Select-Object -Last 2)[0]
    $TraceId = (New-GuidV5 -Name "$($Root.Command) $($Root.Arguments) $($Root.InvocationInfo.HistoryId)").ToString()
    $singleton = Get-WotelSingleton
    if(!$Singleton.self.ContainsKey($TraceId)){
        $Singleton.self[$TraceId] = @{
            Spans = @{}
        }
    }
    $Trace = $Singleton.self[$TraceId]
    #endregion Trace

    #region span
    $SpanCallstack = $Callstack[0]
    $prefix = (New-GuidV5 -Name $SpanCallstack.Command).ToString()
    $suffix = (New-GuidV5 -Name $SpanCallstack.Arguments).ToString()
    $SpanId = "$($prefix.substring(0,18)):$($suffix.substring(19))"
    if(!$Trace.Spans.ContainsKey($SpanId)){
        $Trace.Spans[$SpanId] = @{
            name = $SpanCallstack.Command
            arguments = $SpanCallstack.Arguments
            events = [System.Collections.Generic.List[WotelEvent]]::new()
            metrics = @{}
        }
    }
    return $Trace.Spans[$SpanId]
    #endregion span
}