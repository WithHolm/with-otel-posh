<#
.SYNOPSIS
returns a list of all ansi colors currently used by the console writer, including example of how it looks
#>
function Show-WotelWriterConsoleColor {
    [CmdletBinding()]
    param ()

    $Reset = Get-WotelAnsiStyle -Reset
    $Settings = Get-WotelSetting -Key "writers.console"
    $Settings.colors.GetEnumerator()|ForEach-Object{
        $ColorAnsi = "default"
        if($_.value){ #if its not null..
            $ColorAnsi = Get-WotelAnsiStyle -NamedColor $_.value -ForOrBackgGround Foreground
        }
        Write-Host "$($_.key): $ColorAnsi$($_.value)$Reset"
    }
}