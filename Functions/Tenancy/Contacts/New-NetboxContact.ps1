
function New-NetboxContact {
<#
    .SYNOPSIS
        Create a new contact in Netbox

    .DESCRIPTION
        Creates a new contact object in Netbox which can be linked to other objects

    .PARAMETER Name
        The contacts full name, e.g "Leroy Jenkins"

    .PARAMETER Email
        Email address of the contact

    .PARAMETER Title
        Job title or other title related to the contact

    .PARAMETER Phone
        Telephone number

    .PARAMETER Address
        Physical address, usually mailing address

    .PARAMETER Description
        Short description of the contact

    .PARAMETER Comments
        Detailed comments. Markdown supported.

    .PARAMETER Link
        URI related to the contact

    .PARAMETER Custom_Fields
        A description of the Custom_Fields parameter.

    .PARAMETER Raw
        A description of the Raw parameter.

    .EXAMPLE
        PS C:\> New-NetboxContact -Name 'Leroy Jenkins' -Email 'leroy.jenkins@example.com'

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
        [ValidateLength(0, 254)]
        [string]$Email,

        [ValidateLength(0, 100)]
        [string]$Title,

        [ValidateLength(0, 50)]
        [string]$Phone,

        [ValidateLength(0, 200)]
        [string]$Address,

        [ValidateLength(0, 200)]
        [string]$Description,

        [string]$Comments,

        [ValidateLength(0, 200)]
        [string]$Link,

        [hashtable]$Custom_Fields,

        [switch]$Raw
    )

    process {
        $Segments = [System.Collections.ArrayList]::new(@('tenancy', 'contacts'))
        $Method = 'POST'

        $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters

        $URI = BuildNewURI -Segments $URIComponents.Segments

        if ($PSCmdlet.ShouldProcess($Name, 'Create new contact')) {
            InvokeNetboxRequest -URI $URI -Method $Method -Body $URIComponents.Parameters -Raw:$Raw
        }
    }
}




