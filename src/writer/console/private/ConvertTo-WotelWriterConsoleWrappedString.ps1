<#
.SYNOPSIS
Formats one or more lines of text to fit within the console width, tabbing the message from the context so a multiline message only needs one message

.PARAMETER Message
Input message to wrap

.PARAMETER Context
What information to prepend to the message. in a wrapped message this will only be on first line

.PARAMETER Prefix
for each line, do you want to append a prefix to the line

.PARAMETER Suffix
for each line, do you want to append a suffix to the line

.EXAMPLE
ConvertTo-WotelWriterConsoleWrappedString -Message ("pester"*100) -Context "test "
#outputs the following
> test pesterpesterpesterpesterpesterpesterpesterpesterpesterpes
       terpesterpesterpesterpesterpesterpesterpesterpesterpester
       pesterpesterpesterpesterpesterpesterpesterpesterpesterpes
       terpesterpesterpesterpesterpesterpesterpesterpesterpester
       pesterpesterpesterpesterpesterpesterpesterpesterpesterpes
       terpesterpesterpesterpesterpesterpesterpesterpesterpester
       pesterpesterpesterpesterpesterpesterpesterpesterpesterpes
       terpesterpesterpesterpesterpesterpesterpesterpesterpester
       pesterpesterpesterpesterpesterpesterpesterpesterpesterpes
       terpesterpesterpesterpesterpesterpesterpesterpesterpester
       pesterpesterpesterpesterpester


.NOTES
General notes
#>
function ConvertTo-WotelWriterConsoleWrappedString {
    [CmdletBinding()]
    [OutputType([System.Collections.Generic.List[String]])]
    param (
        [string[]]$Message,
        [string]$Context,
        [int]$ContextLength
    )

    begin {
        New-WotelSpan -OutputToConsole Disabled
        $Return = [System.Collections.Generic.List[String]]::new()
    }
    process {
        #remove any empty lines and trim lines that have many whitespaces in front or back
        $Message = $Message.split("`r`n") | ForEach-Object { $_.trim() } | Where-Object { $_ }

        #cmdlet for pester mocking, but its essentially console width
        $ConsoleWidth = (Get-WotelWriterConsoleWindowSize).Width - 2
        if(!$ContextLength){
            $ContextLength = $Context.Length
        }
        $MaxMsgLength = ($ConsoleWidth - $ContextLength)


        Write-WotelLog "Console width is $ConsoleWidth" -Severity system
        Write-WotelLog "Max msg length is $MaxMsgLength" -Severity system
        Write-WotelLog "Context length is $ContextLength" -Severity system

        #todo: split the message to newlines on spaces, periods or commas to enhance readability
        for ($i = 0; $i -lt $Message.Count; $i++) {
            # $First = $i -eq 0
            $msg = $Message[$i]

            #while the message is too long for the console
            while($msg.Length -ge $MaxMsgLength){
                #take the first $MaxMsgLength characters of the message
                $ThisMsg = $msg.Substring(0, $MaxMsgLength)
                #add to return list
                $Return.Add("$Prefix$ThisMsg$Suffix")
                #remove the first $MaxMsgLength characters from the message
                $msg = $msg.Substring($MaxMsgLength)
            }

            #handle last line
            if(![string]::IsNullOrEmpty($msg)){
                $Return.Add("$Prefix$Msg$Suffix")
            }
        }
    }
    end {
        
        if($Return.count -gt 0){
            #append context to first line
            Write-WotelLog "Appending context ($context) to first line" -Severity system
            $Return[0] = "$Context $($Return[0])"
            for ($i = 1; $i -lt $Return.Count; $i++) {
                Write-WotelLog "Line $i is $($Return[$i].Length) long" -Severity system
                $Return[$i] = "$(" "*$ContextLength) $($Return[$i])"
            }
        }
        Write-WotelLog "Returning $($Return.Count) lines" -Severity system
        return $Return
    }

}
# Convert-ToBoltWrappedMessage -Message ("pester"*100) -Context "test"