
function Get-NetboxDCIMManufacture {
    [CmdletBinding()]
    #region Parameters
    param
    (
        [uint16]$Offset,

        [uint16]$Limit,

        [Parameter(ParameterSetName = 'ById')]
        [uint16[]]$Id,

        [string]$Name,

        [string]$Slug,

        [switch]$Raw
    )
    #endregion Parameters

    switch ($PSCmdlet.ParameterSetName) {
        'ById' {
            foreach ($ManuID in $Id) {
                $Segments = [System.Collections.ArrayList]::new(@('dcim', 'manufacturers', $ManuID))

                $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Id', 'Raw'

                $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters

                InvokeNetboxRequest -URI $URI -Raw:$Raw
            }

            break
        }

        default {

            $Segments = [System.Collections.ArrayList]::new(@('dcim', 'manufacturers'))

            $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Raw'

            $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters

            InvokeNetboxRequest -URI $URI -Raw:$Raw

        }
    }

}