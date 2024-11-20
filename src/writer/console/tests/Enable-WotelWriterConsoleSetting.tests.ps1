Describe "Enable-WotelWriterConsoleSettings" {
    InModuleScope 'With-Otel' {
        BeforeEach {
            Initialize-WotelSingleton
            $settings = Get-WotelSetting -Key 'writers.console'
            Mock Write-host {$env:output}
        }
        context "-DisableTextwrap" {
            it "should set Textwrap to <bool> on value '<str>'" -TestCases @(
                @{
                    "bool" = $true
                    "str"  = "enable"
                }
                @{
                    "bool" = $false
                    "str"  = "disable"
                }
            ) {
                param ($bool, $str)
                # $settings = Get-WotelSetting -Key 'writers.console'
                Enable-WotelWriterConsoleSetting -Textwrap $str
                $settings.enable_textwrap | Should -Be $bool
            }
        }

        Context "-DisableAnsi" {
            it "should set disable_ansi to <bool> on value '<str>'" -TestCases @(
                @{
                    "bool" = $true
                    "str"  = "enable"
                }
                @{
                    "bool" = $false
                    "str"  = "disable"
                }
            ) {
                param ($bool, $str)
                # $settings = Get-WotelSetting -Key 'writers.console'
                Enable-WotelWriterConsoleSetting -Ansi $str
                $settings.enable_ansi | Should -Be $bool
            }
        }

        Context "-UseSeverityShortNames" {
            it "should set use_short_names to <bool> on value '<str>'" -TestCases @(
                @{
                    "bool" = $true
                    "str"  = "enable"
                }
                @{
                    "bool" = $false
                    "str"  = "disable"
                }
            ) {
                param ($bool, $str)
                # $settings = Get-WotelSetting -Key 'writers.console'
                Enable-WotelWriterConsoleSetting -UseSeverityShortNames $str
                $settings.use_short_names | Should -Be $bool
            }
        }

        Context "-DevInfoLevel" {
            BeforeDiscovery {
                $DevInfoTestCases = [enum]::GetNames(([PwshSeverity]))|%{
                    @{
                        str = $_
                    }
                }
            }

            it "should not be touched if value is not provided" {
                $settings = Get-WotelSetting -Key 'writers.console'
                $settings.dev_info_level = [PwshSeverity]::debug
                Enable-WotelWriterConsoleSetting
                $settings.dev_info_level.ToString() | Should -Be 'debug'
            }
            
            it "should set dev_info_level to <str>" -TestCases $DevInfoTestCases {
                param ($str)
                $settings = Get-WotelSetting -Key 'writers.console'
                Enable-WotelWriterConsoleSetting -DevInfoLevel $str
                $settings.dev_info_level.ToString() | Should -Be $str
            }
        }

        Context "-TimestampFormat" {
            it "should set timestamp_format to <str> on value '<str>'" -TestCases @(
                @{
                    "str" = "HH:mm:ss"
                }
                @{
                    "str" = "HH:mm:ss.fff"
                }
                @{
                    "str" = "HH:mm:ss.fffZ"
                }
            ) {
                param ($str)
                Enable-WotelWriterConsoleSetting -TimestampFormat $str
                $settings.timestamp_format | Should -Be $str
            }

            # it "should throw if invalid timestamp format" {
            #     $settings = Get-WotelSetting -Key 'writers.console'
            #     {
            #         Enable-WotelWriterConsoleSettings -TimestampFormat "invalid"
            #     } | Should -Throw "Invalid timestamp format: invalid"
            # }
        }
    }
}