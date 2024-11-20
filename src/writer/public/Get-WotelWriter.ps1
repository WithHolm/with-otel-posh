function Get-WotelWriter {
    [CmdletBinding()]
    param (

    )
    dynamicparam {
        #add dynamic param that has validateset of colors.json
        $ParamAttrib = New-Object System.Management.Automation.ParameterAttribute
        $ParamAttrib.Position = 0
        # $ParamAttrib.Mandatory = $true
        # $ParamAttrib.ParameterSetName = 'NamedColor'

        $AttribColl = New-Object  System.Collections.ObjectModel.Collection[System.Attribute]
        $AttribColl.Add($ParamAttrib)
        $opt = (Get-WotelSetting -Key 'writers').keys
        $AttribColl.Add((New-Object  System.Management.Automation.ValidateSetAttribute($opt)))
        $RuntimeParam = New-Object System.Management.Automation.RuntimeDefinedParameter('Writer', [string], $AttribColl)
        $RuntimeParamDic = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $RuntimeParamDic.Add('Writer', $RuntimeParam)
        return  $RuntimeParamDic
    }

    begin {

    }

    process {
        $Settings = Get-WotelSetting
        $Settings.writers.GetEnumerator()|ForEach-Object{
            Write-output ([pscustomobject]@{
                Name = $_.key
                Enabled = $_.key -in $Settings.enabled_writers
                Settings = $_.value
            })
        }
    }

    end {

    }
}