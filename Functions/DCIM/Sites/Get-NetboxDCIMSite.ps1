<#
    .NOTES
    ===========================================================================
     Created with:  SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.181
     Created on:    2020-10-02 15:52
     Created by:    Claussen
     Organization:  NEOnet
     Filename:      Get-NetboxDCIMSite.ps1
    ===========================================================================
    .DESCRIPTION
        A description of the file.
#>



function Get-NetboxDCIMSite {
    [CmdletBinding(DefaultParameterSetName = 'Query')]
    [OutputType([pscustomobject])]
    param
    (
        [Parameter(ParameterSetName = 'ByID', ValueFromPipelineByPropertyName = $true)]
        [uint32]$Id,

        [Parameter(ParameterSetName = 'Query')]
        [string]$Name,

        [Parameter(ParameterSetName = 'Query')]
        [string]$Query,

        [Parameter(ParameterSetName = 'Query')]
        [string]$Slug,

        [Parameter(ParameterSetName = 'Query')]
        [string]$Facility,

        [Parameter(ParameterSetName = 'Query')]
        [uint32]$ASN,

        [Parameter(ParameterSetName = 'Query')]
        [decimal]$Latitude,

        [Parameter(ParameterSetName = 'Query')]
        [decimal]$Longitude,

        [Parameter(ParameterSetName = 'Query')]
        [string]$Contact_Name,

        [Parameter(ParameterSetName = 'Query')]
        [string]$Contact_Phone,

        [Parameter(ParameterSetName = 'Query')]
        [string]$Contact_Email,

        [Parameter(ParameterSetName = 'Query')]
        [uint32]$Tenant_Group_ID,

        [Parameter(ParameterSetName = 'Query')]
        [string]$Tenant_Group,

        [Parameter(ParameterSetName = 'Query')]
        [uint32]$Tenant_ID,

        [Parameter(ParameterSetName = 'Query')]
        [string]$Tenant,

        [Parameter(ParameterSetName = 'Query')]
        [string]$Status,

        [Parameter(ParameterSetName = 'Query')]
        [uint32]$Region_ID,

        [Parameter(ParameterSetName = 'Query')]
        [string]$Region,

        [Parameter(ParameterSetName = 'Query')]
        [uint16]$Limit,

        [Parameter(ParameterSetName = 'Query')]
        [uint16]$Offset,

        [switch]$Raw
    )

    process {
        switch ($PSCmdlet.ParameterSetName) {
            'ById' {
                foreach ($Site_ID in $ID) {
                    $Segments = [System.Collections.ArrayList]::new(@('dcim', 'sites', $Site_Id))

                    $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters -SkipParameterByName "Id"

                    $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters

                    InvokeNetboxRequest -URI $URI -Raw:$Raw
                }
            }

            default {
                $Segments = [System.Collections.ArrayList]::new(@('dcim', 'sites'))

                $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters

                $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters

                InvokeNetboxRequest -URI $URI -Raw:$Raw
            }
        }
    }
}
