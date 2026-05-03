function Get-NetboxDCIMVirtualDeviceContext {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param
    (
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [uint64]$Id,

        [string]$Name,

        [object]$Status,

        [uint16]$Identifier,

        [string]$Device,

        [uint64]$Device_Id,

        [uint64]$Tenant_Id,

        [string]$Tenant,

        [uint16]$Limit,

        [uint16]$Offset,

        [switch]$Raw
    )

    process {
        $Segments = [System.Collections.ArrayList]::new(@('dcim', 'virtual-device-contexts'))

        $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters

        $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters

        InvokeNetboxRequest -URI $URI -Raw:$Raw
    }
}