<#
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/23/2020 12:06
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-NetboxDCIMDevice.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


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

        [uint16]$Manufacturer_Id,

        [string]$Manufacturer,

        [uint16]$Device_Type_Id,

        [uint16]$Role_Id,

        [string]$Role,

        [uint16]$Tenant_Id,

        [string]$Tenant,

        [uint16]$Platform_Id,

        [string]$Platform,

        [string]$Asset_Tag,

        [uint16]$Site_Id,

        [string]$Site,

        [uint16]$Rack_Group_Id,

        [uint16]$Rack_Id,

        [uint16]$Cluster_Id,

        [uint16]$Model,

        [object]$Status,

        [bool]$Is_Full_Depth,

        [bool]$Is_Console_Server,

        [bool]$Is_PDU,

        [bool]$Is_Network_Device,

        [string]$MAC_Address,

        [bool]$Has_Primary_IP,

        [uint16]$Virtual_Chassis_Id,

        [uint16]$Position,

        [string]$Serial,

        [switch]$Raw
    )

    #endregion Parameters

    if ($null -ne $Status) {
        $PSBoundParameters.Status = ValidateDCIMChoice -ProvidedValue $Status -DeviceStatus
    }

    $Segments = [System.Collections.ArrayList]::new(@('dcim', 'devices'))

    $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Raw'

    $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters

    InvokeNetboxRequest -URI $URI -Raw:$Raw
}