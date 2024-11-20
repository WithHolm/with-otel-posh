<#
.SYNOPSIS
return the size of the console window.
#>
function Get-WotelWriterConsoleWindowSize {
    [CmdletBinding()]
    [OutputType([System.Management.Automation.Host.Size])]
    param (

    )
    return $Host.UI.RawUI.BufferSize
}
