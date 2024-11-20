ipmo .\With-Otel.psm1 -force

# $Args = @(
#     "-i 'C:\Users\phili\Pictures\lice\gump spin.gif'",
#     "'C:\Users\phili\Pictures\lice\test.gif'",
#     "-y"
# )
# New-WotelSpan -DisplayName 'ffmpeg' -Arguments $Args -File (get-command ffmpeg).source
# Write-WotelLog -Body 'running ffmpeg..'
# $Command = "ffmpeg $($Args -join " ") *>&1"
# [scriptblock]::Create($Command).Invoke()|Write-WotelLog -SpanId 'ffmpeg' -Severity info

# Invoke-Command -FilePath (get-command ffmpeg).source -ArgumentList $args
# & "ffmpeg $($Args -join " ")"*>&1|Write-WotelLog -SpanId 'ffmpeg' -Severity info

# # Enable-WotelWriter -Writer Json -LogFolder "$env:TEMP\wotel-logs"
# Write-host "Log level is set to 'info'"
# Set-WotelLogLevel -Severity info
New-WotelSpan -DisplayName "Hello World" -Arguments "{}"
Enable-WotelWriter -Writer console -Style modern
Write-WotelLog -Body "Hello World - default level"
Write-WotelLog -Body "Hello World - system level" -Severity system -Resource "custom resource"
Write-WotelLog -Body "Hello World - trace level" -Severity trace
Write-WotelLog -Body "Hello World - debug level" -Severity debug
Write-WotelLog -Body "Hello World - verbose level" -Severity verbose
Write-WotelLog -Body "Hello World - info level" -Severity info
Write-WotelLog -Body "Hello World - Success level" -Severity success
Write-WotelLog -Body "Hello World - warning level" -Severity warning
Write-WotelLog -Body "Hello World - error level" -Severity error
Write-WotelLog -Body "Hello World - fatal level" -Severity fatal
Write-WotelLog -Body "Hello World - throwing level" -Severity throwing
Write-WotelLog -Body ("Really really long string, " * 100) -Resource "long string textwrap" -Severity success