<#
    .NOTES
    ===========================================================================
     Created with:  SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.181
     Created on:    2020-10-02 15:52
     Created by:    Claussen
     Organization:  NEOnet
     Filename:      New-NetboxDCIMSite.ps1
    ===========================================================================
    .DESCRIPTION
        A description of the file.
#>


function Remove-NetboxDCIMSite {
    <#
        .SYNOPSIS
            Remove a Site

        .DESCRIPTION
            Remove a DCIM Site from Netbox

        .EXAMPLE
            Remove-NetboxDCIMSite -Id 1

            Remove DCM Site with id 1

        .EXAMPLE
            Get-NetboxDCIMSite -name My Site | Remove-NetboxDCIMSite -confirm:$false

            Remove DCM Site with name My Site without confirmation

    #>

    [CmdletBinding(ConfirmImpact = 'High',
        SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
        [uint]$Id

    )

    begin {

    }

    process {
        $CurrentSite = Get-NetboxDCIMSite -Id $Id -ErrorAction Stop

        if ($pscmdlet.ShouldProcess("$($CurrentSite.Name)/$($CurrentSite.Id)", "Remove Site")) {
            $Segments = [System.Collections.ArrayList]::new(@('dcim', 'sites', $CurrentSite.Id))

            $URI = BuildNewURI -Segments $Segments

            InvokeNetboxRequest -URI $URI -Method DELETE
        }
    }

    end {

    }
}