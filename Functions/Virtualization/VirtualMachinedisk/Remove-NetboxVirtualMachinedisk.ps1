
function Remove-NetboxVirtualMachineDisk {
<#
    .SYNOPSIS
        Delete a virtual machine disk

    .DESCRIPTION
        Deletes a virtual machine disk from Netbox by ID

    .PARAMETER Id
        Database ID of the virtual machine disk

    .PARAMETER Force
        Force deletion without any prompts

    .EXAMPLE
        PS C:\> Remove-NetboxVirtualMachineDisk -Id $value1

    .NOTES
        Additional information about the function.
#>

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
        foreach ($DiskId in $Id) {
            $CurrentDisk = Get-NetboxVirtualMachineDisk -Id $DiskId -ErrorAction Stop

            if ($Force -or $pscmdlet.ShouldProcess("$($CurrentDisk.Name)/$($CurrentDisk.Id)", "Remove")) {
                $Segments = [System.Collections.ArrayList]::new(@('virtualization', 'virtual-disks', $CurrentDisk.Id))

                $URI = BuildNewURI -Segments $Segments

                InvokeNetboxRequest -URI $URI -Method DELETE
            }
        }
    }

    end {

    }
}
