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
<#
    .SYNOPSIS
        Get a tenent from Netbox
    
    .DESCRIPTION
        A detailed description of the Get-NetboxTenant function.
    
    .PARAMETER Name
        The specific name of the tenant. Must match exactly as is defined in Netbox
    
    .PARAMETER Id
        The database ID of the tenant
    
    .PARAMETER Query
        A standard search query that will match one or more tenants.
    
    .PARAMETER Slug
        The specific slug of the tenant. Must match exactly as is defined in Netbox
    
    .PARAMETER Group
        The specific group as defined in Netbox.
    
    .PARAMETER GroupID
        The database ID of the group in Netbox
    
    .PARAMETER CustomFields
        Hashtable in the format @{"field_name" = "value"} to search
    
    .PARAMETER Limit
        Limit the number of results to this number
    
    .PARAMETER Offset
        Start the search at this index in results
    
    .PARAMETER Raw
        Return the unparsed data from the HTTP request
    
    .EXAMPLE
        PS C:\> Get-NetboxTenant
    
    .NOTES
        Additional information about the function.
#>
    
    [CmdletBinding(DefaultParameterSetName = 'Query')]
    param
    (
        [Parameter(ParameterSetName = 'Query',
                   Position = 0)]
        [string]$Name,
        
        [Parameter(ParameterSetName = 'ByID')]
        [uint32[]]$Id,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Query,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Slug,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Group,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint16]$GroupID,
        
        [Parameter(ParameterSetName = 'Query')]
        [hashtable]$CustomFields,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint16]$Limit,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint16]$Offset,
        
        [switch]$Raw
    )
    
    switch ($PSCmdlet.ParameterSetName) {
        'ById' {
            foreach ($Tenant_ID in $Id) {
                $Segments = [System.Collections.ArrayList]::new(@('tenancy', 'tenants', $Tenant_ID))
                
                $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Id'
                
                $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
                
                InvokeNetboxRequest -URI $uri -Raw:$Raw
            }
            
            break
        }
        
        default {
            $Segments = [System.Collections.ArrayList]::new(@('tenancy', 'tenants'))
            
            $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters
            
            $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
            
            InvokeNetboxRequest -URI $uri -Raw:$Raw
            
            break
        }
    }
}