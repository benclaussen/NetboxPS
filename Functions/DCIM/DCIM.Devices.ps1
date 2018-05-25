<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2018 v5.5.152
	 Created on:   	5/25/2018 2:52 PM
	 Created by:   	Ben Claussen
	 Organization: 	NEOnet
	 Filename:     	DCIM.Devices.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>

#region GET commands

function Get-NetboxDCIMDevice {
    [CmdletBinding()]
    #region Parameters
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

#endregion GET commands


#region NEW commands

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

#endregion NEW commands


#region SET commands

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

#endregion SET commands


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

#endregion REMOVE commands