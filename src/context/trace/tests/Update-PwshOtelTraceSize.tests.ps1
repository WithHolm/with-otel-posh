Describe 'Update-WotelTraceSize' {
    BeforeEach {
        $global:wotel = [hashtable]::Synchronized(@{
                global = @{
                    global     = $true
                    maxHistory = 10
                }
            }
        )
        for ($i = 0; $i -lt 20; $i++) {
            $guid = [guid]::NewGuid().ToString()
            $global:wotel.Add($guid, @{
                    options     = @{
                        OutputToConsole = "Enabled"
                        IgnoreLogs      = "Disabled"
                    }
                    name        = "test"
                    arguments   = "test"
                    historyId   = $i
                    createdTime = [datetime]::UtcNow.AddMinutes($i)
                    spans       = [System.Collections.Generic.Dictionary[string, hashtable]]::new()
                    id          = $guid
                }
            )
        }
    }

    AfterAll{
        $global:wotel = $null
    }

    It 'should remove old traces' {
        Update-WotelTraceSize
        $global:wotel.Count | Should -Be ($global:wotel.global.maxHistory + 1)
    }

    It "Should Follow the global max history (test: <maxHistory> returns <count> traces)" -TestCases @(
            @{ maxHistory = 10; Count = 11 }
            @{ maxHistory = 5; Count = 6 }
    ) {
        param ($maxHistory, $Count)
        $global:wotel.global.maxHistory = $maxHistory
        Update-WotelTraceSize
        $global:wotel.Count | Should -Be $Count
    }

    it "Should not remove global trace" {
        Update-WotelTraceSize
        $global:wotel.global | should -Not -BeNullOrEmpty
    }

    it "should not touch new traces" {
        $active = ($global:wotel.values|?{
            $_.global -ne $true
        }|sort-object -Property createdTime -Descending|select-object -first $global:wotel.global.maxHistory).id
        $Active += "global"
        Update-WotelTraceSize
        $global:wotel.values.id | should -BeIn $active
    }
}