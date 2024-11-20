<#
.SYNOPSIS
imports the singleton. good for when you run inside runspace or jobs

.EXAMPLE
$Singleton = Get-WotelSingleton

$rsBlock = {
    Import-WotelSingleton -Singleton $using:Singleton
    New-WotelSpan -DisplayName "test"
    ..rest of code
}
[powershell]::Create($rsBlock).Invoke()

#>
function Import-WotelSingleton {
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '', Justification = "get-variable returns value, and not pointer, so i need to reference variable so system references correct object", Scope = 'function')]
    [CmdletBinding()]
    param (
        [hashtable]$Singleton
    )

    if($Singleton -isnot [hashtable]){
        Throw "Singleton is not a hashtable"
    }

    if($Singleton.IsSynchronized -ne $true){
        Throw "Singleton is not synchronized, please use the output from Get-WotelSingleton"
    }

    $Global:Wotel = $Singleton
}