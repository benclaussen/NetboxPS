<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2018 v5.5.148
	 Created on:   	2/28/2018 3:33 PM
	 Created by:   	Ben Claussen
	 Organization: 	NEOnet
	 Filename:     	Setup.ps1
	===========================================================================
	.DESCRIPTION
		These are the function used to setup the environment for connecting
        to a Netbox API
#>

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
            'Connected' = $false
            'Choices' = @{}
        }
    }
    
    Write-Verbose "NetboxConfig hashtable already exists"
}

function GetNetboxConfigVariable {
    return $script:NetboxConfig
}

function Set-NetboxHostName {
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true)]
		[string]$Hostname
	)
	
	$script:NetboxConfig.Hostname = $Hostname.Trim()
	$script:NetboxConfig.Hostname
}

function Get-NetboxHostname {
	[CmdletBinding()]
	param ()
    
    Write-Verbose "Getting Netbox hostname"
	if ($script:NetboxConfig.Hostname -eq $null) {
		throw "Netbox Hostname is not set! You may set it with Set-NetboxHostname -Hostname 'hostname.domain.tld'"
	}
	
	$script:NetboxConfig.Hostname
}

function Set-NetboxCredentials {
	[CmdletBinding(DefaultParameterSetName = 'CredsObject')]
	[OutputType([pscredential], ParameterSetName = 'CredsObject')]
	[OutputType([pscredential], ParameterSetName = 'UserPass')]
	param
	(
		[Parameter(ParameterSetName = 'CredsObject',
				   Mandatory = $true)]
		[pscredential]$Credentials,
		
		[Parameter(ParameterSetName = 'UserPass',
				   Mandatory = $true)]
		[string]$Token
	)
	
	switch ($PsCmdlet.ParameterSetName) {
		'CredsObject' {
			$script:NetboxConfig.Credentials = $Credentials
			break
		}
		
		'UserPass' {
			$securePW = ConvertTo-SecureString $Token -AsPlainText -Force
			$script:NetboxConfig.Credentials = [System.Management.Automation.PSCredential]::new('notapplicable', $securePW)
			break
		}
	}
	
	$script:NetboxConfig.Credentials
}

function Get-NetboxCredentials {
	[CmdletBinding()]
	[OutputType([pscredential])]
	param ()
	
	if (-not $script:NetboxConfig.Credentials) {
		throw "Netbox Credentials not set! You may set with Set-NetboxCredentials"
	}
	
	$script:NetboxConfig.Credentials
}

function VerifyAPIConnectivity {
    [CmdletBinding()]
    param ()
    
    $uriSegments = [System.Collections.ArrayList]::new(@('extras', '_choices'))
    
    $uri = BuildNewURI -Segments $uriSegments -SkipConnectedCheck
    
    InvokeNetboxRequest -URI $uri
}

function Connect-NetboxAPI {
<#
    .SYNOPSIS
        Connects to the Netbox API and ensures credentials work properly
    
    .DESCRIPTION
        A detailed description of the Connect-NetboxAPI function.
    
    .PARAMETER Hostname
        A description of the Hostname parameter.
    
    .PARAMETER Credentials
        A description of the Credentials parameter.
    
    .EXAMPLE
        PS C:\> Connect-NetboxAPI -Hostname "netbox.domain.com"
        
        This will prompt for credentials, then proceed to attempt a connection to Netbox
    
    .NOTES
        Additional information about the function.
#>
    
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Hostname,
        
        [Parameter(Mandatory = $false)]
        [pscredential]$Credentials
    )
    
    if (-not $Credentials) {
        try {
            $Credentials = Get-NetboxCredentials -ErrorAction Stop
        } catch {
            # Credentials are not set... Try to obtain from the user
            if (-not ($Credentials = Get-Credential -UserName 'username-not-applicable' -Message "Enter token for Netbox")) {
                throw "Token is necessary to connect to a Netbox API."
            }
        }
    }
    
    $null = Set-NetboxHostName -Hostname $Hostname
    $null = Set-NetboxCredentials -Credentials $Credentials
    
    try {
        Write-Verbose "Verifying API connectivity..."
        $APIInfo = VerifyAPIConnectivity
        $script:NetboxConfig.Connected = $true
        Write-Verbose "Successfully connected!"
    } catch {
        Write-Verbose "Failed to connect. Generating error"
        Write-Verbose $_.Exception.Message
        if (($_.Exception.Response) -and ($_.Exception.Response.StatusCode -eq 403)) {
            throw "Invalid token"
        } else {
            throw $_
        }
    }
    
    Write-Verbose "Caching static choices"
    $script:NetboxConfig.Choices.Circuits = Get-NetboxCircuitsChoices
    #$script:NetboxConfig.Choices.DCIM = Get-NetboxDCIMChoices          # Not completed yet
    $script:NetboxConfig.Choices.Extras = Get-NetboxExtrasChoices
    $script:NetboxConfig.Choices.IPAM = Get-NetboxIPAMChoices
    #$script:NetboxConfig.Choices.Secrets = Get-NetboxSecretsChoices    # Not completed yet
    #$script:NetboxConfig.Choices.Tenancy = Get-NetboxTenancyChoices    # Not completed yet
    $script:NetboxConfig.Choices.Virtualization = Get-NetboxVirtualizationChoices
    
    Write-Verbose "Connection process completed"
}









