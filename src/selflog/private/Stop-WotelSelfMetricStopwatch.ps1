<#
.SYNOPSIS
updates metric
#>
function Stop-WotelSelfMetricStopwatch {
    [CmdletBinding()]
    param (
        [parameter(
            Mandatory
        )]
        $Name,
        [System.Management.Automation.CallStackFrame[]]$Callstack = (Get-PSCallStack)
    )

    $span = Get-WotelSelfSpan -Callstack $Callstack

    if (!$span.metrics.ContainsKey($Name)) {
        Throw "Metric with name '$Name' does not exist on span $($span.id)"
    }

    $metric = $span.metrics[$Name]
    $metric.value.Stop()
    # $span.metrics[$Name].value.Stop()
}