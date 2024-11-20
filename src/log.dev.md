# log

Based on otel.
It has 3 different context levels:
Trace -> from when you started the ps1 script
span -> from when you started a new command
event -> Thing that happened inside the span. this can be a log, or a metric

if you use `Write-WotelLog` you can write a new log event to the current span
you can append a spanid to log to any span if you want, but if you dont i will assume you mean the current span. (ie you can call the span 'Writing to file', while the command is 'write-FileCommand').


## log architecture
```
┌──────────────┐                 
│   trace      │                 
└────┬─────────┘                 
     │  ┌───────────────┐        
     ├──►    span 1     │        
     │  └──┬────────────┘        
     │     │  ┌──────────────┐   
     │     └─►│log 1         │   
     │        ┌──────────────┐   
     │        │log 2         │   
     │        └──────────────┘   
     │  ┌───────────────┐        
     └──►    span 2     │        
        └───────────────┘        
```

## level

the Otel standard has defined int 1-24 for severity levels, and its up to the implementer of what actual levels you want to use.

for out cse we have the following:
```powershell
    enum PwshSeverity {
        # pscore = 1 # not enabled, but think this might be used for pwsh core used for powershell cure logging. 
        system = 2
        trace = 3
        debug = 5
        verbose = 7
        info = 9
        sucess = 10
        warning = 13
        error = 17
        fatal = 21
        throwing = 24
    }
```

## experimental features

for later use..
https://learn.microsoft.com/en-us/powershell/module/Microsoft.PowerShell.Core/About/about_Experimental_Features?view=powershell-7.4