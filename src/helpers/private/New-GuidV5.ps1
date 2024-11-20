
<#
.SYNOPSIS
Generate a GUID based on a name (V5)

.DESCRIPTION
Generate a GUID based on a name (V5). Uses Md5 to generate the "source". not recommended for security purposes, but good enough for span and trace ids

.PARAMETER Name
The name to generate the GUID from

.EXAMPLE
New-GuidV5 -Name "test"
#>
function New-GuidV5 {
    [CmdletBinding()]
    [OutputType([System.Guid])]
    param (
        [Parameter(Mandatory=$true)]
        # [ValidateCount(0,3)]
        [string]$Name
    )

    # Create a hash value from the name
    $Hash = [System.Security.Cryptography.SHA256]::Create()
    $HashValue = $Hash.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($Name))
    $strbuilder = [System.Text.StringBuilder]::new()
    $hashvalue.ForEach{
        $strbuilder.Append(([byte]$_).ToString("x2")) | Out-Null
    }

    #
    $hash = $strbuilder.ToString()[0..31] -join ""

    # Generate a GUID from the byte array
    return [Guid]::new($hash)
}