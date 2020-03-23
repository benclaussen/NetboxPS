<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/23/2020 12:15
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-NetboxCircuitsChoices.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function Get-NetboxCircuitsChoices {
<#
	.SYNOPSIS
		Gets the choices associated with circuits
	
	.DESCRIPTION
		A detailed description of the Get-NetboxCircuitsChoices function.
	
	.EXAMPLE
				PS C:\> Get-NetboxCircuitsChoices
	
	.NOTES
		Additional information about the function.
#>
    
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "", Justification = "These are literally 'choices' in Netbox")]
    param ()
    
    $uriSegments = [System.Collections.ArrayList]::new(@('circuits', '_choices'))
    $uri = BuildNewURI -Segments $uriSegments
    
    InvokeNetboxRequest -URI $uri
}
