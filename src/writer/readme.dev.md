all commands should have follow "{verb}-WotelWriter{yourWriter}{thing to do}"
To make sure that the individual writers can be enbaled and used by wotel, you have to implement the following structure:
* make a folder with the name of your writer
* inside that folder, make 4 folders: public (optional), private (optional), interface (required), tests (required if you have any public or private functions)
  * `Public` folder should contain all public functions that are accessible by the user. not all writes needs this.
  * `Private` folder should contain all private functions that are not accessible by the user. not all writes needs this.
  * `Interface` folder should contain all functions that are used by wotel to enable and use your writer.
  * `Tests` folder should contain all tests for your writer.
  
Expected commands inside `interface` folder:
* `Initialize-WotelWriter{YourWriter}`
  * generates and returns a new settings object for your writer (hashtable). this can be used to set default settings for your writer.
  * tip: dont return a hashtable directly as this could create a stack overflow. create hashtalbe with settings and then return.
    ```powershell
    #example from json writer
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
    ```
* `Enable-WotelWriter{YourWriter}`
  * enable and set settings for your writer.
  * all parameteres defined here will be available when the user uses `Enable-WotelWriter`, and setting writer to your writer.
  * This is also the place where you can start any background tasks that you need to do. 
  * TLDR: this command is both a "start" and "a set settings" command.
    ``` powershell
    #example from json writer
    function Enable-WotelWriterJsonSetting {
        [CmdletBinding()]
        param (
            [System.IO.Directory]$LogFolder = "$env:TEMP\wotel-logs"
        )
        process {
            $Settings = Get-WotelSetting -Key 'writers.json'
            if ($LogFolder) {
                $Settings.log_folder = $LogFolder.FullName
            }
            Start-WotelWriterJsonRunspace
        }
    }
    ...
    #when enabling the writer. this command acts as a proxy for your command
    Enable-WotelWriter -Writer Json -LogFolder "myotherfolder"
    ```
* `Invoke-WotelWriter{YourWriter}` - invoke your writer.
  *  what you decide to take as input is up to you, but generally; event item (either as a hashtable or the parameters themselves), span item, and trace item.
  *  this is where you "do the thing" and write the log to wherever you defined.
  *  to make full use of this 
*  

Special Note: all the objects are hashtables with no class as powershell uses almost twice as long to create a a class than a hashtable.
to get the actual properties of the object, please see here