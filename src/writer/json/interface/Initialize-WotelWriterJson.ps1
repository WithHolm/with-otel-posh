<#
.SYNOPSIS
Initializes the json writer
#>
function Initialize-WotelWriterJson {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param (

    )

    $ret = @{
        log_folder = "$env:TEMP\wotel"
        log_name_date_format = "yy-MM-dd hhmmss"
        Queue = [System.Collections.Queue]::Synchronized((New-Object System.Collections.Queue))
    }
    return $ret
}