
function Set-NetboxTimeout {
    [CmdletBinding(ConfirmImpact = 'Low',
                   SupportsShouldProcess = $true)]
    [OutputType([uint16])]
    param
    (
        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 65535)]
        [uint16]$TimeoutSeconds = 30
    )

    if ($PSCmdlet.ShouldProcess('Netbox Timeout', 'Set')) {
        $script:NetboxConfig.Timeout = $TimeoutSeconds
        $script:NetboxConfig.Timeout
    }
}