function Invoke-WotelWriter {
    [CmdletBinding()]
    param (
        [hashtable]$EventItem,
        [hashtable]$SpanItem,
        [Hashtable]$TraceItem
    )
    
    $IgnoreLogs = "disabled" -in $SpanItem.options.IgnoreLogs , $TraceItem.options.IgnoreLogs
    $IgnoreConsole = "Disabled" -in $TraceItem.options.OutputToConsole, $SpanItem.options.OutputToConsole

    try {
        $PwshSeverity = [PwshSeverity]$EventItem.SeverityNumber
    } catch {
        Throw "Invalid Severity Number $SeverityNumber. available numbers are: $(([enum]::GetValues(([PwshSeverity]))|%{[int]$_}) -join ", ")"
    }

    switch (Get-WotelSetting -Key 'enabled_writers') {
        'console' {
            $LoglevelHighEnough = $EventItem.SeverityNumber -ge [int](Get-WotelLogLevel)
            if (!$IgnoreConsole -and $LoglevelHighEnough) {
                Invoke-WotelWriterConsole @EventItem 
            }
        }
        'json'{
            if(!$IgnoreLogs){
                Invoke-WotelWriterJson @EventItem -TraceId $TraceItem.id -SpanId $SpanItem.id
            }
        }
    }
}