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
        [string]$URI
    )

    if (-not $Credential) {
        try {
            $Credential = Get-NetboxCredential -ErrorAction Stop
        }
        catch {
            # Credentials are not set... Try to obtain from the user
            if (-not ($Credential = Get-Credential -UserName 'username-not-applicable' -Message "Enter token for Netbox")) {
                throw "Token is necessary to connect to a Netbox API."
            }
        }
    }

    $null = Set-NetboxCredential -Credential $Credential

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
    $null = Set-NetboxHostScheme -Scheme $uriBuilder.Scheme
    $null = Set-NetboxHostPort -Port $uriBuilder.Port

    try {
        Write-Verbose "Verifying API connectivity..."
        $null = VerifyAPIConnectivity
    }
    catch {
        Write-Verbose "Failed to connect. Generating error"
        Write-Verbose $_.Exception.Message
        if (($_.Exception.Response) -and ($_.Exception.Response.StatusCode -eq 403)) {
            throw "Invalid token"
        }
        else {
            throw $_
        }
    }

    Write-Verbose "Caching API definition"
    $script:NetboxConfig.APIDefinition = Get-NetboxAPIDefinition

    if ([version]$script:NetboxConfig.APIDefinition.info.version -lt 2.8) {
        $Script:NetboxConfig.Connected = $false
        throw "Netbox version is incompatible with this PS module. Requires >=2.8.*, found version $($script:NetboxConfig.APIDefinition.info.version)"
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