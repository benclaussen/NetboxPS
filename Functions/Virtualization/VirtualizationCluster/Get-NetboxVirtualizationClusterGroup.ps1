<#
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/19/2020 14:11
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-NetboxVirtualizationClusterGroup.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function Get-NetboxVirtualizationClusterGroup {
    [CmdletBinding()]
    param
    (
        [string]$Name,

        [string]$Slug,

        [string]$Description,

        [string]$Query,

        [uint32[]]$Id,

        [uint16]$Limit,

        [uint16]$Offset,

        [switch]$Raw
    )

    $Segments = [System.Collections.ArrayList]::new(@('virtualization', 'cluster-groups'))

    $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters

    $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters

    InvokeNetboxRequest -URI $uri -Raw:$Raw
}