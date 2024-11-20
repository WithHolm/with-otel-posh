<#
.SYNOPSIS
Writes the log to json

.PARAMETER Event
Parameter description

.PARAMETER TraceTimestamp
Parameter description

.PARAMETER TraceId
Parameter description

.PARAMETER SpanId
Parameter description

.NOTES
General notes
#>
function Invoke-WotelWriterJson {
    [CmdletBinding()]
    param (
        [hashtable]$Event,
        [datetime]$TraceTimestamp,
        [string]$TraceId,
        [string]$SpanId
    )
    begin {
        $Settings = Get-WotelSetting -Key 'writers.json'
        $Filename = $TraceTimestamp.ToString($Settings.log_name_date_format)
        $Path = join-path $Settings.log_folder "$Filename.json"
        $Path = [System.IO.Path]::GetFullPath($Path)
        if(!(Test-Path $Path)){
            New-Item -Path $Path -ItemType File -Force -Value "[`r`n]" | Out-Null
        }
    }
    process {
        if($Settings.singleton)
        {

        }

        $OutData = [System.Collections.Generic.List[string]]::new()



        # $strData = [System.Text.Encoding]::UTF8.GetBytes("$str")
        # $WriterSingleton = {
        #     param(

        #     )
        # }
        #it seems weiard, i know, but it generally just goes to last line, appends data and then writes the closing tag

        $FileStream = [System.IO.FileStream]::new($Path, [System.IO.FileMode]::OpenOrCreate, [System.IO.FileAccess]::ReadWrite)

        if($FileStream.Length -eq 4){
            #file with just beginning and end brackets (empty file)
            #replace last line with $data and append ]
            $null = $FileStream.Seek(-2, [System.IO.SeekOrigin]::End)
        }
        else{
            #file with data already in it

            #set "cursor" at end of line of last item
            $null = $FileStream.Seek(-3, [System.IO.SeekOrigin]::End)

            #add comma and new line
            $OutData.Add(",`r`n")
        }

        #add json data
        $OutData.add(($event|ConvertTo-Json -Compress))

        #add new line and closing bracket
        $OutData.add("`r`n]")

        #write data to file
        $bytes = [System.Text.Encoding]::UTF8.GetBytes([string]::Join("", $OutData))

        if(!($global:Wotel_disable_writer_output -eq $true)){
            # return
            $FileStream.Write($bytes, 0, $bytes.Length)
        }

        $FileStream.Dispose()
    }
    end {

    }
}