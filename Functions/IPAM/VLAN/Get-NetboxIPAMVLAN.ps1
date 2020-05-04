<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/16/2020 16:34
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-NetboxIPAMVLAN.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function Get-NetboxIPAMVLAN {
    [CmdletBinding()]
    param
    (
        [uint16]$VID,
        
        [uint16[]]$Id,
        
        [string]$Query,
        
        [string]$Name,
        
        [string]$Tenant,
        
        [uint16]$Tenant_Id,
        
        [string]$TenantGroup,
        
        [uint16]$TenantGroup_Id,
        
        [object]$Status,
        
        [string]$Region,
        
        [string]$Site,
        
        [uint16]$Site_Id,
        
        [string]$Group,
        
        [uint16]$Group_Id,
        
        [string]$Role,
        
        [uint16]$Role_Id,
        
        [uint16]$Limit,
        
        [uint16]$Offset,
        
        [switch]$Raw
    )
    
    if ($null -ne $Status) {
        $PSBoundParameters.Status = ValidateIPAMChoice -ProvidedValue $Status -VLANStatus
    }
    
    $Segments = [System.Collections.ArrayList]::new(@('ipam', 'vlans'))
    
    $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters
    
    $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
    
    InvokeNetboxRequest -URI $uri -Raw:$Raw
}




