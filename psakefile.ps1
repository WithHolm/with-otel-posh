Properties {
    $scripts = gci "$($psake.build_script_dir)/src" -Recurse -File -filter "*.ps1" |
    Where-Object { $_.BaseName -notlike "$*" } |
    Where-Object { $_.BaseName -notlike "*.tests" } |
    Where-Object { $_.Directory.Name -notlike "*ignore*" -or $_.BaseName -notlike "*.ignore*" }

    $AnalyzeAsync = $false
    $Analyze = @{
        default = @{
            Settings = "$($psake.build_script_dir)/PSScriptAnalyzerSettings.psd1"
        }
        fix     = @{
            Settings = "$($psake.build_script_dir)/PSScriptAnalyzerSettings-fix.psd1"
        }
    }

}

task default -depends taskDocs -description 'does nothing'
task taskDocs -description 'share a list of tasks.. you are looking at it!' {
    "available tasks:"
    Get-PSakeScriptTasks |
    Where-Object { $_.Description -like "!*" } |
    ForEach-Object {
        $_.description = $_.description.substring(1)
        $_ 
    } | Format-Table name, description
}

task NeedsPester -description "check if any file need pester tests" {
    Foreach ($Item in $Scripts) {
        if (!(test-path "../tests/$($item.BaseName).tests.ps1")) {
            $Rel = [System.IO.Path]::GetRelativePath($psake.build_script_dir, $item.FullName)
            Write-Host "File $($Rel) needs pester tests"
        }
    }
}

#Collection.. runs sync or async depending on setting
task Analyze -description "!run psscriptanalyzer" -depends LoadScriptAnalyzer,AnalyzeSync,AnalyzeAsync {}

task LoadScriptAnalyzer -description "load script analyzer module" {
    $Assembly = [System.AppDomain]::CurrentDomain.GetAssemblies() | ? Location -like "*Microsoft.Windows.PowerShell.ScriptAnalyzer.dll"
    $Modules = Get-Module -ListAvailable psscriptanalyzer
    if ($Assembly -and $Assembly.location -like "*.vscode*") {
        $Script:ScriptAnalyzerModule = $modules|Where-Object Path -like '*.vscode*'|Select-Object -First 1
    }
    else {
        $Script:ScriptAnalyzerModule = $modules|Sort-Object version -Descending|Select-Object -first 1
    }
    $Script:ScriptAnalyzerModule|ipmo    
}

task AnalyzeAsync -description "run psscriptanalyzer asynchronously" -depends LoadScriptAnalyzer -precondition {$AnalyzeAsync -eq $true} {
    $param = $Analyze.default
    $root = $psake.build_script_dir
    $mod = $Script:ScriptAnalyzerModule
    $job = $scripts.FullName | ForEach-Object -AsJob -parallel {
        # ipmo PSScriptAnalyzer -Force
        $param = $using:param
        $root = $using:root
        $mod = $using:mod
        $mod|ipmo
        $relativePath = [System.IO.Path]::GetRelativePath($root, $_)
        Invoke-ScriptAnalyzer @param -Path $_
    }
    $job|wait-job|Receive-Job
}

task AnalyzeSync -description "run psscriptanalyzer synchronously" -depends LoadScriptAnalyzer -precondition {$AnalyzeAsync -eq $false} {
    # module PSScriptAnalyzer -ListAvailable|sort version -Descending|select -first 1|ipmo
    $param = $Analyze.default
    $scripts.FullName | % {
        $Count++
        $relativePath = [System.IO.Path]::GetRelativePath($psake.build_script_dir, $_)
        Write-Progress -Activity "Analyzing" -Status "Analyzing $relativePath" -PercentComplete ($Count / $scripts.Count * 100)
        Invoke-ScriptAnalyzer @param -Path $_
    } | Format-Table -a
}

task Fix -description "!run psscriptanalyzer with fixes for common issues" -depends LoadScriptAnalyzer {
    $scripts | ForEach-Object {
        $param = @{
            Path     = $_.FullName
            Settings = "$($psake.build_script_dir)/PSScriptAnalyzerSettings-fix.psd1"
        }
        $Err = Invoke-ScriptAnalyzer @param
        if ($Err) {
            Write-host "Fixing $($Err.count) issues with $($_.Fullname)"
        }
        Invoke-ScriptAnalyzer @param -Fix
    }
}

task Todo -description "!list all TODO statements" {
    gci $psake.build_script_dir -Recurse -Filter *.ps1 -Exclude "psakefile.ps1" | % {
        $_ | Select-String -Pattern '#TODO'
    } | ft @{n = "Link"; e = { "$($_.Filename) $($_.LineNumber)" } }, @{n = "Item"; e = { $_.Line.trim() } } -AutoSize 
}

task Test -description "!run tests" {
    Write-Host "Importing module"
    Ipmo "$($psake.build_script_dir)\With-Otel.psm1" -Force
    Write-Host "Running tests"
    Invoke-Pester -Path "$($psake.build_script_dir)\src"
}