<#
.SYNOPSIS
Returns the singleton object
#>
function Get-WotelSingleton {
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidGlobalVars',
        '',
        Justification = "get/set-variable returns value, and not pointer, so i need to reference variable so system references correct object",
        Scope = 'function'
        )]
    [CmdletBinding()]
    [OutputType('System.Collections.Hashtable+SyncHashtable')]
    param ()
    # $W = $Global:Wotel

    if(!$Global:Wotel) {
        Initialize-WotelSingleton
    }

    return $Global:Wotel
}