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
        [Parameter(ParameterSetName = 'Query',
                   Position = 0)]
        [ValidateRange(1, 4096)]
        [uint16]$VID,
        
        [Parameter(ParameterSetName = 'ByID')]
        [uint32[]]$Id,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Query,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Name,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Tenant,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint32]$Tenant_Id,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$TenantGroup,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint32]$TenantGroup_Id,
        
        [Parameter(ParameterSetName = 'Query')]
        [object]$Status,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Region,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Site,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint32]$Site_Id,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Group,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint32]$Group_Id,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Role,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint32]$Role_Id,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint16]$Limit,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint16]$Offset,
        
        [switch]$Raw
    )
    
    #    if ($null -ne $Status) {
    #        $PSBoundParameters.Status = ValidateIPAMChoice -ProvidedValue $Status -VLANStatus
    #    }
    
    switch ($PSCmdlet.ParameterSetName) {
        'ById' {
            foreach ($VLAN_ID in $Id) {
                $Segments = [System.Collections.ArrayList]::new(@('ipam', 'vlans', $VLAN_ID))
                
                $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Id'
                
                $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
                
                InvokeNetboxRequest -URI $uri -Raw:$Raw
            }
            
            break
        }
        
        default {
            $Segments = [System.Collections.ArrayList]::new(@('ipam', 'vlans'))
            
            $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters
            
            $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
            
            InvokeNetboxRequest -URI $uri -Raw:$Raw
            
            break
        }
    }
}




