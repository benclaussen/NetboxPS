function Set-NetboxInvokeParams {
    [CmdletBinding(ConfirmImpact = 'Low',
        SupportsShouldProcess = $true)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory = $true)]
        [array]$InvokeParams
    )

    if ($PSCmdlet.ShouldProcess('Netbox Invoke Params', 'Set')) {
        $script:NetboxConfig.InvokeParams = $InvokeParams
        $script:NetboxConfig.InvokeParams
    }
}