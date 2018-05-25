<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2018 v5.5.152
	 Created on:   	5/25/2018 2:57 PM
	 Created by:   	Ben Claussen
	 Organization: 	NEOnet
	 Filename:     	DCIM.Interfaces.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>

#region GET Commands

function Get-NetboxDCIMInterface {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param
    (
        [uint16]$Limit,
        
        [uint16]$Offset,
        
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [uint16]$Id,
        
        [uint16]$Name,
        
        [object]$Form_Factor,
        
        [bool]$Enabled,
        
        [uint16]$MTU,
        
        [bool]$MGMT_Only,
        
        [string]$Device,
        
        [uint16]$Device_Id,
        
        [uint16]$Type,
        
        [uint16]$LAG_Id,
        
        [string]$MAC_Address,
        
        [switch]$Raw
    )
    
    if ($null -ne $Form_Factor) {
        $PSBoundParameters.Form_Factor = ValidateDCIMChoice -ProvidedValue $Form_Factor -InterfaceFormFactor
    }
    
    $Segments = [System.Collections.ArrayList]::new(@('dcim', 'interfaces'))
    
    $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters
    
    $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
    
    InvokeNetboxRequest -URI $URI -Raw:$Raw
}

function Get-NetboxDCIMInterfaceConnection {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param
    (
        [uint16]$Limit,
        
        [uint16]$Offset,
        
        [uint16]$Id,
        
        [object]$Connection_Status,
        
        [uint16]$Site,
        
        [uint16]$Device,
        
        [switch]$Raw
    )
    
    if ($null -ne $Connection_Status) {
        $PSBoundParameters.Connection_Status = ValidateDCIMChoice -ProvidedValue $Connection_Status -InterfaceConnectionStatus
    }
    
    $Segments = [System.Collections.ArrayList]::new(@('dcim', 'interface-connections'))
    
    $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Raw'
    
    $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
    
    InvokeNetboxRequest -URI $URI -Raw:$Raw
}

#endregion GET Commands


#region ADD/NEW commands

function Add-NetboxDCIMInterface {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param
    (
        [Parameter(Mandatory = $true)]
        [uint16]$Device,
        
        [Parameter(Mandatory = $true)]
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
    
    if ($null -ne $Form_Factor) {
        $PSBoundParameters.Form_Factor = ValidateDCIMChoice -ProvidedValue $Form_Factor -InterfaceFormFactor
    }
    
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
    
    $Segments = [System.Collections.ArrayList]::new(@('dcim', 'interfaces'))
    
    $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters
    
    $URI = BuildNewURI -Segments $URIComponents.Segments
    
    InvokeNetboxRequest -URI $URI -Body $URIComponents.Parameters -Method POST
}

function Add-NetboxDCIMInterfaceConnection {
<#
    .SYNOPSIS
        Create a new connection between two interfaces
    
    .DESCRIPTION
        Create a new connection between two interfaces
    
    .PARAMETER Connection_Status
        Is it connected or planned?
    
    .PARAMETER Interface_A
        Database ID of interface A
    
    .PARAMETER Interface_B
        Database ID of interface B
    
    .EXAMPLE
        PS C:\> Add-NetboxDCIMInterfaceConnection -Interface_A $value1 -Interface_B $value2
    
    .NOTES
        Additional information about the function.
#>
    
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param
    (
        [object]$Connection_Status,
        
        [Parameter(Mandatory = $true)]
        [uint16]$Interface_A,
        
        [Parameter(Mandatory = $true)]
        [uint16]$Interface_B
    )
    
    if ($null -ne $Connection_Status) {
        $PSBoundParameters.Connection_Status = ValidateDCIMChoice -ProvidedValue $Connection_Status -InterfaceConnectionStatus
    }
    
    # Verify if both Interfaces exist
    $I_A = Get-NetboxDCIMInterface -Id $Interface_A -ErrorAction Stop
    $I_B = Get-NetboxDCIMInterface -Id $Interface_B -ErrorAction Stop
    
    $Segments = [System.Collections.ArrayList]::new(@('dcim', 'interface-connections'))
    
    $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters
    
    $URI = BuildNewURI -Segments $URIComponents.Segments
    
    InvokeNetboxRequest -URI $URI -Body $URIComponents.Parameters -Method POST
}

#endregion ADD/NEW commands


#region SET Commands

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
        if ($null -ne $Form_Factor) {
            $PSBoundParameters.Form_Factor = ValidateDCIMChoice -ProvidedValue $Form_Factor -InterfaceFormFactor
        }
        
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

function Set-NetboxDCIMInterfaceConnection {
<#
    .SYNOPSIS
        Update an interface connection
    
    .DESCRIPTION
        Update an interface connection
    
    .PARAMETER Id
        A description of the Id parameter.
    
    .PARAMETER Connection_Status
        A description of the Connection_Status parameter.
    
    .PARAMETER Interface_A
        A description of the Interface_A parameter.
    
    .PARAMETER Interface_B
        A description of the Interface_B parameter.
    
    .PARAMETER Force
        A description of the Force parameter.
    
    .EXAMPLE
        PS C:\> Set-NetboxDCIMInterfaceConnection -Id $value1
    
    .NOTES
        Additional information about the function.
#>
    
    [CmdletBinding(ConfirmImpact = 'Medium',
                   SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [uint16[]]$Id,
        
        [object]$Connection_Status,
        
        [uint16]$Interface_A,
        
        [uint16]$Interface_B,
        
        [switch]$Force
    )
    
    begin {
        if ($null -ne $Connection_Status) {
            $PSBoundParameters.Connection_Status = ValidateDCIMChoice -ProvidedValue $Connection_Status -InterfaceConnectionStatus
        }
        
        if ((@($ID).Count -gt 1) -and ($Interface_A -or $Interface_B)) {
            throw "Cannot set multiple connections to the same interface"
        }
    }
    
    process {
        foreach ($ConnectionID in $Id) {
            $CurrentConnection = Get-NetboxDCIMInterfaceConnection -Id $ConnectionID -ErrorAction Stop
            
            $Segments = [System.Collections.ArrayList]::new(@('dcim', 'interface-connections', $CurrentConnection.Id))
            
            if ($Force -or $pscmdlet.ShouldProcess("Connection ID $($CurrentConnection.Id)", "Set")) {
                
                $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Id', 'Force'
                
                $URI = BuildNewURI -Segments $URIComponents.Segments
                
                InvokeNetboxRequest -URI $URI -Body $URIComponents.Parameters -Method PATCH
            }
        }
    }
    
    end {
        
    }
}

#endregion SET Commands


#region REMOVE commands

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

function Remove-NetboxDCIMInterfaceConnection {
    [CmdletBinding(ConfirmImpact = 'High',
                   SupportsShouldProcess = $true)]
    [OutputType([void])]
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
        foreach ($ConnectionID in $Id) {
            $CurrentConnection = Get-NetboxDCIMInterfaceConnection -Id $ConnectionID -ErrorAction Stop
            
            if ($Force -or $pscmdlet.ShouldProcess("Connection ID $($ConnectionID.Id)", "REMOVE")) {
                $Segments = [System.Collections.ArrayList]::new(@('dcim', 'interface-connections', $CurrentConnection.Id))
                
                $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Id', 'Force'
                
                $URI = BuildNewURI -Segments $URIComponents.Segments
                
                InvokeNetboxRequest -URI $URI -Method DELETE
            }
        }
    }
    
    end {
        
    }
}

#endregion REMOVE commands

