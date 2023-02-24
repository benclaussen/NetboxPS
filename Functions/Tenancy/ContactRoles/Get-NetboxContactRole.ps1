
function Get-NetboxContactRole {
<#
    .SYNOPSIS
        Get a contact role from Netbox

    .DESCRIPTION
        A detailed description of the Get-NetboxContactRole function.

    .PARAMETER Name
        The specific name of the contact role. Must match exactly as is defined in Netbox

    .PARAMETER Id
        The database ID of the contact role

    .PARAMETER Query
        A standard search query that will match one or more contact roles.

    .PARAMETER Limit
        Limit the number of results to this number

    .PARAMETER Offset
        Start the search at this index in results

    .PARAMETER Raw
        Return the unparsed data from the HTTP request

    .EXAMPLE
        PS C:\> Get-NetboxContactRole

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
        [string]$Description,

        [Parameter(ParameterSetName = 'Query')]
        [uint16]$Limit,

        [Parameter(ParameterSetName = 'Query')]
        [uint16]$Offset,

        [switch]$Raw
    )

    switch ($PSCmdlet.ParameterSetName) {
        'ById' {
            foreach ($ContactRole_ID in $Id) {
                $Segments = [System.Collections.ArrayList]::new(@('tenancy', 'contact-roles', $ContactRole_ID))

                $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Id'

                $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters

                InvokeNetboxRequest -URI $uri -Raw:$Raw
            }

            break
        }

        default {
            $Segments = [System.Collections.ArrayList]::new(@('tenancy', 'contact-roles'))

            $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters

            $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters

            InvokeNetboxRequest -URI $uri -Raw:$Raw

            break
        }
    }
}