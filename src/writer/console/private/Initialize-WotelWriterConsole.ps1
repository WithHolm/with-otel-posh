function Initialize-WotelWriterConsole {
    [CmdletBinding()]
    param (
        
    )
    

    $ret = @{
        disable_textwrap = $false
        disable_ansi     = Test-WotelWriterConsoleAnsiSupported
        dev_info_level   = [int]([PwshSeverity]::trace)
        use_short_names  = $true
        loglevel         = Get-WotelLogLevel
        #todo: validate this
        timestamp_format = "hh:mm:ss.ff"
        colors           = @{
            system   = "DarkMagenta"
            trace    = "Fuchsia"
            debug    = "Blue"
            verbose  = "DarkCyan"
            info     = $null #uses system default color
            success  = "Green"
            warning  = "Yellow"
            error    = "Crimson"
            fatal    = "Red"
            throwing = "DarkRed"
        }
        #try to use 4-letter names so console log is cleaner
        short_names      = @{
            system   = "syst"
            trace    = "trce"
            debug    = "dbug"
            verbose  = "verb"
            info     = "info"
            success  = "succ"
            warning  = "warn"
            error    = "erro"
            fatal    = "fatl"
            throwing = "thrw"
        }

        #ansi cache.. this is loaded when the console writer is used
        #faster init and then faster to use cached colors when writing to console as color lookup is "slow" (couple ms each time)
        ansi             = @{}
    }

    return $ret
}