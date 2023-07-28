function Get-NetboxContentType {
<#
    .SYNOPSIS
        Get a content type definition from Netbox

    .DESCRIPTION
        A detailed description of the Get-NetboxContentType function.

    .PARAMETER Model
        A description of the Model parameter.

    .PARAMETER Id
        The database ID of the contact role

    .PARAMETER App_Label
        A description of the App_Label parameter.

    .PARAMETER Query
        A standard search query that will match one or more contact roles.

    .PARAMETER Limit
        Limit the number of results to this number

    .PARAMETER Offset
        Start the search at this index in results

    .PARAMETER Raw
        Return the unparsed data from the HTTP request

    .EXAMPLE
        PS C:\> Get-NetboxContentType

    .NOTES
        Additional information about the function.
#>

    [CmdletBinding(DefaultParameterSetName = 'Query')]
    param
    (
        [Parameter(ParameterSetName = 'Query',
                   Position = 0)]
        [string]$Model,

        [Parameter(ParameterSetName = 'ByID')]
        [uint64[]]$Id,

        [Parameter(ParameterSetName = 'Query')]
        [string]$App_Label,

        [Parameter(ParameterSetName = 'Query')]
        [string]$Query,

        [Parameter(ParameterSetName = 'Query')]
        [uint16]$Limit,

        [Parameter(ParameterSetName = 'Query')]
        [uint16]$Offset,

        [switch]$Raw
    )

    switch ($PSCmdlet.ParameterSetName) {
        'ById' {
            foreach ($ContentType_ID in $Id) {
                $Segments = [System.Collections.ArrayList]::new(@('extras', 'content-types', $ContentType_ID))

                $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Id'

                $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters

                InvokeNetboxRequest -URI $uri -Raw:$Raw
            }

            break
        }

        default {
            $Segments = [System.Collections.ArrayList]::new(@('extras', 'content-types'))

            $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters

            $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters

            InvokeNetboxRequest -URI $uri -Raw:$Raw

            break
        }
    }
}