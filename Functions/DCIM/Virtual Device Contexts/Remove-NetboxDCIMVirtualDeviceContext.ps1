function Remove-NetboxDCIMVirtualDeviceContext {
    [CmdletBinding(ConfirmImpact = 'High',
        SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
        [uint64[]]$Id,

        [switch]$Force
    )

    begin {

    }

    process {
        foreach ($VirtualDeviceContextId in $Id) {
            $CurrentVirtualDeviceContext = Get-NetboxDCIMVirtualDeviceContext -Id $VirtualDeviceContextId -ErrorAction Stop

            if ($Force -or $pscmdlet.ShouldProcess("Name: $($CurrentVirtualDeviceContext.Name) | ID: $($CurrentVirtualDeviceContext.Id)", "Remove")) {
                $Segments = [System.Collections.ArrayList]::new(@('dcim', 'virtual-device-contexts', $CurrentVirtualDeviceContext.Id))

                $URI = BuildNewURI -Segments $Segments

                InvokeNetboxRequest -URI $URI -Method DELETE
            }
        }
    }

    end {

    }
}