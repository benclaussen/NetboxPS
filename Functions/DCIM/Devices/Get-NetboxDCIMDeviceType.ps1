
function Get-NetboxDCIMDeviceType {
    [CmdletBinding()]
    #region Parameters
    param
    (
        [uint16]$Offset,

        [uint16]$Limit,

        [uint64[]]$Id,

        [string]$Query,

        [string]$Slug,

        [string]$Manufacturer,

        [uint64]$Manufacturer_Id,

        [string]$Model,

        [string]$Part_Number,

        [uint16]$U_Height,

        [bool]$Is_Full_Depth,

        [bool]$Is_Console_Server,

        [bool]$Is_PDU,

        [bool]$Is_Network_Device,

        [uint16]$Subdevice_Role,

        [switch]$Raw
    )
    #endregion Parameters

    $Segments = [System.Collections.ArrayList]::new(@('dcim', 'device-types'))

    $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Raw'

    $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters

    InvokeNetboxRequest -URI $URI -Raw:$Raw
}