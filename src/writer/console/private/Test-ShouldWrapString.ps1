<#
.SYNOPSIS
Check if the message should be wrapped
#>
function Test-ShouldWrapString {
    [CmdletBinding()]
    [outputType([bool])]
    param (
        [string]$Message
    )
    $ConsoleWidth = (Get-WotelWriterConsoleWindowSize).Width
    if ($Message.length -gt $ConsoleWidth) {
        return $true
    }
    return $false
}