function Enable-WotelWriterConsoleSetting {
    [CmdletBinding()]
    param (
        [ValidateSet('enable', 'disable')]
        [string]$DisableTextwrap,

        [ValidateSet('enable', 'disable')]
        [string]$DisableAnsi,

        [ValidateSet('enable', 'disable')]
        [string]$UseSeverityShortNames,

        [PwshSeverity]$DevInfoLevel,

        [string]$TimestampFormat
    )
    
    begin {}

    process {
        $Settings = Get-WotelSetting -Key 'writers.console'
        if ($DisableTextwrap) {
            $Settings.disable_textwrap = $DisableTextwrap -eq 'enable'
        }

        if ($DisableAnsi) {
            $Settings.disable_ansi = $DisableAnsi -eq 'enable'
        }

        if ($DevInfoLevel) {
            $Settings.dev_info_level = $DevInfoLevel
        }

        if ($TimestampFormat) {
            #checking is hard.. just use whatever..its just console output and user will see errors in their ways quickly
            $settings.timestamp_format = $TimestampFormat
        }

        if ($UseSeverityShortNames) {
            $settings.use_short_names = $UseSeverityShortNames -eq 'enable'
        }
    }
    
    end {
        
    }
}