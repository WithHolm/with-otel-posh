enum OtelSeverity {
    trace = 1
    trace2 = 2
    trace3 = 3
    trace4 = 4
    debug = 5
    debug2 = 6
    debug3 = 7
    debug4 = 8
    info = 9
    info2 = 10
    info3 = 11
    info4 = 12
    warn = 13
    warn2 = 14
    warn3 = 15
    warn4 = 16
    error = 17
    error2 = 18
    error3 = 19
    error4 = 20
    fatal = 21
    fatal2 = 22
    fatal3 = 23
    fatal4 = 24
}

enum PwshSeverity {
    # pscore = 1 # not enabled, but think this might be used for pwsh core used for powershell cure logging. 
    system = 2
    trace = 3
    debug = 5
    verbose = 7
    info = 9
    success = 10
    warning = 13
    error = 17
    fatal = 21
    throwing = 24
}

$scripts = gci "$PSScriptRoot/src" -Recurse -File -filter "*.ps1" |
Where-Object { $_.BaseName -notlike "$*" } |
Where-Object { $_.BaseName -notlike "*.tests" } |
Where-Object { $_.Directory.Name -notlike "*ignore*" -or $_.BaseName -notlike "*.ignore*" }

$scripts|%{
    . $_
}