
function Get-NetboxTag
{
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param
    (
        [uint16]$Limit,

        [uint16]$Offset,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [uint16]$Id,

        [string]$Name,

        [string]$Slug,

        [switch]$Raw
    )

    process
    {

        $Segments = [System.Collections.ArrayList]::new(@('extras', 'tags'))

        $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters

        $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters

        InvokeNetboxRequest -URI $URI -Raw:$Raw
    }
}