
function Remove-NetboxDCIMRearPort
{

    [CmdletBinding(ConfirmImpact = 'High',
        SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
        [uint16[]]$Id,

        [switch]$Force
    )

    begin
    {

    }

    process
    {
        foreach ($RearPortID in $Id)
        {
            $CurrentPort = Get-NetboxDCIMRearPort -Id $RearPortID -ErrorAction Stop

            if ($Force -or $pscmdlet.ShouldProcess("Name: $($CurrentPort.Name) | ID: $($CurrentPort.Id)", "Remove"))
            {
                $Segments = [System.Collections.ArrayList]::new(@('dcim', 'rear-ports', $CurrentPort.Id))

                $URI = BuildNewURI -Segments $Segments

                InvokeNetboxRequest -URI $URI -Method DELETE
            }
        }
    }

    end
    {

    }
}