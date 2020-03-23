function Get-NetboxIPAMAddress {
    [CmdletBinding()]
    param
    (
        [uint16]$Limit,
        
        [uint16]$Offset,
        
        [object]$Family,
        
        [uint16[]]$Id,
        
        [string]$Query,
        
        [uint16]$Parent,
        
        [byte]$Mask_Length,
        
        [string]$VRF,
        
        [uint16]$VRF_Id,
        
        [string]$Tenant,
        
        [uint16]$Tenant_Id,
        
        [string]$Device,
        
        [uint16]$Device_ID,
        
        [string]$Virtual_Machine,
        
        [uint16]$Virtual_Machine_Id,
        
        [uint16]$Interface_Id,
        
        [object]$Status,
        
        [object]$Role,
        
        [switch]$Raw
    )
    
    if ($null -ne $Family) {
        $PSBoundParameters.Family = ValidateIPAMChoice -ProvidedValue $Family -IPAddressFamily
    }
    
    if ($null -ne $Status) {
        $PSBoundParameters.Status = ValidateIPAMChoice -ProvidedValue $Status -IPAddressStatus
    }
    
    if ($null -ne $Role) {
        $PSBoundParameters.Role = ValidateIPAMChoice -ProvidedValue $Role -IPAddressRole
    }
    
    $Segments = [System.Collections.ArrayList]::new(@('ipam', 'ip-addresses'))
    
    $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters
    
    $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
    
    InvokeNetboxRequest -URI $uri -Raw:$Raw
}