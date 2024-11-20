<#
.SYNOPSIS
Initializes the settings object
#>
function Initialize-WotelSetting {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param ()

    #init out of hashtable to avoid call depth overflow
    $Writers = @{
        console = $(Initialize-WotelWriterConsole)
        json = $(Initialize-WotelWriterJson)
    }



    $ret = @{
        logLevel = [int][PwshSeverity]::Info
        maxHistory      = 10
        enabled_writers = @(
            "Console"
        )
        writers         = $Writers
    }

    $DefaultLevel = [int]([PwshSeverity]::info)
    if ([String]::IsNullOrEmpty($env:WOTEL_LOG_LEVEL)) {
        $ret.logLevel = $DefaultLevel
    }
    else {
        try{
            $ret.logLevel = [int]([PwshSeverity]$env:WOTEL_LOG_LEVEL)
        }catch{
            Write-Error "Invalid log level '$env:WOTEL_LOG_LEVEL'. should be one of the following: $([PwshSeverity] | ForEach-Object { $_.value__ }). Will be set to 'info' instead"
            $ret.logLevel = $DefaultLevel
        }
    }

    return $ret
}