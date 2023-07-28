
function Get-NetboxVirtualizationCluster {
<#
    .SYNOPSIS
        Obtains virtualization clusters from Netbox.

    .DESCRIPTION
        Obtains one or more virtualization clusters based on provided filters.

    .PARAMETER Limit
        Number of results to return per page

    .PARAMETER Offset
        The initial index from which to return the results

    .PARAMETER Query
        A general query used to search for a cluster

    .PARAMETER Name
        Name of the cluster

    .PARAMETER Id
        Database ID(s) of the cluster

    .PARAMETER Group
        String value of the cluster group.

    .PARAMETER Group_Id
        Database ID of the cluster group.

    .PARAMETER Type
        String value of the Cluster type.

    .PARAMETER Type_Id
        Database ID of the cluster type.

    .PARAMETER Site
        String value of the site.

    .PARAMETER Site_Id
        Database ID of the site.

    .PARAMETER Raw
        A description of the Raw parameter.

    .EXAMPLE
        PS C:\> Get-NetboxVirtualizationCluster

    .NOTES
        Additional information about the function.
#>

    [CmdletBinding()]
    param
    (
        [string]$Name,

        [Alias('q')]
        [string]$Query,

        [uint16[]]$Id,

        [string]$Group,

        [uint64]$Group_Id,

        [string]$Type,

        [uint16]$Type_Id,

        [string]$Site,

        [uint64]$Site_Id,

        [uint16]$Limit,

        [uint16]$Offset,

        [switch]$Raw
    )

    $Segments = [System.Collections.ArrayList]::new(@('virtualization', 'clusters'))

    $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters

    $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters

    InvokeNetboxRequest -URI $uri -Raw:$Raw
}