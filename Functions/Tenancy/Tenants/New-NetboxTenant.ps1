
function New-NetboxTenant {
<#
    .SYNOPSIS
        Create a new tenant in Netbox

    .DESCRIPTION
        Creates a new tenant object in Netbox

    .PARAMETER Name
        The tenant name, e.g "Contoso Inc"

    .PARAMETER Slug
        The unique URL for the tenant. Can only contain hypens, A-Z, a-z, 0-9, and underscores

    .PARAMETER Description
        Short description of the tenant

    .PARAMETER Custom_Fields
        Hashtable of custom field values.

    .PARAMETER Raw
        Return the unparsed data from the HTTP request

    .EXAMPLE
        PS C:\> New-NetboxTenant -Name 'Contoso Inc' -Slug 'contoso-inc'

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
        [ValidateLength(1, 100)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [ValidateLength(1, 100)]
        [ValidatePattern('^[-a-zA-Z0-9_]+$')]
        [string]$Slug,

        [ValidateLength(0, 200)]
        [string]$Description,

        [hashtable]$Custom_Fields,

        [switch]$Raw
    )

    process {
        $Segments = [System.Collections.ArrayList]::new(@('tenancy', 'tenants'))
        $Method = 'POST'

        $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters

        $URI = BuildNewURI -Segments $URIComponents.Segments

        if ($PSCmdlet.ShouldProcess($Address, 'Create new tenant')) {
            InvokeNetboxRequest -URI $URI -Method $Method -Body $URIComponents.Parameters -Raw:$Raw
        }
    }
}




