<#
.SYNOPSIS
Adds a trace context for the current running script. this will contain all the spans and events for the current script
.PARAMETER Name
Name of the trace, if you want to create a custom trace. this is preferrably used if you want avoid writing logs for your module to the global log.
.PARAMETER Directory
Used with 'Name' param. Directory to use as "src" for future trace lookups. any command where their file is recurivly within that directory will be considered as part of the 'named' trace. if not provided, it will use the directory of the calling script.
#>
function New-WotelTrace {
    [CmdletBinding()]
    param (
        # [string]$Name,
        # [string]$Directory,
        [System.Management.Automation.CallStackFrame[]]$Callstack = (Get-PSCallStack)
    )
    begin {
        $Singleton = Get-WotelSingleton
        # if($Name -eq 'settings'){
        #     Throw "trace name 'settings' is reserved"
        # }
    }
    process {
        #weird select and first of array,because i need the next last item in stack, but sometimes the stack contains one

        $Root = ($Callstack| Select-Object -Last 2)[0]
        $traceId = Get-WotelTraceId -Callstack $Callstack
        # $Trace = Get-WotelTrace -Id $TraceId
        if (!$Singleton.traces.ContainsKey($TraceId)) {
            $Trace = [WotelTrace]::new()
            $Trace.name = $Root.Command
            $Trace.arguments = $Root.Arguments
            $Trace.historyId = $Root.InvocationInfo.HistoryId
            $trace.id = $TraceId

            #if the trace is named
            # if($Name)
            # {
            #     $TraceId = "$traceId`_$Name"
            #     $Trace.name = $Name
            #     $trace.attributes.Named = $true
            #     $Trace.id = $TraceId
            #     if(!$Directory -and [string]::isNullOrEmpty($Callstack[0].ScriptName))
            #     {
            #         Throw "Cannot create named trace without having a directory defined (could not find a source directory from $($Callstack[0].Command)). Mabye just... define a directory with -Directory?"
            #     }
            #     elseif(!$Directory)
            #     {
            #         $Directory = split-path $Callstack[0].ScriptName
            #     }
            # }
            $Singleton.traces.Add($TraceId, $Trace)
        }

        #remove old traces
        Remove-WotelOldTrace
    }
}


# . 'D:\code\git\with-otel-posh\tesfile.ps1'
# $Null = Initialize-WotelSingleton
# New-WotelTrace -Name "test"


# Get-WotelTraceId
# $global:wotel