function Enable-WotelWriter {
    [CmdletBinding(
        DefaultParameterSetName = 'Writer'
    )]
    param (
        [parameter(
            ParameterSetName = 'InputObject'
        )]
        [PscustomObject]$InputObject,
        [Parameter(
            ParameterSetName = "Writer"
        )]
        [ValidateSet('Console', 'Json')]
        [string]$Writer
    )
    dynamicparam {
        #save compute if we are not using the InputObject parameter
        if ($PSCmdlet.ParameterSetName -eq 'InputObject') {
            return
        }

        # #dict to return to runtime. represents param()
        $RuntimeParamDic = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()

        #if not writer is set in user-space (when user is writing the parameters) then return
        Write-debug "writer is $($PSBoundParameters['Writer']) - $($PSBoundParameters.count)"
        if ([string]::IsNullOrEmpty($PSBoundParameters['Writer'])) {
            Write-Debug "returning runtimeparamdic"
            return $RuntimeParamDic
        }

        #region get parameters for the specified "enable-wotelwriter" function.
        $WriterCommand = $PSBoundParameters['Writer'].substring(0, 1).ToUpper() + $PSBoundParameters['Writer'].substring(1)
        # $ExecutionContext.SessionState.InvokeCommand.GetCommand is a smidge slower :()
        $Func = get-item "function:Enable-WotelWriter$WriterCommand`Setting"

        if (!$Func) {
            Write-error "function for enabling $WriterCommand not found"
            return $RuntimeParamDic
        }

        #get parameters for the specified "enable-wotelwriter" function.
        $ExcludeParams = @(
            'PipelineVariable'
            'OutBuffer'
            'OutVariable'
            'WhatIf'
            'Verbose'
            'Debug'
            'InformationAction'
            'InformationVariable'
            'warningAction'
            'WarningVariable'
            'ErrorAction'
            'ErrorVariable'
        )
        Write-debug "found function: $Func, parameters: $($Func.parameters.Count)"

        $Func.parameters.Values.Where{ $_.name -notin $ExcludeParams } | % {
            Write-Debug "adding parameter $($_.name) from function $($Func.name)"
            #lets hope its this simple? edit: it is :)
            $param = $_
            $RuntimeParam = New-Object System.Management.Automation.RuntimeDefinedParameter($param.name, $param.ParameterType, $param.Attributes)
            $RuntimeParamDic.Add($param.name, $RuntimeParam)
        }

        #endregion get parameters for the specified "enable-wotelwriter" function.
        return  $RuntimeParamDic
    }

    begin {
        $Writers = @()
    }
    
    process {
        if ($PSCmdlet.ParameterSetName -eq 'InputObject') {
            if ($InputObject.Enabled) {
                $Writers += $InputObject.Name
            }
        } elseif ($PSCmdlet.ParameterSetName -eq 'Writer' -and $writer) {
            $Writers += $writer

            $params = @{}
            $PSBoundParameters.Keys | ? { $_ -ne 'Writer' } | % {
                $params[$_] = $PSBoundParameters[$_]
            }
            if ($params.count -gt 0) {
                #if i can exchange this with a actual invokation with hashtable splatting it will be faster
                [scriptblock]::create("param(`$opts)$($Func.Name) @opts").Invoke($params)
            }
        }
    }
    end {
        $Settings = Get-WotelSetting
        $Writers | ForEach-Object {
            if (!$Settings.enabled_writers.Contains($_)) {
                $Settings.enabled_writers += $_
            }
        }
    }
}