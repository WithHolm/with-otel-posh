

task default -depends sharetasks -description 'does nothing'
task sharetasks -description 'share a list of tasks.. you are looking at it!' {
    "available tasks:"
    Get-PSakeScriptTasks|?{$_.description -like "!*"}|%{$_.description = $_.description.substring(1) }|ft name,description
}

task test -description "!run tests"{
    
}