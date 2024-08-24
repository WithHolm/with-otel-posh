function Get-WotelSetting {
    [CmdletBinding()]
    param (
        [string]$Key
    )

    $WotelSettings = $(Get-WotelSingleton).settings
    $used = @()
    if([string]::IsNullOrEmpty($Key)){
        return $WotelSettings
    }
    $Key.Split(".")| ForEach-Object {
        if (!$WotelSettings.ContainsKey($_)) {
            throw "Setting '$_' not found in $($used -join '.')"
        }
        $WotelSettings = $WotelSettings.$_
        $used += $_
    }
    return $WotelSettings
}