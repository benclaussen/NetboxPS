<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/19/2020 14:10
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-NetboxVirtualizationCluster.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


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
        [uint16]$Limit,
        
        [uint16]$Offset,
        
        [Alias('q')]
        [string]$Query,
        
        [string]$Name,
        
        [Alias('id__in')]
        [uint16[]]$Id,
        
        [string]$Group,
        
        [uint16]$Group_Id,
        
        [string]$Type,
        
        [uint16]$Type_Id,
        
        [string]$Site,
        
        [uint16]$Site_Id,
        
        [switch]$Raw
    )
    
    $uriSegments = [System.Collections.ArrayList]::new(@('virtualization', 'clusters'))
    
    $URIParameters = @{
    }
    
    foreach ($CmdletParameterName in $PSBoundParameters.Keys) {
        if ($CmdletParameterName -in $CommonParameterNames) {
            # These are common parameters and should not be appended to the URI
            Write-Debug "Skipping parameter $CmdletParameterName"
            continue
        }
        
        if ($CmdletParameterName -eq 'Id') {
            # Check if there is one or more values for Id and build a URI or query as appropriate
            if (@($PSBoundParameters[$CmdletParameterName]).Count -gt 1) {
                $URIParameters['id__in'] = $Id -join ','
            } else {
                [void]$uriSegments.Add($PSBoundParameters[$CmdletParameterName])
            }
        } elseif ($CmdletParameterName -eq 'Query') {
            $URIParameters['q'] = $PSBoundParameters[$CmdletParameterName]
        } else {
            $URIParameters[$CmdletParameterName.ToLower()] = $PSBoundParameters[$CmdletParameterName]
        }
    }
    
    $uri = BuildNewURI -Segments $uriSegments -Parameters $URIParameters
    
    InvokeNetboxRequest -URI $uri -Raw:$Raw
}