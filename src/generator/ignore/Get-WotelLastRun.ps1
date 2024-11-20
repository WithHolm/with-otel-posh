<#
.SYNOPSIS
Returns the last run of the script

.PARAMETER Logs
Parameter description

.PARAMETER Severity
Parameter description

.PARAMETER Statistics
Parameter description

.PARAMETER Raw
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function Get-WotelLastRun {
    [CmdletBinding(
        DefaultParameterSetName = "Logs"
    )]
    param (
        [parameter(
            ParameterSetName = "Logs"
        )]
        [switch]$Logs,

        [parameter(
            ParameterSetName = "Raw"
        )]
        [parameter(
            ParameterSetName = "Logs"
        )]
        [switch]$IncludeWotel,

        [parameter(
            ParameterSetName = "Logs"
        )]
        [PwshSeverity]$Severity = "debug",

        [parameter(
            ParameterSetName = "Statistics"
        )]
        [switch]$Statistics,

        [parameter(
            ParameterSetName = "Raw"
        )]
        [switch]$Raw
    )
    Set-WotelTraceOption -OutputToLogs Disabled

    $singleton = Get-WotelSingleton
    $Traces = Get-WotelTrace -All
    $LastTrace = $Traces | Where-Object {$_.attributes.OutputToLogs} | sort-object -Property createdTime -Descending | select-object -first 1

    if(-not $Raw -and -not $Logs -and -not $Statistics){
        Write-Host "No parameters set. Please specify one of the following parameters: Logs, Statistics, Raw"
        return
    }
    if($Raw -or $Logs){
        $out = LastTrace.spans.values.events
        if ($IncludeWotel) {
            $singleton.self.$LastTrace.spans.values.events|?{ $_.type -eq 'log'}|%{
                $out.Add([wotelLog]$_)
            }
        }
    }

    if ($Raw) {
        return ($out  | Sort-Object Timestamp)
    }
    #return logs
    if ($Logs) {
        #return all logs that are above the severity level. the write to std out accepts a otel log object as input parameters
        ($out | Sort-Object Timestamp) | Where-Object { $_.SeverityNumber -ge ([int]$Severity) } | ForEach-Object {
            Invoke-WotelWriterConsole -EventItem $_ -IgnoreDebugLevel
        }
    }

    if ($Statistics) {
        Write-host "Name: $($LastTrace.name)"
        Write-host "Id: $($LastTrace.id), HistoryId: $($LastTrace.historyId)"
        Write-Host "Started: $($LastTrace.createdTime)"
        Write-Host "Arguments: $($LastTrace.arguments)"
        Write-Host "Options: Oputput To Console: $($LastTrace.options.OutputToConsole), Ignore logs: $($LastTrace.options.IgnoreLogs)"
        $Spans = $LastTrace.spans.values
        # $Spans = Get-OtelSpanTree -TraceId $LastLog.TraceId
        Write-Host "Found $($LastTrace.spans.Count) spans in trace"
        Write-host ("-"*30)

        $highestIndex = $spans.values.index | Sort-Object -Descending | Select-Object -First 1
        $LongestName = ($spans.values.Name | ForEach-Object { $_.length } | Measure-Object -Maximum).Maximum
        Write-Verbose "Longest name: $LongestName, Highest index: $highestIndex"

        #figure out some stats
        for ($i = $spans.Count - 1; $i -gt -1; $i--) {
            $span = $spans[$i]
            $anylog = $Log | Where-Object { $_.Span -eq $span.id } | Select-Object -first 1

            #get start and end of span
            $startlog = $Log | Where-Object { $_.Span -eq $span.id -and $_.Attributes.Start } | Select-Object -First 1
            $endlog = $Log | Where-Object { $_.Span -eq $span.id -and $_.Attributes.End } | Select-Object -First 1

            if ($startlog -and $endlog) {
                $span.start = $startlog.Timestamp
                $span.end = $endlog.Timestamp
                $span.TotalDurationMs = $($span.end - $span.start).TotalMilliseconds
                $ChildDurations = ($span.children | ForEach-Object { $_.ActiveDurationMs } | Measure-Object -Sum).Sum
                $span.ActiveDurationMs = $span.TotalDurationMs - $ChildDurations
            } elseif ($span.index -ne 0) {
                Write-warning "span $($span.id)($($anylog.Attributes.SpanCommand)) has either no start or end log entry"
                $span.start = $null
                $span.end = $null
                $span.TotalDurationMs = 0
                $span.ActiveDurationMs = 0
            } else {
                $span.start = $null
                $span.end = $null
                $span.TotalDurationMs = 0
                $span.ActiveDurationMs = 0
            }
        }

        # $spans
        # $spans.GetEnumerator()|%{[PsCustomObject]$_.value} #|ft Name,TotalDurationMs,ActiveDurationMs -AutoSize


        # #write statistics
        for ($i = 0; $i -lt $spans.Count; $i++) {
            $span = $spans[$i]
            $tab = "  " * $span.index
            $message = $span.name
            $SpanDuration = ""
            if ($span.TotalDurationMs) {
                $SpanDuration = "total:$([math]::round($span.TotalDurationMs))ms, active:$([math]::round($span.ActiveDurationMs))ms"
            }
            $WhitespaceIndex = $highestIndex - $span.index
            if ($span.index -eq 0) {
                $WhitespaceIndex++
            }
            # $NamespaceLength = $LongestName - $span.name.length
            # Write-Verbose "$($span.name):NamespaceLength: $($LongestName - $span.name.length) (Total: $($NamespaceLength + $span.name.length)), WhitespaceIndex: $WhitespaceIndex"

            #even out current name with longes name of span
            $Namespace = " " * $($LongestName - $span.name.length)
            #even out the index space
            $IndexSpace = "  " * ($WhitespaceIndex)
            $whitespace = $Namespace + $IndexSpace

            if ($span.index -ne 0) {
                switch ($span.index) {
                    { $spans[$i + 1].index -eq $_ } { $message = "├──$message" }
                    default { $message = "╰─╮$message" }
                }
            }
            Write-host "$tab$message$whitespace$SpanDuration"
        }
    }
}

# New-Alias 'Get-BoltLastRun' -Value 'Get-OtelLastRun' -Force

# Get-BoltLastRun
# Get-BoltLogLastRun -Statistics -Verbose