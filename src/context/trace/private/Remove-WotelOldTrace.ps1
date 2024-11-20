<#
.SYNOPSIS
removes old traces from the global object

.DESCRIPTION
For Internal usage. Removes old traces from the global object.
Uses otels object settings to select how many traces to keep.
#>
function Remove-WotelOldTrace {
    [CmdletBinding()]
    param ()
    #plus one for global object
    $Traces = Get-WotelTrace -All

    $Settings = Get-WotelSetting
    $RemoveHistoryCount = @($Traces).count - ($settings.maxHistory)
    if ($RemoveHistoryCount -le 0) {
        return
    }

    # Write-WotelLog -Body "Removing $($RemoveHistoryCount) traces" -Severity info
    $OldTraces = $Traces | select-object -Last $RemoveHistoryCount

    $Singleton = Get-WotelSingleton
    $OldTraces | ForEach-Object {
        $Singleton.traces.Remove($_.id)
    }
}

# Remove-WotelOldTrace