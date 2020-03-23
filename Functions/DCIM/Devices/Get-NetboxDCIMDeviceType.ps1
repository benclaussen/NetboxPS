<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/23/2020 12:07
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-NetboxDCIMDeviceType.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function Get-NetboxDCIMDeviceType {
    [CmdletBinding()]
    #region Parameters
    param
    (
        [uint16]$Offset,
        
        [uint16]$Limit,
        
        [uint16[]]$Id,
        
        [string]$Query,
        
        [string]$Slug,
        
        [string]$Manufacturer,
        
        [uint16]$Manufacturer_Id,
        
        [string]$Model,
        
        [string]$Part_Number,
        
        [uint16]$U_Height,
        
        [bool]$Is_Full_Depth,
        
        [bool]$Is_Console_Server,
        
        [bool]$Is_PDU,
        
        [bool]$Is_Network_Device,
        
        [uint16]$Subdevice_Role,
        
        [switch]$Raw
    )
    #endregion Parameters
    
    $Segments = [System.Collections.ArrayList]::new(@('dcim', 'device-types'))
    
    $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Raw'
    
    $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
    
    InvokeNetboxRequest -URI $URI -Raw:$Raw
}