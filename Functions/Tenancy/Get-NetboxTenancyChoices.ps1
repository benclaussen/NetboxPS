<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/19/2020 11:56
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-NetboxTenancyChoices.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function Get-NetboxTenancyChoices {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "", Justification = "These are literally 'choices' in Netbox")]
    param ()
    
    $uriSegments = [System.Collections.ArrayList]::new(@('tenancy', '_choices'))
    
    $uri = BuildNewURI -Segments $uriSegments
    
    InvokeNetboxRequest -URI $uri
}