
function Get-NetboxDCIMCableTermination
{
    [CmdletBinding()]
    #region Parameters
    param
    (
        [uint16]$Limit,

        [uint16]$Offset,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [uint16[]]$Id,

        [uint16]$Cable,

        [string]$Cable_End,

        [string]$Termination_Type,

        [uint16]$Termination_ID,

        [switch]$Raw
    )

    #endregion Parameters

    process
    {
        $Segments = [System.Collections.ArrayList]::new(@('dcim', 'cable-terminations'))

        $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Raw'

        $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters

        InvokeNetboxRequest -URI $URI -Raw:$Raw
    }
}