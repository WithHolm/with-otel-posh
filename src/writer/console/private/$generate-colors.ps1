
add-type -AssemblyName System.Drawing

$ColorMembers = ([System.Drawing.Color]).DeclaredMembers|?{$_.propertytype.name -like "color"}

$Output = $ColorMembers|%{
    [System.Drawing.Color]$_.name|select name,r,g,b,a
}

$Output|convertto-json|out-file "$PSScriptRoot/colors.json"

# (([System.Drawing.Color]).DeclaredMembers|?{$_.propertytype.name -like "color"})|%{[System.Drawing.Color]$_.name|select name,r,g,b,a}|convertto-json