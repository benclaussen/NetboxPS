
function New-NetboxDCIMDevice {
    [CmdletBinding(ConfirmImpact = 'low',
        SupportsShouldProcess = $true)]
    [OutputType([pscustomobject])]
    #region Parameters
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [object]$Device_Role,

        [Parameter(Mandatory = $true)]
        [object]$Device_Type,

        [Parameter(Mandatory = $true)]
        [uint16]$Site,

        [object]$Status = 'Active',

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

        [hashtable]$Custom_Fields
    )
    #endregion Parameters

    #    if ($null -ne $Device_Role) {
    #        # Validate device role?
    #    }

    #    if ($null -ne $Device_Type) {
    #        # Validate device type?
    #    }

    #    if ($null -ne $Status) {
    #        $PSBoundParameters.Status = ValidateDCIMChoice -ProvidedValue $Status -DeviceStatus
    #    }

    #    if ($null -ne $Face) {
    #        $PSBoundParameters.Face = ValidateDCIMChoice -ProvidedValue $Face -DeviceFace
    #    }

    $Segments = [System.Collections.ArrayList]::new(@('dcim', 'devices'))

    $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters

    $URI = BuildNewURI -Segments $URIComponents.Segments

    if ($PSCmdlet.ShouldProcess($Name, 'Create new Device')) {
        InvokeNetboxRequest -URI $URI -Body $URIComponents.Parameters -Method POST
    }
}