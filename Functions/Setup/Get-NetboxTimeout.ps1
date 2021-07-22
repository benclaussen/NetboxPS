
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