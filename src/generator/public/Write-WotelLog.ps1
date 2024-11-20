
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

.PARAMETER SkipConsole
Skip writing to the console. only write to log

.PARAMETER PassThru
Pass the log object to the pipeline without writing to the console

#>
function Write-WotelLog {
    [CmdletBinding(
        DefaultParameterSetName = "Callstack"
    )]
    [OutputType([hashtable])]
    param (
        [parameter(
            Mandatory,
            Position = 0,
            ValueFromPipeline
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

        [switch]$SkipConsole
    )
    begin {
        if($PSCmdlet.ParameterSetName -eq 'custom'){
            $span = Get-WotelSpan -SpanId $SpanId
        }else{
            $span = Get-WotelSpan -Callstack $Callstack
        }

        if(!$span){
            $span = New-WotelSpan -Callstack $Callstack -PassThru
        }

        if(!$span){
            Get-PSCallStack|ForEach-Object{
                Write-Host $_
            }
            throw "Could not find or create a new span.. this should not happen"
        }
    }
    process {
        #this is the events inside the span. this is the log
        $EventItem = [WotelLog]@{
            type           = [WotelEventType]::Log
            attributes = @{
                CreationType = $PSCmdlet.ParameterSetName
                #this is used in invoke console writer, please keep in sync
                Source       = @($Callstack[0].Command, $Callstack[0].ScriptLineNumber) -join ":"
                LineNumber   = $Callstack[0].ScriptLineNumber
                CustomResource = $true
                optionSkipConsole = $SkipConsole
            }
            resource = $Resource
            timestamp = $TimestampUtc
            severityText = $Severity.ToString()
            severityNumber = [int]$Severity
            body = ($body -join "") -replace "`r", "`r`n"
        }

        if ([string]::IsNullOrEmpty($resource)) {
            $EventItem.Resource = $span.name
            $EventItem.Attributes.CustomResource = $false
        }

        $null = $span.events.Add($EventItem)

        if ($PassThru) {
            return $EventItem
        }
        
        Start-WotelSelfMetricStopwatch -Name 'log-write' -Append
        Invoke-WotelWriter -EventItem $EventItem -Span $span -Trace (Get-WotelTrace)
        Stop-WotelSelfMetricStopwatch -Name 'log-write'
    }
    end {}
}

# Write-WotelLog "test"