<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/19/2020 11:54
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-NetboxIPAMChoices.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function Get-NetboxIPAMChoices {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "", Justification = "These are literally 'choices' in Netbox")]
    param ()
    
    $uriSegments = [System.Collections.ArrayList]::new(@('ipam', '_choices'))
    
    $uri = BuildNewURI -Segments $uriSegments -Parameters $Parameters
    
    InvokeNetboxRequest -URI $uri
}