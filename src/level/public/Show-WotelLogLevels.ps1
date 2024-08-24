function Show-WotelLogLevels {
    [CmdletBinding()]
    param (
        
    )
    
    [enum]::GetValues([PwshSeverity]) | ForEach-Object {
 
        [pscustomobject]@{
            name = $_
            OtelLevel = $_.value__
            active = if(($_ -eq (Get-WotelLogLevel))) {"x"} else {""}
        }
    }
}