<#
.SYNOPSIS
Gets a setting from the singleton

.PARAMETER Key
The key to get the setting from

.EXAMPLE
#gets all settings
$settings = Get-WotelSetting

.EXAMPLE
#gets a single setting
$settings = Get-WotelSetting -Key 'logLevel'
#>
function Get-WotelSetting {
    [CmdletBinding()]
    param (
        [string]$Key
    )
    Write-WotelSelfLog -Body "Getting settings" -Severity info
    $WotelSettings = $(Get-WotelSingleton).settings
    $used = @()

    if ([string]::IsNullOrEmpty($Key)) {
        return $WotelSettings
    }

    $Key.Split(".") | ForEach-Object {
        if (!$WotelSettings.ContainsKey($_)) {
            Write-WotelSelfLog -Body "Setting '$_' not found in $($used -join '.')" -Severity error
            throw "Setting '$_' not found in $($used -join '.')"
        }
        $WotelSettings = $WotelSettings.$_
        $used += $_
    }
    
    Write-WotelSelfLog -Body "Returning settings" -Severity info
    return $WotelSettings
}