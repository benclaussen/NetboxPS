
function Add-NetboxVirtualMachineDisk {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [uint64]$Virtual_Machine,

        [string]$MAC_Address,

        [uint64]$Size,

        [string]$Description,

        [hashtable]$Custom_Fields,

        [switch]$Raw
    )

    $Segments = [System.Collections.ArrayList]::new(@('virtualization', 'virtual-disks'))

    $PSBoundParameters.Enabled = $Enabled

    $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters

    $uri = BuildNewURI -Segments $URIComponents.Segments

    InvokeNetboxRequest -URI $uri -Method POST -Body $URIComponents.Parameters
}