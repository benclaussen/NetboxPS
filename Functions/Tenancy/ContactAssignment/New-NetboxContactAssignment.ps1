
function New-NetboxContactRole {
<#
    .SYNOPSIS
        Create a new contact role in Netbox

    .DESCRIPTION
        Creates a new contact role object in Netbox

    .PARAMETER Content_Type
        A description of the Content_Type parameter.

    .PARAMETER Object_Id
        A description of the Object_Id parameter.

    .PARAMETER Contact
        A description of the Contact parameter.

    .PARAMETER Role
        A description of the Role parameter.

    .PARAMETER Priority
        A description of the Priority parameter.

    .PARAMETER Raw
        Return the unparsed data from the HTTP request

    .EXAMPLE
        PS C:\> New-NetboxContactAssignment -Name 'Leroy Jenkins' -Email 'leroy.jenkins@example.com'

    .NOTES
        Additional information about the function.
#>

    [CmdletBinding(ConfirmImpact = 'Low',
                   SupportsShouldProcess = $true)]
    [OutputType([pscustomobject])]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [object]$Content_Type,

        [Parameter(Mandatory = $true)]
        [uint64]$Object_Id,

        [Parameter(Mandatory = $true)]
        [uint64]$Contact,

        [Parameter(Mandatory = $true)]
        [uint64]$Role,

        [ValidateSet('primary', 'secondary', 'tertiary', 'inactive', IgnoreCase = $true)]
        [string]$Priority,

        [switch]$Raw
    )

    begin {
        # https://docs.netbox.dev/en/stable/features/contacts/
        $AllowedContentTypes = @{
            10 = "circuits.circuit"
            7  = "circuits.provider"
            19 = "dcim.device"
            25 = "dcim.location"
            29 = "dcim.manufacturer"
            77 = "dcim.powerpanel"
            20 = "dcim.rack"
            30 = "dcim.region"
            18 = "dcim.site"
            92 = "dcim.sitegroup"
            58 = "tenancy.tenant"
            63 = "virtualization.cluster"
            64 = "virtualization.clustergroup"
            61 = "virtualization.virtualmachine"
        }
    }

    process {
        $Segments = [System.Collections.ArrayList]::new(@('tenancy', 'contact-assignment'))
        $Method = 'POST'

        if ($Content_Type -is [string]) {
            # Need to convert this to an integer
            $Content_Type = ($AllowedContentTypes.GetEnumerator() | Where-Object {
                    $_.Value -eq $Content_Type
                }).Key
        } elseif ($Content_Type -is [int]) {
            if ($Content_Type -notin $($AllowedContentTypes).Keys) {
                throw "Invalid content type defined"
            }
        } else {
            throw "Invalid content type defined"
        }

        $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters

        $URI = BuildNewURI -Segments $URIComponents.Segments

        if ($PSCmdlet.ShouldProcess($Address, 'Create new contact assignment')) {
            InvokeNetboxRequest -URI $URI -Method $Method -Body $URIComponents.Parameters -Raw:$Raw
        }
    }
}




