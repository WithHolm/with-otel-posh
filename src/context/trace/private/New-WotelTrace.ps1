<#
.SYNOPSIS
Adds a trace context for the current running script. this will contain all the spans and events for the current script
#>
function New-WotelTrace {
    [CmdletBinding()]
    param ()
    begin {
        if (!$global:wotel) {
            $hashtable = @{
                global = @{
                    global     = $true
                    maxHistory = 10
                }
            }
            $global:wotel = [hashtable]::Synchronized($hashtable)
        }
    }
    process {
        #weird select and first of array,because i need the next last item in stack, but sometimes the stack contains one
        $Root = (Get-PSCallStack | Select-Object -Last 2)[0]

        $traceId = Get-WotelTraceId

        if (!$global:wotel.ContainsKey($TraceId)) {
            $global:wotel.Add($TraceId, @{
                    options     = @{
                        OutputToConsole = "Enabled"
                        IgnoreLogs      = "Disabled"
                    }
                    name        = $Root.Command
                    arguments   = $Root.Arguments
                    historyId   = $Root.InvocationInfo.HistoryId
                    createdTime = [datetime]::UtcNow
                    spans       = [System.Collections.Generic.Dictionary[string, hashtable]]::new()
                    id          = $TraceId
                }
            )
        }
        
        #remove old traces
        Update-WotelTraceSize
    }
}