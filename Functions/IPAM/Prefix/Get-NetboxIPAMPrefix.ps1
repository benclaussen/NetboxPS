<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/19/2020 11:51
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-NetboxIPAMPrefix.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function Get-NetboxIPAMPrefix {
<#
    .SYNOPSIS
        A brief description of the Get-NetboxIPAMPrefix function.
    
    .DESCRIPTION
        A detailed description of the Get-NetboxIPAMPrefix function.
    
    .PARAMETER Query
        A description of the Query parameter.
    
    .PARAMETER Id
        A description of the Id parameter.
    
    .PARAMETER Limit
        A description of the Limit parameter.
    
    .PARAMETER Offset
        A description of the Offset parameter.
    
    .PARAMETER Family
        A description of the Family parameter.
    
    .PARAMETER Is_Pool
        A description of the Is_Pool parameter.
    
    .PARAMETER Within
        Should be a CIDR notation prefix such as '10.0.0.0/16'
    
    .PARAMETER Within_Include
        Should be a CIDR notation prefix such as '10.0.0.0/16'
    
    .PARAMETER Contains
        A description of the Contains parameter.
    
    .PARAMETER Mask_Length
        CIDR mask length value
    
    .PARAMETER VRF
        A description of the VRF parameter.
    
    .PARAMETER VRF_Id
        A description of the VRF_Id parameter.
    
    .PARAMETER Tenant
        A description of the Tenant parameter.
    
    .PARAMETER Tenant_Id
        A description of the Tenant_Id parameter.
    
    .PARAMETER Site
        A description of the Site parameter.
    
    .PARAMETER Site_Id
        A description of the Site_Id parameter.
    
    .PARAMETER Vlan_VId
        A description of the Vlan_VId parameter.
    
    .PARAMETER Vlan_Id
        A description of the Vlan_Id parameter.
    
    .PARAMETER Status
        A description of the Status parameter.
    
    .PARAMETER Role
        A description of the Role parameter.
    
    .PARAMETER Role_Id
        A description of the Role_Id parameter.
    
    .PARAMETER Raw
        A description of the Raw parameter.
    
    .EXAMPLE
        PS C:\> Get-NetboxIPAMPrefix
    
    .NOTES
        Additional information about the function.
#>
    
    [CmdletBinding()]
    param
    (
        [string]$Prefix,
        
        [string]$Query,
        
        [uint16[]]$Id,
        
        [object]$Family,
        
        [boolean]$Is_Pool,
        
        [string]$Within,
        
        [string]$Within_Include,
        
        [string]$Contains,
        
        [ValidateRange(0, 127)]
        [byte]$Mask_Length,
        
        [string]$VRF,
        
        [uint16]$VRF_Id,
        
        [string]$Tenant,
        
        [uint16]$Tenant_Id,
        
        [string]$Site,
        
        [uint16]$Site_Id,
        
        [string]$Vlan_VId,
        
        [uint16]$Vlan_Id,
        
        [object]$Status,
        
        [string]$Role,
        
        [uint16]$Role_Id,
        
        [uint16]$Limit,
        
        [uint16]$Offset,
        
        [switch]$Raw
    )
    
    if ($null -ne $Family) {
        $PSBoundParameters.Family = ValidateIPAMChoice -ProvidedValue $Family -PrefixFamily
    }
    
    if ($null -ne $Status) {
        $PSBoundParameters.Status = ValidateIPAMChoice -ProvidedValue $Status -PrefixStatus
    }
    
    $Segments = [System.Collections.ArrayList]::new(@('ipam', 'prefixes'))
    
    $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters
    
    $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
    
    InvokeNetboxRequest -URI $uri -Raw:$Raw
}