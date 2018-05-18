<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2018 v5.5.148
	 Created on:   	2/28/2018 3:43 PM
	 Created by:   	Ben Claussen
	 Organization: 	NEOnet
	 Filename:     	Extras.ps1
	===========================================================================
	.DESCRIPTION
		Extras objects functions
#>

function Get-NetboxExtrasChoices {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "", Justification = "These are literally 'choices' in Netbox")]
	param ()
    
    $uriSegments = [System.Collections.ArrayList]::new(@('extras', '_choices'))
    
    $uri = BuildNewURI -Segments $uriSegments
    
    InvokeNetboxRequest -URI $uri
}
