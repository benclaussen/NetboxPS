<#	
    .NOTES
    ===========================================================================
     Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2018 v5.5.148
     Created on:   	2/28/2018 3:33 PM
     Created by:   	Ben Claussen
     Organization: 	NEOnet
     Filename:     	Helpers.ps1
    ===========================================================================
    .DESCRIPTION
    	These function are internal functions and generally are not
        exposed to the end user
#>

function CheckNetboxIsConnected {
	[CmdletBinding()]
    param ()
    
    Write-Verbose "Checking connection status"
	if (-not $script:NetboxConfig.Connected) {
		throw "Not connected to a Netbox API! Please run 'Connect-NetboxAPI'"
    }
}

function BuildNewURI {
<#
    .SYNOPSIS
        Create a new URI for Netbox
    
    .DESCRIPTION
        A detailed description of the BuildNewURI function.
    
    .PARAMETER Hostname
        Hostname of the Netbox API
    
    .PARAMETER Segments
        Array of strings for each segment in the URL path
    
    .PARAMETER Parameters
        Hashtable of query parameters to include
    
    .PARAMETER HTTPS
        Whether to use HTTPS or HTTP
    
    .PARAMETER Port
        A description of the Port parameter.
    
    .PARAMETER APIInfo
        A description of the APIInfo parameter.
    
    .EXAMPLE
        PS C:\> BuildNewURI
    
    .NOTES
        Additional information about the function.
#>
    
    [CmdletBinding()]
    [OutputType([System.UriBuilder])]
    param
    (
        [Parameter(Mandatory = $false)]
        [string]$Hostname,
        
        [Parameter(Mandatory = $false)]
        [string[]]$Segments,
        
        [Parameter(Mandatory = $false)]
        [hashtable]$Parameters,
        
        [Parameter(Mandatory = $false)]
        [boolean]$HTTPS = $true,
        
        [ValidateRange(1, 65535)]
        [uint16]$Port = 443,
        
        [switch]$SkipConnectedCheck
    )
    
    Write-Verbose "Building URI"
    
    if (-not $SkipConnectedCheck) {
        # There is no point in continuing if we have not successfully connected to an API
        $null = CheckNetboxIsConnected
    }
    
    if (-not $Hostname) {
        $Hostname = Get-NetboxHostname
    }
    
    if ($HTTPS) {
        Write-Verbose " Setting scheme to HTTPS"
        $Scheme = 'https'
    } else {
        Write-Warning " Connecting via non-secure HTTP is not-recommended"
        
        Write-Verbose " Setting scheme to HTTP"
        $Scheme = 'http'
        
        if (-not $PSBoundParameters.ContainsKey('Port')) {
            # Set the port to 80 if the user did not supply it
            Write-Verbose " Setting port to 80 as default because it was not supplied by the user"
            $Port = 80
        }
    }
    
    # Begin a URI builder with HTTP/HTTPS and the provided hostname
    $uriBuilder = [System.UriBuilder]::new($Scheme, $Hostname, $Port)
        
    # Generate the path by trimming excess slashes and whitespace from the $segments[] and joining together
    $uriBuilder.Path = "api/{0}/" -f ($Segments.ForEach({$_.trim('/').trim()}) -join '/')
    
    Write-Verbose " URIPath: $($uriBuilder.Path)"
    
    if ($parameters) {
        # Loop through the parameters and use the HttpUtility to create a Query string
        [System.Collections.Specialized.NameValueCollection]$URIParams = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
        
        foreach ($param in $Parameters.GetEnumerator()) {
            Write-Verbose " Adding URI parameter $($param.Key):$($param.Value)"
            $URIParams[$param.Key] = $param.Value
        }
        
        $uriBuilder.Query = $URIParams.ToString()
    }
    
    Write-Verbose " Completed building URIBuilder"
    # Return the entire UriBuilder object
    $uriBuilder
}

function BuildURIComponents {
    [CmdletBinding()]
    [OutputType([hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Collections.ArrayList]$URISegments,
        
        [Parameter(Mandatory = $true)]
        [object]$ParametersDictionary,
        
        [string[]]$SkipParameterByName
    )
    
    Write-Verbose "Building URI components"
    
    $URIParameters = @{}
    
    foreach ($CmdletParameterName in $ParametersDictionary.Keys) {
        if ($CmdletParameterName -in $CommonParameterNames) {
            # These are common parameters and should not be appended to the URI
            Write-Debug "Skipping parameter $CmdletParameterName"
            continue
        }
        
        if ($CmdletParameterName -in $SkipParameterByName) {
            Write-Debug "Skipping parameter $CmdletParameterName"
            continue
        }
        
        if ($CmdletParameterName -eq 'Id') {
            # Check if there is one or more values for Id and build a URI or query as appropriate
            if (@($ParametersDictionary[$CmdletParameterName]).Count -gt 1) {
                Write-Verbose " Joining IDs for parameter"
                $URIParameters['id__in'] = $ParametersDictionary[$CmdletParameterName] -join ','
            } else {
                Write-Verbose " Adding ID to segments"
                [void]$uriSegments.Add($ParametersDictionary[$CmdletParameterName])
            }
        } elseif ($CmdletParameterName -eq 'Query') {
            Write-Verbose " Adding query parameter"
            $URIParameters['q'] = $ParametersDictionary[$CmdletParameterName]
        } else {
            Write-Verbose " Adding $($CmdletParameterName.ToLower()) parameter"
            $URIParameters[$CmdletParameterName.ToLower()] = $ParametersDictionary[$CmdletParameterName]
        }
    }
    
    return @{
        'Segments' = [System.Collections.ArrayList]$URISegments
        'Parameters' = $URIParameters
    }
}

function GetChoiceValidValues {
    [CmdletBinding()]
    [OutputType([System.Collections.ArrayList])]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$MajorObject,
        
        [Parameter(Mandatory = $true)]
        [object]$Choice
    )
    
    $ValidValues = New-Object System.Collections.ArrayList
    
    if (-not $script:NetboxConfig.Choices.$MajorObject.$Choice) {
        throw "Missing choices for $Choice"
    }
    
    [void]$ValidValues.AddRange($script:NetboxConfig.Choices.$MajorObject.$Choice.value)
    [void]$ValidValues.AddRange($script:NetboxConfig.Choices.$MajorObject.$Choice.label)
    
    if ($ValidValues.Count -eq 0) {
        throw "Missing valid values for $MajorObject.$Choice"
    }
    
    return [System.Collections.ArrayList]$ValidValues
}

function ValidateChoice {
    [CmdletBinding()]
    [OutputType([uint16],[string], [bool])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Circuits', 'DCIM', 'Extras', 'IPAM', 'Virtualization', IgnoreCase = $true)]
        [string]$MajorObject,
        
        [Parameter(Mandatory = $true)]
        [string]$ChoiceName,
        
        [Parameter(Mandatory = $true)]
        [object]$ProvidedValue
    )
    
    $ValidValues = GetChoiceValidValues -MajorObject $MajorObject -Choice $ChoiceName
    
    Write-Verbose "Validating $ChoiceName"
    Write-Verbose "Checking '$ProvidedValue' against [$($ValidValues -join ', ')]"

    # Coercing everything to strings for matching... 
    # some values are integers, some are strings, some are booleans
    # Join the valid values with a pipe as a delimeter, because some values have spaces
    if (([string]($ValidValues -join '|') -split '\|') -inotcontains [string]$ProvidedValue) {
        throw "Invalid value '$ProvidedValue' for '$ChoiceName'. Must be one of: $($ValidValues -join ', ')"
    }
    
    switch -wildcard ("$MajorObject/$ChoiceName") {
        "Circuits" {
            # This has things that are not integers
        }
        
        "DCIM/*connection_status" {
            # This has true/false values instead of integers
            try {
                $val = [bool]::Parse($ProvidedValue)
            } catch {
                # It must not be a true/false value
                $val = $script:NetboxConfig.Choices.$MajorObject.$ChoiceName.Where({ $_.Label -eq $ProvidedValue }).Value
            }
            
            return $val
        }
        
        default {
            # Convert the ProvidedValue to the integer value
            try {
                $intVal = [uint16]"$ProvidedValue"
            } catch {
                # It must not be a number, get the value from the label
                $intVal = [uint16]$script:NetboxConfig.Choices.$MajorObject.$ChoiceName.Where({ $_.Label -eq $ProvidedValue }).Value
            }
            
            return $intVal
        }
    }
}


function GetNetboxAPIErrorBody {
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Net.HttpWebResponse]$Response
    )
    
    # This takes the $Response stream and turns it into a useable object... generally a string.
    # If the body is JSON, you should be able to use ConvertFrom-Json
    
    $reader = New-Object System.IO.StreamReader($Response.GetResponseStream())
    $reader.BaseStream.Position = 0
    $reader.DiscardBufferedData()
    $reader.ReadToEnd()
}

function InvokeNetboxRequest {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.UriBuilder]$URI,
        
        [Hashtable]$Headers = @{},
        
        [pscustomobject]$Body = $null,
        
        [ValidateRange(0, 60)]
        [uint16]$Timeout = 5,
        
        [ValidateSet('GET', 'PATCH', 'PUT', 'POST', 'DELETE', IgnoreCase = $true)]
        [string]$Method = 'GET',
        
        [switch]$Raw
    )
    
    $creds = Get-NetboxCredential
    
    $Headers.Authorization = "Token {0}" -f $creds.GetNetworkCredential().Password
    
    $splat = @{
        'Method' = $Method
        'Uri' = $URI.Uri.AbsoluteUri # This property auto generates the scheme, hostname, path, and query
        'Headers' = $Headers
        'TimeoutSec' = $Timeout
        'ContentType' = 'application/json'
        'ErrorAction' = 'Stop'
        'Verbose' = $VerbosePreference
    }
    
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




#region Troubleshooting commands

function ThrowNetboxRESTError {
    $uriSegments = [System.Collections.ArrayList]::new(@('fake', 'url'))
    
    $URIParameters = @{}
    
    $uri = BuildNewURI -Segments $uriSegments -Parameters $URIParameters
    
    InvokeNetboxRequest -URI $uri -Raw
}

function CreateEnum {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [string]$EnumName,
        
        [Parameter(Mandatory = $true)]
        [pscustomobject]$Values,
        
        [switch]$PassThru
    )
    
    $definition = @"
public enum $EnumName
{`n$(foreach ($value in $values) {"`t$($value.label) = $($value.value),`n"})
}
"@
    if (-not ([System.Management.Automation.PSTypeName]"$EnumName").Type) {
        #Write-Host $definition -ForegroundColor Green
        Add-Type -TypeDefinition $definition -PassThru:$PassThru
    } else {
        Write-Warning "EnumType $EnumName already exists."
    }
}

#endregion Troubleshooting commands






