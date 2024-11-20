<#
.SYNOPSIS
Adds a trace context for the current command or a chosen custom span

.DESCRIPTION
Adds a trace context for the current command or a chosen custom span.
This is used to track the execution of a command through the system.
This is automatically called when writing logs, so you don't need to call it yourself.

.PARAMETER DisplayName
Name to be emitted through log resource. If not provided, the command name will be used.

.PARAMETER Arguments
Arguments to be emitted through log resource. mostly for log, but you should emit them as "powershell" argument string "{Test=1}" or "{Test=1, Other=test}"

.PARAMETER OutputToConsole
If set to "Disabled", the span will not be written to the console. This is useful for when you want to preserve log, but not for consumption at runtime

.PARAMETER OutputToLogs
Will output to logs for the span. Useful instead of commenting out each log line in script. logs in this case is all writers that are not console

.PARAMETER Callstack
Only used if you need to create a span for a custom span. else, just use the default.

.EXAMPLE
New-WotelSpan -DisplayName "test"

.EXAMPLE
#log from a external source. note that the name
$Args = @(
    "-i 'inputfile.gif'",
    "'outputfile.gif'",
    "-y"
)
$FfmpegPath = (get-command ffmpeg).source
New-WotelSpan -DisplayName 'ffmpeg' -Arguments $Args -File $FfmpegPath
$Command = "$FfmpegPath $($Args -join " ") *>&1"

Write-WotelLog -Body 'running ffmpeg..'
#create scriptblock so args can be passed to ffmpeg execution
#FFMPEEG will write to stderr, so we need to redirect stderr to stdout..
[scriptblock]::Create($Command).Invoke()|Write-WotelLog -SpanId 'ffmpeg' -Severity info

#outputs:
[10:19:16.19][trce][ffmpeg] Started span - Name:ffmpeg - arguments: -i 'inputfile.gif', 'outputfile.gif', -y
[10:38:50.36][info][tesfile.ps1] running ffmpeg..
[10:19:17.00][info][ffmpeg] ffmpeg version 6.1-full_build-www.gyan.dev Copyright (c) 2000-2023 the FFmpeg developers

.EXAMPLE

.NOTES
General notes
#>
function New-WotelSpan {
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = "Does not change system state", Scope = 'function')]
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
        [string[]]$Arguments,

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
        [System.IO.FileInfo]$File,

        # [ValidateSet("Enabled", "Disabled")]
        [WotelEnabled]$OutputToConsole = "Enabled",

        # [ValidateSet("Enabled", "Disabled")]
        [WotelEnabled]$OutputToLogs = "Enabled",

        [parameter(
            ParameterSetName = "Callstack"
        )]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.CallStackFrame[]]$Callstack = (Get-PSCallStack),

        [switch]$PassThru
    )
    begin {
        $TraceId = Get-WotelTraceId -Callstack $Callstack
        $Singleton = Get-WotelSingleton

        if(!$Singleton.traces.ContainsKey($TraceId)){
            New-WotelTrace -Callstack $Callstack
            $Singleton = Get-WotelSingleton
        }


        if ($PSCmdlet.ParameterSetName -eq 'custom') {
            if (!$DisplayName) {
                throw "DisplayName is required when defining custom span"
            }
            if (!$SpanId) {
                $SpanId = $DisplayName
            }
            if (!$File) {
                $File = $Callstack[0].scriptname
            }
        }

        if ($PSCmdlet.ParameterSetName -eq 'callStack') {
            $Span = Get-WotelSpan -Callstack $Callstack
            if($Span){
                if($PassThru){
                    return $Span
                }
                return
            }
            $SpanId = Get-WotelSpanId -Callstack $Callstack

            $Arguments = $Callstack[0].Arguments
            $File = $Callstack[0].scriptname
            if ([string]::IsNullOrEmpty($DisplayName)) {
                $command = $Callstack[0].command
                $functionName = $Callstack[0].FunctionName
                if ([string]::IsNullOrEmpty($command) -and $functionName -eq '<scriptblock>') {
                    $command = $functionName
                }
                elseif ([string]::IsNullOrEmpty($command)) {
                    $command = $functionName -replace "<.+>", ""
                }
                $DisplayName = $command
            }
        }

        if($Arguments){
            $Arguments = $Arguments -join ", "
        }
    }
    process {
        if ($Singleton.traces[$TraceId].spans.ContainsKey($SpanId)) {
            if($PassThru){
                return $Singleton.traces[$TraceId].spans[$SpanId]
            }
            return
        }

        if([string]::IsNullOrEmpty($ParentId) -and $Callstack.Count -gt 1){
            $parentId = Get-WotelSpanId -Callstack $Callstack[1..$Callstack.Count]
        }

        # $span = [Wotelspan]::new()
        # $span.context.parentId = $ParentId
        # $span.context.traceId = $TraceId
        # $span.context.spanId = $SpanId
        # $span.context.historyId = $Callstack[0].InvocationInfo.HistoryId.ToString()
        # $span.name = $DisplayName
        # $span.arguments = $Arguments
        # $span.
        $Span = [Wotelspan]@{
            context = @{
                historyId = $Callstack[0].InvocationInfo.HistoryId.ToString()
                parentId    = $ParentId
                traceId   = $TraceId
                spanId = $SpanId
            }
            name      = $DisplayName
            arguments = $Arguments
            # startTime = [datetime]::UtcNow
            # endTime = $null
            # events = [System.Collections.Generic.List[hashtable]]::new()
            attributes = @{
                file      = $File.FullName
                OutputToConsole = $OutputToConsole
                OutputToLogs    = $OutputToLogs
                LineNumber = $Callstack[0].ScriptLineNumber
                ModuleName = $Callstack[0].InvocationInfo.MyCommand.ModuleName
            }
        }

        [void]$Singleton.traces[$TraceId].spans.Add($Span.context.spanId, $span)

        if ($PassThru) {
            Write-Output $Singleton.traces[$TraceId].spans[$Span.context.spanId]
        }

        if ($span.attributes.optionOutputToLogs -eq "Enabled") {
            Write-WotelLog -Body "Started span - Name:$($span.name) - arguments: $($span.arguments)" -Severity trace -SpanId $Span.context.spanId
            # return
        }

    }
    end {}
}

# New-WotelSpan

# New-WotelSpan