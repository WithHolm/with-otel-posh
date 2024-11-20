<#
.SYNOPSIS
Test if the console supports ansi. returns true if it does, false if it doesn't
#>
function Test-WotelWriterConsoleAnsiSupported {
    [CmdletBinding()]
    [OutputType([bool])]
    param (

    )

    if ($host.PrivateData.ToString() -eq 'Microsoft.PowerShell.Host.ISE.ISEOptions') {
       return $false
    }

    if(![string]::IsNullOrEmpty($env:WOTEL_WRITER_CONSOLE_DISABLE_ANSI)){
       return $false
    }

    #borrowed from ecsousa/PSColors. really nice check
    $oldPos = $host.UI.RawUI.CursorPosition.X
    Write-Host -NoNewline "$([char](27))[0m" -ForegroundColor ($host.UI.RawUI.BackgroundColor);
    $pos = $host.UI.RawUI.CursorPosition.X

    if ($pos -eq $oldPos) {
        return $true;
    }
    else {
        # If ANSI is not supported, let's clean up ugly ANSI escapes
        Write-Host -NoNewLine ("`b" * 4)
        return $false
    }

   #  #TODO: add checks for GH and pipeline and check if console supports ansi

    return $true
}

Test-WotelWriterConsoleAnsiSupported