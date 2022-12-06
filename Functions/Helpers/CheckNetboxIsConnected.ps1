
function CheckNetboxIsConnected {
    [CmdletBinding()]
    param ()

    Write-Verbose "Checking connection status"
    if (-not $script:NetboxConfig.Connected) {
        throw "Not connected to a Netbox API! Please run 'Connect-NetboxAPI'"
    }
}