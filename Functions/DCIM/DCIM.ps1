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