
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
        [uint64]$Site,

        [object]$Status = 'Active',

        [uint64]$Platform,

        [uint64]$Tenant,

        [uint64]$Cluster,

        [uint64]$Rack,

        [uint16]$Position,

        [object]$Face,

        [string]$Serial,

        [string]$Asset_Tag,

        [uint64]$Virtual_Chassis,

        [uint64]$VC_Priority,

        [uint64]$VC_Position,

        [uint64]$Primary_IP4,

        [uint64]$Primary_IP6,

        [string]$Comments,

        [hashtable]$Custom_Fields
    )
    #endregion Parameters

    $Segments = [System.Collections.ArrayList]::new(@('dcim', 'devices'))

    $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters

    $URI = BuildNewURI -Segments $URIComponents.Segments

    if ($PSCmdlet.ShouldProcess($Name, 'Create new Device')) {
        InvokeNetboxRequest -URI $URI -Body $URIComponents.Parameters -Method POST
    }
}