
function Add-NetboxDCIMInterface {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param
    (
        [Parameter(Mandatory = $true)]
        [uint16]$Device,

        [Parameter(Mandatory = $true)]
        [string]$Name,

        [bool]$Enabled,

        [object]$Form_Factor,

        [uint16]$MTU,

        [string]$MAC_Address,

        [bool]$MGMT_Only,

        [uint16]$LAG,

        [string]$Description,

        [ValidateSet('Access', 'Tagged', 'Tagged All', '100', '200', '300', IgnoreCase = $true)]
        [string]$Mode,

        [ValidateRange(1, 4094)]
        [uint16]$Untagged_VLAN,

        [ValidateRange(1, 4094)]
        [uint16[]]$Tagged_VLANs
    )

#    if ($null -ne $Form_Factor) {
#        $PSBoundParameters.Form_Factor = ValidateDCIMChoice -ProvidedValue $Form_Factor -InterfaceFormFactor
#    }

    if (-not [System.String]::IsNullOrWhiteSpace($Mode)) {
        $PSBoundParameters.Mode = switch ($Mode) {
            'Access' {
                100
                break
            }

            'Tagged' {
                200
                break
            }

            'Tagged All' {
                300
                break
            }

            default {
                $_
            }
        }
    }

    $Segments = [System.Collections.ArrayList]::new(@('dcim', 'interfaces'))

    $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters

    $URI = BuildNewURI -Segments $URIComponents.Segments

    InvokeNetboxRequest -URI $URI -Body $URIComponents.Parameters -Method POST
}