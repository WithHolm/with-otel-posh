function Get-WotelWriterConsoleWindowSize {
    [CmdletBinding()]
    [OutputType([System.Management.Automation.Host.Size])]
    param (
        
    )
    # $Width = $Host.UI.RawUI.BufferSize.Width
    # $Height = $Host.UI.RawUI.BufferSize.Height
    return $Host.UI.RawUI.BufferSize
}
