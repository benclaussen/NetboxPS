function VerifyAPIConnectivity {
    [CmdletBinding()]
    param ()
    
    $uriSegments = [System.Collections.ArrayList]::new(@('extras', '_choices'))
    
    $uri = BuildNewURI -Segments $uriSegments -SkipConnectedCheck
    
    InvokeNetboxRequest -URI $uri
}

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
            'Connected' = $false
            'Choices' = @{
            }
        }
    }
    
    Write-Verbose "NetboxConfig hashtable already exists"
}

function GetNetboxConfigVariable {
    return $script:NetboxConfig
}