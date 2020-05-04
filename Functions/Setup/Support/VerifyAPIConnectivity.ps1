function VerifyAPIConnectivity {
    [CmdletBinding()]
    param ()
    
    $uriSegments = [System.Collections.ArrayList]::new(@('extras'))
    
    $uri = BuildNewURI -Segments $uriSegments -Parameters @{'format' = 'json'} -SkipConnectedCheck
    
    InvokeNetboxRequest -URI $uri
}