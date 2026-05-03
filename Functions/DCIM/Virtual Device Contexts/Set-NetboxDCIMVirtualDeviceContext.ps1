function Set-NetboxDCIMVirtualDeviceContext {
    [CmdletBinding(ConfirmImpact = 'Medium',
        SupportsShouldProcess = $true)]
    [OutputType([pscustomobject])]
    param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
        [uint64[]]$Id,

        [string]$Name,

        [object]$Status,

        [uint16]$Identifier,

        [uint64]$Device,

        [uint64]$Primary_IP4,

        [uint64]$Primary_IP6,

        [uint64]$Tenant,

        [string]$Comments,

        [switch]$Force
    )

    process {
        foreach ($VirtualDeviceContextId in $Id) {
            $CurrentVirtualDeviceContext = Get-NetboxDCIMVirtualDeviceContext -Id $VirtualDeviceContextId -ErrorAction Stop

            $Segments = [System.Collections.ArrayList]::new(@('dcim', 'virtual-device-contexts', $CurrentVirtualDeviceContext.Id))

            $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Id'

            $URI = BuildNewURI -Segments $Segments

            if ($Force -or $pscmdlet.ShouldProcess("Virtual Device Context ID $($CurrentVirtualDeviceContext.Id)", "Set")) {
                InvokeNetboxRequest -URI $URI -Body $URIComponents.Parameters -Method PATCH
            }
        }
    }
}