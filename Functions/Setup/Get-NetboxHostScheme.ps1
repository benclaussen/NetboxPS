function Get-NetboxHostScheme {
    [CmdletBinding()]
    param ()
    
    Write-Verbose "Getting Netbox host scheme"
    if ($null -eq $script:NetboxConfig.Hostscheme) {
        throw "Netbox host sceme is not set! You may set it with Set-NetboxHostScheme -Scheme 'https'"
    }
    
    $script:NetboxConfig.HostScheme
}