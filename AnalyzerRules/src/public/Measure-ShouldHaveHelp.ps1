
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
#TODO: add exception for cmdlet in classes
#>
function Measure-ShouldHaveHelp {
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]])]
    Param
    (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.Language.ScriptBlockAst]
        $testAst
    )

    if ($testAst.Extent.File -like "*.psm1") {
        return
    }

    # if($testAst.Extent )

    $Out = @{
        Message  = "should have help defined at the top of the script. at minimum a description of what the script does"
        RuleName = "PsShouldHaveHelp"
        Severity = "Warning"
    }
    # $FoundAst = @()

    if ($testAst.Extent.File -like "*.psm1") {
        return
    }

    #check if script has contains functions
    $FuncAst = $testAst.FindAll({
            param($ast)
            $ast -is [System.Management.Automation.Language.FunctionDefinitionAst]
        }, $true)

    #For each found function, check if it has help
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