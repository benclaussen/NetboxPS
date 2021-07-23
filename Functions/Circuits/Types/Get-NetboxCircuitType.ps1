<#
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.181
	 Created on:   	2020-11-04 12:34
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-NetboxCircuitType.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>



function Get-NetboxCircuitType {
    [CmdletBinding(DefaultParameterSetName = 'Query')]
    param
    (
        [Parameter(ParameterSetName = 'ById')]
        [uint16[]]$Id,

        [Parameter(ParameterSetName = 'Query')]
        [string]$Name,

        [Parameter(ParameterSetName = 'Query')]
        [string]$Slug,

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
            foreach ($i in $ID) {
                $Segments = [System.Collections.ArrayList]::new(@('circuits', 'circuit_types', $i))

                $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters -SkipParameterByName "Id"

                $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters

                InvokeNetboxRequest -URI $URI -Raw:$Raw
            }
        }

        default {
            $Segments = [System.Collections.ArrayList]::new(@('circuits', 'circuit-types'))

            $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters

            $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters

            InvokeNetboxRequest -URI $URI -Raw:$Raw
        }
    }
}