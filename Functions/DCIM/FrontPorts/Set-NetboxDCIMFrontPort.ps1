function Set-NetboxDCIMFrontPort {
    [CmdletBinding(ConfirmImpact = 'Medium',
        SupportsShouldProcess = $true)]
    [OutputType([pscustomobject])]
    param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
        [uint64[]]$Id,

        [uint16]$Device,

        [uint16]$Module,

        [string]$Name,

        [string]$Label,

        [string]$Type,

        [ValidatePattern('^[0-9a-f]{6}$')]
        [string]$Color,

        [uint16]$Rear_Port,

        [uint16]$Rear_Port_Position,

        [string]$Description,

        [bool]$Mark_Connected,

        [uint16[]]$Tags,

        [switch]$Force
    )

    begin {

    }

    process {
        foreach ($FrontPortID in $Id) {
            $CurrentPort = Get-NetboxDCIMFrontPort -Id $FrontPortID -ErrorAction Stop

            $Segments = [System.Collections.ArrayList]::new(@('dcim', 'front-ports', $CurrentPort.Id))

            $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Id'

            $URI = BuildNewURI -Segments $Segments

            if ($Force -or $pscmdlet.ShouldProcess("Front Port ID $($CurrentPort.Id)", "Set")) {
                InvokeNetboxRequest -URI $URI -Body $URIComponents.Parameters -Method PATCH
            }
        }
    }

    end {

    }
}