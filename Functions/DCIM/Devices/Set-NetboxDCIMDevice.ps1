
function Set-NetboxDCIMDevice {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [uint16[]]$Id,

        [string]$Name,

        [object]$Device_Role,

        [object]$Device_Type,

        [uint16]$Site,

        [object]$Status,

        [uint16]$Platform,

        [uint16]$Tenant,

        [uint16]$Cluster,

        [uint16]$Rack,

        [uint16]$Position,

        [object]$Face,

        [string]$Serial,

        [string]$Asset_Tag,

        [uint16]$Virtual_Chassis,

        [uint16]$VC_Priority,

        [uint16]$VC_Position,

        [uint16]$Primary_IP4,

        [uint16]$Primary_IP6,

        [string]$Comments,

        [hashtable]$Custom_Fields,

        [switch]$Force
    )

    begin {
#        if ($null -ne $Status) {
#            $PSBoundParameters.Status = ValidateDCIMChoice -ProvidedValue $Status -DeviceStatus
#        }

#        if ($null -ne $Face) {
#            $PSBoundParameters.Face = ValidateDCIMChoice -ProvidedValue $Face -DeviceFace
#        }
    }

    process {
        foreach ($DeviceID in $Id) {
            $CurrentDevice = Get-NetboxDCIMDevice -Id $DeviceID -ErrorAction Stop

            if ($Force -or $pscmdlet.ShouldProcess("$($CurrentDevice.Name)", "Set")) {
                $Segments = [System.Collections.ArrayList]::new(@('dcim', 'devices', $CurrentDevice.Id))

                $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Id', 'Force'

                $URI = BuildNewURI -Segments $URIComponents.Segments

                InvokeNetboxRequest -URI $URI -Body $URIComponents.Parameters -Method PATCH
            }
        }
    }

    end {

    }
}
