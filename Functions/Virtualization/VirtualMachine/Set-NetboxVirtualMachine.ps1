<#
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/19/2020 12:45
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Set-NetboxVirtualMachine.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function Set-NetboxVirtualMachine {
    [CmdletBinding(ConfirmImpact = 'Medium',
        SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
        [uint16]$Id,

        [string]$Name,

        [uint16]$Role,

        [uint16]$Cluster,

        [object]$Status,

        [uint16]$Platform,

        [uint16]$Primary_IP4,

        [uint16]$Primary_IP6,

        [byte]$VCPUs,

        [uint16]$Memory,

        [uint16]$Disk,

        [uint16]$Tenant,

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