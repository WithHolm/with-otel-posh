<#
.SYNOPSIS
Set settings for the console writer

.PARAMETER DisableTextwrap


.PARAMETER DisableAnsi
Parameter description

.PARAMETER UseSeverityShortNames
Parameter description

.PARAMETER DevInfoLevel
Parameter description

.PARAMETER TimestampFormat
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function Enable-WotelWriterConsoleSetting {
    [CmdletBinding()]
    param (
        [ValidateSet('enable', 'disable')]
        [string]$Textwrap,

        [ValidateSet('enable', 'disable')]
        [string]$Ansi,

        [ValidateSet('classic', 'modern')]
        [string]$Style,

        [ValidateSet('enable', 'disable')]
        [string]$UseSeverityShortNames,

        [PwshSeverity]$DevInfoLevel,

        [string]$TimestampFormat
    )

    begin {}

    process {
        $Settings = Get-WotelSetting -Key 'writers.console'
        if ($Textwrap) {
            Write-WotelSelfLog "Setting textwrap to $Textwrap" -Severity debug
            $Settings.enable_textwrap = $Textwrap -eq 'enable'
        }

        if ($Ansi) {
            Write-WotelSelfLog "Setting ansi to $Ansi" -Severity debug
            $Settings.enable_ansi = $Ansi -eq 'enable'
        }

        if ($Style) {
            Write-WotelSelfLog "Setting style to $Style" -Severity debug
            $Settings.style = $Style
        }

        if ($DevInfoLevel) {
            Write-WotelSelfLog "Setting dev_info_level to $DevInfoLevel" -Severity debug
            $Settings.dev_info_level = $DevInfoLevel
        }

        if ($TimestampFormat) {
            Write-WotelSelfLog "Setting timestamp_format to $TimestampFormat" -Severity debug
            #checking is hard.. just use whatever..its just console output and user will see errors in their ways quickly
            $settings.timestamp_format = $TimestampFormat
        }

        if ($UseSeverityShortNames) {
            Write-WotelSelfLog "Setting use_short_names to $UseSeverityShortNames" -Severity debug
            $settings.use_short_names = $UseSeverityShortNames -eq 'enable'
        }
    }

    end {

    }
}