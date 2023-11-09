
function Set-NetboxContact {
<#
    .SYNOPSIS
        Update a contact in Netbox

    .DESCRIPTION
        Updates a contact object in Netbox which can be linked to other objects

    .PARAMETER Id
        A description of the Id parameter.

    .PARAMETER Name
        The contacts full name, e.g "Leroy Jenkins"

    .PARAMETER Email
        Email address of the contact

    .PARAMETER Group
        Database ID of assigned group

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

    .PARAMETER Force
        A description of the Force parameter.

    .PARAMETER Raw
        A description of the Raw parameter.

    .EXAMPLE
        PS C:\> Set-NetboxContact -Id 10 -Name 'Leroy Jenkins' -Email 'leroy.jenkins@example.com'

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
        [uint64[]]$Id,

        [ValidateLength(1, 100)]
        [string]$Name,

        [ValidateLength(0, 254)]
        [string]$Email,

        [uint64]$Group,

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

        [switch]$Force,

        [switch]$Raw
    )

    begin {
        $Method = 'PATCH'
    }

    process {
        foreach ($ContactId in $Id) {
            $Segments = [System.Collections.ArrayList]::new(@('tenancy', 'contacts', $ContactId))

            $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Id', 'Force'

            $URI = BuildNewURI -Segments $URIComponents.Segments

            $CurrentContact = Get-NetboxContact -Id $ContactId -ErrorAction Stop

            if ($Force -or $PSCmdlet.ShouldProcess($CurrentContact.Name, 'Update contact')) {
                InvokeNetboxRequest -URI $URI -Method $Method -Body $URIComponents.Parameters -Raw:$Raw
            }
        }
    }
}




