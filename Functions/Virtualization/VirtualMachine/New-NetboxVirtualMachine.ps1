<#
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/19/2020 12:44
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	New-NetboxVirtualMachine.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function New-NetboxVirtualMachine {
    [CmdletBinding(ConfirmImpact = 'low',
        SupportsShouldProcess = $true)]
    [OutputType([pscustomobject])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [uint16]$Cluster,

        [uint16]$Tenant,

        [object]$Status = 'Active',

        [uint16]$Role,

        [uint16]$Platform,

        [uint16]$vCPUs,

        [uint16]$Memory,

        [uint16]$Disk,

        [uint16]$Primary_IP4,

        [uint16]$Primary_IP6,

        [hashtable]$Custom_Fields,

        [string]$Comments
    )

    #    $ModelDefinition = $script:NetboxConfig.APIDefinition.definitions.WritableVirtualMachineWithConfigContext

    #    # Validate the status against the APIDefinition
    #    if ($ModelDefinition.properties.status.enum -inotcontains $Status) {
    #        throw ("Invalid value [] for Status. Must be one of []" -f $Status, ($ModelDefinition.properties.status.enum -join ', '))
    #    }

    #$PSBoundParameters.Status = ValidateVirtualizationChoice -ProvidedValue $Status -VirtualMachineStatus

    $Segments = [System.Collections.ArrayList]::new(@('virtualization', 'virtual-machines'))

    $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters

    $URI = BuildNewURI -Segments $URIComponents.Segments

    if ($PSCmdlet.ShouldProcess($name, 'Create new Virtual Machine')) {
        InvokeNetboxRequest -URI $URI -Method POST -Body $URIComponents.Parameters
    }
}




