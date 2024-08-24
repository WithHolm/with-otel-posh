function Get-WotelTrace {
    [CmdletBinding()]
    param ()

    New-WotelTrace
    $TraceId = Get-WotelTraceId
    return $global:wotel.$TraceId
}