<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/23/2020 12:15
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-NetboxCircuit.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function Get-NetboxCircuit {
<#
    .SYNOPSIS
        Gets one or more circuits
    
    .DESCRIPTION
        A detailed description of the Get-NetboxCircuit function.
    
    .PARAMETER Id
        Database ID of circuit. This will query for exactly the IDs provided
    
    .PARAMETER CID
        Circuit ID
    
    .PARAMETER InstallDate
        Date of installation
    
    .PARAMETER CommitRate
        Committed rate in Kbps
    
    .PARAMETER Query
        A raw search query... As if you were searching the web site
    
    .PARAMETER Provider
        The name or ID of the provider. Provide either [string] or [int]. String will search provider names, integer will search database IDs
    
    .PARAMETER Type
        Type of circuit. Provide either [string] or [int]. String will search provider type names, integer will search database IDs
    
    .PARAMETER Site
        Location/site of circuit. Provide either [string] or [int]. String will search site names, integer will search database IDs
    
    .PARAMETER Tenant
        Tenant assigned to circuit. Provide either [string] or [int]. String will search tenant names, integer will search database IDs
    
    .PARAMETER Limit
        A description of the Limit parameter.
    
    .PARAMETER Offset
        A description of the Offset parameter.
    
    .PARAMETER Raw
        A description of the Raw parameter.
    
    .PARAMETER ID__IN
        Multiple unique DB IDs to retrieve
    
    .EXAMPLE
        PS C:\> Get-NetboxCircuit
    
    .NOTES
        Additional information about the function.
#>
    
    [CmdletBinding(DefaultParameterSetName = 'Query')]
    param
    (
        [Parameter(ParameterSetName = 'ById')]
        [uint16[]]$Id,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$CID,
        
        [Parameter(ParameterSetName = 'Query')]
        [datetime]$InstallDate,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint32]$CommitRate,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Query,
        
        [Parameter(ParameterSetName = 'Query')]
        [object]$Provider,
        
        [Parameter(ParameterSetName = 'Query')]
        [object]$Type,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Site,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Tenant,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint16]$Limit,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint16]$Offset,
        
        [switch]$Raw
    )
    
    switch ($PSCmdlet.ParameterSetName) {
        'ById' {
            foreach ($i in $ID) {
                $Segments = [System.Collections.ArrayList]::new(@('circuits', 'circuits', $i))
                
                $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters -SkipParameterByName "Id"
                
                $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
                
                InvokeNetboxRequest -URI $URI -Raw:$Raw
            }
        }
        
        default {
            $Segments = [System.Collections.ArrayList]::new(@('circuits', 'circuits'))
            
            $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters
            
            $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
            
            InvokeNetboxRequest -URI $URI -Raw:$Raw
        }
    }
}