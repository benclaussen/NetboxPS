
function Get-NetboxVirtualMachineDisk {
    <#
    .SYNOPSIS
        Gets VM disks

    .DESCRIPTION
        Obtains the disk objects for one or more VMs

    .PARAMETER Limit
        Number of results to return per page.

    .PARAMETER Offset
        The initial index from which to return the results.

    .PARAMETER Id
        Database ID of the interface

    .PARAMETER Name
        Name of the disk

    .PARAMETER Size
        Size of the disk in GB

    .PARAMETER Virtual_Machine_Id
        ID of the virtual machine to which the interface(s) are assigned.

    .PARAMETER Virtual_Machine
        Name of the virtual machine to get interfaces

    .PARAMETER Raw
        A description of the Raw parameter.

    .EXAMPLE
        PS C:\> Get-NetboxVirtualMachineDisk

    .NOTES
        Additional information about the function.
#>

    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipeline = $true)]
        [uint64]$Id,

        [string]$Name,

        [string]$Query,

        [uint64]$Size,

        [uint64]$Virtual_Machine_Id,

        [string]$Virtual_Machine,

        [uint16]$Limit,

        [uint16]$Offset,

        [switch]$Raw
    )

    process {
        $Segments = [System.Collections.ArrayList]::new(@('virtualization', 'virtual-disks'))

        $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters

        $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters

        InvokeNetboxRequest -URI $uri -Raw:$Raw
    }
}