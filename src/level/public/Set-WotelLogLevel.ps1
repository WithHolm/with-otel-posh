<#
.SYNOPSIS


.DESCRIPTION
Set the active log level for you current session.
this will work for items below debug aswell
This will also read your $VerbosePreference, $debugPreference, and $WarningPreference when set to continue and use the lowest available log level.
if you set it to 'info', but $verbosePreference is set to continue, it will use the verbose log level.

.PARAMETER Severity
severity log level to set to.

.EXAMPLE
Set-WotelLogLevel -Severity debug
#>
function Set-WotelLogLevel {
    [CmdletBinding()]
    param (
        [PwshSeverity]$Severity
    )
    $spanParam = @{
        SpanId = 'LogLevel'
    }
    New-WotelSpan @spanParam -DisplayName 'wotel.loglevel' -Arguments "{}"


    # Write-Wotel -CmdEvent Begin
    $SetSeverity = [int]$Severity
    Write-WotelLog -Body "Input Loglevel is $severity ($SetSeverity)" -Severity system @spanParam
    $VerbSeverity = [int]([PwshSeverity]::verbose)
    $DebugSeverity = [int]([PwshSeverity]::debug)
    $WarnSeverity = [int]([PwshSeverity]::warning)

    #if the severity of verbose is less than the currently set level AND its not set in a "be quiet mode"
    #use that instead of the provided severity. lower number is more shown logs
    if($VerbosePreference -eq "continue" -and $VerbSeverity -lt $SetSeverity)
    {
        Write-WotelLog -Body "Verbose preference enabled. using this log level ($VerbSeverity)" -Severity system  @spanParam
        $SetSeverity = [math]::min($VerbSeverity, $SetSeverity)
    }

    if ($DebugPreference -eq "continue" -and $DebugSeverity -lt $SetSeverity) {
        Write-WotelLog -Body "Debug preference enabled. using this log level ($DebugSeverity)" -Severity system @spanParam
        $SetSeverity = [math]::min($DebugSeverity, $SetSeverity)
    }

    if ($WarningPreference -eq "continue" -and $WarnSeverity -lt $SetSeverity) {
        Write-WotelLog -Body "Warning preference enabled. using this log level ($WarnSeverity)" -Severity system @spanParam
        $SetSeverity = [math]::min($WarnSeverity, $SetSeverity)
    }

    Write-WotelLog -Body "Setting log level to $SetSeverity" -Severity system @spanParam
    $env:WOTEL_LOG_LEVEL = $SetSeverity
    $settings = Get-WotelSetting
    $settings.loglevel = $SetSeverity
}

