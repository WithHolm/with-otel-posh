<#
.SYNOPSIS
Initializes the wotel main object
#>
function Initialize-WotelSingleton {
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidGlobalVars',
        '',
        Justification = "get/set-variable returns value, and not pointer, so i need to reference variable so system references correct object",
        Scope = 'function'
        )]
    [CmdletBinding()]
    param ()
    
    #sync hashtable to have a thread safe singleton
    $Singleton = [hashtable]::Synchronized(@{
        settings = @{}
        traces   = @{}
        self     = @{}
    })
    $Global:Wotel = $Singleton

    $Singleton.settings = Initialize-WotelSetting

    return
}