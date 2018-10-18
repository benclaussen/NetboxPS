<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2018 v5.5.152
	 Created on:   	5/29/2018 1:45 PM
	 Created by:   	Ben Claussen
	 Organization: 	NEOnet
	 Filename:     	Tenancy.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>

function Get-NetboxTenancyChoices {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "", Justification = "These are literally 'choices' in Netbox")]
    param ()
    
    $uriSegments = [System.Collections.ArrayList]::new(@('tenancy', '_choices'))
    
    $uri = BuildNewURI -Segments $uriSegments
    
    InvokeNetboxRequest -URI $uri
}


#region GET commands

function Get-NetboxTenant {
    [CmdletBinding()]
    param
    (
        [uint16]$Limit,
        
        [uint16]$Offset,
        
        [string]$Name,
        
        [uint16[]]$Id,
        
        [string]$Query,
        
        [string]$Group,
        
        [uint16]$GroupID,
        
        [hashtable]$CustomFields,
        
        [switch]$Raw
    )
    
    $Segments = [System.Collections.ArrayList]::new(@('tenancy', 'tenants'))
    
    $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters
    
    $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
    
    InvokeNetboxRequest -URI $uri -Raw:$Raw
}

#endregion GET commands


#region SET commands

#endregion SET commands


#region ADD/NEW commands

#endregion ADD/NEW commands


#region REMOVE commands

#endregion REMOVE commands