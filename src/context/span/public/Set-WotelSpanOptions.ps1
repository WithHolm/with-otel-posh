function Set-WotelSpanOptions {
    [CmdletBinding(
        DefaultParameterSetName = "Callstack"
    )]
    param (
        [ValidateSet("Enabled", "Disabled")]
        [string]$OutputToConsole,

        [parameter(
            ParameterSetName = "Custom",
            Mandatory
        )]
        [string]$SpanId,

        [parameter(
            ParameterSetName = "Callstack"
            # Mandatory
        )]
        [ValidateNotNullOrEmpty()]
        # the default value
        [System.Management.Automation.CallStackFrame[]]$Callstack = (Get-PSCallStack)
    )
    
    begin {
        
    }
    
    process {
        $TraceObj = Get-WotelTrace
        if ($PSCmdlet.ParameterSetName -eq "Callstack") {
            $SpanId = $Callstack[0].InvocationInfo.HistoryId.ToString()
        }

        if(!$TraceObj.spans.ContainsKey($SpanId)){
            Throw "span with id $SpanId not found in trace"
        }

        if(![String]::IsNullOrEmpty($OutputToConsole)){
            $TraceObj.spans[$SpanId].options.OutputToConsole = $OutputToConsole
        }
    }
    
    end {
        
    }
}

# Set-WotelSpanOptions