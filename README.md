# with-otel-posh
open telemetry logging for powershell


## DEV INFO

### Psake

`Invoke-psake` without any parameters will run the default task. this lists all "public" tasks.

```powershell
Invoke-psake
```

To have some sort of clarity, because paske can have alot of tasks and subtasks, to make a command "public" you have to add a "!" to the beginning of the task description.

```powershell
task myPublicTask -description "!some description"{   
}

task myPrivateTask -description "some description"{   
}
```


### ScriptAnalyzer

`Invoke-ScriptAnalyzer` without any parameters will run the default task.