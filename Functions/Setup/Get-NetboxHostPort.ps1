function Get-NetboxHostPort {
    [CmdletBinding()]
    param ()

    Write-Verbose "Getting Netbox host port"
    if ($null -eq $script:NetboxConfig.HostPort) {
        throw "Netbox host port is not set! You may set it with Set-NetboxHostPort -Port 'https'"
    }

    $script:NetboxConfig.HostPort
}