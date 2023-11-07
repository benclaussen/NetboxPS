
function Add-NetboxDCIMInterfaceConnection {
    <#
    .SYNOPSIS
        Create a new connection between two interfaces

    .DESCRIPTION
        Create a new connection between two interfaces

    .PARAMETER Connection_Status
        Is it connected or planned?

    .PARAMETER Interface_A
        Database ID of interface A

    .PARAMETER Interface_B
        Database ID of interface B

    .EXAMPLE
        PS C:\> Add-NetboxDCIMInterfaceConnection -Interface_A $value1 -Interface_B $value2

    .NOTES
        Additional information about the function.
#>

    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param
    (
        [object]$Connection_Status,

        [Parameter(Mandatory = $true)]
        [uint64]$Interface_A,

        [Parameter(Mandatory = $true)]
        [uint64]$Interface_B
    )

    # Verify if both Interfaces exist
    Get-NetboxDCIMInterface -Id $Interface_A -ErrorAction Stop | Out-null
    Get-NetboxDCIMInterface -Id $Interface_B -ErrorAction Stop | Out-null

    $Segments = [System.Collections.ArrayList]::new(@('dcim', 'interface-connections'))

    $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters

    $URI = BuildNewURI -Segments $URIComponents.Segments

    InvokeNetboxRequest -URI $URI -Body $URIComponents.Parameters -Method POST
}