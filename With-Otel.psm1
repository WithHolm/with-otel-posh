using namespace System.Collections.Generic
using namespace System.IO
# ALL CLASSES ARE JUST USED AS SRTUCTURES FOR THE DATA. NO LOGIC SHOULD BE HERE.
#region SEVERITY
enum OtelSeverity {
    trace = 1
    trace2 = 2
    trace3 = 3
    trace4 = 4
    debug = 5
    debug2 = 6
    debug3 = 7
    debug4 = 8
    info = 9
    info2 = 10
    info3 = 11
    info4 = 12
    warn = 13
    warn2 = 14
    warn3 = 15
    warn4 = 16
    error = 17
    error2 = 18
    error3 = 19
    error4 = 20
    fatal = 21
    fatal2 = 22
    fatal3 = 23
    fatal4 = 24
}

enum PwshSeverity {
    # pscore = 1 # not enabled, but think this might be used for pwsh core used for powershell cure logging. 
    system = 2
    trace = 3
    debug = 5
    verbose = 7
    info = 9
    success = 10
    warning = 13
    error = 17
    fatal = 21
    throwing = 24
}
#endregion SEVERITY

enum WotelEnabled{
    Disabled = 0
    Enabled = 1
}

#region EVENT
enum WotelEventType {
    Log = 1
    Metric = 2
}

class WotelEvent {
    [WotelEventType]$type
    [datetime]$timestamp = [datetime]::UtcNow
    [hashtable]$attributes = @{}
    [string]$resource = ""
}

class WotelMetric:WotelEvent {
    [WotelEventType]$type = [WotelEventType]::Metric
    [string]$name = ""

}

class WotelMetricStopwatch: WotelMetric {
    [System.Diagnostics.Stopwatch]$value = [System.Diagnostics.Stopwatch]::new()
    [int]$Lap = 0
}

class WotelMetricCounter: WotelMetric {
    [int]$value = 0
}

class WotelLog: WotelEvent {
    [WotelEventType]$type = [WotelEventType]::Log
    [string]$SeverityText = ""
    [int]$SeverityNumber = 0
    [string]$Body = ""
}
#endregion EVENT

#region SPAN
class WotelSpanAttributes {
    [bool]$outputToConsole = $true
    [bool]$outputToLogs = $true
    [string]$file = ""
    [int]$lineNumber = $null
    [string]$moduleName = ""
    WotelSpanAttributes(){}
    [string]ToString() {
        $ret = @()
        $a = @()
        if($this.OutputToConsole){
            $a += "console"
        }
        if($this.OutputToLogs){
            $a += "logs"
        }
        if($a.count -gt 0){
            $ret += "Outputs: $($a -join ", ")"
        }

        if($this.file){
            $ret += "file:$($this.NamedScope)"
        }

        return $ret -join "| "
    }
}

class WotelSpanContext {
    [string]$historyId = ""
    [string]$parentId = ""
    [string]$traceId = ""
    [string]$spanId = ""
}

class WotelSpan {
    [wotelSpanContext]$context = [wotelSpanContext]::new()
    [string]$name = ""
    [string]$arguments = ""
    [datetime]$startTime = [datetime]::UtcNow
    [datetime]$endTime = [datetime]::UtcNow
    # [hashtable]$events = @{}
    [List[WotelEvent]]$events = [List[WotelEvent]]::new()
    [WotelSpanAttributes]$attributes = [WotelSpanAttributes]::new()
}
#endregion SPAN
#region TRACE
class WotelTraceAttributes {
    [bool]$OutputToConsole = $true
    [bool]$OutputToLogs = $true
    [bool]$Named = $false
    [string]$NamedScope = "" #directory to use as source for named trace. every script will be checked against this.
    WotelTraceAttributes() {}
    [string]ToString() {
        $ret = @()
        $a = @()
        if($this.OutputToConsole){
            $a += "console"
        }
        if($this.OutputToLogs){
            $a += "logs"
        }
        if($a.count -gt 0){
            $ret += "Outputs: $($a -join ", ")"
        }

        if($this.Named){
            $ret += "Named! scope:$($this.NamedScope)"
        }

        return $ret -join "| "
    }
}

class WotelTrace {
    [string]$id = ""
    [string]$name = ""
    [string]$arguments = ""
    [string]$historyId = ""
    [datetime]$createdTime = [datetime]::UtcNow
    [WotelTraceAttributes]$attributes = [WotelTraceAttributes]::new()
    [hashtable]$spans = @{}
    # [Dictionary[string, WotelSpan]]$spans = [Dictionary[string, WotelSpan]]::new()
}
#endregion TRACE

$scripts = gci "$PSScriptRoot/src" -Recurse -File -filter "*.ps1" |
Where-Object { $_.BaseName -notlike "$*" } |
Where-Object { $_.BaseName -notlike "*.tests" } |
Where-Object { $_.Directory.Name -notlike "*ignore*" -or $_.BaseName -notlike "*.ignore*" }

$scripts | % {
    . $_
}

$null = Initialize-WotelSetting
Initialize-WotelSingleton