<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/19/2020 11:56
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-NetboxTenant.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function Get-NetboxTenant {
    [CmdletBinding()]
    param
    (
        [string]$Name,
        
        [string]$Slug,
        
        [uint16[]]$Id,
        
        [string]$Query,
        
        [string]$Group,
        
        [uint16]$GroupID,
        
        [hashtable]$CustomFields,
        
        [uint16]$Limit,
        
        [uint16]$Offset,
        
        [switch]$Raw
    )
    
    $Segments = [System.Collections.ArrayList]::new(@('tenancy', 'tenants'))
    
    $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters
    
    $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
    
    InvokeNetboxRequest -URI $uri -Raw:$Raw
}