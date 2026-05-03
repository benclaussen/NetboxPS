function New-NetboxIPAMVRF {
    <#
    .SYNOPSIS
        Create a new VRF

    .DESCRIPTION
        Create a new VRF in Netbox.

    .PARAMETER Name
        The name of the VRF.

    .PARAMETER RD
        The Route Distinguisher (RFC 4364). Defaults to nothing

    .PARAMETER Tenant
        Tenant ID

    .PARAMETER enforce_unique
        Force unique IP Addresses in this VRF.

    .PARAMETER import_targets
        Arrays of Route Targest

    .PARAMETER export_targets
        Arrays of Route Targest

    .PARAMETER Description
        Description of VRF

    .PARAMETER Custom_Fields
        Custom field hash table. Will be validated by the API service

    .PARAMETER Raw
        Return raw results from API service

    .EXAMPLE
        PS C:\> New-NetboxIPAMVRF -Name MyVRF -Tenant 1 -import_targets @(1,2) -export_targets @(1,2) -RD 65000:100 -enforce_unique $false

    .NOTES
        Additional information about the function.
#>

    [CmdletBinding(ConfirmImpact = 'low',
        SupportsShouldProcess = $true)]
    [OutputType([pscustomobject])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [object]$RD,

        [uint64]$Tenant,

        [object]$enforce_unique = 1,

        [string]$Description,

        [uint64[]]$import_targets,

        [uint64[]]$export_targets,

        [hashtable]$Custom_Fields,

        [switch]$Raw
    )

    $segments = [System.Collections.ArrayList]::new(@('ipam', 'vrfs'))

    $URIComponents = BuildURIComponents -URISegments $segments -ParametersDictionary $PSBoundParameters

    $URI = BuildNewURI -Segments $URIComponents.Segments

    if ($PSCmdlet.ShouldProcess($nae, 'Create new VRF $($Name)')) {
        InvokeNetboxRequest -URI $URI -Method POST -Body $URIComponents.Parameters -Raw:$Raw
    }
}