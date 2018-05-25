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

function ValidateDCIMChoice {
<#
    .SYNOPSIS
        Internal function to validate provided values for static choices
    
    .DESCRIPTION
        When users connect to the API, choices for each major object are cached to the config variable.
        These values are then utilized to validate if the provided value from a user is valid.
    
    .PARAMETER ProvidedValue
        The value to validate against static choices
    
    .PARAMETER PowerConnectionStatus
        Validate against power connection status values
    
    .PARAMETER InterfaceTemplateFormFactor
        Validate against interface template form factor values
    
    .PARAMETER InterfaceConnectionStatus
        Validate against interface connection status values
    
    .PARAMETER InterfaceFormFactor
        Validate against interface form factor values
    
    .PARAMETER ConsolePortConnectionStatus
        Validate against console port connection status values
    
    .PARAMETER DeviceStatus
        Validate against device status values
    
    .PARAMETER DeviceFace
        Validate against device face values
    
    .PARAMETER RackType
        Validate against rack type values
    
    .PARAMETER RackWidth
        Validate against rack width values.
    
    .EXAMPLE
        PS C:\> ValidateDCIMChoice -ProvidedValue 'rear' -DeviceFace
    
    .EXAMPLE
        PS C:\> ValidateDCIMChoice -ProvidedValue 'middle' -DeviceFace
        >> Invalid value middle for device:face. Must be one of: 0, 1, Front, Rear
    
    .OUTPUTS
        This function returns the integer value if valid. Otherwise, it will throw an error.
    
    .NOTES
        Additional information about the function.
    
    .FUNCTIONALITY
        This cmdlet is intended to be used internally and not exposed to the user
#>
    
    [CmdletBinding()]
    [OutputType([uint16])]
    param
    (
        [Parameter(Mandatory = $true)]
        [object]$ProvidedValue,
        
        [Parameter(ParameterSetName = 'power-port:connection_status',
                   Mandatory = $true)]
        [switch]$PowerConnectionStatus,
        
        [Parameter(ParameterSetName = 'interface-template:form_factor',
                   Mandatory = $true)]
        [switch]$InterfaceTemplateFormFactor,
        
        [Parameter(ParameterSetName = 'interface-connection:connection_status',
                   Mandatory = $true)]
        [switch]$InterfaceConnectionStatus,
        
        [Parameter(ParameterSetName = 'interface:form_factor',
                   Mandatory = $true)]
        [switch]$InterfaceFormFactor,
        
        [Parameter(ParameterSetName = 'console-port:connection_status',
                   Mandatory = $true)]
        [switch]$ConsolePortConnectionStatus,
        
        [Parameter(ParameterSetName = 'device:status',
                   Mandatory = $true)]
        [switch]$DeviceStatus,
        
        [Parameter(ParameterSetName = 'device:face',
                   Mandatory = $true)]
        [switch]$DeviceFace,
        
        [Parameter(ParameterSetName = 'rack:type',
                   Mandatory = $true)]
        [switch]$RackType,
        
        [Parameter(ParameterSetName = 'rack:width',
                   Mandatory = $true)]
        [switch]$RackWidth
    )
    
    ValidateChoice -MajorObject 'DCIM' -ChoiceName $PSCmdlet.ParameterSetName -ProvidedValue $ProvidedValue
}

#region GET Commands
function Get-NetboxDCIMDevice {
    [CmdletBinding()]
    param
    (
        [uint16]$Limit,
        
        [uint16]$Offset,
        
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [uint16[]]$Id,
        
        [string]$Query,
        
        [string]$Name,
        
        [uint16]$Manufacturer_Id,
        
        [string]$Manufacturer,
        
        [uint16]$Device_Type_Id,
        
        [uint16]$Role_Id,
        
        [string]$Role,
        
        [uint16]$Tenant_Id,
        
        [string]$Tenant,
        
        [uint16]$Platform_Id,
        
        [string]$Platform,
        
        [string]$Asset_Tag,
        
        [uint16]$Site_Id,
        
        [string]$Site,
        
        [uint16]$Rack_Group_Id,
        
        [uint16]$Rack_Id,
        
        [uint16]$Cluster_Id,
        
        [uint16]$Model,
        
        [object]$Status,
        
        [bool]$Is_Full_Depth,
        
        [bool]$Is_Console_Server,
        
        [bool]$Is_PDU,
        
        [bool]$Is_Network_Device,
        
        [string]$MAC_Address,
        
        [bool]$Has_Primary_IP,
        
        [uint16]$Virtual_Chassis_Id,
        
        [uint16]$Position,
        
        [string]$Serial,
        
        [switch]$Raw
    )
    
    #endregion Parameters
    
    if ($null -ne $Status) {
        $PSBoundParameters.Status = ValidateDCIMChoice -ProvidedValue $Status -DeviceStatus
    }
    
    $Segments = [System.Collections.ArrayList]::new(@('dcim', 'devices'))
    
    $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Raw'
    
    $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
    
    InvokeNetboxRequest -URI $URI -Raw:$Raw
}

function Get-NetboxDCIMDeviceType {
    [CmdletBinding()]
    #region Parameters
    param
    (
        [uint16]$Offset,
        
        [uint16]$Limit,
        
        [uint16[]]$Id,
        
        [string]$Query,
        
        [string]$Slug,
        
        [string]$Manufacturer,
        
        [uint16]$Manufacturer_Id,
        
        [string]$Model,
        
        [string]$Part_Number,
        
        [uint16]$U_Height,
        
        [bool]$Is_Full_Depth,
        
        [bool]$Is_Console_Server,
        
        [bool]$Is_PDU,
        
        [bool]$Is_Network_Device,
        
        [uint16]$Subdevice_Role,
        
        [switch]$Raw
    )
    #endregion Parameters
    
    $Segments = [System.Collections.ArrayList]::new(@('dcim', 'device-types'))
    
    $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Raw'
    
    $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
    
    InvokeNetboxRequest -URI $URI -Raw:$Raw
}

function Get-NetboxDCIMDeviceRole {
    [CmdletBinding()]
    param
    (
        [uint16]$Limit,
        
        [uint16]$Offset,
        
        [Parameter(ParameterSetName = 'ById')]
        [uint16[]]$Id,
        
        [string]$Name,
        
        [string]$Slug,
        
        [string]$Color,
        
        [bool]$VM_Role,
        
        [switch]$Raw
    )
    
    switch ($PSCmdlet.ParameterSetName) {
        'ById' {
            foreach ($DRId in $Id) {
                $Segments = [System.Collections.ArrayList]::new(@('dcim', 'device-roles', $DRId))
                
                $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Id', 'Raw'
                
                $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
                
                InvokeNetboxRequest -URI $URI -Raw:$Raw
            }
            
            break
        }
        
        default {
            $Segments = [System.Collections.ArrayList]::new(@('dcim', 'device-roles'))
            
            $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Raw'
            
            $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
            
            InvokeNetboxRequest -URI $URI -Raw:$Raw
        }
    }
}

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
function New-NetboxDCIMDevice {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    #region Parameters
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Name,
        
        [Parameter(Mandatory = $true)]
        [object]$Device_Role,
        
        [Parameter(Mandatory = $true)]
        [object]$Device_Type,
        
        [Parameter(Mandatory = $true)]
        [uint16]$Site,
        
        [object]$Status = 'Active',
        
        [uint16]$Platform,
        
        [uint16]$Tenant,
        
        [uint16]$Cluster,
        
        [uint16]$Rack,
        
        [uint16]$Position,
        
        [object]$Face,
        
        [string]$Serial,
        
        [string]$Asset_Tag,
        
        [uint16]$Virtual_Chassis,
        
        [uint16]$VC_Priority,
        
        [uint16]$VC_Position,
        
        [uint16]$Primary_IP4,
        
        [uint16]$Primary_IP6,
        
        [string]$Comments,
        
        [hashtable]$Custom_Fields
    )
    #endregion Parameters
    
    if ($null -ne $Device_Role) {
        # Validate device role?
    }
    
    if ($null -ne $Device_Type) {
        # Validate device type?
    }
    
    if ($null -ne $Status) {
        $PSBoundParameters.Status = ValidateDCIMChoice -ProvidedValue $Status -DeviceStatus
    }
    
    if ($null -ne $Face) {
        $PSBoundParameters.Face = ValidateDCIMChoice -ProvidedValue $Face -DeviceFace
    }
    
    $Segments = [System.Collections.ArrayList]::new(@('dcim', 'devices'))
    
    $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters
    
    $URI = BuildNewURI -Segments $URIComponents.Segments
    
    InvokeNetboxRequest -URI $URI -Body $URIComponents.Parameters -Method POST
}

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
function Set-NetboxDCIMDevice {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [uint16[]]$Id,
        
        [string]$Name,
        
        [object]$Device_Role,
        
        [object]$Device_Type,
        
        [uint16]$Site,
        
        [object]$Status,
        
        [uint16]$Platform,
        
        [uint16]$Tenant,
        
        [uint16]$Cluster,
        
        [uint16]$Rack,
        
        [uint16]$Position,
        
        [object]$Face,
        
        [string]$Serial,
        
        [string]$Asset_Tag,
        
        [uint16]$Virtual_Chassis,
        
        [uint16]$VC_Priority,
        
        [uint16]$VC_Position,
        
        [uint16]$Primary_IP4,
        
        [uint16]$Primary_IP6,
        
        [string]$Comments,
        
        [hashtable]$Custom_Fields,
        
        [switch]$Force
    )
    
    begin {
        if ($null -ne $Status) {
            $PSBoundParameters.Status = ValidateDCIMChoice -ProvidedValue $Status -DeviceStatus
        }
        
        if ($null -ne $Face) {
            $PSBoundParameters.Face = ValidateDCIMChoice -ProvidedValue $Face -DeviceFace
        }
    }
    
    process {
        foreach ($DeviceID in $Id) {
            $CurrentDevice = Get-NetboxDCIMDevice -Id $DeviceID -ErrorAction Stop
            
            if ($Force -or $pscmdlet.ShouldProcess("$($CurrentDevice.Name)", "Set")) {
                $Segments = [System.Collections.ArrayList]::new(@('dcim', 'devices', $CurrentDevice.Id))
                
                $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Id', 'Force'
                
                $URI = BuildNewURI -Segments $URIComponents.Segments
                
                InvokeNetboxRequest -URI $URI -Body $URIComponents.Parameters -Method PATCH
            }
        }
    }
    
    end {
        
    }
}

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
function Remove-NetboxDCIMDevice {
<#
    .SYNOPSIS
        Delete a device
    
    .DESCRIPTION
        Deletes a device from Netbox by ID
    
    .PARAMETER Id
        Database ID of the device
    
    .PARAMETER Force
        Force deletion without any prompts
    
    .EXAMPLE
        PS C:\> Remove-NetboxDCIMDevice -Id $value1
    
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
        foreach ($DeviceID in $Id) {
            $CurrentDevice = Get-NetboxDCIMDevice -Id $DeviceID -ErrorAction Stop
            
            if ($Force -or $pscmdlet.ShouldProcess("Name: $($CurrentDevice.Name) | ID: $($CurrentDevice.Id)", "Remove")) {
                $Segments = [System.Collections.ArrayList]::new(@('dcim', 'devices', $CurrentDevice.Id))
                
                $URI = BuildNewURI -Segments $Segments
                
                InvokeNetboxRequest -URI $URI -Method DELETE
            }
        }
    }
    
    end {
        
    }
}

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















