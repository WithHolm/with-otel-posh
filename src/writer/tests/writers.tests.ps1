#General test for writers
describe 'writers' {
    InModuleScope "with-otel" {
        BeforeDiscovery {
            $Writers = gci $PSScriptRoot\..\ -Directory | ? { $_.name -notin @('tests', 'public', 'private') } | % {
                @{
                    name = $_.name
                    path = $_.fullname
                }
            }
        }

        it "<name> should have only test,private,public and interface folders" -TestCases $Writers {
            param($name, $path)
            $writerFolders = Get-ChildItem $path -Directory
            $Folders = 'public', 'private', 'tests', 'interface'

            'public', 'private', 'tests', 'interface' | should -BeIn $writerFolders.name
            $writerFolders | Where-Object { $_.name -notin $Folders } | Should -BeNullOrEmpty
        }

        context "Command:Enable-WotelWriter<name>Setting" {
            it "<name> has settings Enable-WotelWriter<name>Setting function defined in interface folder" -TestCases $Writers {
                param($name, $path)

                $Function = "Enable-WotelWriter$name`Setting"
                $path = join-path $path 'interface'
                $ScriptPath = join-path $path "$Function.ps1"
                $ScriptPath | Should -Exist
                Get-ChildItem $ScriptPath | Select-String "function $Function" | Should -Not -BeNullOrEmpty

                # $path = join-path $path 'interface'
                # join-path $path "Enable-WotelWriter$name`Setting" | Should -Exist
                # Get-ChildItem $path -Filter "*.ps1" | ? { $_.name -notlike "*tests*" } | Select-String "function enable-wotelwriter$name`setting" | Should -Not -BeNullOrEmpty
            }
    
            it "<name> should be accessible by 'Enable-WotelWriter'" -TestCases $Writers {
                param($name, $path)
                { Enable-WotelWriter -Writer $name } | Should -Not -Throw
            }

            it "<name> should have pester test for Enable-WotelWriter<name>Setting" -TestCases $Writers {
                param($name, $path)
                $path = join-path $path 'tests'
                join-path $path "Enable-WotelWriter$name`Setting.tests.ps1" | Should -Exist
            }
        }

        context "Command:Initialize-WotelWriter" {
            it "<name> should have Initialize-WotelWriter<name> function defined in interface folder" -TestCases $Writers {
                param($name, $path)
                $Function = "Initialize-WotelWriter$name"
                $path = join-path $path 'interface'
                $ScriptPath = join-path $path "$Function.ps1"
                $ScriptPath | Should -Exist
                Get-ChildItem $ScriptPath | Select-String "function $Function" | Should -Not -BeNullOrEmpty

                # $path = join-path $path 'interface'
                # join-path $path "Initialize-WotelWriter$name.ps1" | Should -Exist
                # Get-ChildItem $path -Filter "*.ps1" | ? { $_.name -notlike "*tests*" } | Select-String "function initialize-wotelwriter$name" | Should -Not -BeNullOrEmpty
            }

            it "<name> initialize should return a hashtable" -TestCases $Writers {
                param($name, $path)

                $Result = [scriptblock]::Create("Initialize-WotelWriter$name").Invoke()
                $Result | Should -BeOfType [hashtable]
            }


        }

        context "Command:Invoke-WotelWriter" {
            it "<name> should have Invoke-WotelWriter<name> function defined in interface folder" -TestCases $Writers {
                param($name, $path)

                $Function = "Invoke-WotelWriter$name"
                $path = join-path $path 'interface'
                $ScriptPath = join-path $path "$Function.ps1"
                $ScriptPath | Should -Exist
                Get-ChildItem $ScriptPath | Select-String "function $Function" | Should -Not -BeNullOrEmpty
            }

            it "implements global:Wotel_disable_writer_output variable" -TestCases $Writers {
                param($name, $path)
                $path = join-path $path 'interface'
                Get-ChildItem $path -Filter "*.ps1" | ? { $_.name -notlike "*tests*" } | Select-String "global:Wotel_disable_writer_output" | Should -Not -BeNullOrEmpty
            }
        }


    }
}