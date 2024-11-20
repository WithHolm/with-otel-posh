<#
.SYNOPSIS
Gets traces. Either current, all or by id. returns current by default.

.PARAMETER All
Get all traces

.PARAMETER Id
Get a trace by id
#>
function Get-WotelTrace {
    [OutputType('WotelTrace')]
    param(
        [Switch]$All,
        [string]$Id,
        [System.Management.Automation.CallStackFrame[]]$Callstack = (Get-PSCallStack)
    )

    $Singleton = Get-WotelSingleton
    $traces = $Singleton.traces

    if(!$All -and [string]::IsNullOrEmpty($Id)){
        New-WotelTrace
        $TraceId = Get-WotelTraceId
        return $traces.$TraceId
    }

    if(![string]::IsNullOrEmpty($Id)){
        if(!$Traces.ContainsKey($Id)){
            throw "TraceId $Id not found"
        }
        return $Traces.$Id
    }

    if($All){
        return ($Traces.values |sort-object -Property createdTime -Descending)
    }
}