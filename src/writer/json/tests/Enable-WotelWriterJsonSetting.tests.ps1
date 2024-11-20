Describe "Enable-WotelWriterJsonSetting" {
    InModuleScope 'With-Otel' {
        BeforeEach {
            Initialize-WotelSingleton
            $settings = Get-WotelSetting -Key 'writers.json'
            Mock Write-host { $env:output }
        }
        context "-LogFolder" {
            it "should set log_folder to on value '<str>'" -TestCases @(
                @{
                    str = "$env:TEMP\wo-log"
                }
                @{
                    str = "test"
                }
            ) {
                param ($str)
                # $settings = Get-WotelSetting -Key 'writers.json'
                Enable-WotelWriterJsonSetting -LogFolder $str
                $settings.log_folder | Should -Be $([System.IO.Path]::GetFullPath($str))
            }
        }
    }
}