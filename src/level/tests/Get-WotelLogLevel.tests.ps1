Describe "Get-WotelLogLevel" {
    InModuleScope 'bolt.core' {
        BeforeDiscovery {
            $PwshLogLevels = [enum]::GetNames(([PwshSeverity])) | % {
                @{
                    Name = $_
                    Int  = [int]([PwshSeverity]$_)
                    Enum = ([PwshSeverity]$_)
                }
            }
        }
        BeforeAll {
            Set-WotelSpanOptions -OutputToConsole Disabled
        }

        it "should return 'pwshSeverity' enum"{
            (Get-WotelLogLevel) -is [PwshSeverity]| should -Be $true
        }

        it "should return a severity 'info' if no env variable has been defined" {
            $env:OTEL_LOG_LEVEL = $null
            (Get-WotelLogLevel).GetType().name | should -Be ([PwshSeverity]::info).gettype().name
        }

        it "should return severity::info if no env has been defined" {
            $env:OTEL_LOG_LEVEL = $null
            Get-WotelLogLevel | should -Be 'info'
        }

        it "should set env:OTEL_LOG_LEVEL if no env has been defined" {
            $env:OTEL_LOG_LEVEL = $null
            Get-WotelLogLevel | out-null
            $env:OTEL_LOG_LEVEL | should -be ([int]([OtelSeverity]::info))
        }

        it "should return value '<Name>' if int <int> is set as log level" -TestCases $PwshLogLevels {
            param(
                [string]$Name,
                [int]$int,
                [OtelSeverity]$Enum
            )
            $env:OTEL_LOG_LEVEL = $int
            Get-WotelLogLevel | should -be $Enum
        }
    }
}