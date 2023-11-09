

function Set-NetboxContactAssignment {
<#
    .SYNOPSIS
        Update a contact role assignment in Netbox

    .DESCRIPTION
        Updates a contact role assignment in Netbox

    .PARAMETER Content_Type
        The content type for this assignment.

    .PARAMETER Object_Id
        ID of the object to assign.

    .PARAMETER Contact
        ID of the contact to assign.

    .PARAMETER Role
        ID of the contact role to assign.

    .PARAMETER Priority
        Priority of the contact assignment.

    .PARAMETER Raw
        Return the unparsed data from the HTTP request

    .EXAMPLE
        PS C:\> Set-NetboxContactAssignment -Id 11 -Content_Type 'dcim.location' -Object_id 10 -Contact 15 -Role 10 -Priority 'Primary'

    .NOTES
        Valid content types: https://docs.netbox.dev/en/stable/features/contacts/#contacts_1
#>

    [CmdletBinding(ConfirmImpact = 'Low',
                   SupportsShouldProcess = $true)]
    [OutputType([pscustomobject])]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [uint64[]]$Id,

        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [ValidateSet('circuits.circuit', 'circuits.provider', 'circuits.provideraccount', 'dcim.device', 'dcim.location', 'dcim.manufacturer', 'dcim.powerpanel', 'dcim.rack', 'dcim.region', 'dcim.site', 'dcim.sitegroup', 'tenancy.tenant', 'virtualization.cluster', 'virtualization.clustergroup', 'virtualization.virtualmachine', IgnoreCase = $true)]
        [string]$Content_Type,

        [uint64]$Object_Id,

        [uint64]$Contact,

        [uint64]$Role,

        [ValidateSet('primary', 'secondary', 'tertiary', 'inactive', IgnoreCase = $true)]
        [string]$Priority,

        [switch]$Raw
    )

    begin {
        $Method = 'Patch'
    }

    process {
        foreach ($ContactAssignmentId in $Id) {
            $Segments = [System.Collections.ArrayList]::new(@('tenancy', 'contact-assignments', $ContactAssignmentId))

            $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Id', 'Force'

            $URI = BuildNewURI -Segments $URIComponents.Segments

            $CurrentContactAssignment = Get-NetboxContactAssignment -Id $ContactAssignmentId -ErrorAction Stop

            if ($PSCmdlet.ShouldProcess($CurrentContactAssignment.Id, 'Update contact assignment')) {
                InvokeNetboxRequest -URI $URI -Method $Method -Body $URIComponents.Parameters -Raw:$Raw
            }
        }
    }
}




