<#
.SYNOPSIS
Gets the id of the current trace. this is a idempotent function based on the current call stack. 
It will change for every new invocation on console host
#>
function Get-WotelTraceId {
    [CmdletBinding()]
    [OutputType([string])]
    param ()
    # return (Get-PSCallStack|select -Last 2)[0].InvocationInfo.HistoryId.ToString()
    $Root = (Get-PSCallStack | Select-Object -Last 2)[0]
    return (New-GuidV5 -Name "$($Root.Command) $($Root.Arguments) $($Root.InvocationInfo.HistoryId)").ToString()
}