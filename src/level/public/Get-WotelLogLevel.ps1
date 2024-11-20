<#
.SYNOPSIS
Get Current log level. defaults to 'info' if not set yet
#>
function Get-WotelLogLevel {
    [CmdletBinding()]
    [OutputType('PwshSeverity')]
    param ()

    $Settings = Get-WotelSetting
    return ([PwshSeverity]$Settings.logLevel)
}