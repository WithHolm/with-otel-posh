function Show-WotelWriterConsoleColors {
    [CmdletBinding()]
    param (
        
    )
    
    $Reset = Get-WotelAnsiStyle -Reset
    $Settings = Get-WotelSetting -Key "writers.console"
    $Settings.colors.GetEnumerator()|%{
        $ColorAnsi = "default"
        if($_.value){ #if its not null..
            $ColorAnsi = Get-WotelAnsiStyle -NamedColor $_.value -ForOrBackgGround Foreground
        }
        Write-Host "$($_.key): $ColorAnsi$($_.value)$Reset"
    }
}