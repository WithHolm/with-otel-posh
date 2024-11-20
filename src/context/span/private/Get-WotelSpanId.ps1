<#
.SYNOPSIS
returns id of the current span. first 18 characters is the command name, second 19 is the arguments, they are divided by a semicolon

.EXAMPLE
Get-WotelSpanId -callstack (Get-PSCallStack)
#1b21ba48-6900-185e:1146-ad16f7e8649e

#>
function Get-WotelSpanId {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [parameter(
            ParameterSetName = "Callstack"
        )]
        [System.Management.Automation.CallStackFrame[]]$Callstack = (Get-PSCallStack)
    )
    if($Callstack.Count -eq 0){
        throw "cannot create a span id without a callstack"
    }
    $Span = $Callstack[0]
    $prefix = (New-GuidV5 -Name $Span.Command).ToString()
    $suffix = (New-GuidV5 -Name $Span.Arguments).ToString()
    return "$($prefix.substring(0,18)):$($suffix.substring(19))"
}