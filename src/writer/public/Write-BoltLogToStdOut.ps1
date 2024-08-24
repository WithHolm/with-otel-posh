<#
.SYNOPSIS
Prepares a log object for writing to the console

.DESCRIPTION
Prepares a log object for writing to the console. this mostly handles if i should add extra context and color based on the log level.

.PARAMETER Type
Type of signal. if its a log event or metric

.PARAMETER Timestamp
Parameter description

.PARAMETER Attributes
Parameter description

.PARAMETER Resource
Parameter description

.PARAMETER Body
Parameter description

.PARAMETER SeverityText
Parameter description

.PARAMETER SeverityNumber
Parameter description

.PARAMETER IgnoreDebugLevel
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
function Write-BoltLogToStdOut {
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
    try{
        $PwshSeverity = [PwshSeverity]$SeverityNumber
    }catch{
        $thing = [enum]::GetValues(([OtelSeverity]))|%{
            "$([int]$_) = $($_.ToString())"
        }
        # Write-host $thing
        Throw "Invalid Severity Number $SeverityNumber. available numbers are: $(([enum]::GetValues(([PwshSeverity]))|%{[int]$_}) -join ", ")"
    }
    # Write-Host "$PwshSeverity"
    $colors = @{
        system   = "DarkMagenta"
        trace    = "Fuchsia"
        debug    = "Blue"
        verbose  = "DarkCyan"
        info     = $null
        sucess   = "Green"
        warning  = "Yellow"
        error    = "DarkRed"
        fatal    = "Red"
        throwing = "Red"
    }
    #if current log level is  eq or less than the level i set, write as debug out instead of normal out
    $SetLogLevel = [int](Get-WotelLogLevel)
    $DevInfoLevel = [int]([PwshSeverity]::trace)

    $LogInfo = @(
        $PwshSeverity
    )
    if ($SetLogLevel -le $DevInfoLevel -or $IgnoreDebugLevel) {
        $LogInfo += $Attributes.Source
    }
    else{
        $LogInfo += $Resource
    }
    $params = @{
        Context = "[$($Timestamp.ToString("mm:ss.fff"))] $($LogInfo.foreach{"[$_]"} -join '')"
        Message = "$body"
        TextWrapMessage = $true
    }
    if($colors[$PwshSeverity.ToString()])
    {
        $params.NamedColor = $colors[$PwshSeverity.ToString()]
    }
    Write-BoltConsoleLine @params
}