Describe "Get-WotelLogLevel" {
    InModuleScope 'With-Otel' {
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
            Set-WotelSpanOption -OutputToConsole Disabled
        }

        it "should return 'pwshSeverity' enum"{
            (Get-WotelLogLevel) -is [PwshSeverity]| should -Be $true
        }

        it "should return a severity 'info' if no env variable has been defined" {
            $env:WOTEL_LOG_LEVEL = $null
            Initialize-WotelSingleton
            (Get-WotelLogLevel).GetType().name | should -Be ([PwshSeverity]::info).gettype().name
        }

        it "should return severity::info if no env has been defined" {
            $env:WOTEL_LOG_LEVEL = $null
            Initialize-WotelSingleton
            Get-WotelLogLevel | should -Be 'info'
        }

        it "should return value '<Name>' if int <int> is set as log level" -TestCases $PwshLogLevels {
            param(
                [string]$Name,
                [int]$int,
                [OtelSeverity]$Enum
            )
            $env:WOTEL_LOG_LEVEL = $int
            Initialize-WotelSingleton
            Get-WotelLogLevel | should -be $Enum
        }
    }
}