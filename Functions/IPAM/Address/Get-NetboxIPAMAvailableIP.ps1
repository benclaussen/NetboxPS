
function Get-NetboxIPAMAvailableIP {
    <#
    .SYNOPSIS
        A convenience method for returning available IP addresses within a prefix

    .DESCRIPTION
        By default, the number of IPs returned will be equivalent to PAGINATE_COUNT. An arbitrary limit
        (up to MAX_PAGE_SIZE, if set) may be passed, however results will not be paginated

    .PARAMETER Prefix_ID
        A description of the Prefix_ID parameter.

    .PARAMETER Limit
        A description of the Limit parameter.

    .PARAMETER Raw
        A description of the Raw parameter.

    .PARAMETER NumberOfIPs
        A description of the NumberOfIPs parameter.

    .EXAMPLE
        Get-NetboxIPAMAvailableIP -Prefix_ID (Get-NetboxIPAMPrefix -Prefix 192.0.2.0/24).id

        Get (Next) Available IP on the Prefix 192.0.2.0/24

    .EXAMPLE
        Get-NetboxIPAMAvailableIP -Prefix_ID 2 -NumberOfIPs 3

        Get 3 (Next) Available IP on the Prefix 192.0.2.0/24

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

        [Alias('NumberOfIPs')]
        [uint64]$Limit,

        [switch]$Raw
    )

    process {
        $Segments = [System.Collections.ArrayList]::new(@('ipam', 'prefixes', $Prefix_ID, 'available-ips'))

        $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters -SkipParameterByName 'prefix_id'

        $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters

        InvokeNetboxRequest -URI $uri -Raw:$Raw
    }
}