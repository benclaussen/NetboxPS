<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/19/2020 12:45
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Remove-NetboxVirtualMachine.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function Remove-NetboxVirtualMachine {
<#
    .SYNOPSIS
        Delete a virtual machine
    
    .DESCRIPTION
        Deletes a virtual machine from Netbox by ID
    
    .PARAMETER Id
        Database ID of the virtual machine
    
    .PARAMETER Force
        Force deletion without any prompts
    
    .EXAMPLE
        PS C:\> Remove-NetboxVirtualMachine -Id $value1
    
    .NOTES
        Additional information about the function.
#>
    
    [CmdletBinding(ConfirmImpact = 'High',
                   SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [uint16[]]$Id,
        
        [switch]$Force
    )
    
    begin {
        
    }
    
    process {
        foreach ($VMId in $Id) {
            $CurrentVM = Get-NetboxVirtualMachine -Id $VMId -ErrorAction Stop
            
            if ($Force -or $pscmdlet.ShouldProcess("$($CurrentVM.Name)/$($CurrentVM.Id)", "Remove")) {
                $Segments = [System.Collections.ArrayList]::new(@('virtualization', 'virtual-machines', $CurrentVM.Id))
                
                $URI = BuildNewURI -Segments $Segments
                
                InvokeNetboxRequest -URI $URI -Method DELETE
            }
        }
    }
    
    end {
        
    }
}