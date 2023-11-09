
function Get-NetboxAPIDefinition {
    [CmdletBinding()]
    param
    (
        [ValidateSet('json', 'yaml', IgnoreCase = $true)]
        [string]$Format = 'json'
    )

    #$URI = "https://netbox.neonet.org/api/schema/?format=json"

    $Segments = [System.Collections.ArrayList]::new(@('schema'))

    $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary @{
        'format' = $Format.ToLower()
    }

    $URI = BuildNewURI -Segments $URIComponents.Segments -Parameters $URIComponents.Parameters -SkipConnectedCheck

    InvokeNetboxRequest -URI $URI
}
