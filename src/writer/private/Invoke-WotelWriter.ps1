<#
.SYNOPSIS
Handles what writers to use

.DESCRIPTION
Handles what writers to use. Depending on the settings, it will use the console or json writer

.PARAMETER Event
Event Item to write

.PARAMETER Span
Span Item to use. contains options on if to write to console or json

.PARAMETER Trace
Trace Item to use. contains options on if to write to console or json

.NOTES
General notes
#>
function Invoke-WotelWriter {
    [CmdletBinding()]
    param (
        [WotelEvent]$EventItem,
        [WotelSpan]$Span,
        [WotelTrace]$Trace
    )

    $OutputToLogs = $false -notin $Span.attributes.outputToLogs,$Trace.attributes.OutputToLogs
    $OutputToConsole = $false -notin $Span.attributes.outputToConsole, $Trace.attributes.OutputToConsole

    try {
        $null = [PwshSeverity]$EventItem.SeverityNumber
    } catch {
        Throw "Invalid Severity Number $SeverityNumber. available numbers are: $(([enum]::GetValues(([PwshSeverity]))|ForEach-Object{[int]$_}) -join ", ")"
    }

    switch (Get-WotelSetting -Key 'enabled_writers') {
        'console' {
            $LoglevelHighEnough = $EventItem.SeverityNumber -ge [int](Get-WotelLogLevel)
            if ($OutputToConsole -and $LoglevelHighEnough) {
                Invoke-WotelWriterConsole -EventItem $EventItem
            }
        }
        'json'{
            if($OutputToLogs){
                Invoke-WotelWriterJson @EventItem -TraceId $Trace.id -SpanId $Span.id
            }
        }
    }
}