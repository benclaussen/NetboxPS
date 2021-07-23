<#
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/23/2020 12:12
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Remove-NetboxDCIMInterfaceConnection.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function Remove-NetboxDCIMInterfaceConnection {
    [CmdletBinding(ConfirmImpact = 'High',
                   SupportsShouldProcess = $true)]
    [OutputType([void])]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [uint16[]]$Id,

        [switch]$Force
    )

    begin {

    }

    process {
        foreach ($ConnectionID in $Id) {
            $CurrentConnection = Get-NetboxDCIMInterfaceConnection -Id $ConnectionID -ErrorAction Stop

            if ($Force -or $pscmdlet.ShouldProcess("Connection ID $($ConnectionID.Id)", "REMOVE")) {
                $Segments = [System.Collections.ArrayList]::new(@('dcim', 'interface-connections', $CurrentConnection.Id))

                $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Id', 'Force'

                $URI = BuildNewURI -Segments $URIComponents.Segments

                InvokeNetboxRequest -URI $URI -Method DELETE
            }
        }
    }

    end {

    }
}