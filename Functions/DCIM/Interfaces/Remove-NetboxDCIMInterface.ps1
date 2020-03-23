<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/23/2020 12:11
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Remove-NetboxDCIMInterface.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function Remove-NetboxDCIMInterface {
<#
    .SYNOPSIS
        Removes an interface
    
    .DESCRIPTION
        Removes an interface by ID from a device
    
    .PARAMETER Id
        A description of the Id parameter.
    
    .PARAMETER Force
        A description of the Force parameter.
    
    .EXAMPLE
        		PS C:\> Remove-NetboxDCIMInterface -Id $value1
    
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
        foreach ($InterfaceId in $Id) {
            $CurrentInterface = Get-NetboxDCIMInterface -Id $InterfaceId -ErrorAction Stop
            
            if ($Force -or $pscmdlet.ShouldProcess("Name: $($CurrentInterface.Name) | ID: $($CurrentInterface.Id)", "Remove")) {
                $Segments = [System.Collections.ArrayList]::new(@('dcim', 'interfaces', $CurrentInterface.Id))
                
                $URI = BuildNewURI -Segments $Segments
                
                InvokeNetboxRequest -URI $URI -Method DELETE
            }
        }
    }
    
    end {
        
    }
}