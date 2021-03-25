<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.181
	 Created on:   	2020-11-04 11:48
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	New-NetboxCircuit.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>



function New-NetboxCircuit {
    [CmdletBinding(ConfirmImpact = 'Low',
                   SupportsShouldProcess = $true)]
    [OutputType([pscustomobject])]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [string]$CID,
        
        [Parameter(Mandatory = $true)]
        [uint32]$Provider,
        
        [Parameter(Mandatory = $true)]
        [uint32]$Type,
        
        #[ValidateSet('Active', 'Planned', 'Provisioning', 'Offline', 'Deprovisioning', 'Decommissioned ')]
        [uint16]$Status = 'Active',
        
        [string]$Description,
        
        [uint32]$Tenant,
        
        [string]$Termination_A,
        
        [datetime]$Install_Date,
        
        [string]$Termination_Z,
        
        [ValidateRange(0, 2147483647)]
        [uint32]$Commit_Rate,
        
        [string]$Comments,
        
        [hashtable]$Custom_Fields,
        
        [switch]$Force,
        
        [switch]$Raw
    )
    
    $Segments = [System.Collections.ArrayList]::new(@('circuits', 'circuits'))
    $Method = 'POST'
    
    $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters
    
    $URI = BuildNewURI -Segments $URIComponents.Segments
    
    if ($Force -or $PSCmdlet.ShouldProcess($CID, 'Create new circuit')) {
        InvokeNetboxRequest -URI $URI -Method $Method -Body $URIComponents.Parameters -Raw:$Raw
    }
}