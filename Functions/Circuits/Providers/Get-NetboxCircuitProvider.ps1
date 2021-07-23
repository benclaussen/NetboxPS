<#
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.181
	 Created on:   	2020-11-04 12:06
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-NetboxCircuitProvider.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>



function Get-NetboxCircuitProvider {
    [CmdletBinding(DefaultParameterSetName = 'Query')]
    param
    (
        [Parameter(ParameterSetName = 'ById',
                   Mandatory = $true)]
        [uint16[]]$Id,

        [Parameter(ParameterSetName = 'Query',
                   Mandatory = $false)]
        [string]$Name,

        [Parameter(ParameterSetName = 'Query')]
        [string]$Query,

        [Parameter(ParameterSetName = 'Query')]
        [string]$Slug,

        [Parameter(ParameterSetName = 'Query')]
        [string]$ASN,

        [Parameter(ParameterSetName = 'Query')]
        [string]$Account,

        [Parameter(ParameterSetName = 'Query')]
        [uint16]$Limit,

        [Parameter(ParameterSetName = 'Query')]
        [uint16]$Offset,

        [switch]$Raw
    )

    switch ($PSCmdlet.ParameterSetName) {
        'ById' {
            foreach ($i in $ID) {
                $Segments = [System.Collections.ArrayList]::new(@('circuits', 'providers', $i))

                $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters -SkipParameterByName "Id"

                $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters

                InvokeNetboxRequest -URI $URI -Raw:$Raw
            }
        }

        default {
            $Segments = [System.Collections.ArrayList]::new(@('circuits', 'providers'))

            $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters

            $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters

            InvokeNetboxRequest -URI $URI -Raw:$Raw
        }
    }
}