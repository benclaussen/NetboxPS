function Add-NetboxDCIMVirtualDeviceContext {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param
    (
        [Parameter(Mandatory = $true)]
        [uint64]$Device,

        [Parameter(Mandatory = $true)]
        [string]$Name,

        [object]$Status = 'active',

        [uint16]$Identifier,

        [uint64]$Primary_IP4,

        [uint64]$Primary_IP6,

        [uint64]$Tenant,

        [string]$Comments
    )

    if (-not $PSBoundParameters.ContainsKey('Status')) {
        $PSBoundParameters['Status'] = $Status
    }

    $Segments = [System.Collections.ArrayList]::new(@('dcim', 'virtual-device-contexts'))

    $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters

    $URI = BuildNewURI -Segments $URIComponents.Segments

    InvokeNetboxRequest -URI $URI -Body $URIComponents.Parameters -Method POST
}