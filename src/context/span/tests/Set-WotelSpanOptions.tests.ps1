Describe 'Set-WotelSpanOption' {
    InModuleScope 'With-Otel' {
        BeforeAll {
            Initialize-WotelSingleton
            New-WotelTrace
        }

        Context 'callstack'{
            It 'should set OutputToConsole to <name>' -TestCases @(
                @{
                    name = 'Disabled'
                }
                @{
                    name = 'Enabled'
                }
            ){
                # write-host (Get-WotelSpanId)
                New-WotelSpan


                # Set-WotelSpanOption -OutputToConsole Disabled
                # $Traces.spans.values[0].attributes.optionOutputToConsole | Should -Be $false
            }
        }
    }
}