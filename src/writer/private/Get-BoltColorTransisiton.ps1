using namespace System.Drawing
function Get-BoltColorTransition {
    [CmdletBinding()]
    param (
        [color]$Start,
        [color]$End,
        [int]$steps = 15
    )
    
    begin {
        
    }
    
    process {
        for ($i = 0; $i -lt $steps; $i++) {
            $r = $start.r + (($end.r - $start.r) / $steps) * $i
            $g = $start.g + (($end.g - $start.g) / $steps) * $i
            $b = $start.b + (($end.b - $start.b) / $steps) * $i
            $a = $start.a + (($end.a - $start.a) / $steps) * $i
            write-output ([color]::FromArgb($a, $r, $g, $b))
        }
    }
    
    end {
        
    }
}