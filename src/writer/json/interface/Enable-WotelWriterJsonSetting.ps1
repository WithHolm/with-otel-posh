function Enable-WotelWriterJsonSetting {
    [CmdletBinding()]
    param (
        [System.IO.Directory]$LogFolder = "$env:TEMP\wotel-logs"
    )
    
    begin {
        
    }
    
    process {
        $Settings = Get-WotelSetting -Key 'writers.json'
        if ($LogFolder) {
            $Settings.log_folder = $LogFolder.FullName
        }
    }
    
    end {
        
    }
}