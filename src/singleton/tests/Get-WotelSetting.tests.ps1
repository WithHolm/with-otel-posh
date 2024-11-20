Describe "Get-WotelSetting" {
    it "returns a hashtable" {
        Get-WotelSetting|should -BeOfType [hashtable]
    }

    it "will find a setting by key '<name>'" -TestCases @(
        @{ name = 'logLevel' }
        @{ name = 'maxHistory' }
        @{ name = 'enabled_writers' }
        @{ name = 'writers.console' }
        @{ name = 'writers.json' }
    ) {
        param($name)
        $settings = Get-WotelSetting -Key $name
        $settings|should -Not -BeNullOrEmpty
    }

    it "should error when key not found" {
        {Get-WotelSetting -Key 'notfound'}|should -Throw
    }
}