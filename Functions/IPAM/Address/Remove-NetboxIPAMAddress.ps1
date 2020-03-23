<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/19/2020 11:52
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Remove-NetboxIPAMAddress.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>

function Remove-NetboxIPAMAddress {
<#
    .SYNOPSIS
        Remove an IP address from Netbox
    
    .DESCRIPTION
        Removes/deletes an IP address from Netbox by ID and optional other filters
    
    .PARAMETER Id
        Database ID of the IP address object.
    
    .PARAMETER Force
        Do not confirm.
    
    .EXAMPLE
        PS C:\> Remove-NetboxIPAMAddress -Id $value1
    
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
        foreach ($IPId in $Id) {
            $CurrentIP = Get-NetboxIPAMAddress -Id $IPId -ErrorAction Stop
            
            $Segments = [System.Collections.ArrayList]::new(@('ipam', 'ip-addresses', $IPId))
            
            if ($Force -or $pscmdlet.ShouldProcess($CurrentIP.Address, "Delete")) {
                $URI = BuildNewURI -Segments $Segments
                
                InvokeNetboxRequest -URI $URI -Method DELETE
            }
        }
    }
    
    end {
    }
}