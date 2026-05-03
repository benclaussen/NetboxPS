function Remove-NetboxDCIMPlatform {

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
        foreach ($PlatformID in $Id) {
            $CurrentPlatform = Get-NetboxDCIMPlatform -Id $PlatformID -ErrorAction Stop

            if ($Force -or $pscmdlet.ShouldProcess("Name: $($CurrentPlatform.Name) | ID: $($CurrentPlatform.Id)", "Remove")) {
                $Segments = [System.Collections.ArrayList]::new(@('dcim', 'platforms', $CurrentPlatform.Id))

                $URI = BuildNewURI -Segments $Segments

                InvokeNetboxRequest -URI $URI -Method DELETE
            }
        }
    }

    end {

    }
}