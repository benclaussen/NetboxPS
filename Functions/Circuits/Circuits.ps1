<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2018 v5.5.148
	 Created on:   	2/28/2018 4:06 PM
	 Created by:   	Ben Claussen
	 Organization: 	NEOnet
	 Filename:     	Circuits.ps1
	===========================================================================
	.DESCRIPTION
		Circuit object functions
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

function Get-NetboxCircuit {
<#
	.SYNOPSIS
		Gets one or more circuits
	
	.DESCRIPTION
		A detailed description of the Get-NetboxCircuit function.
	
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
	
	.PARAMETER Id
		Database ID of circuit. This will query for exactly the IDs provided
	
	.PARAMETER ID__IN
		Multiple unique DB IDs to retrieve
	
	.EXAMPLE
		PS C:\> Get-NetboxCircuit
	
	.NOTES
		Additional information about the function.
#>
	
	[CmdletBinding()]
	param
	(
		[string]$CID,
		
		[datetime]$InstallDate,
		
		[uint32]$CommitRate,
		
		[string]$Query,
		
		[object]$Provider,
		
		[object]$Type,
		
		[string]$Site,
		
		[string]$Tenant,
		
		[uint16[]]$Id
	)
	
	#TODO: Place script here
}
