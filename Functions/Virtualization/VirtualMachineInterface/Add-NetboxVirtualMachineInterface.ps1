<#
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/19/2020 12:46
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Add-NetboxVirtualMachineInterface.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function Add-NetboxVirtualMachineInterface {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [uint16]$Virtual_Machine,

        [boolean]$Enabled = $true,

        [string]$MAC_Address,

        [uint16]$MTU,

        [string]$Description,

        [switch]$Raw
    )

    $Segments = [System.Collections.ArrayList]::new(@('virtualization', 'interfaces'))

    $PSBoundParameters.Enabled = $Enabled

    $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters

    $uri = BuildNewURI -Segments $URIComponents.Segments

    InvokeNetboxRequest -URI $uri -Method POST -Body $URIComponents.Parameters
}