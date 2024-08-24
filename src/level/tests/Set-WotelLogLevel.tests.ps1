Describe "Set-WotelLogLevel" {
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
        it "Should be able to increase the log level" {
            $env:OTEL_LOG_LEVEL = ([int]([PwshSeverity]::trace))
            { Set-WotelLogLevel -Severity info } | should -not -Throw
            $env:OTEL_LOG_LEVEL | should -be ([int]([PwshSeverity]::info))
        }

        it "Should set env:OTEL_LOG_LEVEL to <int> when level '<name>' is defined" -TestCases  $PwshLogLevels {
            param(
                [string]$Name,
                [int]$int,
                [PwshSeverity]$Enum
            )
            Set-WotelLogLevel -Severity $Name -Verbose:$false -Debug:$false -WarningAction SilentlyContinue
            $env:OTEL_LOG_LEVEL | should -be $int
        }

        it "Should be overidden by <Name> level if $<var> is '<value>' and its lower than the current log level" -TestCases @(
            @{
                Name  = "verbose"
                Value = $true
                var   = "VerbosePreference"
                key   = "verbose"
            },
            @{
                Name  = "debug"
                Value = $true
                var   = "DebugPreference"
                key   = "debug"
            },
            @{
                Name  = "warning"
                Value = "Continue"
                var   = "WarningPreference"
                key   = "WarningAction"
            }
        ) {
            param(
                $name,
                $value,
                $var,
                $key
            )
            $param = @{
                verbose       = $false
                debug         = $false
                warningAction = "SilentlyContinue"
            }
            $param.$key = $value
            $severity = [PwshSeverity]$name

            Set-WotelLogLevel -Severity throwing @param
            $env:OTEL_LOG_LEVEL | should -be ([int]($severity))
        }
    }
}