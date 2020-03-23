<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/19/2020 14:11
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-NetboxVirtualizationClusterGroup.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function Get-NetboxVirtualizationClusterGroup {
    [CmdletBinding()]
    param
    (
        [uint16]$Limit,
        
        [uint16]$Offset,
        
        [string]$Name,
        
        [string]$Slug,
        
        [switch]$Raw
    )
    
    $uriSegments = [System.Collections.ArrayList]::new(@('virtualization', 'cluster-groups'))
    
    $URIParameters = @{
    }
    
    foreach ($CmdletParameterName in $PSBoundParameters.Keys) {
        if ($CmdletParameterName -in $CommonParameterNames) {
            # These are common parameters and should not be appended to the URI
            Write-Debug "Skipping parameter $CmdletParameterName"
            continue
        }
        
        $URIParameters[$CmdletParameterName.ToLower()] = $PSBoundParameters[$CmdletParameterName]
    }
    
    $uri = BuildNewURI -Segments $uriSegments -Parameters $URIParameters
    
    InvokeNetboxRequest -URI $uri -Raw:$Raw
}