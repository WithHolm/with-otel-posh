Describe "Test-ShouldRenderLog" {
    #the lower the level the more verbose the output
    It "should return true if set log level is lower than input severity" {
        Set-WotelLogLevel -Severity 10
        Test-WotelShouldRenderLog -LogSeverity 11 | Should -Be $true
    }

    It "should return false if set log level is higher than input severity" {
        Set-WotelLogLevel -Severity 10
        Test-WotelShouldRenderLog -LogSeverity 9 | Should -Be $false
    }
}