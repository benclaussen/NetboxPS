<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2018 v5.5.152
	 Created on:   	5/22/2018 4:47 PM
	 Created by:   	Ben Claussen
	 Organization: 	NEOnet
	 Filename:     	DCIM.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>

function Get-NetboxDCIMChoices {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "", Justification = "These are literally 'choices' in Netbox")]
    param ()
    
    $uriSegments = [System.Collections.ArrayList]::new(@('dcim', '_choices'))
    
    $uri = BuildNewURI -Segments $uriSegments -Parameters $Parameters
    
    InvokeNetboxRequest -URI $uri
}


#region GET commands

function Get-NetboxDCIMPlatform {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param
    (
        [uint16]$Limit,
        
        [uint16]$Offset,
        
        [Parameter(ParameterSetName = 'ById')]
        [uint16[]]$Id,
        
        [string]$Name,
        
        [string]$Slug,
        
        [uint16]$Manufacturer_Id,
        
        [string]$Manufacturer,
        
        [switch]$Raw
    )
    
    switch ($PSCmdlet.ParameterSetName) {
        'ById' {
            foreach ($PlatformID in $Id) {
                $Segments = [System.Collections.ArrayList]::new(@('dcim', 'platforms', $PlatformID))
                
                $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Id', 'Raw'
                
                $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
                
                InvokeNetboxRequest -URI $URI -Raw:$Raw
            }
            
            break
        }
        
        default {
            $Segments = [System.Collections.ArrayList]::new(@('dcim', 'platforms'))
            
            $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Raw'
            
            $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
            
            InvokeNetboxRequest -URI $URI -Raw:$Raw
        }
    }
}

#endregion GET commands



#region NEW/ADD commands

#endregion NEW/ADD commands



#region SET commands

#endregion SET commands



#region REMOVE commands

#endregion REMOVE commands









