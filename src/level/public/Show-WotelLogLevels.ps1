<#
.SYNOPSIS
Shows a list of all log levels including their otel level and if they are active or not
#>
function Show-WotelLogLevel {
    [CmdletBinding()]
    param ()

    [enum]::GetValues([PwshSeverity]) | ForEach-Object {

        [pscustomobject]@{
            name = $_
            OtelLevel = $_.value__
            active = if(($_ -eq (Get-WotelLogLevel))) {"x"} else {""}
        }
    }
}