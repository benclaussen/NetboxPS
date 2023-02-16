function SetupNetboxConfigVariable {
    [CmdletBinding()]
    param
    (
        [switch]$Overwrite
    )

    Write-Verbose "Checking for NetboxConfig hashtable"
    if ((-not ($script:NetboxConfig)) -or $Overwrite) {
        Write-Verbose "Creating NetboxConfig hashtable"
        $script:NetboxConfig = @{
            'Connected'     = $false
            'Choices'       = @{
            }
            'APIDefinition' = $null
            'ContentTypes' = $null
        }
    }

    Write-Verbose "NetboxConfig hashtable already exists"
}