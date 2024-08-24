function Initialize-WotelSetting {
    [CmdletBinding()]
    param ()

    #init out of hashtable to avoid call depth overflow
    $Writers = @{
        console = $(Initialize-WotelWriterConsole)
    }

    #handle log level
    $DefaultLevel = [int]([PwshSeverity]::info)
    if(![string]::IsNullOrEmpty($env:OTEL_LOG_LEVEL)){
        #check if int
        $result = [int]::MaxValue
        if([int]::TryParse($env:OTEL_LOG_LEVEL, [ref]$result)){
            $env:OTEL_LOG_LEVEL = $result
            $ret.logLevel = $result
        }
        else{
            Write-Warning "Invalid log level $env:OTEL_LOG_LEVEL. Using default log level $([PwshSeverity]::info)"
            $env:OTEL_LOG_LEVEL = [int]([PwshSeverity]::info)
        }

        #check if valid int level, and pick the closest one upwards'
        
    }

    $ret = @{
        logLevel        = $env:OTEL_LOG_LEVEL
        maxHistory      = 10
        enabled_writers = @(
            "console"
        )
        writers         = $Writers
    }
    return $ret
}