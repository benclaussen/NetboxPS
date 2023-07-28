function Set-NetboxURLPath {
    [CmdletBinding(ConfirmImpact = 'Low',
        SupportsShouldProcess = $true)]
    [OutputType([string])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if ($PSCmdlet.ShouldProcess('Netbox URL Path', 'Set')) {
        $script:NetboxConfig.URLPath = $Path.Trim()
        $script:NetboxConfig.URLPath
    }
}