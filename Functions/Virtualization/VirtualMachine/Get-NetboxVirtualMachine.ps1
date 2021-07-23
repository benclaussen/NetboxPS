<#
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/19/2020 12:44
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-NetboxVirtualMachine.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function Get-NetboxVirtualMachine {
<#
    .SYNOPSIS
        Obtains virtual machines from Netbox.

    .DESCRIPTION
        Obtains one or more virtual machines based on provided filters.

    .PARAMETER Limit
        Number of results to return per page

    .PARAMETER Offset
        The initial index from which to return the results

    .PARAMETER Query
        A general query used to search for a VM

    .PARAMETER Name
        Name of the VM

    .PARAMETER Id
        Database ID of the VM

    .PARAMETER Status
        Status of the VM

    .PARAMETER Tenant
        String value of tenant

    .PARAMETER Tenant_ID
        Database ID of the tenant.

    .PARAMETER Platform
        String value of the platform

    .PARAMETER Platform_ID
        Database ID of the platform

    .PARAMETER Cluster_Group
        String value of the cluster group.

    .PARAMETER Cluster_Group_Id
        Database ID of the cluster group.

    .PARAMETER Cluster_Type
        String value of the Cluster type.

    .PARAMETER Cluster_Type_Id
        Database ID of the cluster type.

    .PARAMETER Cluster_Id
        Database ID of the cluster.

    .PARAMETER Site
        String value of the site.

    .PARAMETER Site_Id
        Database ID of the site.

    .PARAMETER Role
        String value of the role.

    .PARAMETER Role_Id
        Database ID of the role.

    .PARAMETER Raw
        A description of the Raw parameter.

    .PARAMETER TenantID
        Database ID of tenant

    .PARAMETER PlatformID
        Database ID of the platform

    .PARAMETER id__in
        Database IDs of VMs

    .EXAMPLE
        PS C:\> Get-NetboxVirtualMachine

    .NOTES
        Additional information about the function.
#>

    [CmdletBinding()]
    param
    (
        [Alias('q')]
        [string]$Query,

        [string]$Name,

        [uint16[]]$Id,

        [object]$Status,

        [string]$Tenant,

        [uint16]$Tenant_ID,

        [string]$Platform,

        [uint16]$Platform_ID,

        [string]$Cluster_Group,

        [uint16]$Cluster_Group_Id,

        [string]$Cluster_Type,

        [uint16]$Cluster_Type_Id,

        [uint16]$Cluster_Id,

        [string]$Site,

        [uint16]$Site_Id,

        [string]$Role,

        [uint16]$Role_Id,

        [uint16]$Limit,

        [uint16]$Offset,

        [switch]$Raw
    )

    if ($null -ne $Status) {
        $PSBoundParameters.Status = ValidateVirtualizationChoice -ProvidedValue $Status -VirtualMachineStatus
    }

    $Segments = [System.Collections.ArrayList]::new(@('virtualization', 'virtual-machines'))

    $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters

    $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters

    InvokeNetboxRequest -URI $uri -Raw:$Raw
}