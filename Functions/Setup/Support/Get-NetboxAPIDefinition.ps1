
function Get-NetboxAPIDefinition {
    [CmdletBinding()]
    param ()

    #$URI = "https://netbox.neonet.org/api/docs/?format=openapi"

    $Segments = [System.Collections.ArrayList]::new(@('docs'))

    $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary @{'format' = 'openapi' }

    $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters -SkipConnectedCheck

    InvokeNetboxRequest -URI $URI
}
