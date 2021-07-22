<#
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/26/2020 14:24
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	InvokeNetboxRequest.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function InvokeNetboxRequest {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.UriBuilder]$URI,

        [Hashtable]$Headers = @{
        },

        [pscustomobject]$Body = $null,

        [ValidateRange(0, 60)]
        [uint16]$Timeout = 5,

        [ValidateSet('GET', 'PATCH', 'PUT', 'POST', 'DELETE', 'OPTIONS', IgnoreCase = $true)]
        [string]$Method = 'GET',

        [switch]$Raw
    )

    $creds = Get-NetboxCredential

    $Headers.Authorization = "Token {0}" -f $creds.GetNetworkCredential().Password

    $splat = @{
        'Method'      = $Method
        'Uri'         = $URI.Uri.AbsoluteUri # This property auto generates the scheme, hostname, path, and query
        'Headers'     = $Headers
        'TimeoutSec'  = $Timeout
        'ContentType' = 'application/json'
        'ErrorAction' = 'Stop'
        'Verbose'     = $VerbosePreference
    }

    $splat += Get-NetboxInvokeParams

    if ($Body) {
        Write-Verbose "BODY: $($Body | ConvertTo-Json -Compress)"
        $null = $splat.Add('Body', ($Body | ConvertTo-Json -Compress))
    }

    $result = Invoke-RestMethod @splat

    #region TODO: Handle errors a little more gracefully...

    <#
    try {
        Write-Verbose "Sending request..."
        $result = Invoke-RestMethod @splat
        Write-Verbose $result
    } catch {
        Write-Verbose "Caught exception"
        if ($_.Exception.psobject.properties.Name.contains('Response')) {
            Write-Verbose "Exception contains a response property"
            if ($Raw) {
                Write-Verbose "RAW provided...throwing raw exception"
                throw $_
            }

            Write-Verbose "Converting response to object"
            $myError = GetNetboxAPIErrorBody -Response $_.Exception.Response | ConvertFrom-Json
        } else {
            Write-Verbose "No response property found"
            $myError = $_
        }
    }

    Write-Verbose "MyError is $($myError.GetType().FullName)"

    if ($myError -is [Exception]) {
        throw $_
    } elseif ($myError -is [pscustomobject]) {
        throw $myError.detail
    }
    #>

    #endregion TODO: Handle errors a little more gracefully...

    # If the user wants the raw value from the API... otherwise return only the actual result
    if ($Raw) {
        Write-Verbose "Returning raw result by choice"
        return $result
    } else {
        if ($result.psobject.Properties.Name.Contains('results')) {
            Write-Verbose "Found Results property on data, returning results directly"
            return $result.Results
        } else {
            Write-Verbose "Did NOT find results property on data, returning raw result"
            return $result
        }
    }
}