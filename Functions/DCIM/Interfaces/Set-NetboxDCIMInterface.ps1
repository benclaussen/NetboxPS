
function Set-NetboxDCIMInterface {
    [CmdletBinding(ConfirmImpact = 'Medium',
        SupportsShouldProcess = $true)]
    [OutputType([pscustomobject])]
    param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
        [uint16[]]$Id,

        [uint16]$Device,

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

    begin {
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
    }

    process {
        foreach ($InterfaceId in $Id) {
            $CurrentInterface = Get-NetboxDCIMInterface -Id $InterfaceId -ErrorAction Stop

            $Segments = [System.Collections.ArrayList]::new(@('dcim', 'interfaces', $CurrentInterface.Id))

            $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Id'

            $URI = BuildNewURI -Segments $Segments

            if ($Force -or $pscmdlet.ShouldProcess("Interface ID $($CurrentInterface.Id)", "Set")) {
                InvokeNetboxRequest -URI $URI -Body $URIComponents.Parameters -Method PATCH
            }
        }
    }

    end {

    }
}