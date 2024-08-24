function Get-WotelSpanId {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [parameter(
            ParameterSetName = "Callstack"
        )]
        [System.Management.Automation.CallStackFrame[]]$Callstack = (Get-PSCallStack)
    )

    $SpanCall = $Callstack[0]
    $GuidName = "$($SpanCall.Command) $($SpanCall.Arguments) $($SpanCall.InvocationInfo.HistoryId)"
    $TraceGuid = New-GuidV5 -Name $GuidName
    return $TraceGuid.ToString()
}