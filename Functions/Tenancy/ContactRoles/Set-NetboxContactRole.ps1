
function Set-NetboxContactRole {
<#
    .SYNOPSIS
        Update a contact role in Netbox

    .DESCRIPTION
        Updates a contact role in Netbox

    .PARAMETER Name
        The contact role name, e.g "Network Support"

    .PARAMETER Slug
        The unique URL for the role. Can only contain hypens, A-Z, a-z, 0-9, and underscores

    .PARAMETER Description
        Short description of the contact role

    .PARAMETER Custom_Fields
        A description of the Custom_Fields parameter.

    .PARAMETER Raw
        Return the unparsed data from the HTTP request

    .EXAMPLE
        PS C:\> New-NetboxContact -Name 'Leroy Jenkins' -Email 'leroy.jenkins@example.com'

    .NOTES
        Additional information about the function.
#>
    
    [CmdletBinding(ConfirmImpact = 'Low',
                   SupportsShouldProcess = $true)]
    [OutputType([pscustomobject])]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [uint64[]]$Id,
        
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateLength(1, 100)]
        [string]$Name,
        
        [ValidateLength(1, 100)]
        [ValidatePattern('^[-a-zA-Z0-9_]+$')]
        [string]$Slug,
        
        [ValidateLength(0, 200)]
        [string]$Description,
        
        [hashtable]$Custom_Fields,
        
        [switch]$Raw
    )
    
    begin {
        $Method = 'PATCH'
    }
    
    process {
        foreach ($ContactRoleId in $Id) {
            $Segments = [System.Collections.ArrayList]::new(@('tenancy', 'contacts', $ContactRoleId))
            
            $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Id', 'Force'
            
            $URI = BuildNewURI -Segments $URIComponents.Segments
            
            $CurrentContactRole = Get-NetboxContactRole -Id $ContactRoleId -ErrorAction Stop
            
            if ($Force -or $PSCmdlet.ShouldProcess($CurrentContactRole.Name, 'Update contact role')) {
                InvokeNetboxRequest -URI $URI -Method $Method -Body $URIComponents.Parameters -Raw:$Raw
            }
        }
    }
}




