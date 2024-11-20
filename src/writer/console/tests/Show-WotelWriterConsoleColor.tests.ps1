Describe "Show-WotelWriterConsoleColor" {
    InModuleScope 'With-Otel' {
        BeforeDiscovery {
            $Settings = Get-WotelSetting -Key 'writers.console'
            Mock Write-host {param($object) $global:output = ($object -join "")}
        }
        BeforeAll {
            $global:output = ""
        }

        it "should return a list of all ansi colors currently used by the console writer, including example of how it looks" {
            # Show-WotelWriterConsoleColor
            # $global:output | Should -BeLike "*default: default*`r`n*system: DarkMagenta*`r`n*trace: Fuchsia*`r`n*debug: Blue*`r`n*verbose: DarkCyan*`r`n*info: default*`r`n*success: Green*`r`n*warning: Yellow*`r`n*error: Crimson*`r`n*fatal: Red*`r`n*throwing: DarkRed*`r`n"
        }
    }
}