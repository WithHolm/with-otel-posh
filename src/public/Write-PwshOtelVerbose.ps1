function Write-WotelVerbose {
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
        Write-Wotel -Severity verbose -message $message -Callstack (Get-PSCallStack|Select-Object -Skip 1)
    }
    end {}
}

# Set-Alias -Name 'Write-verbose' -Value 'Write-WotelVerbose' -Scope script