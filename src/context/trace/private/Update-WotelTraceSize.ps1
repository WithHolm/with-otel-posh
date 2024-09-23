<#
.SYNOPSIS
removes old logs from the global object

.DESCRIPTION
For Internal usage. Removes old traces from the global object. Uses otels object settings to select how many traces to keep.
#>
function Update-WotelTraceSize {
    [CmdletBinding()]
    param ()


    $Singleton = Get-WotelSingleton

    #plus one for global object
    $TraceKeys = $Singleton.keys | Where-Object { $_ -ne "settings"}

    $RemoveHistoryCount = @($TraceKeys).count - ($Singleton.settings.maxHistory)
    if ($RemoveHistoryCount -le 0) {
        return
    }

    # $TraceKeys = $global:wotel.values | Where-Object { $_.global -ne $true }
    $OldTraces = $TraceKeys | ForEach-Object { $Singleton[$_] } | sort-object -Property createdTime -Descending | select-object -Last $RemoveHistoryCount

    $OldTraces | ForEach-Object {
        $global:wotel.Remove($_.id)
    }
}