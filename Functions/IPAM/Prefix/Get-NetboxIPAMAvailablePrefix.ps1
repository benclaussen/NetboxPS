function Get-NetboxIPAMAvailablePrefix {
    <#
    .SYNOPSIS
        A convenience method for returning available prefixes within a prefix

    .DESCRIPTION
        Will return any available prefixes within a prefix.

    .PARAMETER Prefix_ID
        A description of the Prefix_ID parameter.

    .PARAMETER Raw
        A description of the Raw parameter.

    .EXAMPLE
        Get-NetboxIPAMAvailablePrefix -Prefix_ID (Get-NetboxIPAMPrefix -Prefix 192.0.2.0/24).id

    .NOTES
        Additional information about the function.
#>

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [uint64]$Prefix_ID,

        [switch]$Raw
    )

    process {
        $Segments = [System.Collections.ArrayList]::new(@('ipam', 'prefixes', $Prefix_ID, 'available-prefixes'))

        $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters -SkipParameterByName 'prefix_id'

        $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters

        InvokeNetboxRequest -URI $uri -Raw:$Raw
    }
}