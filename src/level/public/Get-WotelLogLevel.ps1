function Get-WotelLogLevel {
    [CmdletBinding()]
    [OutputType('PwshSeverity')]
    param ()

    if ([String]::IsNullOrEmpty($env:WOTEL_LOG_LEVEL)) {
        # $settings = Get-WotelSetting
        $env:WOTEL_LOG_LEVEL = [int]([PwshSeverity]::Info)
    }
    return ([PwshSeverity]$env:WOTEL_LOG_LEVEL)
}
# Get-WotelLogLevel