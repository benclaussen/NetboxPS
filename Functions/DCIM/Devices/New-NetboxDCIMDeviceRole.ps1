
function New-NetboxDCIMDeviceRole {
    [CmdletBinding(ConfirmImpact = 'low',
        SupportsShouldProcess = $true)]
    [OutputType([pscustomobject])]
    param
    (
        [string]$Name,

        [string]$Color,

        [bool]$VM_Role,

        [string]$Description,

        [hashtable]$Custom_Fields
    )

    $Segments = [System.Collections.ArrayList]::new(@('dcim', 'device-roles'))
    $Method = 'POST'

    if (-not $PSBoundParameters.ContainsKey('slug')) {
        $PSBoundParameters.Add('slug', (GenerateSlug -Slug $Name))
    }

    $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters

    $URI = BuildNewURI -Segments $URIComponents.Segments

    if ($PSCmdlet.ShouldProcess($Name, 'Create new Device Role')) {
        InvokeNetboxRequest -URI $URI -Method $Method -Body $URIComponents.Parameters
    }
}