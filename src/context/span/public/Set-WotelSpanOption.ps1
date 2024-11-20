<#
.SYNOPSIS
Set options for the current span

.PARAMETER OutputToConsole
If set to "Disabled", the span will not be written to the console. This is useful for when you want to preserve log, but not for consumption at runtime

.PARAMETER OutputToLogs
Will output to logs for the span. This is generally the same as totally disabling the logs.

.PARAMETER Callstack
Only set if you need to set the options for a specific span. else, just use the default
#>
function Set-WotelSpanOption {
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Justification = "Does not change system state", Scope = 'function')]
    [CmdletBinding(
        DefaultParameterSetName = "Callstack"
    )]
    param (
        [WotelEnabled]$OutputToConsole,

        [WotelEnabled]$OutputToLogs,

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
            $Span = Get-WotelSpan -Callstack $Callstack
            if (!$Span) {
                $SpanId = Get-WotelSpanId -Callstack $Callstack
                $span = New-WotelSpan -Callstack $Callstack -PassThru
            }
        }
        else{
            $Span = Get-WotelSpan -SpanId $SpanId
        }

        if (!$Span) {
            Throw "SpanId $SpanId does not exist in trace $($TraceObj.id)"
        }

        if (![String]::IsNullOrEmpty($OutputToConsole)) {
            $Span.attributes.OutputToConsole = [bool]$OutputToConsole
        }

        if (![String]::IsNullOrEmpty($OutputToLogs)) {
            $Span.attributes.OutputToLogs = [bool]$OutputToLogs
        }
    }

    end {

    }
}

# Set-WotelSpanOption
# Set-WotelSpanOptions