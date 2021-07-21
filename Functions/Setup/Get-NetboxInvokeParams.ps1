function Get-NetboxInvokeParams {
    [CmdletBinding()]
    param ()

    Write-Verbose "Getting Netbox InvokeParams"
    if ($null -eq $script:NetboxConfig.InvokeParams) {
        throw "Netbox Invoke Parms is not set! You may set it with Set-NetboxInvokeParams -InvokeParams ..."
    }

    $script:NetboxConfig.InvokeParams
}