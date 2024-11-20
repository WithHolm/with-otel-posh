using namespace System.Collections
<#
.SYNOPSIS
Gets a span from the current callstack
#>
function Get-WotelSpan {
    [CmdletBinding(
        DefaultParameterSetName = "Callstack"
    )]
    param (
        [parameter(
            ParameterSetName = "Custom"
        )]
        [ValidateNotNullOrEmpty()]
        [string]$SpanId,

        [parameter(
            ParameterSetName = "Callstack"
        )]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.CallStackFrame[]]$Callstack = (Get-PSCallStack)
    )
    begin {}
    process {
        if([string]::IsNullOrEmpty($SpanId)){
            $SpanId = Get-WotelSpanId -Callstack $Callstack
        }
        $Singleton = Get-WotelSingleton

        $TraceId = Get-WotelTraceId -Callstack $Callstack

        if(!$Singleton.traces.ContainsKey($TraceId)){
            Write-WotelSelfLog "TraceId '$TraceId' not found" -Severity debug
            return $null
        }

        $spans = $Singleton.traces[$TraceId].spans
        $SpanIds = @($spans.keys)
        if($spans.count -eq 0){
            Write-WotelSelfLog "No spans found in trace '$TraceId'" -Severity debug
            return $null
        }
        #about linq: https://www.red-gate.com/simple-talk/development/dotnet-development/high-performance-powershell-linq/
        #match whole string
        # [Func[DictionaryEntry,bool]] $WholeDelegate = { param([DictionaryEntry]$s); return $s.Key -eq $SpanId}
        # #match prefix (just the command name).. is .split faster than substring?
        # [Func[DictionaryEntry,bool]] $PrefixDelegate = { param([DictionaryEntry]$s); return $s.Key.substring(0,18) -eq $SpanId.substring(0,18)}

        # $WholeResult = [Linq.Enumerable]::Where($spans, $WholeDelegate)
        $WholeResult = $SpanIds.Where{$_ -eq $SpanId}
        if($WholeResult){
            # $WholeResult = $WholeResult.value
            Write-WotelSelfLog "Found span using full id $($WholeResult)" -Severity debug
            return $spans.$WholeResult
        }

        # $PrefixResult = [Linq.Enumerable]::Where($Spans, $PrefixDelegate)
        $PrefixResult = $SpanIds.Where{$_.split(":")[0] -eq $SpanId.split(":")[0]}
        if($PrefixResult){
            # $PrefixResult = $PrefixResult.value
            if($PrefixResult.Count -gt 1){
                $PrefixResult = $PrefixResult[0]
                Write-WotelSelfLog "Found multiple spans using prefix, using first ($($PrefixResult))" -Severity debug
            }
            return $spans[$PrefixResult]
        }

        Write-WotelSelfLog "SpanId '$SpanId' not found" -Severity debug
        return $null
    }
    end {}
}