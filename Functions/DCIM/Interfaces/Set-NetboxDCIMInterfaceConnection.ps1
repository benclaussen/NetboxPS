
function Set-NetboxDCIMInterfaceConnection {
<#
    .SYNOPSIS
        Update an interface connection

    .DESCRIPTION
        Update an interface connection

    .PARAMETER Id
        A description of the Id parameter.

    .PARAMETER Connection_Status
        A description of the Connection_Status parameter.

    .PARAMETER Interface_A
        A description of the Interface_A parameter.

    .PARAMETER Interface_B
        A description of the Interface_B parameter.

    .PARAMETER Force
        A description of the Force parameter.

    .EXAMPLE
        PS C:\> Set-NetboxDCIMInterfaceConnection -Id $value1

    .NOTES
        Additional information about the function.
#>

    [CmdletBinding(ConfirmImpact = 'Medium',
                   SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [uint16[]]$Id,

        [object]$Connection_Status,

        [uint16]$Interface_A,

        [uint16]$Interface_B,

        [switch]$Force
    )

    begin {
#        if ($null -ne $Connection_Status) {
#            $PSBoundParameters.Connection_Status = ValidateDCIMChoice -ProvidedValue $Connection_Status -InterfaceConnectionStatus
#        }

        if ((@($ID).Count -gt 1) -and ($Interface_A -or $Interface_B)) {
            throw "Cannot set multiple connections to the same interface"
        }
    }

    process {
        foreach ($ConnectionID in $Id) {
            $CurrentConnection = Get-NetboxDCIMInterfaceConnection -Id $ConnectionID -ErrorAction Stop

            $Segments = [System.Collections.ArrayList]::new(@('dcim', 'interface-connections', $CurrentConnection.Id))

            if ($Force -or $pscmdlet.ShouldProcess("Connection ID $($CurrentConnection.Id)", "Set")) {

                $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Id', 'Force'

                $URI = BuildNewURI -Segments $URIComponents.Segments

                InvokeNetboxRequest -URI $URI -Body $URIComponents.Parameters -Method PATCH
            }
        }
    }

    end {

    }
}