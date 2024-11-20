Describe "Measure-ShouldHaveHelp" {
    BeforeDiscovery {
        $TestCases = @(
            @{
                Name = "Function"
                Code = {
                    function test {
                        Write-Host "test"
                    }
                }
                ShouldPass = $false
            },
            @{
                Name = "Function with help inside function"
                Code = {
                    function test {
                        <#
                        .SYNOPSIS
                            test
                        .DESCRIPTION
                            test
                        .EXAMPLE
                            test
                        #>
                        Write-Host "test"
                    }
                }
                ShouldPass = $true
            }
            @{
                Name = "Function with help outside function"
                Code = {
                    <#
                    .SYNOPSIS
                        test
                    .DESCRIPTION
                        test
                    .EXAMPLE
                        test
                    #>
                    function test {
                        Write-Host "test"
                    }
                }
                ShouldPass = $true
            }
            @{
                Name = "Script"
                Code = {
                    $test = "test"
                }
                ShouldPass = $false
            },
            @{
                Name = "Script with help"
                Code = {
                    <#
                    .SYNOPSIS
                        test
                    .DESCRIPTION
                        test
                    .EXAMPLE
                        test
                    #>
                    $test = "test"
                }
                ShouldPass = $true
            }
        )
    }

    it "Should pass if function has help" -TestCases $TestCases {
        param(
            [string]$Name,
            [scriptblock]$Code,
            [bool]$ShouldPass
        )
        $ast = [System.Management.Automation.Language.Parser]::ParseInput($Code, [ref]$null, [ref]$null)
        $result = Measure-ShouldHaveHelp -testAst $ast
        if ($ShouldPass) {
            $result.Count | should -Be 0
        } else {
            $result.Count | should -BeGreaterThan 0
        }
    }

    it "Should detect if script has several functions" {
        $ast = [System.Management.Automation.Language.Parser]::ParseInput({
            function test {
                Write-Host "test"
            }

            <#
            .SYNOPSIS
            Short description
            General notes
            #>
            function test2 {
                Write-Host "test2"
            }

            function test3 {
                Write-Host "test"
            }

        }, [ref]$null, [ref]$null)
        $result = Measure-ShouldHaveHelp -testAst $ast
        $result.Count | should -Be 2
    }


}