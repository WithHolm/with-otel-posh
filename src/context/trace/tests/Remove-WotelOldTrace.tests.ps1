Describe 'Remove-WotelOldTrace' {
    inModuleScope "with-otel" {
        BeforeEach {
            Initialize-WotelSingleton
            $Singleton = Get-WotelSingleton

            for ($i = 0; $i -lt 20; $i++) {
                $guid = [guid]::NewGuid().ToString()
                $Singleton.traces.Add($guid, [WotelTrace]@{
                        name        = "test"
                        arguments   = "test"
                        historyId   = $i
                        createdTime = [datetime]::UtcNow.AddMinutes($i)
                        id          = $guid
                    }
                )
            }
        }

        AfterAll {
            Initialize-WotelSingleton
        }

        It 'should remove old traces' {
            Get-WotelTrace -All | should -not -BeNullOrEmpty
            Remove-WotelOldTrace
            $Traces = Get-WotelTrace -All
            $Settings = Get-WotelSetting
            $Traces.Count | Should -Be ($Settings.maxHistory)
        }

        It "Should Follow the global max history (test: <maxHistory> returns <count> traces)" -TestCases @(
            @{ maxHistory = 10; Count = 10 }
            @{ maxHistory = 5; Count = 5 }
        ) {
            param ($maxHistory, $Count)
            $settings = Get-WotelSetting
            $settings.maxHistory = $maxHistory
            Remove-WotelOldTrace
            $(Get-WotelTrace -all).Count | Should -Be $Count
        }

        it "should not touch new traces" {
            $Settings = Get-WotelSetting
            $active = (Get-WotelTrace -All | select-object -first $Settings.maxHistory).id
            Remove-WotelOldTrace
            $traces = Get-WotelTrace -All
            $traces.id | % {
                $_ | should -BeIn $active
            }
        }
    }
}