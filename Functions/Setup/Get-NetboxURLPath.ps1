function Get-NetboxURLPath {
    [CmdletBinding()]
    param ()

    Write-Verbose "Getting Netbox URL Path"
    if ($null -eq $script:NetboxConfig.URLPath) {
        throw "Netbox URL Path is not set! You may set it with Set-NetboxURLPath -Path 'netbox/'"
    }

    $script:NetboxConfig.URLPath
}