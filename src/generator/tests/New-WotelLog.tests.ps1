Describe "Write-WotelLog" {
    InModuleScope "With-Otel" {
        It "Creates a log" {
            New-WotelSpan
            $Log = Write-WotelLog -Body "test" -Severity info -SkipConsole
        }
    }
}