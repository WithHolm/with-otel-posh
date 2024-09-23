function Initialize-WotelWriterJson {
    [CmdletBinding()]
    param (
        
    )
    
    $ret = @{
        log_folder = "$env:TEMP\wotel"
        log_name_date_format = "yy-MM-dd hhmmss"
    }
    return $ret
}