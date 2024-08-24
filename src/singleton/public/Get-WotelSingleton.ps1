function Get-WotelSingleton {
    [CmdletBinding()]
    param (
        [switch]$Reset
    )
    if(!$Global:Wotel -or $Reset) {
        #init out of hashtable to avoid stack overload in pwsh engine
        $settings = Initialize-WotelSetting

        $Global:Wotel = @{
            settings = $settings
        }
    }

    return $Global:Wotel
}