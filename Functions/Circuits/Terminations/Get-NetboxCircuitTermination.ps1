
function Get-NetboxCircuitTermination {
    [CmdletBinding(DefaultParameterSetName = 'Query')]
    param
    (
        [Parameter(ParameterSetName = 'ById',
                   ValueFromPipelineByPropertyName = $true)]
        [uint32[]]$Id,

        [Parameter(ParameterSetName = 'Query')]
        [string]$Circuit_ID,

        [Parameter(ParameterSetName = 'Query')]
        [string]$Term_Side,

        [Parameter(ParameterSetName = 'Query')]
        [uint32]$Port_Speed,

        [Parameter(ParameterSetName = 'Query')]
        [string]$Query,

        [Parameter(ParameterSetName = 'Query')]
        [string]$Site_ID,

        [Parameter(ParameterSetName = 'Query')]
        [string]$Site,

        [Parameter(ParameterSetName = 'Query')]
        [string]$XConnect_ID,

        [Parameter(ParameterSetName = 'Query')]
        [uint16]$Limit,

        [Parameter(ParameterSetName = 'Query')]
        [uint16]$Offset,

        [switch]$Raw
    )

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'ById' {
                foreach ($i in $ID) {
                    $Segments = [System.Collections.ArrayList]::new(@('circuits', 'circuit-terminations', $i))

                    $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters -SkipParameterByName "Id"

                    $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters

                    InvokeNetboxRequest -URI $URI -Raw:$Raw
                }
            }

            default {
                $Segments = [System.Collections.ArrayList]::new(@('circuits', 'circuit-terminations'))

                $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters

                $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters

                InvokeNetboxRequest -URI $URI -Raw:$Raw
            }
        }
    }
}