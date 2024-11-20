<#
.SYNOPSIS
Set Settings for the json writer

.PARAMETER LogFolder
Log folder to write to. defaults to $env:TEMP\wotel-logs

.EXAMPLE
An example

.NOTES
General notes
#>
function Enable-WotelWriterJsonSetting {
    [CmdletBinding()]
    param (
        [System.IO.DirectoryInfo]$LogFolder = "$env:TEMP\wotel-logs"
    )
    process {
        $Settings = Get-WotelSetting -Key 'writers.json'
        if ($LogFolder) {
            $Settings.log_folder = $LogFolder.FullName
        }
        Start-WotelWriterJsonRunspace
    }
}