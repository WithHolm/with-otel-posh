<#
.SYNOPSIS
removes old logs from the global object

.DESCRIPTION
For Internal usage. Removes old traces from the global object. Uses otels object settings to select how many traces to keep.
#>
function Update-WotelTraceSize {
    [CmdletBinding()]
    param ()

    if(!$global:wotel)
    {
        return
    }

    #plus one for global object
    $RemoveHistoryCount = @($global:wotel.Keys|?{$_ -ne 'global'}).count - ($global:wotel.global.maxHistory)
    if ($RemoveHistoryCount -le 0) {
        return
    }

    $Traces = $global:wotel.values|Where-Object{$_.global -ne $true}
    $OldTraces = $Traces|sort-object -Property createdTime -Descending|select-object -Last $RemoveHistoryCount

    $OldTraces|ForEach-Object{
        $global:wotel.Remove($_.id)
    }
}