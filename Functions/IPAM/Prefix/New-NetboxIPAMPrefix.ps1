<#
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/19/2020 11:52
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	New-NetboxIPAMPrefix.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function New-NetboxIPAMPrefix {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Prefix,

        [object]$Status = 'Active',

        [uint16]$Tenant,

        [object]$Role,

        [bool]$IsPool,

        [string]$Description,

        [uint16]$Site,

        [uint16]$VRF,

        [uint16]$VLAN,

        [hashtable]$Custom_Fields,

        [switch]$Raw
    )

#    $PSBoundParameters.Status = ValidateIPAMChoice -ProvidedValue $Status -PrefixStatus

    <#
    # As of 2018/10/18, this does not appear to be a validated IPAM choice
    if ($null -ne $Role) {
        $PSBoundParameters.Role = ValidateIPAMChoice -ProvidedValue $Role -PrefixRole
    }
    #>

    $segments = [System.Collections.ArrayList]::new(@('ipam', 'prefixes'))

    $URIComponents = BuildURIComponents -URISegments $segments -ParametersDictionary $PSBoundParameters

    $URI = BuildNewURI -Segments $URIComponents.Segments

    InvokeNetboxRequest -URI $URI -Method POST -Body $URIComponents.Parameters -Raw:$Raw
}