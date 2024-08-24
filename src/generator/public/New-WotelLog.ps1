
<#
.SYNOPSIS
Generate a log line, with full controll over the object being created. i am assuing a span and trace for this to be put in has been created

.PARAMETER Body
Message to log

.PARAMETER Severity
Severity of the log

.PARAMETER Span
Span of the log. generally historyid of the command that started the span

.PARAMETER Parent
Parent of the log. generally historyid of the command that called the command that started the span

.PARAMETER Resource
Resource of the log. generally. what "thing" is sending the log. uses span name if not provided

.PARAMETER Timestamp
Timestamp of the log. when the log was created. optional

.PARAMETER TraceId
TraceId of the log. generally historyid of the command that started the span

.PARAMETER PassThru
Pass the log object to the pipeline without writing to the console

#>
function New-WotelLog {
    [CmdletBinding(
        DefaultParameterSetName = "Callstack"
    )]
    param (
        [parameter(
            Mandatory,
            Position = 0
        )]
        [string]$Body,

        # [parameter(Mandatory)]
        [PwshSeverity]$Severity = "info",

        [parameter(
            ParameterSetName = "Custom",
            Mandatory
        )]
        [string]$SpanId,
        [String]$Resource,
        [datetime]$TimestampUtc = [datetime]::UtcNow,

        [parameter(
            ParameterSetName = "Callstack"
        )]
        [System.Management.Automation.CallStackFrame[]]$Callstack = (Get-PSCallStack),

        [switch]$SkipConsole,
        [switch]$PassThru
    )
    begin {
        $traceObj = Get-WotelTrace

        if ($PSCmdlet.ParameterSetName -eq 'Callstack') {
            $SpanId = Get-WotelSpanId -Callstack $Callstack
        }

        if ($null -eq $traceObj) {
            Throw "Could not find a TraceId $TraceId does not exist"
        }

        if (!$traceObj.spans.ContainsKey($SpanId)) {
            if ($pscmdlet.ParameterSetName -eq 'Callstack') {
                New-WotelSpan -Callstack $Callstack
            } else {
                Throw "SpanId $SpanId does not exist in trace $TraceId"
            }
        }

        $SpanObj = $traceObj.spans.$SpanId

        if ("Enabled" -in $SpanObj.options.IgnoreLogs, $traceObj.options.IgnoreLogs) {
            return
        }

    }
    process {
        #this is the events inside the span. this is the log
        $EventItem = @{
            Type           = "log"
            Timestamp      = $TimestampUtc
            Attributes     = @{
                CreationType = $PSCmdlet.ParameterSetName

                #this is used in invoke console writer, please keep in sync
                Source       = @($Callstack[0].Command, $Callstack[0].ScriptLineNumber) -join ":"
                LineNumber   = $Callstack[0].ScriptLineNumber
                CustomResource = $true
                optionSkipConsole = $SkipConsole
            }
            Resource       = $Resource
            SeverityText   = $Severity.ToString()
            SeverityNumber = [int]$Severity
            Body           = ($body -join "") -replace "`r", "`r`n"
        }

        if ([string]::IsNullOrEmpty($resource)) {
            $EventItem.Resource = $SpanObj.name
            $EventItem.Attributes.CustomResource = $false
        }

        $SpanObj.events.Add($EventItem)

        if ($PassThru) {
            return $EventItem
        }


        Invoke-WotelWriter -EventItem $EventItem -SpanItem $SpanObj -TraceItem $traceObj
    }
    end {}
}

# New-WotelLog "test"  