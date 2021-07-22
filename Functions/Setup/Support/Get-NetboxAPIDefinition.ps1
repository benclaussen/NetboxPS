<#
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.174
	 Created on:   	4/28/2020 11:57
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-NetboxAPIDefinition.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>



function Get-NetboxAPIDefinition {
	[CmdletBinding()]
	param ()

	#$URI = "https://netbox.neonet.org/api/docs/?format=openapi"

	$Segments = [System.Collections.ArrayList]::new(@('docs'))

	$URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary @{'format' = 'openapi' }

	$URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters -SkipConnectedCheck

	InvokeNetboxRequest -URI $URI
}
