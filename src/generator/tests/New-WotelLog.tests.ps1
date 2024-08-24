Describe "New-WotelLog" {
    InModuleScope bolt.core {
        It "Creates a log" {
            $global:wotel = $null
            New-WotelSpan
            $Log = New-WotelLog -Body "test" -Severity info -SkipConsole
        }
    }
}