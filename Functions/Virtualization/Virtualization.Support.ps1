function ValidateVirtualizationChoice {
<#
    .SYNOPSIS
        Internal function to verify provided values for static choices
    
    .DESCRIPTION
        When users connect to the API, choices for each major object are cached to the config variable. 
        These values are then utilized to verify if the provided value from a user is valid.
    
    .PARAMETER ProvidedValue
        The value to validate against static choices
    
    .PARAMETER AggregateFamily
        Verify against aggregate family values
    
    .PARAMETER PrefixFamily
        Verify against prefix family values
    
    .PARAMETER PrefixStatus
        Verify against prefix status values
    
    .PARAMETER IPAddressFamily
        Verify against ip-address family values
    
    .PARAMETER IPAddressStatus
        Verify against ip-address status values
    
    .PARAMETER IPAddressRole
        Verify against ip-address role values
    
    .PARAMETER VLANStatus
        Verify against VLAN status values
    
    .PARAMETER ServiceProtocol
        Verify against service protocol values
    
    .EXAMPLE
        PS C:\> VerifyIPAMChoices -ProvidedValue 'loopback' -IPAddressRole
    
    .EXAMPLE
        PS C:\> VerifyIPAMChoices -ProvidedValue 'Loopback' -IPAddressFamily
                >> Invalid value Loopback for ip-address:family. Must be one of: 4, 6, IPv4, IPv6
    
    .FUNCTIONALITY
        This cmdlet is intended to be used internally and not exposed to the user
    
    .OUTPUT
        This function returns nothing if the value is valid. Otherwise, it will throw an error.
#>
    
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [object]$ProvidedValue,
        
        [Parameter(ParameterSetName = 'virtual-machine:status',
                   Mandatory = $true)]
        [switch]$VirtualMachineStatus
    )
    
    ValidateChoice -MajorObject 'Virtualization' -ChoiceName $PSCmdlet.ParameterSetName -ProvidedValue $ProvidedValue
}