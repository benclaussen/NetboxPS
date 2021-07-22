

#region File Add-NetboxDCIMInterface.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/23/2020 12:10
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Add-NetboxDCIMInterface.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


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
    
#    if ($null -ne $Form_Factor) {
#        $PSBoundParameters.Form_Factor = ValidateDCIMChoice -ProvidedValue $Form_Factor -InterfaceFormFactor
#    }
    
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

#endregion

#region File Add-NetboxDCIMInterfaceConnection.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/23/2020 12:10
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Add-NetboxDCIMInterfaceConnection.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


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

#endregion

#region File Add-NetboxVirtualMachineInterface.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/19/2020 12:46
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Add-NetboxVirtualMachineInterface.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function Add-NetboxVirtualMachineInterface {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Name,
        
        [Parameter(Mandatory = $true)]
        [uint16]$Virtual_Machine,
        
        [boolean]$Enabled = $true,
        
        [string]$MAC_Address,
        
        [uint16]$MTU,
        
        [string]$Description,
        
        [switch]$Raw
    )
    
    $Segments = [System.Collections.ArrayList]::new(@('virtualization', 'interfaces'))
    
    $PSBoundParameters.Enabled = $Enabled
    
    $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters
    
    $uri = BuildNewURI -Segments $URIComponents.Segments
    
    InvokeNetboxRequest -URI $uri -Method POST -Body $URIComponents.Parameters
}

#endregion

#region File BuildNewURI.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/26/2020 14:22
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	BuildNewURI.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function BuildNewURI {
<#
    .SYNOPSIS
        Create a new URI for Netbox
    
    .DESCRIPTION
        Internal function used to build a URIBuilder object.
    
    .PARAMETER Hostname
        Hostname of the Netbox API
    
    .PARAMETER Segments
        Array of strings for each segment in the URL path
    
    .PARAMETER Parameters
        Hashtable of query parameters to include
    
    .PARAMETER HTTPS
        Whether to use HTTPS or HTTP
    
    .PARAMETER Port
        A description of the Port parameter.
    
    .PARAMETER APIInfo
        A description of the APIInfo parameter.
    
    .EXAMPLE
        PS C:\> BuildNewURI
    
    .NOTES
        Additional information about the function.
#>
    
    [CmdletBinding()]
    [OutputType([System.UriBuilder])]
    param
    (
        [Parameter(Mandatory = $false)]
        [string[]]$Segments,
        
        [Parameter(Mandatory = $false)]
        [hashtable]$Parameters,
        
        [switch]$SkipConnectedCheck
    )
    
    Write-Verbose "Building URI"
    
    if (-not $SkipConnectedCheck) {
        # There is no point in continuing if we have not successfully connected to an API
        $null = CheckNetboxIsConnected
    }
    
    # Begin a URI builder with HTTP/HTTPS and the provided hostname
    $uriBuilder = [System.UriBuilder]::new($script:NetboxConfig.HostScheme, $script:NetboxConfig.Hostname, $script:NetboxConfig.HostPort)
    
    # Generate the path by trimming excess slashes and whitespace from the $segments[] and joining together
    $uriBuilder.Path = "api/{0}/" -f ($Segments.ForEach({
                $_.trim('/').trim()
            }) -join '/')
    
    Write-Verbose " URIPath: $($uriBuilder.Path)"
    
    if ($parameters) {
        # Loop through the parameters and use the HttpUtility to create a Query string
        [System.Collections.Specialized.NameValueCollection]$URIParams = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
        
        foreach ($param in $Parameters.GetEnumerator()) {
            Write-Verbose " Adding URI parameter $($param.Key):$($param.Value)"
            $URIParams[$param.Key] = $param.Value
        }
        
        $uriBuilder.Query = $URIParams.ToString()
    }
    
    Write-Verbose " Completed building URIBuilder"
    # Return the entire UriBuilder object
    $uriBuilder
}

#endregion

#region File BuildURIComponents.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/26/2020 14:23
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	BuildURIComponents.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function BuildURIComponents {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Collections.ArrayList]$URISegments,
        
        [Parameter(Mandatory = $true)]
        [object]$ParametersDictionary,
        
        [string[]]$SkipParameterByName
    )
    
    Write-Verbose "Building URI components"
    
    $URIParameters = @{
    }
    
    foreach ($CmdletParameterName in $ParametersDictionary.Keys) {
        if ($CmdletParameterName -in $script:CommonParameterNames) {
            # These are common parameters and should not be appended to the URI
            Write-Debug "Skipping common parameter $CmdletParameterName"
            continue
        }
        
        if ($CmdletParameterName -in $SkipParameterByName) {
            Write-Debug "Skipping parameter $CmdletParameterName by SkipParameterByName"
            continue
        }
        
        switch ($CmdletParameterName) {
            "id" {
                # Check if there is one or more values for Id and build a URI or query as appropriate
                if (@($ParametersDictionary[$CmdletParameterName]).Count -gt 1) {
                    Write-Verbose " Joining IDs for parameter"
                    $URIParameters['id__in'] = $ParametersDictionary[$CmdletParameterName] -join ','
                } else {
                    Write-Verbose " Adding ID to segments"
                    [void]$uriSegments.Add($ParametersDictionary[$CmdletParameterName])
                }
                
                break
            }
            
            'Query' {
                Write-Verbose " Adding query parameter"
                $URIParameters['q'] = $ParametersDictionary[$CmdletParameterName]
                break
            }
            
            'CustomFields' {
                Write-Verbose " Adding custom field query parameters"
                foreach ($field in $ParametersDictionary[$CmdletParameterName].GetEnumerator()) {
                    Write-Verbose "  Adding parameter 'cf_$($field.Key) = $($field.Value)"
                    $URIParameters["cf_$($field.Key.ToLower())"] = $field.Value
                }
                
                break
            }
            
            default {
                Write-Verbose " Adding $($CmdletParameterName.ToLower()) parameter"
                $URIParameters[$CmdletParameterName.ToLower()] = $ParametersDictionary[$CmdletParameterName]
                break
            }
        }
    }
    
    return @{
        'Segments' = [System.Collections.ArrayList]$URISegments
        'Parameters' = $URIParameters
    }
}

#endregion

#region File CheckNetboxIsConnected.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/26/2020 14:22
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	CheckNetboxIsConnected.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function CheckNetboxIsConnected {
    [CmdletBinding()]
    param ()
    
    Write-Verbose "Checking connection status"
    if (-not $script:NetboxConfig.Connected) {
        throw "Not connected to a Netbox API! Please run 'Connect-NetboxAPI'"
    }
}

#endregion

#region File Circuits.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2018 v5.5.148
	 Created on:   	2/28/2018 4:06 PM
	 Created by:   	Ben Claussen
	 Organization: 	NEOnet
	 Filename:     	Circuits.ps1
	===========================================================================
	.DESCRIPTION
		Circuit object functions
#>



#endregion

#region File Clear-NetboxCredential.ps1

function Clear-NetboxCredential {
    [CmdletBinding(ConfirmImpact = 'Medium', SupportsShouldProcess = $true)]
    param
    (
        [switch]$Force
    )
    
    if ($Force -or ($PSCmdlet.ShouldProcess('Netbox Credentials', 'Clear'))) {
        $script:NetboxConfig.Credential = $null
    }
}

#endregion

#region File Connect-NetboxAPI.ps1

function Connect-NetboxAPI {
<#
    .SYNOPSIS
        Connects to the Netbox API and ensures Credential work properly

    .DESCRIPTION
        Connects to the Netbox API and ensures Credential work properly

    .PARAMETER Hostname
        The hostname for the resource such as netbox.domain.com

    .PARAMETER Credential
        Credential object containing the API key in the password. Username is not applicable

    .PARAMETER Scheme
        Scheme for the URI such as HTTP or HTTPS. Defaults to HTTPS

    .PARAMETER Port
        Port for the resource. Value between 1-65535

    .PARAMETER URI
        The full URI for the resource such as "https://netbox.domain.com:8443"

    .PARAMETER SkipCertificateCheck
        A description of the SkipCertificateCheck parameter.

    .PARAMETER TimeoutSeconds
        The number of seconds before the HTTP call times out. Defaults to 30 seconds

    .EXAMPLE
        PS C:\> Connect-NetboxAPI -Hostname "netbox.domain.com"

        This will prompt for Credential, then proceed to attempt a connection to Netbox

    .NOTES
        Additional information about the function.
#>

    [CmdletBinding(DefaultParameterSetName = 'Manual')]
    param
    (
        [Parameter(ParameterSetName = 'Manual',
                   Mandatory = $true)]
        [string]$Hostname,

        [Parameter(Mandatory = $false)]
        [pscredential]$Credential,

        [Parameter(ParameterSetName = 'Manual')]
        [ValidateSet('https', 'http', IgnoreCase = $true)]
        [string]$Scheme = 'https',

        [Parameter(ParameterSetName = 'Manual')]
        [uint16]$Port = 443,

        [Parameter(ParameterSetName = 'URI',
                   Mandatory = $true)]
        [string]$URI,

        [Parameter(Mandatory = $false)]
        [switch]$SkipCertificateCheck = $false,

        [ValidateNotNullOrEmpty()]
        [ValidateRange(1, 65535)]
        [uint16]$TimeoutSeconds = 30
    )

    if (-not $Credential) {
        try {
            $Credential = Get-NetboxCredential -ErrorAction Stop
        } catch {
            # Credentials are not set... Try to obtain from the user
            if (-not ($Credential = Get-Credential -UserName 'username-not-applicable' -Message "Enter token for Netbox")) {
                throw "Token is necessary to connect to a Netbox API."
            }
        }
    }

    $invokeParams = @{ SkipCertificateCheck = $SkipCertificateCheck; }

    if ("Desktop" -eq $PSVersionTable.PsEdition) {
        #Remove -SkipCertificateCheck from Invoke Parameter (not supported <= PS 5)
        $invokeParams.remove("SkipCertificateCheck")
    }

    #for PowerShell (<=) 5 (Desktop), Enable TLS 1.1, 1.2 and Disable SSL chain trust
    if ("Desktop" -eq $PSVersionTable.PsEdition) {
        #Enable TLS 1.1 and 1.2
        Set-NetboxCipherSSL
        if ($SkipCertificateCheck) {
            #Disable SSL chain trust...
            Set-NetboxuntrustedSSL
        }
    }

    switch ($PSCmdlet.ParameterSetName) {
        'Manual' {
            $uriBuilder = [System.UriBuilder]::new($Scheme, $Hostname, $Port)
        }

        'URI' {
            $uriBuilder = [System.UriBuilder]::new($URI)
            if ([string]::IsNullOrWhiteSpace($uriBuilder.Host)) {
                throw "URI appears to be invalid. Must be in format [host.name], [scheme://host.name], or [scheme://host.name:port]"
            }
        }
    }

    $null = Set-NetboxHostName -Hostname $uriBuilder.Host
    $null = Set-NetboxCredential -Credential $Credential
    $null = Set-NetboxHostScheme -Scheme $uriBuilder.Scheme
    $null = Set-NetboxHostPort -Port $uriBuilder.Port
    $null = Set-NetboxInvokeParams -invokeParams $invokeParams
    $null = Set-NetboxTimeout -TimeoutSeconds $TimeoutSeconds

    try {
        Write-Verbose "Verifying API connectivity..."
        $null = VerifyAPIConnectivity
    } catch {
        Write-Verbose "Failed to connect. Generating error"
        Write-Verbose $_.Exception.Message
        if (($_.Exception.Response) -and ($_.Exception.Response.StatusCode -eq 403)) {
            throw "Invalid token"
        } else {
            throw $_
        }
    }

#    Write-Verbose "Caching API definition"
#    $script:NetboxConfig.APIDefinition = Get-NetboxAPIDefinition
#
#    if ([version]$script:NetboxConfig.APIDefinition.info.version -lt 2.8) {
#        $Script:NetboxConfig.Connected = $false
#        throw "Netbox version is incompatible with this PS module. Requires >=2.8.*, found version $($script:NetboxConfig.APIDefinition.info.version)"
    #    }

    Write-Verbose "Checking Netbox version compatibility"
    $script:NetboxConfig.NetboxVersion = Get-NetboxVersion
    if ([version]$script:NetboxConfig.NetboxVersion.'netbox-version' -lt 2.8) {
        $Script:NetboxConfig.Connected = $false
        throw "Netbox version is incompatible with this PS module. Requires >=2.8.*, found version $($script:NetboxConfig.NetboxVersion.'netbox-version')"
    } else {
        Write-Verbose "Found compatible version [$($script:NetboxConfig.NetboxVersion.'netbox-version')]!"
    }

    $script:NetboxConfig.Connected = $true
    Write-Verbose "Successfully connected!"

    #Write-Verbose "Caching static choices"
    #$script:NetboxConfig.Choices.Circuits = Get-NetboxCircuitsChoices
    #$script:NetboxConfig.Choices.DCIM = Get-NetboxDCIMChoices # Not completed yet
    #$script:NetboxConfig.Choices.Extras = Get-NetboxExtrasChoices
    #$script:NetboxConfig.Choices.IPAM = Get-NetboxIPAMChoices
    ##$script:NetboxConfig.Choices.Secrets = Get-NetboxSecretsChoices    # Not completed yet
    ##$script:NetboxConfig.Choices.Tenancy = Get-NetboxTenancyChoices
    #$script:NetboxConfig.Choices.Virtualization = Get-NetboxVirtualizationChoices

    Write-Verbose "Connection process completed"
}

#endregion

#region File CreateEnum.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/26/2020 14:25
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	CreateEnum.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function CreateEnum {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$EnumName,
        
        [Parameter(Mandatory = $true)]
        [pscustomobject]$Values,
        
        [switch]$PassThru
    )
    
    $definition = @"
public enum $EnumName
{`n$(foreach ($value in $values) {
            "`t$($value.label) = $($value.value),`n"
        })
}
"@
    if (-not ([System.Management.Automation.PSTypeName]"$EnumName").Type) {
        #Write-Host $definition -ForegroundColor Green
        Add-Type -TypeDefinition $definition -PassThru:$PassThru
    } else {
        Write-Warning "EnumType $EnumName already exists."
    }
}

#endregion

#region File Get-ModelDefinition.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.181
	 Created on:   	2020-11-04 14:23
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-ModelDefinition.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>



function Get-ModelDefinition {
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    param
    (
        [Parameter(ParameterSetName = 'ByName',
                   Mandatory = $true)]
        [string]$ModelName,
        
        [Parameter(ParameterSetName = 'ByPath',
                   Mandatory = $true)]
        [string]$URIPath,
        
        [Parameter(ParameterSetName = 'ByPath')]
        [string]$Method = "post"
    )
    
    switch ($PsCmdlet.ParameterSetName) {
        'ByName' {
            $script:NetboxConfig.APIDefinition.definitions.$ModelName
            break
        }
        
        'ByPath' {
            switch ($Method) {
                "get" {
                    
                    break
                }
                
                "post" {
                    if (-not $URIPath.StartsWith('/')) {
                        $URIPath = "/$URIPath"
                    }
                    
                    if (-not $URIPath.EndsWith('/')) {
                        $URIPath = "$URIPath/"
                    }
                    
                    $ModelName = $script:NetboxConfig.APIDefinition.paths.$URIPath.post.parameters.schema.'$ref'.split('/')[-1]
                    $script:NetboxConfig.APIDefinition.definitions.$ModelName
                    break
                }
            }
            
            break
        }
    }
    
}

#endregion

#region File Get-NetboxAPIDefinition.ps1

<#
    .NOTES
    ===========================================================================
     Created with:     SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.174
     Created on:       4/28/2020 11:57
     Created by:       Claussen
     Organization:     NEOnet
     Filename:         Get-NetboxAPIDefinition.ps1
    ===========================================================================
    .DESCRIPTION
        A description of the file.
#>



function Get-NetboxAPIDefinition {
    [CmdletBinding()]
    param ()

    #$URI = "https://netbox.neonet.org/api/docs/?format=openapi"

    $Segments = [System.Collections.ArrayList]::new(@('docs'))

    $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary @{'format' = 'openapi' }

    $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters -SkipConnectedCheck

    InvokeNetboxRequest -URI $URI
}

#endregion

#region File GetNetboxAPIErrorBody.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/26/2020 14:23
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	GetNetboxAPIErrorBody.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function GetNetboxAPIErrorBody {
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Net.HttpWebResponse]$Response
    )
    
    # This takes the $Response stream and turns it into a useable object... generally a string.
    # If the body is JSON, you should be able to use ConvertFrom-Json
    
    $reader = New-Object System.IO.StreamReader($Response.GetResponseStream())
    $reader.BaseStream.Position = 0
    $reader.DiscardBufferedData()
    $reader.ReadToEnd()
}

#endregion

#region File Get-NetboxCircuit.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/23/2020 12:15
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-NetboxCircuit.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function Get-NetboxCircuit {
<#
    .SYNOPSIS
        Gets one or more circuits
    
    .DESCRIPTION
        A detailed description of the Get-NetboxCircuit function.
    
    .PARAMETER Id
        Database ID of circuit. This will query for exactly the IDs provided
    
    .PARAMETER CID
        Circuit ID
    
    .PARAMETER InstallDate
        Date of installation
    
    .PARAMETER CommitRate
        Committed rate in Kbps
    
    .PARAMETER Query
        A raw search query... As if you were searching the web site
    
    .PARAMETER Provider
        The name or ID of the provider. Provide either [string] or [int]. String will search provider names, integer will search database IDs
    
    .PARAMETER Type
        Type of circuit. Provide either [string] or [int]. String will search provider type names, integer will search database IDs
    
    .PARAMETER Site
        Location/site of circuit. Provide either [string] or [int]. String will search site names, integer will search database IDs
    
    .PARAMETER Tenant
        Tenant assigned to circuit. Provide either [string] or [int]. String will search tenant names, integer will search database IDs
    
    .PARAMETER Limit
        A description of the Limit parameter.
    
    .PARAMETER Offset
        A description of the Offset parameter.
    
    .PARAMETER Raw
        A description of the Raw parameter.
    
    .PARAMETER ID__IN
        Multiple unique DB IDs to retrieve
    
    .EXAMPLE
        PS C:\> Get-NetboxCircuit
    
    .NOTES
        Additional information about the function.
#>
    
    [CmdletBinding(DefaultParameterSetName = 'Query')]
    param
    (
        [Parameter(ParameterSetName = 'ById')]
        [uint16[]]$Id,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$CID,
        
        [Parameter(ParameterSetName = 'Query')]
        [datetime]$InstallDate,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint32]$CommitRate,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Query,
        
        [Parameter(ParameterSetName = 'Query')]
        [object]$Provider,
        
        [Parameter(ParameterSetName = 'Query')]
        [object]$Type,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Site,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Tenant,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint16]$Limit,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint16]$Offset,
        
        [switch]$Raw
    )
    
    switch ($PSCmdlet.ParameterSetName) {
        'ById' {
            foreach ($i in $ID) {
                $Segments = [System.Collections.ArrayList]::new(@('circuits', 'circuits', $i))
                
                $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters -SkipParameterByName "Id"
                
                $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
                
                InvokeNetboxRequest -URI $URI -Raw:$Raw
            }
        }
        
        default {
            $Segments = [System.Collections.ArrayList]::new(@('circuits', 'circuits'))
            
            $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters
            
            $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
            
            InvokeNetboxRequest -URI $URI -Raw:$Raw
        }
    }
}

#endregion

#region File Get-NetboxCircuitProvider.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.181
	 Created on:   	2020-11-04 12:06
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-NetboxCircuitProvider.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>



function Get-NetboxCircuitProvider {
    [CmdletBinding(DefaultParameterSetName = 'Query')]
    param
    (
        [Parameter(ParameterSetName = 'ById',
                   Mandatory = $true)]
        [uint16[]]$Id,
        
        [Parameter(ParameterSetName = 'Query',
                   Mandatory = $false)]
        [string]$Name,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Query,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Slug,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$ASN,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Account,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint16]$Limit,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint16]$Offset,
        
        [switch]$Raw
    )
    
    switch ($PSCmdlet.ParameterSetName) {
        'ById' {
            foreach ($i in $ID) {
                $Segments = [System.Collections.ArrayList]::new(@('circuits', 'providers', $i))
                
                $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters -SkipParameterByName "Id"
                
                $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
                
                InvokeNetboxRequest -URI $URI -Raw:$Raw
            }
        }
        
        default {
            $Segments = [System.Collections.ArrayList]::new(@('circuits', 'providers'))
            
            $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters
            
            $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
            
            InvokeNetboxRequest -URI $URI -Raw:$Raw
        }
    }
}

#endregion

#region File Get-NetboxCircuitTermination.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.181
	 Created on:   	2020-11-04 10:22
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-NetboxCircuitTermination.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>



function Get-NetboxCircuitTermination {
    [CmdletBinding(DefaultParameterSetName = 'Query')]
    param
    (
        [Parameter(ParameterSetName = 'ById',
                   ValueFromPipelineByPropertyName = $true)]
        [uint32[]]$Id,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Circuit_ID,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Term_Side,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint32]$Port_Speed,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Query,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Site_ID,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Site,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$XConnect_ID,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint16]$Limit,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint16]$Offset,
        
        [switch]$Raw
    )
    
    process {
        switch ($PSCmdlet.ParameterSetName) {
            'ById' {
                foreach ($i in $ID) {
                    $Segments = [System.Collections.ArrayList]::new(@('circuits', 'circuit-terminations', $i))
                    
                    $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters -SkipParameterByName "Id"
                    
                    $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
                    
                    InvokeNetboxRequest -URI $URI -Raw:$Raw
                }
            }
            
            default {
                $Segments = [System.Collections.ArrayList]::new(@('circuits', 'circuit-terminations'))
                
                $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters
                
                $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
                
                InvokeNetboxRequest -URI $URI -Raw:$Raw
            }
        }
    }
}

#endregion

#region File Get-NetboxCircuitType.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.181
	 Created on:   	2020-11-04 12:34
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-NetboxCircuitType.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>



function Get-NetboxCircuitType {
    [CmdletBinding(DefaultParameterSetName = 'Query')]
    param
    (
        [Parameter(ParameterSetName = 'ById')]
        [uint16[]]$Id,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Name,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Slug,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Query,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint16]$Limit,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint16]$Offset,
        
        [switch]$Raw
    )
    
    switch ($PSCmdlet.ParameterSetName) {
        'ById' {
            foreach ($i in $ID) {
                $Segments = [System.Collections.ArrayList]::new(@('circuits', 'circuit_types', $i))
                
                $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters -SkipParameterByName "Id"
                
                $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
                
                InvokeNetboxRequest -URI $URI -Raw:$Raw
            }
        }
        
        default {
            $Segments = [System.Collections.ArrayList]::new(@('circuits', 'circuit-types'))
            
            $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters
            
            $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
            
            InvokeNetboxRequest -URI $URI -Raw:$Raw
        }
    }
}

#endregion

#region File GetNetboxConfigVariable.ps1

function GetNetboxConfigVariable {
    return $script:NetboxConfig
}

#endregion

#region File Get-NetboxCredential.ps1

function Get-NetboxCredential {
    [CmdletBinding()]
    [OutputType([pscredential])]
    param ()

    if (-not $script:NetboxConfig.Credential) {
        throw "Netbox Credentials not set! You may set with Set-NetboxCredential"
    }

    $script:NetboxConfig.Credential
}

#endregion

#region File Get-NetboxDCIMDevice.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/23/2020 12:06
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-NetboxDCIMDevice.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


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

#endregion

#region File Get-NetboxDCIMDeviceRole.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/23/2020 12:07
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-NetboxDCIMDeviceRole.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


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

#endregion

#region File Get-NetboxDCIMDeviceType.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/23/2020 12:07
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-NetboxDCIMDeviceType.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


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

#endregion

#region File Get-NetboxDCIMInterface.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/23/2020 12:09
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-NetboxDCIMInterface.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


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

#endregion

#region File Get-NetboxDCIMInterfaceConnection.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/23/2020 12:10
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-NetboxDCIMInterfaceConnection.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


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

#endregion

#region File Get-NetboxDCIMPlatform.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/23/2020 12:13
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-NetboxDCIMPlatform.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


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

#endregion

#region File Get-NetboxDCIMSite.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.181
	 Created on:   	2020-10-02 15:52
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-NetboxDCIMSite.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>



function Get-NetboxDCIMSite {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param
    (
        [Parameter(ParameterSetName = 'ByID', ValueFromPipelineByPropertyName = $true)]
        [uint32]$Id,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Name,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Query,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Slug,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Facility,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint32]$ASN,
        
        [Parameter(ParameterSetName = 'Query')]
        [decimal]$Latitude,
        
        [Parameter(ParameterSetName = 'Query')]
        [decimal]$Longitude,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Contact_Name,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Contact_Phone,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Contact_Email,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint32]$Tenant_Group_ID,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Tenant_Group,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint32]$Tenant_ID,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Tenant,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Status,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint32]$Region_ID,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Region,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint16]$Limit,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint16]$Offset,
        
        [switch]$Raw
    )
    
    switch ($PSCmdlet.ParameterSetName) {
        'ById' {
            foreach ($Site_ID in $ID) {
                $Segments = [System.Collections.ArrayList]::new(@('dcim', 'sites', $Site_Id))
                
                $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters -SkipParameterByName "Id"
                
                $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
                
                InvokeNetboxRequest -URI $URI -Raw:$Raw
            }
        }
        
        default {
            $Segments = [System.Collections.ArrayList]::new(@('dcim', 'sites'))
            
            $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters
            
            $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
            
            InvokeNetboxRequest -URI $URI -Raw:$Raw
        }
    }
}


#endregion

#region File Get-NetboxHostname.ps1

function Get-NetboxHostname {
    [CmdletBinding()]
    param ()

    Write-Verbose "Getting Netbox hostname"
    if ($null -eq $script:NetboxConfig.Hostname) {
        throw "Netbox Hostname is not set! You may set it with Set-NetboxHostname -Hostname 'hostname.domain.tld'"
    }

    $script:NetboxConfig.Hostname
}

#endregion

#region File Get-NetboxHostPort.ps1

function Get-NetboxHostPort {
    [CmdletBinding()]
    param ()
    
    Write-Verbose "Getting Netbox host port"
    if ($null -eq $script:NetboxConfig.HostPort) {
        throw "Netbox host port is not set! You may set it with Set-NetboxHostPort -Port 'https'"
    }
    
    $script:NetboxConfig.HostPort
}

#endregion

#region File Get-NetboxHostScheme.ps1

function Get-NetboxHostScheme {
    [CmdletBinding()]
    param ()
    
    Write-Verbose "Getting Netbox host scheme"
    if ($null -eq $script:NetboxConfig.Hostscheme) {
        throw "Netbox host sceme is not set! You may set it with Set-NetboxHostScheme -Scheme 'https'"
    }
    
    $script:NetboxConfig.HostScheme
}

#endregion

#region File Get-NetboxInvokeParams.ps1

function Get-NetboxInvokeParams {
    [CmdletBinding()]
    param ()

    Write-Verbose "Getting Netbox InvokeParams"
    if ($null -eq $script:NetboxConfig.InvokeParams) {
        throw "Netbox Invoke Params is not set! You may set it with Set-NetboxInvokeParams -InvokeParams ..."
    }

    $script:NetboxConfig.InvokeParams
}

#endregion

#region File Get-NetboxIPAMAddress.ps1

function Get-NetboxIPAMAddress {
    [CmdletBinding(DefaultParameterSetName = 'Query')]
    param
    (
        [Parameter(ParameterSetName = 'Query',
            Position = 0)]
        [string]$Address,

        [Parameter(ParameterSetName = 'ByID')]
        [uint32[]]$Id,

        [Parameter(ParameterSetName = 'Query')]
        [string]$Query,

        [Parameter(ParameterSetName = 'Query')]
        [object]$Family,

        [Parameter(ParameterSetName = 'Query')]
        [uint32]$Parent,

        [Parameter(ParameterSetName = 'Query')]
        [byte]$Mask_Length,

        [Parameter(ParameterSetName = 'Query')]
        [string]$VRF,

        [Parameter(ParameterSetName = 'Query')]
        [uint32]$VRF_Id,

        [Parameter(ParameterSetName = 'Query')]
        [string]$Tenant,

        [Parameter(ParameterSetName = 'Query')]
        [uint32]$Tenant_Id,

        [Parameter(ParameterSetName = 'Query')]
        [string]$Device,

        [Parameter(ParameterSetName = 'Query')]
        [uint32]$Device_ID,

        [Parameter(ParameterSetName = 'Query')]
        [string]$Virtual_Machine,

        [Parameter(ParameterSetName = 'Query')]
        [uint32]$Virtual_Machine_Id,

        [Parameter(ParameterSetName = 'Query')]
        [uint32]$Interface_Id,

        [Parameter(ParameterSetName = 'Query')]
        [object]$Status,

        [Parameter(ParameterSetName = 'Query')]
        [object]$Role,

        [Parameter(ParameterSetName = 'Query')]
        [uint16]$Limit,

        [Parameter(ParameterSetName = 'Query')]
        [uint16]$Offset,

        [switch]$Raw
    )

    switch ($PSCmdlet.ParameterSetName) {
        'ById' {
            foreach ($IP_ID in $Id) {
                $Segments = [System.Collections.ArrayList]::new(@('ipam', 'ip-addresses', $IP_ID))

                $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Id'

                $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters

                InvokeNetboxRequest -URI $uri -Raw:$Raw
            }

            break
        }

        default {
            $Segments = [System.Collections.ArrayList]::new(@('ipam', 'ip-addresses'))

            $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters

            $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters

            InvokeNetboxRequest -URI $uri -Raw:$Raw

            break
        }
    }
}

#endregion

#region File Get-NetboxIPAMAggregate.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/19/2020 11:49
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-NetboxIPAMAggregate.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function Get-NetboxIPAMAggregate {
    [CmdletBinding(DefaultParameterSetName = 'Query')]
    param
    (
        [Parameter(ParameterSetName = 'Query')]
        [string]$Query,
        
        [Parameter(ParameterSetName = 'ByID')]
        [uint16[]]$Id,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Prefix,
        
        [Parameter(ParameterSetName = 'Query')]
        [object]$Family,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint16]$RIR_Id,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$RIR,
        
        [Parameter(ParameterSetName = 'Query')]
        [datetime]$Date_Added,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint16]$Limit,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint16]$Offset,
        
        [switch]$Raw
    )
    
#    if ($null -ne $Family) {
#        $PSBoundParameters.Family = ValidateIPAMChoice -ProvidedValue $Family -AggregateFamily
    #    }
    
    switch ($PSCmdlet.ParameterSetName) {
        'ById' {
            foreach ($IP_ID in $Id) {
                $Segments = [System.Collections.ArrayList]::new(@('ipam', 'aggregates', $IP_ID))
                
                $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Id'
                
                $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
                
                InvokeNetboxRequest -URI $uri -Raw:$Raw
            }
            break
        }
        
        default {
            $Segments = [System.Collections.ArrayList]::new(@('ipam', 'aggregates'))
            
            $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters
            
            $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
            
            InvokeNetboxRequest -URI $uri -Raw:$Raw
            
            break
        }
    }
}

#endregion

#region File Get-NetboxIPAMAvailableIP.ps1

<#
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/19/2020 11:50
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-NetboxIPAMAvailableIP.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function Get-NetboxIPAMAvailableIP {
    <#
    .SYNOPSIS
        A convenience method for returning available IP addresses within a prefix

    .DESCRIPTION
        By default, the number of IPs returned will be equivalent to PAGINATE_COUNT. An arbitrary limit
        (up to MAX_PAGE_SIZE, if set) may be passed, however results will not be paginated

    .PARAMETER Prefix_ID
        A description of the Prefix_ID parameter.

    .PARAMETER Limit
        A description of the Limit parameter.

    .PARAMETER Raw
        A description of the Raw parameter.

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
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
        [Alias('Id')]
        [int]$Prefix_ID,

        [Alias('NumberOfIPs')]
        [int]$Limit,

        [switch]$Raw
    )

    process {
        $Segments = [System.Collections.ArrayList]::new(@('ipam', 'prefixes', $Prefix_ID, 'available-ips'))

        $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters -SkipParameterByName 'prefix_id'

        $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters

        InvokeNetboxRequest -URI $uri -Raw:$Raw
    }
}

#endregion

#region File Get-NetboxIPAMPrefix.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/19/2020 11:51
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-NetboxIPAMPrefix.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function Get-NetboxIPAMPrefix {
<#
    .SYNOPSIS
        A brief description of the Get-NetboxIPAMPrefix function.
    
    .DESCRIPTION
        A detailed description of the Get-NetboxIPAMPrefix function.
    
    .PARAMETER Query
        A description of the Query parameter.
    
    .PARAMETER Id
        A description of the Id parameter.
    
    .PARAMETER Limit
        A description of the Limit parameter.
    
    .PARAMETER Offset
        A description of the Offset parameter.
    
    .PARAMETER Family
        A description of the Family parameter.
    
    .PARAMETER Is_Pool
        A description of the Is_Pool parameter.
    
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
    
    [CmdletBinding(DefaultParameterSetName = 'Query')]
    param
    (
        [Parameter(ParameterSetName = 'Query',
                   Position = 0)]
        [string]$Prefix,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Query,
        
        [Parameter(ParameterSetName = 'ByID')]
        [uint32[]]$Id,
        
        [Parameter(ParameterSetName = 'Query')]
        [object]$Family,
        
        [Parameter(ParameterSetName = 'Query')]
        [boolean]$Is_Pool,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Within,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Within_Include,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Contains,
        
        [Parameter(ParameterSetName = 'Query')]
        [ValidateRange(0, 127)]
        [byte]$Mask_Length,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$VRF,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint32]$VRF_Id,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Tenant,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint32]$Tenant_Id,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Site,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint32]$Site_Id,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Vlan_VId,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint32]$Vlan_Id,
        
        [Parameter(ParameterSetName = 'Query')]
        [object]$Status,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Role,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint32]$Role_Id,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint16]$Limit,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint16]$Offset,
        
        [switch]$Raw
    )
    
    #    if ($null -ne $Family) {
    #        $PSBoundParameters.Family = ValidateIPAMChoice -ProvidedValue $Family -PrefixFamily
    #    }
    #    
    #    if ($null -ne $Status) {
    #        $PSBoundParameters.Status = ValidateIPAMChoice -ProvidedValue $Status -PrefixStatus
    #    }
    
    switch ($PSCmdlet.ParameterSetName) {
        'ById' {
            foreach ($Prefix_ID in $Id) {
                $Segments = [System.Collections.ArrayList]::new(@('ipam', 'prefixes', $Prefix_ID))
                
                $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Id'
                
                $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
                
                InvokeNetboxRequest -URI $uri -Raw:$Raw
            }
            
            break
        }
        
        default {
            $Segments = [System.Collections.ArrayList]::new(@('ipam', 'prefixes'))
            
            $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters
            
            $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
            
            InvokeNetboxRequest -URI $uri -Raw:$Raw
            
            break
        }
    }
}

#endregion

#region File Get-NetboxIPAMRole.ps1


function Get-NetboxIPAMRole {
<#
    .SYNOPSIS
        Get IPAM Prefix/VLAN roles
    
    .DESCRIPTION
        A role indicates the function of a prefix or VLAN. For example, you might define Data, Voice, and Security roles. Generally, a prefix will be assigned the same functional role as the VLAN to which it is assigned (if any).
    
    .PARAMETER Id
        Unique ID
    
    .PARAMETER Query
        Search query
    
    .PARAMETER Name
        Role name
    
    .PARAMETER Slug
        Role URL slug
    
    .PARAMETER Brief
        Brief format
    
    .PARAMETER Limit
        Result limit
    
    .PARAMETER Offset
        Result offset
    
    .PARAMETER Raw
        A description of the Raw parameter.
    
    .EXAMPLE
        PS C:\> Get-NetboxIPAMRole
    
    .NOTES
        Additional information about the function.
#>
    
    [CmdletBinding()]
    param
    (
        [Parameter(ParameterSetName = 'Query',
                   Position = 0)]
        [string]$Name,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Query,
        
        [Parameter(ParameterSetName = 'ByID')]
        [uint32[]]$Id,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Slug,
        
        [Parameter(ParameterSetName = 'Query')]
        [switch]$Brief,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint16]$Limit,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint16]$Offset,
        
        [switch]$Raw
    )
    
    switch ($PSCmdlet.ParameterSetName) {
        'ById' {
            foreach ($Role_ID in $Id) {
                $Segments = [System.Collections.ArrayList]::new(@('ipam', 'roles', $Role_ID))
                
                $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Id'
                
                $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
                
                InvokeNetboxRequest -URI $uri -Raw:$Raw
            }
            
            break
        }
        
        default {
            $Segments = [System.Collections.ArrayList]::new(@('ipam', 'roles'))
            
            $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters
            
            $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
            
            InvokeNetboxRequest -URI $uri -Raw:$Raw
            
            break
        }
    }
}

#endregion

#region File Get-NetboxIPAMVLAN.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/16/2020 16:34
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-NetboxIPAMVLAN.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function Get-NetboxIPAMVLAN {
    [CmdletBinding()]
    param
    (
        [Parameter(ParameterSetName = 'Query',
                   Position = 0)]
        [ValidateRange(1, 4096)]
        [uint16]$VID,
        
        [Parameter(ParameterSetName = 'ByID')]
        [uint32[]]$Id,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Query,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Name,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Tenant,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint32]$Tenant_Id,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$TenantGroup,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint32]$TenantGroup_Id,
        
        [Parameter(ParameterSetName = 'Query')]
        [object]$Status,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Region,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Site,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint32]$Site_Id,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Group,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint32]$Group_Id,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Role,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint32]$Role_Id,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint16]$Limit,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint16]$Offset,
        
        [switch]$Raw
    )
    
    #    if ($null -ne $Status) {
    #        $PSBoundParameters.Status = ValidateIPAMChoice -ProvidedValue $Status -VLANStatus
    #    }
    
    switch ($PSCmdlet.ParameterSetName) {
        'ById' {
            foreach ($VLAN_ID in $Id) {
                $Segments = [System.Collections.ArrayList]::new(@('ipam', 'vlans', $VLAN_ID))
                
                $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Id'
                
                $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
                
                InvokeNetboxRequest -URI $uri -Raw:$Raw
            }
            
            break
        }
        
        default {
            $Segments = [System.Collections.ArrayList]::new(@('ipam', 'vlans'))
            
            $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters
            
            $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
            
            InvokeNetboxRequest -URI $uri -Raw:$Raw
            
            break
        }
    }
}





#endregion

#region File Get-NetboxTenant.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/19/2020 11:56
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-NetboxTenant.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function Get-NetboxTenant {
<#
    .SYNOPSIS
        Get a tenent from Netbox
    
    .DESCRIPTION
        A detailed description of the Get-NetboxTenant function.
    
    .PARAMETER Name
        The specific name of the tenant. Must match exactly as is defined in Netbox
    
    .PARAMETER Id
        The database ID of the tenant
    
    .PARAMETER Query
        A standard search query that will match one or more tenants.
    
    .PARAMETER Slug
        The specific slug of the tenant. Must match exactly as is defined in Netbox
    
    .PARAMETER Group
        The specific group as defined in Netbox.
    
    .PARAMETER GroupID
        The database ID of the group in Netbox
    
    .PARAMETER CustomFields
        Hashtable in the format @{"field_name" = "value"} to search
    
    .PARAMETER Limit
        Limit the number of results to this number
    
    .PARAMETER Offset
        Start the search at this index in results
    
    .PARAMETER Raw
        Return the unparsed data from the HTTP request
    
    .EXAMPLE
        PS C:\> Get-NetboxTenant
    
    .NOTES
        Additional information about the function.
#>
    
    [CmdletBinding(DefaultParameterSetName = 'Query')]
    param
    (
        [Parameter(ParameterSetName = 'Query',
                   Position = 0)]
        [string]$Name,
        
        [Parameter(ParameterSetName = 'ByID')]
        [uint32[]]$Id,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Query,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Slug,
        
        [Parameter(ParameterSetName = 'Query')]
        [string]$Group,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint16]$GroupID,
        
        [Parameter(ParameterSetName = 'Query')]
        [hashtable]$CustomFields,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint16]$Limit,
        
        [Parameter(ParameterSetName = 'Query')]
        [uint16]$Offset,
        
        [switch]$Raw
    )
    
    switch ($PSCmdlet.ParameterSetName) {
        'ById' {
            foreach ($Tenant_ID in $Id) {
                $Segments = [System.Collections.ArrayList]::new(@('tenancy', 'tenants', $Tenant_ID))
                
                $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Id'
                
                $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
                
                InvokeNetboxRequest -URI $uri -Raw:$Raw
            }
            
            break
        }
        
        default {
            $Segments = [System.Collections.ArrayList]::new(@('tenancy', 'tenants'))
            
            $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters
            
            $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
            
            InvokeNetboxRequest -URI $uri -Raw:$Raw
            
            break
        }
    }
}

#endregion

#region File Get-NetboxTimeout.ps1


function Get-NetboxTimeout {
    [CmdletBinding()]
    [OutputType([uint16])]
    param ()

    Write-Verbose "Getting Netbox Timeout"
    if ($null -eq $script:NetboxConfig.Timeout) {
        throw "Netbox Timeout is not set! You may set it with Set-NetboxTimeout -TimeoutSeconds [uint16]"
    }

    $script:NetboxConfig.Timeout
}

#endregion

#region File Get-NetboxVersion.ps1


function Get-NetboxVersion {
    [CmdletBinding()]
    param ()

    $Segments = [System.Collections.ArrayList]::new(@('status'))

    $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary @{
        'format' = 'json'
    }

    $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters -SkipConnectedCheck

    InvokeNetboxRequest -URI $URI
}

#endregion

#region File Get-NetboxVirtualizationCluster.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/19/2020 14:10
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-NetboxVirtualizationCluster.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function Get-NetboxVirtualizationCluster {
<#
    .SYNOPSIS
        Obtains virtualization clusters from Netbox.
    
    .DESCRIPTION
        Obtains one or more virtualization clusters based on provided filters.
    
    .PARAMETER Limit
        Number of results to return per page
    
    .PARAMETER Offset
        The initial index from which to return the results
    
    .PARAMETER Query
        A general query used to search for a cluster
    
    .PARAMETER Name
        Name of the cluster
    
    .PARAMETER Id
        Database ID(s) of the cluster
    
    .PARAMETER Group
        String value of the cluster group.
    
    .PARAMETER Group_Id
        Database ID of the cluster group.
    
    .PARAMETER Type
        String value of the Cluster type.
    
    .PARAMETER Type_Id
        Database ID of the cluster type.
    
    .PARAMETER Site
        String value of the site.
    
    .PARAMETER Site_Id
        Database ID of the site.
    
    .PARAMETER Raw
        A description of the Raw parameter.
    
    .EXAMPLE
        PS C:\> Get-NetboxVirtualizationCluster
    
    .NOTES
        Additional information about the function.
#>
    
    [CmdletBinding()]
    param
    (
        [string]$Name,
        
        [Alias('q')]
        [string]$Query,
        
        [uint16[]]$Id,
        
        [string]$Group,
        
        [uint16]$Group_Id,
        
        [string]$Type,
        
        [uint16]$Type_Id,
        
        [string]$Site,
        
        [uint16]$Site_Id,
        
        [uint16]$Limit,
        
        [uint16]$Offset,
        
        [switch]$Raw
    )
    
    $Segments = [System.Collections.ArrayList]::new(@('virtualization', 'clusters'))
    
    $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters
    
    $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
    
    InvokeNetboxRequest -URI $uri -Raw:$Raw
}

#endregion

#region File Get-NetboxVirtualizationClusterGroup.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/19/2020 14:11
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-NetboxVirtualizationClusterGroup.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function Get-NetboxVirtualizationClusterGroup {
    [CmdletBinding()]
    param
    (
        [string]$Name,
        
        [string]$Slug,
        
        [string]$Description,
        
        [string]$Query,
        
        [uint32[]]$Id,
        
        [uint16]$Limit,
        
        [uint16]$Offset,
        
        [switch]$Raw
    )
    
    $Segments = [System.Collections.ArrayList]::new(@('virtualization', 'cluster-groups'))
    
    $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters
    
    $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
    
    InvokeNetboxRequest -URI $uri -Raw:$Raw
}

#endregion

#region File Get-NetboxVirtualMachine.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/19/2020 12:44
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-NetboxVirtualMachine.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function Get-NetboxVirtualMachine {
<#
    .SYNOPSIS
        Obtains virtual machines from Netbox.
    
    .DESCRIPTION
        Obtains one or more virtual machines based on provided filters.
    
    .PARAMETER Limit
        Number of results to return per page
    
    .PARAMETER Offset
        The initial index from which to return the results
    
    .PARAMETER Query
        A general query used to search for a VM
    
    .PARAMETER Name
        Name of the VM
    
    .PARAMETER Id
        Database ID of the VM
    
    .PARAMETER Status
        Status of the VM
    
    .PARAMETER Tenant
        String value of tenant
    
    .PARAMETER Tenant_ID
        Database ID of the tenant.
    
    .PARAMETER Platform
        String value of the platform
    
    .PARAMETER Platform_ID
        Database ID of the platform
    
    .PARAMETER Cluster_Group
        String value of the cluster group.
    
    .PARAMETER Cluster_Group_Id
        Database ID of the cluster group.
    
    .PARAMETER Cluster_Type
        String value of the Cluster type.
    
    .PARAMETER Cluster_Type_Id
        Database ID of the cluster type.
    
    .PARAMETER Cluster_Id
        Database ID of the cluster.
    
    .PARAMETER Site
        String value of the site.
    
    .PARAMETER Site_Id
        Database ID of the site.
    
    .PARAMETER Role
        String value of the role.
    
    .PARAMETER Role_Id
        Database ID of the role.
    
    .PARAMETER Raw
        A description of the Raw parameter.
    
    .PARAMETER TenantID
        Database ID of tenant
    
    .PARAMETER PlatformID
        Database ID of the platform
    
    .PARAMETER id__in
        Database IDs of VMs
    
    .EXAMPLE
        PS C:\> Get-NetboxVirtualMachine
    
    .NOTES
        Additional information about the function.
#>
    
    [CmdletBinding()]
    param
    (
        [Alias('q')]
        [string]$Query,
        
        [string]$Name,
        
        [uint16[]]$Id,
        
        [object]$Status,
        
        [string]$Tenant,
        
        [uint16]$Tenant_ID,
        
        [string]$Platform,
        
        [uint16]$Platform_ID,
        
        [string]$Cluster_Group,
        
        [uint16]$Cluster_Group_Id,
        
        [string]$Cluster_Type,
        
        [uint16]$Cluster_Type_Id,
        
        [uint16]$Cluster_Id,
        
        [string]$Site,
        
        [uint16]$Site_Id,
        
        [string]$Role,
        
        [uint16]$Role_Id,
        
        [uint16]$Limit,
        
        [uint16]$Offset,
        
        [switch]$Raw
    )
    
    if ($null -ne $Status) {
        $PSBoundParameters.Status = ValidateVirtualizationChoice -ProvidedValue $Status -VirtualMachineStatus
    }
    
    $Segments = [System.Collections.ArrayList]::new(@('virtualization', 'virtual-machines'))
    
    $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters
    
    $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
    
    InvokeNetboxRequest -URI $uri -Raw:$Raw
}

#endregion

#region File Get-NetboxVirtualMachineInterface.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/19/2020 12:47
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-NetboxVirtualMachineInterface.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function Get-NetboxVirtualMachineInterface {
<#
    .SYNOPSIS
        Gets VM interfaces
    
    .DESCRIPTION
        Obtains the interface objects for one or more VMs
    
    .PARAMETER Limit
        Number of results to return per page.
    
    .PARAMETER Offset
        The initial index from which to return the results.
    
    .PARAMETER Id
        Database ID of the interface
    
    .PARAMETER Name
        Name of the interface
    
    .PARAMETER Enabled
        True/False if the interface is enabled
    
    .PARAMETER MTU
        Maximum Transmission Unit size. Generally 1500 or 9000
    
    .PARAMETER Virtual_Machine_Id
        ID of the virtual machine to which the interface(s) are assigned.
    
    .PARAMETER Virtual_Machine
        Name of the virtual machine to get interfaces
    
    .PARAMETER MAC_Address
        MAC address assigned to the interface
    
    .PARAMETER Raw
        A description of the Raw parameter.
    
    .EXAMPLE
        PS C:\> Get-NetboxVirtualMachineInterface
    
    .NOTES
        Additional information about the function.
#>
    
    [CmdletBinding()]
    param
    (
        [Parameter(ValueFromPipeline = $true)]
        [uint16]$Id,
        
        [string]$Name,
        
        [string]$Query,
        
        [boolean]$Enabled,
        
        [uint16]$MTU,
        
        [uint16]$Virtual_Machine_Id,
        
        [string]$Virtual_Machine,
        
        [string]$MAC_Address,
        
        [uint16]$Limit,
        
        [uint16]$Offset,
        
        [switch]$Raw
    )
    
    $Segments = [System.Collections.ArrayList]::new(@('virtualization', 'interfaces'))
    
    $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters
    
    $uri = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters
    
    InvokeNetboxRequest -URI $uri -Raw:$Raw
}

#endregion

#region File InvokeNetboxRequest.ps1

<#
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/26/2020 14:24
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	InvokeNetboxRequest.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function InvokeNetboxRequest {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.UriBuilder]$URI,

        [Hashtable]$Headers = @{
        },

        [pscustomobject]$Body = $null,

        [ValidateRange(1, 65535)]
        [uint16]$Timeout = (Get-NetboxTimeout),

        [ValidateSet('GET', 'PATCH', 'PUT', 'POST', 'DELETE', 'OPTIONS', IgnoreCase = $true)]
        [string]$Method = 'GET',

        [switch]$Raw
    )

    $creds = Get-NetboxCredential

    $Headers.Authorization = "Token {0}" -f $creds.GetNetworkCredential().Password

    $splat = @{
        'Method'      = $Method
        'Uri'         = $URI.Uri.AbsoluteUri # This property auto generates the scheme, hostname, path, and query
        'Headers'     = $Headers
        'TimeoutSec'  = $Timeout
        'ContentType' = 'application/json'
        'ErrorAction' = 'Stop'
        'Verbose'     = $VerbosePreference
    }

    $splat += Get-NetboxInvokeParams

    if ($Body) {
        Write-Verbose "BODY: $($Body | ConvertTo-Json -Compress)"
        $null = $splat.Add('Body', ($Body | ConvertTo-Json -Compress))
    }

    $result = Invoke-RestMethod @splat

    #region TODO: Handle errors a little more gracefully...

    <#
    try {
        Write-Verbose "Sending request..."
        $result = Invoke-RestMethod @splat
        Write-Verbose $result
    } catch {
        Write-Verbose "Caught exception"
        if ($_.Exception.psobject.properties.Name.contains('Response')) {
            Write-Verbose "Exception contains a response property"
            if ($Raw) {
                Write-Verbose "RAW provided...throwing raw exception"
                throw $_
            }

            Write-Verbose "Converting response to object"
            $myError = GetNetboxAPIErrorBody -Response $_.Exception.Response | ConvertFrom-Json
        } else {
            Write-Verbose "No response property found"
            $myError = $_
        }
    }

    Write-Verbose "MyError is $($myError.GetType().FullName)"

    if ($myError -is [Exception]) {
        throw $_
    } elseif ($myError -is [pscustomobject]) {
        throw $myError.detail
    }
    #>

    #endregion TODO: Handle errors a little more gracefully...

    # If the user wants the raw value from the API... otherwise return only the actual result
    if ($Raw) {
        Write-Verbose "Returning raw result by choice"
        return $result
    } else {
        if ($result.psobject.Properties.Name.Contains('results')) {
            Write-Verbose "Found Results property on data, returning results directly"
            return $result.Results
        } else {
            Write-Verbose "Did NOT find results property on data, returning raw result"
            return $result
        }
    }
}

#endregion

#region File New-NetboxCircuit.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.181
	 Created on:   	2020-11-04 11:48
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	New-NetboxCircuit.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>



function New-NetboxCircuit {
    [CmdletBinding(ConfirmImpact = 'Low',
                   SupportsShouldProcess = $true)]
    [OutputType([pscustomobject])]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [string]$CID,
        
        [Parameter(Mandatory = $true)]
        [uint32]$Provider,
        
        [Parameter(Mandatory = $true)]
        [uint32]$Type,
        
        #[ValidateSet('Active', 'Planned', 'Provisioning', 'Offline', 'Deprovisioning', 'Decommissioned ')]
        [uint16]$Status = 'Active',
        
        [string]$Description,
        
        [uint32]$Tenant,
        
        [string]$Termination_A,
        
        [datetime]$Install_Date,
        
        [string]$Termination_Z,
        
        [ValidateRange(0, 2147483647)]
        [uint32]$Commit_Rate,
        
        [string]$Comments,
        
        [hashtable]$Custom_Fields,
        
        [switch]$Force,
        
        [switch]$Raw
    )
    
    $Segments = [System.Collections.ArrayList]::new(@('circuits', 'circuits'))
    $Method = 'POST'
    
    $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters
    
    $URI = BuildNewURI -Segments $URIComponents.Segments
    
    if ($Force -or $PSCmdlet.ShouldProcess($CID, 'Create new circuit')) {
        InvokeNetboxRequest -URI $URI -Method $Method -Body $URIComponents.Parameters -Raw:$Raw
    }
}

#endregion

#region File New-NetboxDCIMDevice.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/23/2020 12:08
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	New-NetboxDCIMDevice.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


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
    
#    if ($null -ne $Device_Role) {
#        # Validate device role?
#    }
#    
#    if ($null -ne $Device_Type) {
#        # Validate device type?
#    }
#    
#    if ($null -ne $Status) {
#        $PSBoundParameters.Status = ValidateDCIMChoice -ProvidedValue $Status -DeviceStatus
#    }
#    
#    if ($null -ne $Face) {
#        $PSBoundParameters.Face = ValidateDCIMChoice -ProvidedValue $Face -DeviceFace
#    }
    
    $Segments = [System.Collections.ArrayList]::new(@('dcim', 'devices'))
    
    $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters
    
    $URI = BuildNewURI -Segments $URIComponents.Segments
    
    InvokeNetboxRequest -URI $URI -Body $URIComponents.Parameters -Method POST
}

#endregion

#region File New-NetboxIPAMAddress.ps1

<#
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/19/2020 11:51
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	New-NetboxIPAMAddress.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


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

    .PARAMETER Dns_name
        DNS Name of IP address (example : netbox.example.com)

    .PARAMETER Force
        Do not prompt for confirmation to create IP.

    .PARAMETER Raw
        Return raw results from API service

    .EXAMPLE
        PS C:\> Create-NetboxIPAMAddress

    .NOTES
        Additional information about the function.
#>

    [CmdletBinding(ConfirmImpact = 'Low',
        SupportsShouldProcess = $true)]
    [OutputType([pscustomobject])]
    param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string]$Address,

        [object]$Status = 'Active',

        [int]$Tenant,

        [int]$VRF,

        [object]$Role,

        [int]$NAT_Inside,

        [hashtable]$Custom_Fields,

        [int]$Interface,

        [string]$Description,

        [string]$Dns_name,

        [switch]$Force,

        [switch]$Raw
    )

    process {
        $Segments = [System.Collections.ArrayList]::new(@('ipam', 'ip-addresses'))
        $Method = 'POST'

        #    # Value validation
        #    $ModelDefinition = GetModelDefinitionFromURIPath -Segments $Segments -Method $Method
        #    $EnumProperties = GetModelEnumProperties -ModelDefinition $ModelDefinition
        #
        #    foreach ($Property in $EnumProperties.Keys) {
        #        if ($PSBoundParameters.ContainsKey($Property)) {
        #            Write-Verbose "Validating property [$Property] with value [$($PSBoundParameters.$Property)]"
        #            $PSBoundParameters.$Property = ValidateValue -ModelDefinition $ModelDefinition -Property $Property -ProvidedValue $PSBoundParameters.$Property
        #        }
        #    }
        #
        $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters

        $URI = BuildNewURI -Segments $URIComponents.Segments

        if ($Force -or $PSCmdlet.ShouldProcess($Address, 'Create new IP address')) {
            InvokeNetboxRequest -URI $URI -Method $Method -Body $URIComponents.Parameters -Raw:$Raw
        }
    }
}






#endregion

#region File New-NetboxIPAMPrefix.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/19/2020 11:52
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	New-NetboxIPAMPrefix.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function New-NetboxIPAMPrefix {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Prefix,
        
        [object]$Status = 'Active',
        
        [uint16]$Tenant,
        
        [object]$Role,
        
        [bool]$IsPool,
        
        [string]$Description,
        
        [uint16]$Site,
        
        [uint16]$VRF,
        
        [uint16]$VLAN,
        
        [hashtable]$Custom_Fields,
        
        [switch]$Raw
    )
    
#    $PSBoundParameters.Status = ValidateIPAMChoice -ProvidedValue $Status -PrefixStatus
    
    <#
    # As of 2018/10/18, this does not appear to be a validated IPAM choice
    if ($null -ne $Role) {
        $PSBoundParameters.Role = ValidateIPAMChoice -ProvidedValue $Role -PrefixRole
    }
    #>
    
    $segments = [System.Collections.ArrayList]::new(@('ipam', 'prefixes'))
    
    $URIComponents = BuildURIComponents -URISegments $segments -ParametersDictionary $PSBoundParameters
    
    $URI = BuildNewURI -Segments $URIComponents.Segments
    
    InvokeNetboxRequest -URI $URI -Method POST -Body $URIComponents.Parameters -Raw:$Raw
}

#endregion

#region File New-NetboxIPAMVLAN.ps1

function New-NetboxIPAMVLAN {
<#
    .SYNOPSIS
        Create a new VLAN
    
    .DESCRIPTION
        Create a new VLAN in Netbox with a status of Active by default.
    
    .PARAMETER VID
        The VLAN ID.
    
    .PARAMETER Name
        The name of the VLAN.
    
    .PARAMETER Status
        Status of the VLAN. Defaults to Active
    
    .PARAMETER Tenant
        Tenant ID
    
    .PARAMETER Role
        Role such as anycast, loopback, etc... Defaults to nothing
    
    .PARAMETER Description
        Description of IP address
    
    .PARAMETER Custom_Fields
        Custom field hash table. Will be validated by the API service
    
    .PARAMETER Raw
        Return raw results from API service
    
    .PARAMETER Address
        IP address in CIDR notation: 192.168.1.1/24
    
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
        [uint16]$VID,
        
        [Parameter(Mandatory = $true)]
        [string]$Name,
        
        [object]$Status = 'Active',
        
        [uint16]$Tenant,
        
        [object]$Role,
        
        [string]$Description,
        
        [hashtable]$Custom_Fields,
        
        [switch]$Raw
    )
    
#    $PSBoundParameters.Status = ValidateIPAMChoice -ProvidedValue $Status -VLANStatus
#    
#    if ($null -ne $Role) {
#        $PSBoundParameters.Role = ValidateIPAMChoice -ProvidedValue $Role -IPAddressRole
#    }
    
    $segments = [System.Collections.ArrayList]::new(@('ipam', 'vlans'))
    
    $URIComponents = BuildURIComponents -URISegments $segments -ParametersDictionary $PSBoundParameters
    
    $URI = BuildNewURI -Segments $URIComponents.Segments
    
    InvokeNetboxRequest -URI $URI -Method POST -Body $URIComponents.Parameters -Raw:$Raw
}

#endregion

#region File New-NetboxVirtualMachine.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/19/2020 12:44
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	New-NetboxVirtualMachine.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function New-NetboxVirtualMachine {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Name,
        
        [Parameter(Mandatory = $true)]
        [uint16]$Cluster,
        
        [uint16]$Tenant,
        
        [object]$Status = 'Active',
        
        [uint16]$Role,
        
        [uint16]$Platform,
        
        [uint16]$vCPUs,
        
        [uint16]$Memory,
        
        [uint16]$Disk,
        
        [uint16]$Primary_IP4,
        
        [uint16]$Primary_IP6,
        
        [hashtable]$Custom_Fields,
        
        [string]$Comments
    )
    
#    $ModelDefinition = $script:NetboxConfig.APIDefinition.definitions.WritableVirtualMachineWithConfigContext
#    
#    # Validate the status against the APIDefinition
#    if ($ModelDefinition.properties.status.enum -inotcontains $Status) {
#        throw ("Invalid value [] for Status. Must be one of []" -f $Status, ($ModelDefinition.properties.status.enum -join ', '))
#    }
#    
    #$PSBoundParameters.Status = ValidateVirtualizationChoice -ProvidedValue $Status -VirtualMachineStatus
    
    $Segments = [System.Collections.ArrayList]::new(@('virtualization', 'virtual-machines'))
    
    $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters
    
    $URI = BuildNewURI -Segments $URIComponents.Segments
    
    InvokeNetboxRequest -URI $URI -Method POST -Body $URIComponents.Parameters
}





#endregion

#region File Remove-NetboxDCIMDevice.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/23/2020 12:08
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Remove-NetboxDCIMDevice.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


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

#endregion

#region File Remove-NetboxDCIMInterface.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/23/2020 12:11
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Remove-NetboxDCIMInterface.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


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

#endregion

#region File Remove-NetboxDCIMInterfaceConnection.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/23/2020 12:12
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Remove-NetboxDCIMInterfaceConnection.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


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

#endregion

#region File Remove-NetboxIPAMAddress.ps1

<#
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/19/2020 11:52
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Remove-NetboxIPAMAddress.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>

function Remove-NetboxIPAMAddress {
    <#
    .SYNOPSIS
        Remove an IP address from Netbox

    .DESCRIPTION
        Removes/deletes an IP address from Netbox by ID and optional other filters

    .PARAMETER Id
        Database ID of the IP address object.

    .PARAMETER Force
        Do not confirm.

    .EXAMPLE
        PS C:\> Remove-NetboxIPAMAddress -Id $value1

    .NOTES
        Additional information about the function.
#>

    [CmdletBinding(ConfirmImpact = 'High',
        SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
        [int[]]$Id,

        [switch]$Force
    )

    process {
        foreach ($IPId in $Id) {
            $CurrentIP = Get-NetboxIPAMAddress -Id $IPId -ErrorAction Stop

            $Segments = [System.Collections.ArrayList]::new(@('ipam', 'ip-addresses', $IPId))

            if ($Force -or $pscmdlet.ShouldProcess($CurrentIP.Address, "Delete")) {
                $URI = BuildNewURI -Segments $Segments

                InvokeNetboxRequest -URI $URI -Method DELETE
            }
        }
    }
}

#endregion

#region File Remove-NetboxVirtualMachine.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/19/2020 12:45
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Remove-NetboxVirtualMachine.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function Remove-NetboxVirtualMachine {
<#
    .SYNOPSIS
        Delete a virtual machine
    
    .DESCRIPTION
        Deletes a virtual machine from Netbox by ID
    
    .PARAMETER Id
        Database ID of the virtual machine
    
    .PARAMETER Force
        Force deletion without any prompts
    
    .EXAMPLE
        PS C:\> Remove-NetboxVirtualMachine -Id $value1
    
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
        foreach ($VMId in $Id) {
            $CurrentVM = Get-NetboxVirtualMachine -Id $VMId -ErrorAction Stop
            
            if ($Force -or $pscmdlet.ShouldProcess("$($CurrentVM.Name)/$($CurrentVM.Id)", "Remove")) {
                $Segments = [System.Collections.ArrayList]::new(@('virtualization', 'virtual-machines', $CurrentVM.Id))
                
                $URI = BuildNewURI -Segments $Segments
                
                InvokeNetboxRequest -URI $URI -Method DELETE
            }
        }
    }
    
    end {
        
    }
}

#endregion

#region File Set-NetboxCipherSSL.ps1

Function Set-NetboxCipherSSL {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessforStateChangingFunctions", "")]
    Param(  )
    # Hack for allowing TLS 1.1 and TLS 1.2 (by default it is only SSL3 and TLS (1.0))
    $AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
    [System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols

}

#endregion

#region File Set-NetboxCredential.ps1

function Set-NetboxCredential {
    [CmdletBinding(DefaultParameterSetName = 'CredsObject',
        ConfirmImpact = 'Low',
        SupportsShouldProcess = $true)]
    [OutputType([pscredential])]
    param
    (
        [Parameter(ParameterSetName = 'CredsObject',
            Mandatory = $true)]
        [pscredential]$Credential,

        [Parameter(ParameterSetName = 'UserPass',
            Mandatory = $true)]
        [securestring]$Token
    )

    if ($PSCmdlet.ShouldProcess('Netbox Credentials', 'Set')) {
        switch ($PsCmdlet.ParameterSetName) {
            'CredsObject' {
                $script:NetboxConfig.Credential = $Credential
                break
            }

            'UserPass' {
                $script:NetboxConfig.Credential = [System.Management.Automation.PSCredential]::new('notapplicable', $Token)
                break
            }
        }

        $script:NetboxConfig.Credential
    }
}

#endregion

#region File Set-NetboxDCIMDevice.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/23/2020 12:08
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Set-NetboxDCIMDevice.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


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
#        if ($null -ne $Status) {
#            $PSBoundParameters.Status = ValidateDCIMChoice -ProvidedValue $Status -DeviceStatus
#        }
#        
#        if ($null -ne $Face) {
#            $PSBoundParameters.Face = ValidateDCIMChoice -ProvidedValue $Face -DeviceFace
#        }
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

#endregion

#region File Set-NetboxDCIMInterface.ps1

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

#endregion

#region File Set-NetboxDCIMInterfaceConnection.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/23/2020 12:11
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Set-NetboxDCIMInterfaceConnection.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


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
#        if ($null -ne $Connection_Status) {
#            $PSBoundParameters.Connection_Status = ValidateDCIMChoice -ProvidedValue $Connection_Status -InterfaceConnectionStatus
#        }
        
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

#endregion

#region File Set-NetboxHostName.ps1

function Set-NetboxHostName {
    [CmdletBinding(ConfirmImpact = 'Low',
        SupportsShouldProcess = $true)]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Hostname
    )

    if ($PSCmdlet.ShouldProcess('Netbox Hostname', 'Set')) {
        $script:NetboxConfig.Hostname = $Hostname.Trim()
        $script:NetboxConfig.Hostname
    }
}

#endregion

#region File Set-NetboxHostPort.ps1

function Set-NetboxHostPort {
    [CmdletBinding(ConfirmImpact = 'Low',
                   SupportsShouldProcess = $true)]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [uint16]$Port
    )
    
    if ($PSCmdlet.ShouldProcess('Netbox Port', 'Set')) {
        $script:NetboxConfig.HostPort = $Port
        $script:NetboxConfig.HostPort
    }
}

#endregion

#region File Set-NetboxHostScheme.ps1

function Set-NetboxHostScheme {
    [CmdletBinding(ConfirmImpact = 'Low',
                   SupportsShouldProcess = $true)]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $false)]
        [ValidateSet('https', 'http', IgnoreCase = $true)]
        [string]$Scheme = 'https'
    )
    
    if ($PSCmdlet.ShouldProcess('Netbox Host Scheme', 'Set')) {
        if ($Scheme -eq 'http') {
            Write-Warning "Connecting via non-secure HTTP is not-recommended"
        }
        
        $script:NetboxConfig.HostScheme = $Scheme
        $script:NetboxConfig.HostScheme
    }
}

#endregion

#region File Set-NetboxInvokeParams.ps1

function Set-NetboxInvokeParams {
    [CmdletBinding(ConfirmImpact = 'Low',
        SupportsShouldProcess = $true)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [array]$InvokeParams
    )

    if ($PSCmdlet.ShouldProcess('Netbox Invoke Params', 'Set')) {
        $script:NetboxConfig.InvokeParams = $InvokeParams
        $script:NetboxConfig.InvokeParams
    }
}

#endregion

#region File Set-NetboxIPAMAddress.ps1

<#
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/19/2020 11:53
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Set-NetboxIPAMAddress.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function Set-NetboxIPAMAddress {
    [CmdletBinding(ConfirmImpact = 'Medium',
        SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
        [int[]]$Id,

        [string]$Address,

        [string]$Status,

        [int]$Tenant,

        [int]$VRF,

        [object]$Role,

        [int]$NAT_Inside,

        [hashtable]$Custom_Fields,

        [ValidateSet('dcim.interface', 'virtualization.vminterface', IgnoreCase = $true)]
        [string]$Assigned_Object_Type,

        [uint16]$Assigned_Object_Id,

        [string]$Description,

        [string]$Dns_name,

        [switch]$Force
    )

    begin {
        #        Write-Verbose "Validating enum properties"
        #        $Segments = [System.Collections.ArrayList]::new(@('ipam', 'ip-addresses', 0))
        $Method = 'PATCH'
        #
        #        # Value validation
        #        $ModelDefinition = GetModelDefinitionFromURIPath -Segments $Segments -Method $Method
        #        $EnumProperties = GetModelEnumProperties -ModelDefinition $ModelDefinition
        #
        #        foreach ($Property in $EnumProperties.Keys) {
        #            if ($PSBoundParameters.ContainsKey($Property)) {
        #                Write-Verbose "Validating property [$Property] with value [$($PSBoundParameters.$Property)]"
        #                $PSBoundParameters.$Property = ValidateValue -ModelDefinition $ModelDefinition -Property $Property -ProvidedValue $PSBoundParameters.$Property
        #            } else {
        #                Write-Verbose "User did not provide a value for [$Property]"
        #            }
        #        }
        #
        #        Write-Verbose "Finished enum validation"
    }

    process {
        foreach ($IPId in $Id) {
            if ($PSBoundParameters.ContainsKey('Assigned_Object_Type') -or $PSBoundParameters.ContainsKey('Assigned_Object_Id')) {
                if ((-not [string]::IsNullOrWhiteSpace($Assigned_Object_Id)) -and [string]::IsNullOrWhiteSpace($Assigned_Object_Type)) {
                    throw "Assigned_Object_Type is required when specifying Assigned_Object_Id"
                }
                elseif ((-not [string]::IsNullOrWhiteSpace($Assigned_Object_Type)) -and [string]::IsNullOrWhiteSpace($Assigned_Object_Id)) {
                    throw "Assigned_Object_Id is required when specifying Assigned_Object_Type"
                }
            }

            $Segments = [System.Collections.ArrayList]::new(@('ipam', 'ip-addresses', $IPId))

            Write-Verbose "Obtaining IP from ID $IPId"
            $CurrentIP = Get-NetboxIPAMAddress -Id $IPId -ErrorAction Stop

            if ($Force -or $PSCmdlet.ShouldProcess($CurrentIP.Address, 'Set')) {
                $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Id', 'Force'

                $URI = BuildNewURI -Segments $URIComponents.Segments

                InvokeNetboxRequest -URI $URI -Body $URIComponents.Parameters -Method $Method
            }
        }
    }
}

#endregion

#region File Set-NetboxIPAMPrefix.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2021 v5.8.186
	 Created on:   	2021-03-23 13:54
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Set-NetboxIPAMPrefix.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function Set-NetboxIPAMPrefix {
    [CmdletBinding(ConfirmImpact = 'Medium',
                   SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [uint16[]]$Id,
        
        [string]$Prefix,
        
        [string]$Status,
        
        [uint16]$Tenant,
        
        [uint16]$Site,
        
        [uint16]$VRF,
        
        [uint16]$VLAN,
        
        [object]$Role,
        
        [hashtable]$Custom_Fields,
        
        [string]$Description,
        
        [switch]$Is_Pool,
        
        [switch]$Force
    )
    
    begin {
        #        Write-Verbose "Validating enum properties"
        #        $Segments = [System.Collections.ArrayList]::new(@('ipam', 'ip-addresses', 0))
        $Method = 'PATCH'
        #        
        #        # Value validation
        #        $ModelDefinition = GetModelDefinitionFromURIPath -Segments $Segments -Method $Method
        #        $EnumProperties = GetModelEnumProperties -ModelDefinition $ModelDefinition
        #        
        #        foreach ($Property in $EnumProperties.Keys) {
        #            if ($PSBoundParameters.ContainsKey($Property)) {
        #                Write-Verbose "Validating property [$Property] with value [$($PSBoundParameters.$Property)]"
        #                $PSBoundParameters.$Property = ValidateValue -ModelDefinition $ModelDefinition -Property $Property -ProvidedValue $PSBoundParameters.$Property
        #            } else {
        #                Write-Verbose "User did not provide a value for [$Property]"
        #            }
        #        }
        #        
        #        Write-Verbose "Finished enum validation"
    }
    
    process {
        foreach ($PrefixId in $Id) {
            $Segments = [System.Collections.ArrayList]::new(@('ipam', 'prefixes', $PrefixId))
            
            Write-Verbose "Obtaining Prefix from ID $PrefixId"
            $CurrentPrefix = Get-NetboxIPAMPrefix -Id $PrefixId -ErrorAction Stop
            
            if ($Force -or $PSCmdlet.ShouldProcess($CurrentPrefix.Prefix, 'Set')) {
                $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Id', 'Force'
                
                $URI = BuildNewURI -Segments $URIComponents.Segments
                
                InvokeNetboxRequest -URI $URI -Body $URIComponents.Parameters -Method $Method
            }
        }
    }
}









#endregion

#region File Set-NetboxTimeout.ps1


function Set-NetboxTimeout {
    [CmdletBinding(ConfirmImpact = 'Low',
                   SupportsShouldProcess = $true)]
    [OutputType([uint16])]
    param
    (
        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 65535)]
        [uint16]$TimeoutSeconds = 30
    )

    if ($PSCmdlet.ShouldProcess('Netbox Timeout', 'Set')) {
        $script:NetboxConfig.Timeout = $TimeoutSeconds
        $script:NetboxConfig.Timeout
    }
}

#endregion

#region File Set-NetboxUnstrustedSSL.ps1

Function Set-NetboxUntrustedSSL {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessforStateChangingFunctions", "")]
    Param(  )
    # Hack for allowing untrusted SSL certs with https connections
    Add-Type -TypeDefinition @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
        ServicePoint srvPoint, X509Certificate certificate,
        WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@

    [System.Net.ServicePointManager]::CertificatePolicy = New-Object -TypeName TrustAllCertsPolicy

}

#endregion

#region File Set-NetboxVirtualMachine.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/19/2020 12:45
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Set-NetboxVirtualMachine.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function Set-NetboxVirtualMachine {
    [CmdletBinding(ConfirmImpact = 'Medium',
                   SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [uint16]$Id,
        
        [string]$Name,
        
        [uint16]$Role,
        
        [uint16]$Cluster,
        
        [object]$Status,
        
        [uint16]$Platform,
        
        [uint16]$Primary_IP4,
        
        [uint16]$Primary_IP6,
        
        [byte]$VCPUs,
        
        [uint16]$Memory,
        
        [uint16]$Disk,
        
        [uint16]$Tenant,
        
        [string]$Comments,
        
        [hashtable]$Custom_Fields,
        
        [switch]$Force
    )
    
#    if ($null -ne $Status) {
#        $PSBoundParameters.Status = ValidateVirtualizationChoice -ProvidedValue $Status -VirtualMachineStatus
#    }
#    
    $Segments = [System.Collections.ArrayList]::new(@('virtualization', 'virtual-machines', $Id))
    
    Write-Verbose "Obtaining VM from ID $Id"
    
    #$CurrentVM = Get-NetboxVirtualMachine -Id $Id -ErrorAction Stop
    
    Write-Verbose "Finished obtaining VM"
    
    if ($Force -or $pscmdlet.ShouldProcess($ID, "Set properties on VM ID")) {
        $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Id', 'Force'
        
        $URI = BuildNewURI -Segments $URIComponents.Segments
        
        InvokeNetboxRequest -URI $URI -Body $URIComponents.Parameters -Method PATCH
    }
}

#endregion

#region File Set-NetboxVirtualMachineInterface.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/19/2020 12:47
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Set-NetboxVirtualMachineInterface.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function Set-NetboxVirtualMachineInterface {
    [CmdletBinding(ConfirmImpact = 'Medium',
                   SupportsShouldProcess = $true)]
    [OutputType([pscustomobject])]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [uint16[]]$Id,
        
        [string]$Name,
        
        [string]$MAC_Address,
        
        [uint16]$MTU,
        
        [string]$Description,
        
        [boolean]$Enabled,
        
        [uint16]$Virtual_Machine,
        
        [switch]$Force
    )
    
    begin {
        
    }
    
    process {
        foreach ($VMI_ID in $Id) {
            Write-Verbose "Obtaining VM Interface..."
            $CurrentVMI = Get-NetboxVirtualMachineInterface -Id $VMI_ID -ErrorAction Stop
            Write-Verbose "Finished obtaining VM Interface"
            
            $Segments = [System.Collections.ArrayList]::new(@('virtualization', 'interfaces', $CurrentVMI.Id))
            
            if ($Force -or $pscmdlet.ShouldProcess("Interface $($CurrentVMI.Id) on VM $($CurrentVMI.Virtual_Machine.Name)", "Set")) {
                $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Id', 'Force'
                
                $URI = BuildNewURI -Segments $URIComponents.Segments
                
                InvokeNetboxRequest -URI $URI -Body $URIComponents.Parameters -Method PATCH
            }
        }
    }
    
    end {
        
    }
}

#endregion

#region File SetupNetboxConfigVariable.ps1

function SetupNetboxConfigVariable {
    [CmdletBinding()]
    param
    (
        [switch]$Overwrite
    )

    Write-Verbose "Checking for NetboxConfig hashtable"
    if ((-not ($script:NetboxConfig)) -or $Overwrite) {
        Write-Verbose "Creating NetboxConfig hashtable"
        $script:NetboxConfig = @{
            'Connected'     = $false
            'Choices'       = @{
            }
            'APIDefinition' = $null
        }
    }

    Write-Verbose "NetboxConfig hashtable already exists"
}

#endregion

#region File Tenancy.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2018 v5.5.152
	 Created on:   	5/29/2018 1:45 PM
	 Created by:   	Ben Claussen
	 Organization: 	NEOnet
	 Filename:     	Tenancy.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>




#region GET commands



#endregion GET commands


#region SET commands

#endregion SET commands


#region ADD/NEW commands

#endregion ADD/NEW commands


#region REMOVE commands

#endregion REMOVE commands

#endregion

#region File ThrowNetboxRESTError.ps1

<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/26/2020 14:25
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	ThrowNetboxRESTError.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function ThrowNetboxRESTError {
    $uriSegments = [System.Collections.ArrayList]::new(@('fake', 'url'))
    
    $URIParameters = @{
    }
    
    $uri = BuildNewURI -Segments $uriSegments -Parameters $URIParameters
    
    InvokeNetboxRequest -URI $uri -Raw
}

#endregion

#region File VerifyAPIConnectivity.ps1

function VerifyAPIConnectivity {
    [CmdletBinding()]
    param ()

    $uriSegments = [System.Collections.ArrayList]::new(@('extras'))

    $uri = BuildNewURI -Segments $uriSegments -Parameters @{'format' = 'json' } -SkipConnectedCheck

    InvokeNetboxRequest -URI $uri
}

#endregion

<#
    .NOTES
    --------------------------------------------------------------------------------
     Code generated by:  SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
     Generated on:       3/26/2020 15:16
     Generated by:       Claussen
     Organization:       NEOnet
    --------------------------------------------------------------------------------
    .DESCRIPTION
        Script generated by PowerShell Studio 2020
#>

# Build a list of common paramters so we can omit them to build URI parameters
$script:CommonParameterNames = New-Object System.Collections.ArrayList
[void]$script:CommonParameterNames.AddRange(@([System.Management.Automation.PSCmdlet]::CommonParameters))
[void]$script:CommonParameterNames.AddRange(@([System.Management.Automation.PSCmdlet]::OptionalCommonParameters))
[void]$script:CommonParameterNames.Add('Raw')

SetupNetboxConfigVariable

Export-ModuleMember -Function *
#Export-ModuleMember -Function *-*
