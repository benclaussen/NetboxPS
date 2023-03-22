
function New-NetboxDCIMDeviceType {
    [CmdletBinding(ConfirmImpact = 'low',
        SupportsShouldProcess = $true)]
    [OutputType([pscustomobject])]
    #region Parameters
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$Manufacturer,

        [Parameter(Mandatory = $true)]
        [string]$Model,

        [string]$Part_Number,

        [uint16]$U_Height,

        [bool]$Is_Full_Depth,

        [string]$Subdevice_Role,

        [string]$Airflow,

        [uint16]$Weight,

        [string]$Weight_Unit,

        [string]$Description,

        [string]$Comments,

        [hashtable]$Custom_Fields
    )
    #endregion Parameters

    $Segments = [System.Collections.ArrayList]::new(@('dcim', 'device-types'))
    $Method = 'POST'

    if (-not $PSBoundParameters.ContainsKey('slug')) {
        $PSBoundParameters.Add('slug', (GenerateSlug -Slug $Model))
    }

    $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters

    $URI = BuildNewURI -Segments $URIComponents.Segments

    if ($PSCmdlet.ShouldProcess($Name, 'Create new Device Types')) {
        InvokeNetboxRequest -URI $URI -Method $Method -Body $URIComponents.Parameters
    }
}