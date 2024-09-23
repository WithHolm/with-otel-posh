function Invoke-WotelWriterConsole {
    [CmdletBinding()]
    param (
        [string]$Type,
        [datetime]$Timestamp,
        [hashtable]$Attributes,
        [string]$Resource,
        [string]$Body,
        [string]$SeverityText,
        [int]$SeverityNumber,
        [Switch]$IgnoreDebugLevel
    )
    begin {
        $Settings = Get-WotelSetting -key "writers.console"
        #init colors and ansi stuff if not loaded. adding them here to avoid stack overflow
        if ($Settings.ansi.count -eq 0) {

            #init ansi cache
            $Settings.ansi = @{
                Reset   = Get-WotelAnsiStyle -Reset
                boldOn  = Get-WotelAnsiStyle -Modes Bold
                boldOff = Get-WotelAnsiStyle -Modes BoldOff
            }
        }

        #add color to ansi cache if not already calulated.
        if ([string]::IsNullOrEmpty($settings.ansi[$SeverityText])) {
            $NamedColor = $Settings.colors[$SeverityText]
            if ($NamedColor) {
                $Settings.ansi[$SeverityText] = Get-WotelAnsiStyle -NamedColor $settings.colors[$SeverityText] -ForOrBackgGround 'Foreground'
            } else {
                $Settings.ansi[$SeverityText] = ""
            }
        }
        $ansi = $Settings.ansi
    }
    
    process {
        #if current log level is  eq or less than the level i set, write as debug out instead of normal out
        $CurrentLogLevel = [int](Get-WotelLogLevel)
        $DevInfoLevel = [int]([PwshSeverity]$Settings.dev_info_level)
        

        $Res = $Resource
        if ($CurrentLogLevel -le $DevInfoLevel -or $IgnoreDebugLevel) {
            $sourceSplit = $Attributes.Source.Split(":")
            #checks if the resource is the same as start of source (to avoid "myresource|myresource:123")
            if($sourceSplit[0] -eq $Resource)
            {
                $Res = $Attributes.Source
            }
            else{
                $Res += "|$($Attributes.Source)"
            }
        }

        $sev = $SeverityText
        if ($Settings.use_short_names) {
            $sev = $Settings.short_names[$sev]
        }

        $Out_Timestamp = $Timestamp.ToString($Settings.timestamp_format)
        $Out_Severity = "{0}{1}{2}{3}" -f $ansi[$SeverityText], $ansi.BoldOn, $sev, $ansi.Reset
        $Out_Resource = "{0}{1}{2}" -f $ansi.BoldOn, $Res, $ansi.Reset

        if(!$Settings.disable_textwrap){
            $OutMsg = ConvertTo-WotelWriterConsoleWrappedString -Message $Body -Context "[$Out_Timestamp][$Out_Severity][$Out_Resource]" -Prefix "" -Suffix ""
        }
        else{
            $OutMsg = "[$Out_Timestamp][$Out_Severity][$Out_Resource] $Body"
        }

        #
        if($global:Wotel_disable_writer_output -eq $true){
            return
        }
        Write-host $OutMsg
    }
    
    end {
        
    }
}