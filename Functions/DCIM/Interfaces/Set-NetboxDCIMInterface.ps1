<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/23/2020 12:11
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Set-NetboxDCIMInterface.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function Set-NetboxDCIMInterface {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [uint16[]]$Id,
        
        [uint16]$Device,
        
        [string]$Name,
        
        [bool]$Enabled,
        
        [object]$Form_Factor,
        
        [uint16]$MTU,
        
        [string]$MAC_Address,
        
        [bool]$MGMT_Only,
        
        [uint16]$LAG,
        
        [string]$Description,
        
        [ValidateSet('Access', 'Tagged', 'Tagged All', '100', '200', '300', IgnoreCase = $true)]
        [string]$Mode,
        
        [ValidateRange(1, 4094)]
        [uint16]$Untagged_VLAN,
        
        [ValidateRange(1, 4094)]
        [uint16[]]$Tagged_VLANs
    )
    
    begin {
#        if ($null -ne $Form_Factor) {
#            $PSBoundParameters.Form_Factor = ValidateDCIMChoice -ProvidedValue $Form_Factor -InterfaceFormFactor
#        }
        
        if (-not [System.String]::IsNullOrWhiteSpace($Mode)) {
            $PSBoundParameters.Mode = switch ($Mode) {
                'Access' {
                    100
                    break
                }
                
                'Tagged' {
                    200
                    break
                }
                
                'Tagged All' {
                    300
                    break
                }
                
                default {
                    $_
                }
            }
        }
    }
    
    process {
        foreach ($InterfaceId in $Id) {
            $CurrentInterface = Get-NetboxDCIMInterface -Id $InterfaceId -ErrorAction Stop
            
            $Segments = [System.Collections.ArrayList]::new(@('dcim', 'interfaces', $CurrentInterface.Id))
            
            $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Id'
            
            $URI = BuildNewURI -Segments $Segments
            
            InvokeNetboxRequest -URI $URI -Body $URIComponents.Parameters -Method PATCH
        }
    }
    
    end {
        
    }
}