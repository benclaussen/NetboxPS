<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/19/2020 11:49
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-NetboxIPAMAggregate.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function Get-NetboxIPAMAggregate {
    [CmdletBinding()]
    param
    (
        [uint16]$Limit,
        
        [uint16]$Offset,
        
        [object]$Family,
        
        [datetime]$Date_Added,
        
        [uint16[]]$Id,
        
        [string]$Query,
        
        [uint16]$RIR_Id,
        
        [string]$RIR,
        
        [switch]$Raw
    )
    
    if ($null -ne $Family) {
        $PSBoundParameters.Family = ValidateIPAMChoice -ProvidedValue $Family -AggregateFamily
    }
    
    $Segments = [System.Collections.ArrayList]::new(@('ipam', 'aggregates'))
    
    $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters
    
    $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
    
    InvokeNetboxRequest -URI $uri -Raw:$Raw
}