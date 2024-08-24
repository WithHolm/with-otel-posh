function Write-WotelDebug {
    [CmdletBinding()]
    param (
        [parameter(
            Mandatory,
            ValueFromPipeline,
            Position = 0
        )]
        [Alias("msg")]
        [String]$Message
    )
    begin {}
    process {
        Write-Wotel -Severity debug -message $message -Callstack (Get-PSCallStack|Select-Object -Skip 1)
    }
    end {}
}

# Set-Alias 'Write-Debug' -Value "Write-WotelDebug"