
function Get-NetboxDCIMDevice {
    [CmdletBinding()]
    #region Parameters
    param
    (
        [uint16]$Limit,

        [uint16]$Offset,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [uint16[]]$Id,

        [string]$Query,

        [string]$Name,

        [uint64]$Manufacturer_Id,

        [string]$Manufacturer,

        [uint64]$Device_Type_Id,

        [uint64]$Role_Id,

        [string]$Role,

        [uint64]$Tenant_Id,

        [string]$Tenant,

        [uint64]$Platform_Id,

        [string]$Platform,

        [string]$Asset_Tag,

        [uint64]$Site_Id,

        [string]$Site,

        [uint64]$Rack_Group_Id,

        [uint64]$Rack_Id,

        [uint64]$Cluster_Id,

        [uint64]$Model,

        [object]$Status,

        [bool]$Is_Full_Depth,

        [bool]$Is_Console_Server,

        [bool]$Is_PDU,

        [bool]$Is_Network_Device,

        [string]$MAC_Address,

        [bool]$Has_Primary_IP,

        [uint64]$Virtual_Chassis_Id,

        [uint16]$Position,

        [string]$Serial,

        [switch]$Raw
    )

    #endregion Parameters

    process {
        $Segments = [System.Collections.ArrayList]::new(@('dcim', 'devices'))

        $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Raw'

        $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters

        InvokeNetboxRequest -URI $URI -Raw:$Raw
    }
}