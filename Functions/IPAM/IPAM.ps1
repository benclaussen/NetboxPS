<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2018 v5.5.150
	 Created on:   	5/10/2018 3:41 PM
	 Created by:   	Ben Claussen
	 Organization: 	NEOnet
	 Filename:     	IPAM.ps1
	===========================================================================
	.DESCRIPTION
		IPAM Object functions
#>

function Get-NetboxIPAMChoices {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "", Justification = "These are literally 'choices' in Netbox")]
    param ()
    
    $uriSegments = [System.Collections.ArrayList]::new(@('ipam', '_choices'))
    
    $uri = BuildNewURI -Segments $uriSegments -Parameters $Parameters
    
    InvokeNetboxRequest -URI $uri
}

function VerifyIPAMChoices {
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


function Get-NetboxIPAMAggregate {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "", Justification = "These are literally 'choices' in Netbox")]
    param
    (
        [uint16]$Limit,
        
        [uint16]$Offset,
        
        [object]$Family,
        
        [datetime]$Date_Added,
        
        [uint16[]]$Id,
        
        [string]$Query,
        
        [uint16]$RIR_Id,
        
        [string]$RIR,
        
        [switch]$Raw
    )
    
    if ($null -ne $Family) {
        $PSBoundParameters.Family = VerifyIPAMChoices -ProvidedValue $Family -AggregateFamily
    }
    
    $Segments = [System.Collections.ArrayList]::new(@('ipam', 'aggregates'))
    
    $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters
    
    $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
    
    InvokeNetboxRequest -URI $uri -Raw:$Raw
}

function Get-NetboxIPAMAddress {
    [CmdletBinding()]
    param
    (
        [uint16]$Limit,
        
        [uint16]$Offset,
        
        [object]$Family,
        
        [uint16[]]$Id,
        
        [string]$Query,
        
        [uint16]$Parent,
        
        [byte]$Mask_Length,
        
        [string]$VRF,
        
        [uint16]$VRF_Id,
        
        [string]$Tenant,
        
        [uint16]$Tenant_Id,
        
        [string]$Device,
        
        [uint16]$Device_ID,
        
        [string]$Virtual_Machine,
        
        [uint16]$Virtual_Machine_Id,
        
        [uint16]$Interface_Id,
        
        [object]$Status,
        
        [object]$Role,
        
        [switch]$Raw
    )
    
    if ($null -ne $Family) {
        $PSBoundParameters.Family = VerifyIPAMChoices -ProvidedValue $Family -IPAddressFamily
    }
    
    if ($null -ne $Status) {
        $PSBoundParameters.Status = VerifyIPAMChoices -ProvidedValue $Status -IPAddressStatus
    }
    
    if ($null -ne $Role) {
        $PSBoundParameters.Role = VerifyIPAMChoices -ProvidedValue $Role -IPAddressRole
    }
    
    $Segments = [System.Collections.ArrayList]::new(@('ipam', 'ip-addresses'))
    
    $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters
    
    $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
    
    InvokeNetboxRequest -URI $uri -Raw:$Raw
}

function Get-NetboxIPAMAvailableIP {
<#
    .SYNOPSIS
        A convenience method for returning available IP addresses within a prefix
    
    .DESCRIPTION
        By default, the number of IPs returned will be equivalent to PAGINATE_COUNT. An arbitrary limit
        (up to MAX_PAGE_SIZE, if set) may be passed, however results will not be paginated
    
    .PARAMETER Prefix_ID
        A description of the Prefix_ID parameter.
    
    .PARAMETER NumberOfIPs
        A description of the NumberOfIPs parameter.
    
    .PARAMETER Raw
        A description of the Raw parameter.
    
    .EXAMPLE
        PS C:\> Get-NetboxIPAMAvaiableIP -Prefix_ID $value1
    
    .NOTES
        Additional information about the function.
#>
    
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [uint16]$Prefix_ID,
        
        [Alias('NumberOfIPs')]
        [uint16]$Limit,
        
        [switch]$Raw
    )
    
    $Segments = [System.Collections.ArrayList]::new(@('ipam', 'prefixes', $Prefix_ID, 'available-ips'))
    
    $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters -SkipParameterByName 'prefix_id'
    
    $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
    
    InvokeNetboxRequest -URI $uri -Raw:$Raw
}

function Get-NetboxIPAMPrefix {
<#
    .SYNOPSIS
        A brief description of the Get-NetboxIPAMPrefix function.
    
    .DESCRIPTION
        A detailed description of the Get-NetboxIPAMPrefix function.
    
    .PARAMETER Limit
        A description of the Limit parameter.
    
    .PARAMETER Offset
        A description of the Offset parameter.
    
    .PARAMETER Family
        A description of the Family parameter.
    
    .PARAMETER Is_Pool
        A description of the Is_Pool parameter.
    
    .PARAMETER Id
        A description of the Id parameter.
    
    .PARAMETER Query
        A description of the Query parameter.
    
    .PARAMETER Within
        Should be a CIDR notation prefix such as '10.0.0.0/16'
    
    .PARAMETER Within_Include
        Should be a CIDR notation prefix such as '10.0.0.0/16'
    
    .PARAMETER Contains
        A description of the Contains parameter.
    
    .PARAMETER Mask_Length
        CIDR mask length value
    
    .PARAMETER VRF
        A description of the VRF parameter.
    
    .PARAMETER VRF_Id
        A description of the VRF_Id parameter.
    
    .PARAMETER Tenant
        A description of the Tenant parameter.
    
    .PARAMETER Tenant_Id
        A description of the Tenant_Id parameter.
    
    .PARAMETER Site
        A description of the Site parameter.
    
    .PARAMETER Site_Id
        A description of the Site_Id parameter.
    
    .PARAMETER Vlan_VId
        A description of the Vlan_VId parameter.
    
    .PARAMETER Vlan_Id
        A description of the Vlan_Id parameter.
    
    .PARAMETER Status
        A description of the Status parameter.
    
    .PARAMETER Role
        A description of the Role parameter.
    
    .PARAMETER Role_Id
        A description of the Role_Id parameter.
    
    .PARAMETER Raw
        A description of the Raw parameter.
    
    .EXAMPLE
        		PS C:\> Get-NetboxIPAMPrefix
    
    .NOTES
        Additional information about the function.
#>
    
    [CmdletBinding()]
    param
    (
        [uint16]$Limit,
        
        [uint16]$Offset,
        
        [object]$Family,
        
        [boolean]$Is_Pool,
        
        [uint16[]]$Id,
        
        [string]$Query,
        
        [string]$Within,
        
        [string]$Within_Include,
        
        [string]$Contains,
        
        [ValidateRange(0, 127)]
        [byte]$Mask_Length,
        
        [string]$VRF,
        
        [uint16]$VRF_Id,
        
        [string]$Tenant,
        
        [uint16]$Tenant_Id,
        
        [string]$Site,
        
        [uint16]$Site_Id,
        
        [string]$Vlan_VId,
        
        [uint16]$Vlan_Id,
        
        [object]$Status,
        
        [string]$Role,
        
        [uint16]$Role_Id,
        
        [switch]$Raw
    )
    
    if ($null -ne $Family) {
        $PSBoundParameters.Family = VerifyIPAMChoices -ProvidedValue $Family -PrefixFamily
    }
    
    if ($null -ne $Status) {
        $PSBoundParameters.Status = VerifyIPAMChoices -ProvidedValue $Status -PrefixStatus
    }
    
    $Segments = [System.Collections.ArrayList]::new(@('ipam', 'prefixes'))
    
    $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters
    
    $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
    
    InvokeNetboxRequest -URI $uri -Raw:$Raw
}

function New-NetboxIPAMAddress {
<#
    .SYNOPSIS
        Create a new IP address to Netbox
    
    .DESCRIPTION
        Create a new IP address to Netbox with a status of Active by default.
    
    .PARAMETER Address
        IP address in CIDR notation: 192.168.1.1/24
    
    .PARAMETER Status
        Status of the IP. Defaults to Active
    
    .PARAMETER Tenant
        Tenant ID
    
    .PARAMETER VRF
        VRF ID
    
    .PARAMETER Role
        Role such as anycast, loopback, etc... Defaults to nothing
    
    .PARAMETER NAT_Inside
        ID of IP for NAT
    
    .PARAMETER Custom_Fields
        Custom field hash table. Will be validated by the API service
    
    .PARAMETER Interface
        ID of interface to apply IP
    
    .PARAMETER Description
        Description of IP address
    
    .PARAMETER Raw
        Return raw results from API service
    
    .EXAMPLE
        PS C:\> Create-NetboxIPAMAddress
    
    .NOTES
        Additional information about the function.
#>
    
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Address,
        
        [object]$Status = 'Active',
        
        [uint16]$Tenant,
        
        [uint16]$VRF,
        
        [object]$Role,
        
        [uint16]$NAT_Inside,
        
        [hashtable]$Custom_Fields,
        
        [uint16]$Interface,
        
        [string]$Description,
        
        [switch]$Raw
    )
    
    $PSBoundParameters.Status = VerifyIPAMChoices -ProvidedValue $Status -IPAddressStatus
    
    if ($null -ne $Role) {
        $PSBoundParameters.Role = VerifyIPAMChoices -ProvidedValue $Role -IPAddressRole
    }
    
    $segments = [System.Collections.ArrayList]::new(@('ipam', 'ip-addresses'))
    
    $URIComponents = BuildURIComponents -URISegments $segments -ParametersDictionary $PSBoundParameters
    
    $URI = BuildNewURI -Segments $URIComponents.Segments
    
    InvokeNetboxRequest -URI $URI -Method POST -Body $URIComponents.Parameters -Raw:$Raw
}

function Remove-NetboxIPAMAddress {
<#
    .SYNOPSIS
        Remove an IP address from Netbox
    
    .DESCRIPTION
        Removes/deletes an IP address from Netbox by ID and optional other filters
    
    .PARAMETER Id
        A description of the Id parameter.
    
    .PARAMETER Force
        A description of the Force parameter.
    
    .PARAMETER Query
        A description of the Query parameter.
    
    .EXAMPLE
        PS C:\> Remove-NetboxIPAMAddress -Id $value1
    
    .NOTES
        Additional information about the function.
#>
    
    [CmdletBinding(ConfirmImpact = 'High',
                   SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true)]
        [uint16[]]$Id,
        
        [switch]$Force
    )
    
    $CurrentIPs = @(Get-NetboxIPAMAddress -Id $Id -ErrorAction Stop)
    
    $Segments = [System.Collections.ArrayList]::new(@('ipam', 'ip-addresses'))
    
    foreach ($IP in $CurrentIPs) {
        if ($Force -or $pscmdlet.ShouldProcess($IP.Address, "Delete")) {
            $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary @{'id' = $IP.Id}
            
            $URI = BuildNewURI -Segments $URIComponents.Segments
            
            InvokeNetboxRequest -URI $URI -Method DELETE
        }
    }
}

function Set-NetboxIPAMAddress {
    [CmdletBinding(ConfirmImpact = 'High',
                   SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [uint16]$Id,
        
        [string]$Address,
        
        [object]$Status,
        
        [uint16]$Tenant,
        
        [uint16]$VRF,
        
        [object]$Role,
        
        [uint16]$NAT_Inside,
        
        [hashtable]$Custom_Fields,
        
        [uint16]$Interface,
        
        [string]$Description,
        
        [switch]$Force
    )
    
    if ($Status) {
        $PSBoundParameters.Status = VerifyIPAMChoices -ProvidedValue $Status -IPAddressStatus
    }
    
    if ($Role) {
        $PSBoundParameters.Role = VerifyIPAMChoices -ProvidedValue $Role -IPAddressRole
    }
    
    $Segments = [System.Collections.ArrayList]::new(@('ipam', 'ip-addresses', $Id))
    
    Write-Verbose "Obtaining IPs from ID $Id"
    $CurrentIP = Get-NetboxIPAMAddress -Id $Id -ErrorAction Stop
    
    if ($Force -or $PSCmdlet.ShouldProcess($($CurrentIP | Select-Object -ExpandProperty 'Address'), 'Set')) {
        $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Id', 'Force'
        
        $URI = BuildNewURI -Segments $URIComponents.Segments
        
        InvokeNetboxRequest -URI $URI -Body $URIComponents.Parameters -Method PATCH
    }
}










