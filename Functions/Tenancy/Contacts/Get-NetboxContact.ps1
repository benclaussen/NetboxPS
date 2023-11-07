
function Get-NetboxContact {
<#
    .SYNOPSIS
        Get a contact from Netbox

    .DESCRIPTION
        Obtain a contact or contacts from Netbox by ID or query

    .PARAMETER Name
        The specific name of the Contact. Must match exactly as is defined in Netbox

    .PARAMETER Id
        The database ID of the Contact

    .PARAMETER Query
        A standard search query that will match one or more Contacts.

    .PARAMETER Email
        Email address of the contact

    .PARAMETER Title
        Title of the contact

    .PARAMETER Phone
        Telephone number of the contact

    .PARAMETER Address
        Physical address of the contact

    .PARAMETER Group
        The specific group as defined in Netbox.

    .PARAMETER GroupID
        The database ID of the group in Netbox

    .PARAMETER Limit
        Limit the number of results to this number

    .PARAMETER Offset
        Start the search at this index in results

    .PARAMETER Raw
        Return the unparsed data from the HTTP request

    .EXAMPLE
        PS C:\> Get-NetboxContact

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
        [uint64[]]$Id,

        [Parameter(ParameterSetName = 'Query')]
        [string]$Query,

        [Parameter(ParameterSetName = 'Query')]
        [string]$Email,

        [Parameter(ParameterSetName = 'Query')]
        [string]$Title,

        [Parameter(ParameterSetName = 'Query')]
        [string]$Phone,

        [Parameter(ParameterSetName = 'Query')]
        [string]$Address,

        [Parameter(ParameterSetName = 'Query')]
        [string]$Group,

        [Parameter(ParameterSetName = 'Query')]
        [uint64]$GroupID,

        [Parameter(ParameterSetName = 'Query')]
        [uint16]$Limit,

        [Parameter(ParameterSetName = 'Query')]
        [uint16]$Offset,

        [switch]$Raw
    )

    switch ($PSCmdlet.ParameterSetName) {
        'ById' {
            foreach ($Contact_ID in $Id) {
                $Segments = [System.Collections.ArrayList]::new(@('tenancy', 'contacts', $Contact_ID))

                $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Id'

                $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters

                InvokeNetboxRequest -URI $uri -Raw:$Raw
            }

            break
        }

        default {
            $Segments = [System.Collections.ArrayList]::new(@('tenancy', 'contacts'))

            $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters

            $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters

            InvokeNetboxRequest -URI $uri -Raw:$Raw

            break
        }
    }
}