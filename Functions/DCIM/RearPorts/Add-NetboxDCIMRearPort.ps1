function Add-NetboxDCIMRearPort {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param
    (
        [Parameter(Mandatory = $true)]
        [uint16]$Device,

        [uint16]$Module,

        [Parameter(Mandatory = $true)]
        [string]$Name,

        [string]$Label,

        [Parameter(Mandatory = $true)]
        [string]$Type,

        [ValidatePattern('^[0-9a-f]{6}$')]
        [string]$Color,

        [uint16]$Positions = 1,

        [string]$Description,

        [bool]$Mark_Connected,

        [uint16[]]$Tags,

        [string[]]$Tags_Slug

    )

    begin {
        if (-not [System.String]::IsNullOrWhiteSpace($Tags_Slug)) {
            if ([System.String]::IsNullOrWhiteSpace($Tags)) {
                $PSBoundParameters.Tags = @()
            }
            foreach ($CurrentTagSlug in $Tags_Slug) {
                $CurrentTagID = (Get-NetboxTag -slug $CurrentTagSlug -ErrorAction Stop).Id
                $PSBoundParameters.Tags += $CurrentTagID
            }
        }
    }

    process {
        $Segments = [System.Collections.ArrayList]::new(@('dcim', 'rear-ports'))

        $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Tags_Slug'

        $URI = BuildNewURI -Segments $URIComponents.Segments

        InvokeNetboxRequest -URI $URI -Body $URIComponents.Parameters -Method POST
    }

    end {

    }
}