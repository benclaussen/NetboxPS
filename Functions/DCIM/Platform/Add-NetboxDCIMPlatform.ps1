function Add-NetboxDCIMPlatform {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [ValidateLength(1, 100)]
        [ValidatePattern('^[-a-zA-Z0-9_]+$')]
        [string]$Slug,

        [uint64]$Manufacturer,

        [uint64]$Config_Template,

        [string]$Description,

        [uint16[]]$Tags

    )

    $Segments = [System.Collections.ArrayList]::new(@('dcim', 'platforms'))

    if (-not $PSBoundParameters.ContainsKey('slug')) {
        $PSBoundParameters.Add('slug', $($name | Get-NetboxSlug))
    }

    $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters

    $URI = BuildNewURI -Segments $URIComponents.Segments

    InvokeNetboxRequest -URI $URI -Body $URIComponents.Parameters -Method POST
}