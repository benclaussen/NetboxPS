
function Get-NetboxContactAssignment {
<#
    .SYNOPSIS
        Get a contact Assignment from Netbox
    
    .DESCRIPTION
        A detailed description of the Get-NetboxContactAssignment function.
    
    .PARAMETER Name
        The specific name of the contact Assignment. Must match exactly as is defined in Netbox
    
    .PARAMETER Id
        The database ID of the contact Assignment
    
    .PARAMETER Content_Type_Id
        A description of the Content_Type_Id parameter.
    
    .PARAMETER Content_Type
        A description of the Content_Type parameter.
    
    .PARAMETER Object_Id
        A description of the Object_Id parameter.
    
    .PARAMETER Contact_Id
        A description of the Contact_Id parameter.
    
    .PARAMETER Role_Id
        A description of the Role_Id parameter.
    
    .PARAMETER Limit
        Limit the number of results to this number
    
    .PARAMETER Offset
        Start the search at this index in results
    
    .PARAMETER Raw
        Return the unparsed data from the HTTP request
    
    .EXAMPLE
        PS C:\> Get-NetboxContactAssignment
    
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
        [uint32]$Content_Type_Id,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Content_Type,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint32]$Object_Id,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint32]$Contact_Id,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint32]$Role_Id,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint16]$Limit,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint16]$Offset,
        
        [switch]$Raw
    )
    
    switch ($PSCmdlet.ParameterSetName) {
        'ById' {
            foreach ($ContactAssignment_ID in $Id) {
                $Segments = [System.Collections.ArrayList]::new(@('tenancy', 'contact-assignments', $ContactAssignment_ID))
                
                $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Id'
                
                $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
                
                InvokeNetboxRequest -URI $uri -Raw:$Raw
            }
            
            break
        }
        
        default {
            $Segments = [System.Collections.ArrayList]::new(@('tenancy', 'contact-assignments'))
            
            $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters
            
            $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
            
            InvokeNetboxRequest -URI $uri -Raw:$Raw
            
            break
        }
    }
}