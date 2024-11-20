Describe "ConvertTo-WotelWriterConsoleWrappedString" {
    InModuleScope With-Otel {
        BeforeAll {
            #mock Get-BoltConsoleWindowSize
            Mock Get-WotelWriterConsoleWindowSize -MockWith {
                if ($env:pester_console_width -eq $null) {
                    $env:pester_console_width = 10
                }
                return [System.Drawing.Rectangle]::new(0, 0, $env:pester_console_width, 10)
            }
        }

        it "Should Not wrap messages that are less than the max length" {
            $param = @{
                Message = "message"
                Context = "context"
            }
            $env:pester_console_width = 20
            $Return = ConvertTo-WotelWriterConsoleWrappedString @param
            # Write-host $Return
            $Return.Count | Should -Be 1
            # it should really retun this, but powershell is smart and converts it to a string if only one item is returned... dammit
            # $return|should -BeOfType [System.Collections.Generic.List[String]]
            $Return | Should -Be "$($param.Context) $($param.Message)"
        }

        it "Should wrap messages that are greater than the max length" {
            $param = @{
                Message = ("pester" * 3)
                Context = "context"
            }

            $env:pester_console_width = 21
            $Return = ConvertTo-WotelWriterConsoleWrappedString @param
            <#
            context pesterpester
                    pester
            #>
            $Return.Count | Should -Be 2
            for ($i = 0; $i -lt $return.Count; $i++) {
                $return[$i].length | Should -BeLessOrEqual $env:pester_console_width -Because "line $i should be shorter than console width"
            }
            $Return[0] | Should -Be "$($param.Context) pesterpester"
            $Return[1] | Should -Be "$(" "*$param.Context.Length) pester"
        } 
    }
}