
function Set-NetboxVirtualMachine {
    [CmdletBinding(ConfirmImpact = 'Medium',
        SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
        [uint64]$Id,

        [string]$Name,

        [uint64]$Role,

        [uint64]$Cluster,

        [object]$Status,

        [uint64]$Platform,

        [uint64]$Primary_IP4,

        [uint64]$Primary_IP6,

        [byte]$VCPUs,

        [uint64]$Memory,

        [uint64]$Disk,

        [uint64]$Tenant,

        [string]$Comments,

        [hashtable]$Custom_Fields,

        [switch]$Force
    )

    #    if ($null -ne $Status) {
    #        $PSBoundParameters.Status = ValidateVirtualizationChoice -ProvidedValue $Status -VirtualMachineStatus
    #    }

    process {
        $Segments = [System.Collections.ArrayList]::new(@('virtualization', 'virtual-machines', $Id))

        Write-Verbose "Obtaining VM from ID $Id"

        #$CurrentVM = Get-NetboxVirtualMachine -Id $Id -ErrorAction Stop

        Write-Verbose "Finished obtaining VM"

        if ($Force -or $pscmdlet.ShouldProcess($ID, "Set properties on VM ID")) {
            $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Id', 'Force'

            $URI = BuildNewURI -Segments $URIComponents.Segments

            InvokeNetboxRequest -URI $URI -Body $URIComponents.Parameters -Method PATCH
        }
    }
}