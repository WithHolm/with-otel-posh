function Enable-WotelWriterConsoleSettings {
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

            # try {
            #     $dts = [Datetime]::Now.ToString($TimestampFormat)
            #     $null = [datetime]::ParseExact($dts, $TimestampFormat, [System.Globalization.CultureInfo]::InvariantCulture)
            # } catch {
            #     throw "Invalid timestamp format: $TimestampFormat"
            # }

            # $out = [datetime]::new(0)
            # $culture = [System.Globalization.CultureInfo]::InvariantCulture
            # if (!([datetime]::TryParseExact("01/01/1970", $TimestampFormat, $culture, [System.Globalization.DateTimeStyles]::None, [ref]$out))) {
            # }
            # $settings.timestamp_format = $TimestampFormat

            # try{
            #     $null = [datetime]::now.ToString($TimestampFormat)
            # }
            # catch{
            #     Throw "Invalid timestamp format: $TimestampFormat"
            # }

            
        }

        if ($UseSeverityShortNames) {
            $settings.use_short_names = $UseSeverityShortNames -eq 'enable'
        }
    }
    
    end {
        
    }
}