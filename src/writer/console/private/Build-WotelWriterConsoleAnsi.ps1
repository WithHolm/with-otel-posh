<#
.SYNOPSIS
Builds ansi settings for the console writer
#>
function Build-WotelWriterConsoleAnsi {
    [CmdletBinding()]
    param (
        $Settings
    )
    #if its already filled, return
    if ($Settings.ansi.count -ne 0) {
        return
    }

    #if ansi is disabled, return with empty strings
    if ($Settings.enable_ansi -eq $false) {
        $Settings.ansi = @{
            Reset   = ""
            boldOn  = ""
            boldOff = ""
        }
        foreach ($key in $Settings.colors.keys) {
            $Settings.ansi[$key] = ""
        }
        return
    }

    #init ansi cache
    $Settings.ansi = @{
        Reset   = Get-WotelAnsiStyle -Reset
        boldOn  = Get-WotelAnsiStyle -Modes Bold
        boldOff = Get-WotelAnsiStyle -Modes BoldOff
    }

    foreach ($key in $Settings.colors.keys) {
        $NamedColor = $Settings.colors[$key]
        if ($NamedColor) {
            $param = @{
                NamedColor = $settings.colors[$key]
                ForOrBackgGround = 'Foreground'
            }
            $Settings.ansi[$key] = Get-WotelAnsiStyle @param
        }
        else {
            $Settings.ansi[$key] = ""
        }
    }
}