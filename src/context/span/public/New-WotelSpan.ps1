<#
.SYNOPSIS
Adds a trace context for the current command or a chosen custom span

.DESCRIPTION
Adds a trace context for the current command or a chosen custom span. This is used to track the execution of a command through the system.

.PARAMETER DisplayName
Name to be emitted through log resource. If not provided, the command name will be used.

.PARAMETER Arguments
Arguments to be emitted through log resource. mostly for log, but you should emit them as "powershell" argument string "{Test=1}" or "{Test=1, Other=test}"

.PARAMETER OutputToConsole
If set to "Disabled", the span will not be written to the console. This is useful for when you want to preserve log, but not for consumption at runtime

.PARAMETER IgnoreLogs
Will ignore all the logs for the span. Useful instead of commenting out each log line in script

.PARAMETER Callstack
Parameter description

.EXAMPLE 
An example

.NOTES
General notes
#>
function New-WotelSpan {
    [CmdletBinding(
        DefaultParameterSetName = "Callstack"
    )]
    param (
        [parameter(
            ParameterSetName = "Custom",
            Mandatory
        )]
        [parameter(
            ParameterSetName = "Callstack"
        )]
        [string]$DisplayName,

        [parameter(
            ParameterSetName = "Custom"
        )]
        [ValidateNotNullOrEmpty()]
        [string]$Arguments,

        [parameter(
            ParameterSetName = "Custom"
        )]
        [ValidateNotNullOrEmpty()]
        [string]$SpanId,

        [parameter(
            ParameterSetName = "Custom"
        )]
        [string]$ParentId,

        [parameter(
            ParameterSetName = "Custom"
        )]
        # [ValidateNotNullOrEmpty()]
        [System.IO.FileInfo]$File,

        [ValidateSet("Enabled", "Disabled")]
        [String]$OutputToConsole = "Enabled",
        
        [ValidateSet("Enabled", "Disabled")]
        [string]$IgnoreLogs = "Enabled",

        [parameter(
            ParameterSetName = "Callstack"
            # Mandatory
        )]
        [ValidateNotNullOrEmpty()]
        # the default value
        [System.Management.Automation.CallStackFrame[]]$Callstack = (Get-PSCallStack)
    )
    begin {}
    process {
        # $Root = (Get-PSCallStack)[-2]
        #add trace if not exists
        New-WotelTrace

        $TraceId = Get-WotelTraceId # New-GuidV5 -Name "$($Callstack[-2].Command) $($Callstack[-2].Arguments) $($Callstack[-2].InvocationInfo.HistoryId)"

        if ($PSCmdlet.ParameterSetName -eq 'callStack') {
            $SpanId = Get-WotelSpanId -Callstack $Callstack
        }

        if($PSCmdlet.ParameterSetName -eq 'Custom' -and !$File){
            $File = $Callstack[0].scriptname
        }

        if ($global:wotel[$TraceId].spans.ContainsKey($SpanId)) {
            return
        }
        if ($PSCmdlet.ParameterSetName -eq 'callStack' -or [string]::IsNullOrEmpty($ParentId)) {
            if ($Callstack.Count -gt 1) {
                $parentId = Get-WotelSpanId -Callstack $Callstack[1..$Callstack.Count]
            } else {
                $parentId = $null
            }
        }

        # if ($Callstack.Count -gt 1) {
        #     $parent = $Callstack[1].InvocationInfo.HistoryId.ToString()
        # } else {
        #     $parent = $null
        # }

        switch ($PSCmdlet.ParameterSetName) {
            "Custom" {
                $span = @{
                    historyId = $Callstack[0].InvocationInfo.HistoryId.ToString()
                    name      = $DisplayName
                    arguments = $Arguments
                    file      = $File.FullName
                    id        = $SpanId
                    parent    = $ParentId
                }
            }
            "Callstack" {
                # $SpanId = New-GuidV5 -Name "$($Callstack[-2].Command) $($Callstack[-2].Arguments) $($Callstack[-2].InvocationInfo.HistoryId)"
                if ([string]::IsNullOrEmpty($DisplayName)) {
                    $command = $Callstack[0].command
                    $functionName = $Callstack[0].FunctionName
                    if ([string]::IsNullOrEmpty($command) -and $functionName -eq '<scriptblock>') {
                        $command = $functionName
                    } elseif ([string]::IsNullOrEmpty($command)) {
                        $command = $functionName -replace "<.+>", ""
                    }
                } else {
                    $command = $DisplayName
                }

                $span = @{
                    name      = $command
                    arguments = $Callstack[0].Arguments
                    File      = $Callstack[0].scriptname
                    id        = $SpanId
                    parent    = $parentId
                    historyId = $Callstack[0].InvocationInfo.HistoryId.ToString()
                }
            }
        }
        $span.startUtc = [datetime]::UtcNow
        $span.endUtc = $null #will be set when the span is ended.. not really used
        $span.events = [System.Collections.Generic.List[hashtable]]::new()

        $span.options = @{
            OutputToConsole = $OutputToConsole
            IgnoreLogs = $IgnoreLogs
        }

        $span.scopeAttributes = @{
            historyId = $Callstack[0].InvocationInfo.HistoryId.ToString()
            ScriptLineNumber = $Callstack[0].InvocationInfo.ScriptLineNumber
            ModuleName = $Callstack[0].InvocationInfo.MyCommand.ModuleName
        }

        [void]$global:wotel.$TraceId.spans.Add($span.id, $span)

        if($span.options.IgnoreLogs -eq "Enabled"){
            return
        }
        
        New-WotelLog -Body "Started span - Name: $($span.name) - arguments: $($span.arguments)" -Severity trace -SpanId $Span.id 
    }
    end {}
}

# New-WotelSpan