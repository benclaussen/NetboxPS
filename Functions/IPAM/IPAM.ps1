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
    
    $ValidValues = New-Object System.Collections.ArrayList
    
    [void]$ValidValues.AddRange($script:NetboxConfig.Choices.IPAM.$($PSCmdlet.ParameterSetName).value)
    [void]$ValidValues.AddRange($script:NetboxConfig.Choices.IPAM.$($PSCmdlet.ParameterSetName).label)
    
    if ($ValidValues.Count -eq 0) {
        throw "Missing valid values for $($PSCmdlet.ParameterSetName)"
    }
    
    if ($ValidValues -inotcontains $ProvidedValue) {
        throw "Invalid value '$ProvidedValue' for '$($PSCmdlet.ParameterSetName)'. Must be one of: $($ValidValues -join ', ')"
    }
    
    # Convert the ProvidedValue to the integer value
    try {
        $intVal = [uint16]"$ProvidedValue"
    } catch {
        # It must not be a number, get the value from the label
        $intVal = [uint16]$script:NetboxConfig.Choices.IPAM.$($PSCmdlet.ParameterSetName).Where({$_.Label -eq $ProvidedValue}).Value
    }
    
    return $intVal
}


function Get-NetboxIPAMAggregate {
    [CmdletBinding()]
    param
    (
        [uint16]$Limit,
        
        [uint16]$Offset,
        
        [string]$Family,
        
        [datetime]$Date_Added,
        
        [uint16[]]$Id,
        
        [string]$Query,
        
        [uint16]$RIR_Id,
        
        [string]$RIR,
        
        [switch]$Raw
    )
    
    $uriSegments = [System.Collections.ArrayList]::new(@('ipam', 'aggregates'))
    
    $URIParameters = @{}
    
    foreach ($CmdletParameterName in $PSBoundParameters.Keys) {
        if ($CmdletParameterName -in $CommonParameterNames) {
            # These are common parameters and should not be appended to the URI
            Write-Debug "Skipping parameter $CmdletParameterName"
            continue
        }
        
        if ($CmdletParameterName -eq 'Id') {
            # Check if there is one or more values for Id and build a URI or query as appropriate
            if (@($PSBoundParameters[$CmdletParameterName]).Count -gt 1) {
                $URIParameters['id__in'] = $Id -join ','
            } else {
                [void]$uriSegments.Add($PSBoundParameters[$CmdletParameterName])
            }
        } elseif ($CmdletParameterName -eq 'Query') {
            $URIParameters['q'] = $PSBoundParameters[$CmdletParameterName]
        } else {
            $URIParameters[$CmdletParameterName.ToLower()] = $PSBoundParameters[$CmdletParameterName]
        }
    }
    
    $uri = BuildNewURI -Segments $uriSegments -Parameters $URIParameters
    
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
    
    if ($Family) {
        $PSBoundParameters.Family = VerifyIPAMChoices -ProvidedValue $Family -IPAddressFamily   
    }
    
    if ($Status) {
        $PSBoundParameters.Status = VerifyIPAMChoices -ProvidedValue $Status -IPAddressStatus
    }
    
    if ($Role) {
        $PSBoundParameters.Role = VerifyIPAMChoices -ProvidedValue $Role -IPAddressRole
    }
    
    $uriSegments = [System.Collections.ArrayList]::new(@('ipam', 'ip-addresses'))
    
    $URIParameters = @{}
    
    foreach ($CmdletParameterName in $PSBoundParameters.Keys) {
        if ($CmdletParameterName -in $CommonParameterNames) {
            # These are common parameters and should not be appended to the URI
            Write-Debug "Skipping parameter $CmdletParameterName"
            continue
        }
        
        if ($CmdletParameterName -eq 'Id') {
            # Check if there is one or more values for Id and build a URI or query as appropriate
            if (@($PSBoundParameters[$CmdletParameterName]).Count -gt 1) {
                $URIParameters['id__in'] = $Id -join ','
            } else {
                [void]$uriSegments.Add($PSBoundParameters[$CmdletParameterName])
            }
        } elseif ($CmdletParameterName -eq 'Query') {
            $URIParameters['q'] = $PSBoundParameters[$CmdletParameterName]
        } else {
            $URIParameters[$CmdletParameterName.ToLower()] = $PSBoundParameters[$CmdletParameterName]
        }
    }
    
    $uri = BuildNewURI -Segments $uriSegments -Parameters $URIParameters
    
    InvokeNetboxRequest -URI $uri -Raw:$Raw
}

function Get-NetboxIPAMAvaiableIP {
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
        
        [uint16]$NumberOfIPs,
        
        [switch]$Raw
    )
    
    $uriSegments = [System.Collections.ArrayList]::new(@('ipam', 'prefixes', $Prefix_ID, 'available-ips'))
    
    $uriParameters = @{}
    
    if ($NumberOfIPs) {
        [void]$uriParameters.Add('limit', $NumberOfIPs)
    }
    
    $uri = BuildNewURI -Segments $uriSegments -Parameters $uriParameters
    
    InvokeNetboxRequest -URI $uri -Raw:$Raw
}

function Get-NetboxIPAMPrefix {
    [CmdletBinding()]
    param
    (
        [uint16]$Limit,
        
        [uint16]$Offset,
        
        [object]$Family,
        
        [uint16[]]$Id,
        
        [string]$Query,
        
        #[string]$Within,

        #[string]$Within_Include,

        [string]$Contains,
        
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
    
    if ($Family) {
        $PSBoundParameters.Family = VerifyIPAMChoices -ProvidedValue $Family -PrefixFamily
    }
    
    if ($Status) {
        $PSBoundParameters.Status = VerifyIPAMChoices -ProvidedValue $Status -PrefixStatus
    }
    
    $uriSegments = [System.Collections.ArrayList]::new(@('ipam', 'prefixes'))
    
    $URIParameters = @{}
    
    foreach ($CmdletParameterName in $PSBoundParameters.Keys) {
        if ($CmdletParameterName -in $CommonParameterNames) {
            # These are common parameters and should not be appended to the URI
            Write-Debug "Skipping parameter $CmdletParameterName"
            continue
        }
        
        if ($CmdletParameterName -eq 'Id') {
            # Check if there is one or more values for Id and build a URI or query as appropriate
            if (@($PSBoundParameters[$CmdletParameterName]).Count -gt 1) {
                $URIParameters['id__in'] = $Id -join ','
            } else {
                [void]$uriSegments.Add($PSBoundParameters[$CmdletParameterName])
            }
        } elseif ($CmdletParameterName -eq 'Query') {
            $URIParameters['q'] = $PSBoundParameters[$CmdletParameterName]
        } else {
            $URIParameters[$CmdletParameterName.ToLower()] = $PSBoundParameters[$CmdletParameterName]
        }
    }
    
    $uri = BuildNewURI -Segments $uriSegments -Parameters $URIParameters
    
    InvokeNetboxRequest -URI $uri -Raw:$Raw
}

















