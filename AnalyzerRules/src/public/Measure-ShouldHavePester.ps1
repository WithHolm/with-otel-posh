<#
.SYNOPSIS
    Function or script should have help
.DESCRIPTION
    Function or script should have some sort of help functionality, explaining what the function does
.EXAMPLE
.INPUTS
    [System.Management.Automation.Language.StringConstantExpressionAst]
.OUTPUTS
    [Microsoft.Windows.Powershell.ScriptAnalyzer.Generic.DiagnosticRecord[]]
.NOTES
#>
function Measure-ShouldHavePester {
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]])]
    Param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Language.ScriptBlockAst]
        $testAst
    )

    if ([string]::IsNullOrEmpty($testAst.Extent.File)) {
        return
    }

    $Item = Get-Item $testAst.Extent.File
    if ($Item.Extension -ne ".ps1") {
        return
    }

    $PesterLocation = [System.IO.Path]::GetFullPath("$($Item.Directory.FullName)\..\tests\$($Item.BaseName).tests.ps1")

    if ((Test-Path $PesterLocation)) {
        return
    }

    $Out = @{
        Message  = "should have pester tests defined for the function at location '$PesterLocation'."
        RuleName = "PsShouldHavePester"
        Severity = "Error"
    }

    $FuncAst = $testAst.FindAll({
            param($ast)
            $ast -is [System.Management.Automation.Language.FunctionDefinitionAst]
        }, $true)

    #For each found function, check if it has tests for the filename
    $FuncAst | ForEach-Object {
        if (!$_.Name) {
            continue
        }
        $Help = $_.GetHelpContent()
        if (-not $Help) {
            $result = [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]]@{
                Message    = "cmdlet $($_.Name) $($Out.Message)"
                RuleName   = $out.RuleName
                Severity   = $out.Severity
                ScriptPath = $_.Extent.File
                Extent     = $_.Extent
            }
            Write-Output $result
        }
    }

}