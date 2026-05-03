
function Set-NetboxVirtualMachineDisk {
    [CmdletBinding(ConfirmImpact = 'Medium',
                   SupportsShouldProcess = $true)]
    [OutputType([pscustomobject])]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [uint64[]]$Id,

        [string]$Name,

        [uint64]$Size,

        [string]$Description,

        [uint64]$Virtual_Machine,

        [hashtable]$Custom_Fields,

        [switch]$Force
    )

    begin {

    }

    process {
        foreach ($VMI_ID in $Id) {
            Write-Verbose "Obtaining VM virtual disk..."
            $CurrentVMI = Get-NetboxVirtualMachinedisk -Id $VMI_ID -ErrorAction Stop
            Write-Verbose "Finished obtaining VM disk"

            $Segments = [System.Collections.ArrayList]::new(@('virtualization', 'virtual-disks', $CurrentVMI.Id))

            if ($Force -or $pscmdlet.ShouldProcess("Disk $($CurrentVMI.Id) on VM $($CurrentVMI.Virtual_Machine.Name)", "Set")) {
                $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Id', 'Force'

                $URI = BuildNewURI -Segments $URIComponents.Segments

                InvokeNetboxRequest -URI $URI -Body $URIComponents.Parameters -Method PATCH
            }
        }
    }

    end {

    }
}