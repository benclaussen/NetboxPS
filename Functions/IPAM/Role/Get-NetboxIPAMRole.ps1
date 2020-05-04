
function Get-NetboxIPAMRole {
<#
    .SYNOPSIS
        Get IPAM Prefix/VLAN roles
    
    .DESCRIPTION
        A role indicates the function of a prefix or VLAN. For example, you might define Data, Voice, and Security roles. Generally, a prefix will be assigned the same functional role as the VLAN to which it is assigned (if any).
    
    .PARAMETER Id
        Unique ID
    
    .PARAMETER Query
        Search query
    
    .PARAMETER Name
        Role name
    
    .PARAMETER Slug
        Role URL slug
    
    .PARAMETER Brief
        Brief format
    
    .PARAMETER Limit
        Result limit
    
    .PARAMETER Offset
        Result offset
    
    .PARAMETER Raw
        A description of the Raw parameter.
    
    .EXAMPLE
        PS C:\> Get-NetboxIPAMRole
    
    .NOTES
        Additional information about the function.
#>
    
    [CmdletBinding()]
    param
    (
        [string]$Name,
        
        [string]$Query,
        
        [uint16[]]$Id,
        
        [string]$Slug,
        
        [switch]$Brief,
        
        [uint16]$Limit,
        
        [uint16]$Offset,
        
        [switch]$Raw
    )
    
    $Segments = [System.Collections.ArrayList]::new(@('ipam', 'roles'))
    
    $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters
    
    $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
    
    InvokeNetboxRequest -URI $uri -Raw:$Raw
}