<#
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/23/2020 12:10
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Add-NetboxDCIMInterfaceConnection.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function Add-NetboxDCIMInterfaceConnection {
<#
    .SYNOPSIS
        Create a new connection between two interfaces

    .DESCRIPTION
        Create a new connection between two interfaces

    .PARAMETER Connection_Status
        Is it connected or planned?

    .PARAMETER Interface_A
        Database ID of interface A

    .PARAMETER Interface_B
        Database ID of interface B

    .EXAMPLE
        PS C:\> Add-NetboxDCIMInterfaceConnection -Interface_A $value1 -Interface_B $value2

    .NOTES
        Additional information about the function.
#>

    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param
    (
        [object]$Connection_Status,

        [Parameter(Mandatory = $true)]
        [uint16]$Interface_A,

        [Parameter(Mandatory = $true)]
        [uint16]$Interface_B
    )

    if ($null -ne $Connection_Status) {
        $PSBoundParameters.Connection_Status = ValidateDCIMChoice -ProvidedValue $Connection_Status -InterfaceConnectionStatus
    }

    # Verify if both Interfaces exist
    $I_A = Get-NetboxDCIMInterface -Id $Interface_A -ErrorAction Stop
    $I_B = Get-NetboxDCIMInterface -Id $Interface_B -ErrorAction Stop

    $Segments = [System.Collections.ArrayList]::new(@('dcim', 'interface-connections'))

    $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters

    $URI = BuildNewURI -Segments $URIComponents.Segments

    InvokeNetboxRequest -URI $URI -Body $URIComponents.Parameters -Method POST
}