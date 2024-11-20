<#
.SYNOPSIS
Writes a log to the console
#>
function Invoke-WotelWriterConsole {
    [CmdletBinding()]
    param (
        [WotelLog]$EventItem,
        [Switch]$IgnoreDebugLevel
    )
    begin {
        $Settings = Get-WotelSetting -key "writers.console"
        $CurrentLogLevel = [int](Get-WotelLogLevel)
        $DevInfoLevel = [int]([PwshSeverity]$Settings.dev_info_level)

        #init colors and ansi stuff if not loaded
        #adding them here to avoid stack overflow when initializing
        Start-WotelSelfMetricStopwatch -Name 'console-ansi-init' -Append
        Build-WotelWriterConsoleAnsi -Settings $Settings
        Stop-WotelSelfMetricStopwatch -Name 'console-ansi-init'

        $ansi = $Settings.ansi
        $Body = $EventItem.body
        $SeverityText = $EventItem.SeverityText
        $SeverityNumber = $EventItem.SeverityNumber
        $Resource = $EventItem.Resource
        $Timestamp = $EventItem.Timestamp
        $Attributes = $EventItem.Attributes
    }

    process {
        Start-WotelSelfMetricStopwatch -Name 'console-param-creation' -Append
        #if current log level is  eq or less than the level i set, write as debug out instead of normal out
        switch ($settings.style) {
            "classic" {
                #if debug or lower, write debug color
                if($SeverityNumber -le [int]([PwshSeverity]::debug)){
                    $Outparams  = @{
                        Object = "DBUG: $Body"
                        ForegroundColor = $Host.PrivateData.DebugForegroundColor
                    }
                    break
                }elseif($SeverityNumber -eq [int]([PwshSeverity]::verbose)){
                    $Outparams  = @{
                        Object = "VERB: $Body"
                        ForegroundColor = $Host.PrivateData.VerboseForegroundColor
                    }
                    break
                }elseif($SeverityNumber -in @([int]([PwshSeverity]::info), [int]([PwshSeverity]::success))){
                    $Outparams  = @{
                        Object = "$Body"
                    }
                    break
                }elseif($SeverityNumber -eq [int]([PwshSeverity]::warning)){
                    $Outparams  = @{
                        Object = "WARN: $Body"
                        ForegroundColor = $Host.PrivateData.WarningForegroundColor
                    }
                    break
                }
                $Outparams  = @{
                    Object = "ERRO: $Body"
                    ForegroundColor = $Host.PrivateData.ErrorForegroundColor
                }
            }
            "modern" {
                $Res = $Resource
                if ($CurrentLogLevel -le $DevInfoLevel -or $IgnoreDebugLevel) {
                    $sourceSplit = $Attributes.Source.Split(":")
                    #checks if the resource is the same as start of source (to avoid "myresource|myresource:123")
                    if ($sourceSplit[0] -eq $Resource) {
                        $Res = $Attributes.Source
                    }
                    else {
                        $Res += "|$($Attributes.Source)"
                    }
                }

                $sev = $SeverityText
                if ($Settings.use_short_names) {
                    $sev = $Settings.short_names[$SeverityText]
                }

                $Out_Timestamp = $Timestamp.ToString($Settings.timestamp_format)
                $Out_Severity = "{0}{1}{2}{3}" -f $ansi[$SeverityText], $ansi.BoldOn, $sev, $ansi.Reset
                $Out_Resource = "{0}{1}{2}" -f $ansi.BoldOn, $Res, $ansi.Reset

                $ContextWoAnsi = "[$Out_Timestamp][$sev][$Res]"
                $Context = "[$Out_Timestamp][$Out_Severity][$Out_Resource]"
                $OutMsg = "$Context $Body"

                if ($Settings.enable_textwrap -and (Test-ShouldWrapString -Message $Body)) {
                    $OutMsg = ConvertTo-WotelWriterConsoleWrappedString -Message $Body -Context $Context -ContextLength $ContextWoAnsi.Length
                }
                $Outparams = @{
                    Object = $OutMsg
                }
            }
        }
        Stop-WotelSelfMetricStopwatch -Name 'console-param-creation'

        Start-WotelSelfMetricStopwatch -Name 'console-write' -Append
        Write-Host @Outparams
        Stop-WotelSelfMetricStopwatch -Name 'console-write'
    }

    end {

    }
}