<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/23/2020 12:09
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-NetboxDCIMInterface.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function Get-NetboxDCIMInterface {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param
    (
        [uint16]$Limit,
        
        [uint16]$Offset,
        
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [uint16]$Id,
        
        [uint16]$Name,
        
        [object]$Form_Factor,
        
        [bool]$Enabled,
        
        [uint16]$MTU,
        
        [bool]$MGMT_Only,
        
        [string]$Device,
        
        [uint16]$Device_Id,
        
        [uint16]$Type,
        
        [uint16]$LAG_Id,
        
        [string]$MAC_Address,
        
        [switch]$Raw
    )
    
    if ($null -ne $Form_Factor) {
        $PSBoundParameters.Form_Factor = ValidateDCIMChoice -ProvidedValue $Form_Factor -InterfaceFormFactor
    }
    
    $Segments = [System.Collections.ArrayList]::new(@('dcim', 'interfaces'))
    
    $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters
    
    $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
    
    InvokeNetboxRequest -URI $URI -Raw:$Raw
}