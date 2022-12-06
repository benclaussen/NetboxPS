
function Get-NetboxIPAMPrefix {
<#
    .SYNOPSIS
        A brief description of the Get-NetboxIPAMPrefix function.

    .DESCRIPTION
        A detailed description of the Get-NetboxIPAMPrefix function.

    .PARAMETER Query
        A description of the Query parameter.

    .PARAMETER Id
        A description of the Id parameter.

    .PARAMETER Limit
        A description of the Limit parameter.

    .PARAMETER Offset
        A description of the Offset parameter.

    .PARAMETER Family
        A description of the Family parameter.

    .PARAMETER Is_Pool
        A description of the Is_Pool parameter.

    .PARAMETER Within
        Should be a CIDR notation prefix such as '10.0.0.0/16'

    .PARAMETER Within_Include
        Should be a CIDR notation prefix such as '10.0.0.0/16'

    .PARAMETER Contains
        A description of the Contains parameter.

    .PARAMETER Mask_Length
        CIDR mask length value

    .PARAMETER VRF
        A description of the VRF parameter.

    .PARAMETER VRF_Id
        A description of the VRF_Id parameter.

    .PARAMETER Tenant
        A description of the Tenant parameter.

    .PARAMETER Tenant_Id
        A description of the Tenant_Id parameter.

    .PARAMETER Site
        A description of the Site parameter.

    .PARAMETER Site_Id
        A description of the Site_Id parameter.

    .PARAMETER Vlan_VId
        A description of the Vlan_VId parameter.

    .PARAMETER Vlan_Id
        A description of the Vlan_Id parameter.

    .PARAMETER Status
        A description of the Status parameter.

    .PARAMETER Role
        A description of the Role parameter.

    .PARAMETER Role_Id
        A description of the Role_Id parameter.

    .PARAMETER Raw
        A description of the Raw parameter.

    .EXAMPLE
        PS C:\> Get-NetboxIPAMPrefix

    .NOTES
        Additional information about the function.
#>

    [CmdletBinding(DefaultParameterSetName = 'Query')]
    param
    (
        [Parameter(ParameterSetName = 'Query',
                   Position = 0)]
        [string]$Prefix,

        [Parameter(ParameterSetName = 'Query')]
        [string]$Query,

        [Parameter(ParameterSetName = 'ByID')]
        [uint32[]]$Id,

        [Parameter(ParameterSetName = 'Query')]
        [object]$Family,

        [Parameter(ParameterSetName = 'Query')]
        [boolean]$Is_Pool,

        [Parameter(ParameterSetName = 'Query')]
        [string]$Within,

        [Parameter(ParameterSetName = 'Query')]
        [string]$Within_Include,

        [Parameter(ParameterSetName = 'Query')]
        [string]$Contains,

        [Parameter(ParameterSetName = 'Query')]
        [ValidateRange(0, 127)]
        [byte]$Mask_Length,

        [Parameter(ParameterSetName = 'Query')]
        [string]$VRF,

        [Parameter(ParameterSetName = 'Query')]
        [uint32]$VRF_Id,

        [Parameter(ParameterSetName = 'Query')]
        [string]$Tenant,

        [Parameter(ParameterSetName = 'Query')]
        [uint32]$Tenant_Id,

        [Parameter(ParameterSetName = 'Query')]
        [string]$Site,

        [Parameter(ParameterSetName = 'Query')]
        [uint32]$Site_Id,

        [Parameter(ParameterSetName = 'Query')]
        [string]$Vlan_VId,

        [Parameter(ParameterSetName = 'Query')]
        [uint32]$Vlan_Id,

        [Parameter(ParameterSetName = 'Query')]
        [object]$Status,

        [Parameter(ParameterSetName = 'Query')]
        [string]$Role,

        [Parameter(ParameterSetName = 'Query')]
        [uint32]$Role_Id,

        [Parameter(ParameterSetName = 'Query')]
        [uint16]$Limit,

        [Parameter(ParameterSetName = 'Query')]
        [uint16]$Offset,

        [switch]$Raw
    )

    #    if ($null -ne $Family) {
    #        $PSBoundParameters.Family = ValidateIPAMChoice -ProvidedValue $Family -PrefixFamily
    #    }
    #
    #    if ($null -ne $Status) {
    #        $PSBoundParameters.Status = ValidateIPAMChoice -ProvidedValue $Status -PrefixStatus
    #    }

    switch ($PSCmdlet.ParameterSetName) {
        'ById' {
            foreach ($Prefix_ID in $Id) {
                $Segments = [System.Collections.ArrayList]::new(@('ipam', 'prefixes', $Prefix_ID))

                $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Id'

                $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters

                InvokeNetboxRequest -URI $uri -Raw:$Raw
            }

            break
        }

        default {
            $Segments = [System.Collections.ArrayList]::new(@('ipam', 'prefixes'))

            $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters

            $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters

            InvokeNetboxRequest -URI $uri -Raw:$Raw

            break
        }
    }
}