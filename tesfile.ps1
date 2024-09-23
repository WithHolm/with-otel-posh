ipmo .\With-Otel.psm1 -force

# Enable-WotelWriter -Writer Json -LogFolder "$env:TEMP\wotel-logs"
Write-host "Log level is set to 'info'"
Set-WotelLogLevel -Severity info
New-WotelSpan -DisplayName "Hello World" -Arguments "{}"
New-WotelLog -Body "Hello World - default level"
New-WotelLog -Body "Hello World - system level" -Severity system -Resource "custom resource"
New-WotelLog -Body "Hello World - trace level" -Severity trace
New-WotelLog -Body "Hello World - debug level" -Severity debug
New-WotelLog -Body "Hello World - verbose level" -Severity verbose
New-WotelLog -Body "Hello World - info level" -Severity info
New-WotelLog -Body "Hello World - Success level" -Severity success
New-WotelLog -Body "Hello World - warning level" -Severity warning
New-WotelLog -Body "Hello World - error level" -Severity error
New-WotelLog -Body "Hello World - fatal level" -Severity fatal
New-WotelLog -Body "Hello World - throwing level" -Severity throwing
New-WotelLog -Body ("Really really long string, " * 100) -Resource "long string textwrap" -Severity success