function Get-NetboxDCIMCable {
    [CmdletBinding()]
    #region Parameters
    param
    (
        [uint16]$Limit,

        [uint16]$Offset,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [uint16[]]$Id,

        [string]$Label,

        [string]$Termination_A_Type,

        [uint16]$Termination_A_ID,

        [string]$Termination_B_Type,

        [UInt16]$Termination_B_ID,

        [string]$Type,

        [string]$Status,

        [string]$Color,

        [UInt16]$Device_ID,

        [string]$Device,

        [uint16]$Rack_Id,

        [string]$Rack,

        [uint16]$Location_ID,

        [string]$Location,

        [switch]$Raw
    )

    #endregion Parameters

    process {
        $Segments = [System.Collections.ArrayList]::new(@('dcim', 'cables'))

        $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Raw'

        $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters

        InvokeNetboxRequest -URI $URI -Raw:$Raw
    }
}