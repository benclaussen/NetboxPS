

function New-NetboxIPAMAddressRange {
<#
    .SYNOPSIS
        Create a new IP address range to Netbox

    .DESCRIPTION
        Create a new IP address range to Netbox with a status of Active by default. The maximum supported
        size of an IP range is 2^32 - 1.

    .PARAMETER Start_Address
        Starting IPv4 or IPv6 address (with mask). The maximum supported size of an IP range is 2^32 - 1.

    .PARAMETER End_Address
        Ending IPv4 or IPv6 address (with mask). The maximum supported size of an IP range is 2^32 - 1.

    .PARAMETER Status
        Operational status of this range. Defaults to Active

    .PARAMETER Tenant
        Tenant ID

    .PARAMETER VRF
        VRF ID

    .PARAMETER Role
        Role such as backup, customer, development, etc... Defaults to nothing

    .PARAMETER Custom_Fields
        Custom field hash table. Will be validated by the API service

    .PARAMETER Description
        Description of IP address range

    .PARAMETER Comments
        Extra comments (markdown supported).

    .PARAMETER Tags
        One or more tags.

    .PARAMETER Mark_Utilized
        Treat as 100% utilized

    .PARAMETER Raw
        Return raw results from API service

    .EXAMPLE
        New-NetboxIPAMAddressRange -Start_Address 192.0.2.20/24 -End_Address 192.0.2.20/24

        Add new IP Address range from 192.0.2.20/24 to 192.0.2.20/24 with status active

    .NOTES
        https://netbox.neonet.org/static/docs/models/ipam/iprange/
#>

    [CmdletBinding(ConfirmImpact = 'Low',
                   SupportsShouldProcess = $true)]
    [OutputType([pscustomobject])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Start_Address,

        [Parameter(Mandatory = $true)]
        [string]$End_Address,

        [object]$Status = 'Active',

        [uint64]$Tenant,

        [uint64]$VRF,

        [object]$Role,

        [hashtable]$Custom_Fields,

        [uint64]$Interface,

        [string]$Description,

        [string]$Comments,

        [object[]]$Tags,

        [switch]$Mark_Utilized,

        [switch]$Raw
    )

    process {
        $Segments = [System.Collections.ArrayList]::new(@('ipam', 'ip-ranges'))
        $Method = 'POST'

        $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters

        $URI = BuildNewURI -Segments $URIComponents.Segments

        if ($PSCmdlet.ShouldProcess($Start_Address, 'Create new IP address range')) {
            InvokeNetboxRequest -URI $URI -Method $Method -Body $URIComponents.Parameters -Raw:$Raw
        }
    }
}





