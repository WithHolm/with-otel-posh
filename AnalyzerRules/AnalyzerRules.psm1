gci $PSScriptRoot -Filter "*.ps1" -Recurse -File | Where-Object {$_.Directory.Name -in "public","private"}| % {
    Write-host "importing $($_.FullName)"
    . $_
}

# Export-ModuleMember -Function Measure*