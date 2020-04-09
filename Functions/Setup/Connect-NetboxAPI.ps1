function Connect-NetboxAPI {
<#
    .SYNOPSIS
        Connects to the Netbox API and ensures Credential work properly
    
    .DESCRIPTION
        A detailed description of the Connect-NetboxAPI function.
    
    .PARAMETER Hostname
        A description of the Hostname parameter.
    
    .PARAMETER Credential
        A description of the Credential parameter.
    
    .EXAMPLE
        PS C:\> Connect-NetboxAPI -Hostname "netbox.domain.com"
        
        This will prompt for Credential, then proceed to attempt a connection to Netbox
    
    .NOTES
        Additional information about the function.
#>
    
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Hostname,
        
        [Parameter(Mandatory = $false)]
        [pscredential]$Credential
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
    
    $null = Set-NetboxHostName -Hostname $Hostname
    $null = Set-NetboxCredential -Credential $Credential
    
    try {
        Write-Verbose "Verifying API connectivity..."
        $null = VerifyAPIConnectivity
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
    $script:NetboxConfig.Choices.DCIM = Get-NetboxDCIMChoices # Not completed yet
    $script:NetboxConfig.Choices.Extras = Get-NetboxExtrasChoices
    $script:NetboxConfig.Choices.IPAM = Get-NetboxIPAMChoices
    #$script:NetboxConfig.Choices.Secrets = Get-NetboxSecretsChoices    # Not completed yet
    #$script:NetboxConfig.Choices.Tenancy = Get-NetboxTenancyChoices
    $script:NetboxConfig.Choices.Virtualization = Get-NetboxVirtualizationChoices
    
    Write-Verbose "Connection process completed"
}