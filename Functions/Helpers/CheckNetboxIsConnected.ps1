<#
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/26/2020 14:22
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	CheckNetboxIsConnected.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function CheckNetboxIsConnected {
    [CmdletBinding()]
    param ()

    Write-Verbose "Checking connection status"
    if (-not $script:NetboxConfig.Connected) {
        throw "Not connected to a Netbox API! Please run 'Connect-NetboxAPI'"
    }
}