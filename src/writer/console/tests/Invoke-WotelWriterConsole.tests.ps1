Describe "Invoke-WotelWriterConsole" {
    InModuleScope 'With-Otel' {
        BeforeDiscovery{
            $SeverityTests = @(
                @{
                    Name = "Verbose"
                }
            )
        }
        BeforeAll{
            $global:Wotel_disable_writer_output = $false
        }
        BeforeEach {
            Enable-WotelWriter -Writer Console -Ansi disable -Textwrap disable
            # $settings = Get-WotelSetting -Key 'writers.console'
            # $settings.disable_textwrap = $true
            # $settings.disable_ansi = $true
            Mock -CommandName 'Write-host' -MockWith {param($object) $global:output = ($object -join "")}
        }

        it "should write to host with default settings" {
            $Event = [WotelLog]@{
                Type = "log"
                Timestamp = [datetime]::Now
                Attributes = @{
                    Source = "test"
                }
                Resource = "test"
                Body = "test"
                SeverityText = "Verbose"
                SeverityNumber = 1
            }
            Invoke-WotelWriterConsole -EventItem $Event
            # write-warning "$global:output"
            $global:output | Should -BeLike "*$($param.Body)*" #-Contain $param.Body
        }

        # it "should output "


    }
}