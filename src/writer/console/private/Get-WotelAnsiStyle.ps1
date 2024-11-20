
<#
.SYNOPSIS
Returns ansi codes for the current console

.PARAMETER HexColor
color in hex format

.PARAMETER NamedColor
color in named format

.PARAMETER Modes
if ya want bold, italic, underline, strikethrough etc

.PARAMETER ForOrBackgGround
if the color is for the foreground or background

.PARAMETER Reset
for ansi reset

.EXAMPLE
Get-WotelAnsiStyle -NamedColor "Red" -mode bold
#would return "`e[38;2;255;0;0m" (its invisible if you just write it to console)

.NOTES
#TODO:CREATE TESTS FOR THIS
#>
function Get-WotelAnsiStyle {
    [CmdletBinding(
        DefaultParameterSetName = "NonReset"
    )]
    [OutputType([System.Drawing.Color])]
    param (
        [parameter(
            ParameterSetName = 'NonReset'
        )]
        [string]$HexColor,

        [parameter(
            ParameterSetName = 'NonReset'
        )]
        [ValidateSet('Bold', "BoldOff", 'Italic', "ItalicOff", 'Underline', "UnderlineOff", 'Strikethrough', "StrikethroughOff")]
        [string[]]$Modes,

        [parameter(
            ParameterSetName = 'NonReset'
        )]
        [ValidateSet('Foreground', 'Background')]
        [string]$ForOrBackgGround = 'Foreground',

        [parameter(
            ParameterSetName = 'Reset'
        )]
        [switch]$Reset
    )
    dynamicparam {
        #add dynamic param that has validateset of colors.json
        $ParamAttrib = New-Object System.Management.Automation.ParameterAttribute
        # $ParamAttrib.Mandatory = $true
        # $ParamAttrib.ParameterSetName = 'NamedColor'

        $AttribColl = New-Object  System.Collections.ObjectModel.Collection[System.Attribute]
        $AttribColl.Add($ParamAttrib)
        if (!$script:DrawingColor) {
            # Write-Verbose "Getting json"
            $script:DrawingColor = [System.IO.File]::ReadAllText("$psscriptroot\colors.json") | ConvertFrom-Json
        }
        $colors = $script:DrawingColor
        $ColorNames = $colors.name
        $AttribColl.Add((New-Object  System.Management.Automation.ValidateSetAttribute($ColorNames)))
        $RuntimeParam = New-Object System.Management.Automation.RuntimeDefinedParameter('NamedColor', [string], $AttribColl)
        $RuntimeParamDic = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
        $RuntimeParamDic.Add('NamedColor', $RuntimeParam)
        return  $RuntimeParamDic
    }
    begin {
        #dont really need to have any output to console because of spam and circular reference, but logging it is nice
        New-WotelSpan -OutputToConsole Disabled

        #region LoadSystemDrawing
        #add type if not loaded
        $AddedAssembly = $false
        try {
            [void][system.drawing.color]::FromKnownColor([System.Drawing.KnownColor]::Black)
        } catch {
            Add-Type -AssemblyName System.Drawing
            $AddedAssembly = $true
        }
        if ($AddedAssembly) {
            #try to double check that it worked
            try {
                [void][system.drawing.color]::FromKnownColor([System.Drawing.KnownColor]::Black)
            } catch {
                Write-WotelLog -Body "Failed to load System.Drawing.Color" -Severity fatal
                # Write-WotelLog -CmdEvent End
                throw "Failed to load System.Drawing.Color"
            }
        }
        #endregion LoadSystemDrawing

        if (!$Script:ColorCache) {
            $Script:ColorCache = @{}
        }
        $Return = [System.Collections.Generic.List[string]]::new()
    }

    process {
        $NamedColor = $PSBoundParameters['NamedColor']
        if ($NamedColor -and $HexColor) {
            Write-WotelLog -Body "Cannot use both NamedColor and HexColor" -Severity fatal
            throw "Cannot use both NamedColor and HexColor"
        }

        if (![string]::IsNullOrEmpty($NamedColor)) {
            $Key = "Named_$NamedColor"
            if (!$Script:ColorCache.ContainsKey($Key)) {
                Write-WotelLog -body "Converting named color '$NamedColor' to color" -Severity system
                if (!$script:DrawingColor) {
                    Write-WotelLog "Loading colors.json" -Severity system
                    $script:DrawingColor = [System.IO.File]::ReadAllText("$psscriptroot\colors.json") | ConvertFrom-Json
                }
                $json = $script:DrawingColor
                #find aRGB values for color
                :colorsearch for ($i = 0; $i -lt $Json.Count; $i++) {
                    if ($Json[$i].name -eq $NamedColor) {
                        $Color = [System.Drawing.Color]::FromArgb($Json[$i].A, $Json[$i].R, $Json[$i].G, $Json[$i].B)
                        Write-WotelLog -Body "Found color '$NamedColor' in colors.json, $($Color.R), $($Color.G), $($Color.B)" -Severity system
                        $Script:ColorCache[$Key] = $Color
                        break :colorsearch
                        # return $return
                    }
                }
            }
            $Color = $Script:ColorCache[$Key]
        } elseif (![string]::IsNullOrEmpty($HexColor)) {
            $Key = "Hex_$HexColor"

            if (!$Script:ColorCache.ContainsKey($Key)) {
                Write-WotelLog -Body "Converting hex '$HexColor' to color" -Severity system
                #remove the # if it exists
                $HexColor = $HexColor.ToLower() -replace '^#', ''
                # Convert hex to RGB
                $R = [System.Convert]::ToInt32($HexColor.Substring(0, 2), 16)
                $G = [System.Convert]::ToInt32($HexColor.Substring(2, 2), 16)
                $B = [System.Convert]::ToInt32($HexColor.Substring(4, 2), 16)
                # Write-WotelLog -CmdEvent End
                # Create System.Drawing.Color
                # $Color = [System.Drawing.Color]::FromArgb($R, $G, $B)
                $Script:ColorCache[$Key] = [System.Drawing.Color]::FromArgb($R, $G, $B)
            }

            $Color = $Script:ColorCache[$Key]
        }

        if ($Color) {
            # Write-WotelLog "Color is $Color, ground is '$ForOrBackgGround'" -Severity system
            if ($ForOrBackgGround -eq 'Foreground') {
                $Return.Add(("38;2;{0};{1};{2}m" -f $Color.R, $Color.G, $Color.B))
                # $Return += "e[38;2;{0};{1};{2}" -f $Color.R, $Color.G, $Color.B
            } else {
                $Return.Add(("48;2;{0};{1};{2}m" -f $Color.R, $Color.G, $Color.B))
                # $Return += "e[48;2;{0};{1};{2}" -f $Color.R, $Color.G,$Color.B
            }
        }

        if ($Reset) {
            $Return.Add("0m")
        }

        if ($Modes) {
            $ModeHash = @{
                Bold             = "1"
                BoldOff          = "22"
                Italic           = "3"
                ItalicOff        = "23"
                Underline        = "4"
                UnderlineOff     = "24"
                Strikethrough    = "9"
                StrikethroughOff = "29"
            }
            $Modes | ForEach-Object {
                $Return.Add(("{0}m" -f $ModeHash[$_]))
            }
        }

        $return = $Return | ForEach-Object {
            Write-WotelLog -Body "Returning ansi code ``e[$_" -Severity system
            "`e[$_"
        }

        return $($return -join "")
    }

    end {

    }
}