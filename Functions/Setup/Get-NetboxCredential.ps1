function Get-NetboxCredential {
    [CmdletBinding()]
    [OutputType([pscredential])]
    param ()

    if (-not $script:NetboxConfig.Credential) {
        throw "Netbox Credentials not set! You may set with Set-NetboxCredential"
    }

    $script:NetboxConfig.Credential
}