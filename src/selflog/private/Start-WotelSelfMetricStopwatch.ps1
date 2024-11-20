<#
.SYNOPSIS
Initialize new self metric. use save-selfmetric to save the metric
#>
function Start-WotelSelfMetricStopwatch {
    [CmdletBinding()]
    param (
        [parameter(
            Mandatory
        )]
        [string]$Name,
        [switch]$Append,
        [System.Management.Automation.CallStackFrame[]]$Callstack = (Get-PSCallStack),
        [System.Diagnostics.Stopwatch]$existing
    )

    $span = Get-WotelSelfSpan -Callstack $Callstack
    if ($span.metrics.ContainsKey($Name) -and !$append) {
        Throw "Metric with name '$Name' already exists on span $($span.name). use -append to append to existing metric"
    }

    $ret = [WotelMetricStopwatch]@{
        name = $Name
        lap = 1
        resource = $Callstack[0].Command
    }

    if($Append -and $span.metrics.ContainsKey($Name)){
        $ret = $span.metrics[$Name]
        $ret.lap++
    }

    if ($existing) {
        $ret.value = $existing
    }

    $ret.value.Start()
    $span.metrics[$Name] = $ret
}