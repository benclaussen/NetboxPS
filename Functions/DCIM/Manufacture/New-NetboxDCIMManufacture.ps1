
function New-NetboxDCIMManufacture {
    [CmdletBinding(ConfirmImpact = 'low',
        SupportsShouldProcess = $true)]
    [OutputType([pscustomobject])]
    #region Parameters
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [string]$Description,

        [hashtable]$Custom_Fields

    )
    #endregion Parameters

    $Segments = [System.Collections.ArrayList]::new(@('dcim', 'manufacturers'))
    $Method = 'POST'

    if (-not $PSBoundParameters.ContainsKey('slug')) {
        $PSBoundParameters.Add('slug', (GenerateSlug -Slug $name))
    }

    $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters

    $URI = BuildNewURI -Segments $URIComponents.Segments

    if ($PSCmdlet.ShouldProcess($Name, 'Create new Manufacture')) {
        InvokeNetboxRequest -URI $URI -Method $Method -Body $URIComponents.Parameters
    }
}