function ValidateIPAMChoice {
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
        PS C:\> ValidateIPAMChoice -ProvidedValue 'loopback' -IPAddressRole
    
    .EXAMPLE
        PS C:\> ValidateIPAMChoice -ProvidedValue 'Loopback' -IPAddressFamily
        >> Invalid value Loopback for ip-address:family. Must be one of: 4, 6, IPv4, IPv6
    
    .OUTPUTS
        This function returns the integer value if valid. Otherwise, it will throw an error.
    
    .NOTES
        Additional information about the function.
    
    .FUNCTIONALITY
        This cmdlet is intended to be used internally and not exposed to the user
#>
    
    [CmdletBinding(DefaultParameterSetName = 'service:protocol')]
    [OutputType([uint16])]
    param
    (
        [Parameter(Mandatory = $true)]
        [object]$ProvidedValue,
        
        [Parameter(ParameterSetName = 'aggregate:family',
                   Mandatory = $true)]
        [switch]$AggregateFamily,
        
        [Parameter(ParameterSetName = 'prefix:family',
                   Mandatory = $true)]
        [switch]$PrefixFamily,
        
        [Parameter(ParameterSetName = 'prefix:status',
                   Mandatory = $true)]
        [switch]$PrefixStatus,
        
        [Parameter(ParameterSetName = 'ip-address:family',
                   Mandatory = $true)]
        [switch]$IPAddressFamily,
        
        [Parameter(ParameterSetName = 'ip-address:status',
                   Mandatory = $true)]
        [switch]$IPAddressStatus,
        
        [Parameter(ParameterSetName = 'ip-address:role',
                   Mandatory = $true)]
        [switch]$IPAddressRole,
        
        [Parameter(ParameterSetName = 'vlan:status',
                   Mandatory = $true)]
        [switch]$VLANStatus,
        
        [Parameter(ParameterSetName = 'service:protocol',
                   Mandatory = $true)]
        [switch]$ServiceProtocol
    )
    
    ValidateChoice -MajorObject 'IPAM' -ChoiceName $PSCmdlet.ParameterSetName -ProvidedValue $ProvidedValue
}
