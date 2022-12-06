
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

    $URIParameters = @{
    }

    foreach ($CmdletParameterName in $ParametersDictionary.Keys) {
        if ($CmdletParameterName -in $script:CommonParameterNames) {
            # These are common parameters and should not be appended to the URI
            Write-Debug "Skipping common parameter $CmdletParameterName"
            continue
        }

        if ($CmdletParameterName -in $SkipParameterByName) {
            Write-Debug "Skipping parameter $CmdletParameterName by SkipParameterByName"
            continue
        }

        switch ($CmdletParameterName) {
            "id" {
                # Check if there is one or more values for Id and build a URI or query as appropriate
                if (@($ParametersDictionary[$CmdletParameterName]).Count -gt 1) {
                    Write-Verbose " Joining IDs for parameter"
                    $URIParameters['id__in'] = $ParametersDictionary[$CmdletParameterName] -join ','
                } else {
                    Write-Verbose " Adding ID to segments"
                    [void]$uriSegments.Add($ParametersDictionary[$CmdletParameterName])
                }

                break
            }

            'Query' {
                Write-Verbose " Adding query parameter"
                $URIParameters['q'] = $ParametersDictionary[$CmdletParameterName]
                break
            }

            'CustomFields' {
                Write-Verbose " Adding custom field query parameters"
                foreach ($field in $ParametersDictionary[$CmdletParameterName].GetEnumerator()) {
                    Write-Verbose "  Adding parameter 'cf_$($field.Key) = $($field.Value)"
                    $URIParameters["cf_$($field.Key.ToLower())"] = $field.Value
                }

                break
            }

            default {
                Write-Verbose " Adding $($CmdletParameterName.ToLower()) parameter"
                $URIParameters[$CmdletParameterName.ToLower()] = $ParametersDictionary[$CmdletParameterName]
                break
            }
        }
    }

    return @{
        'Segments' = [System.Collections.ArrayList]$URISegments
        'Parameters' = $URIParameters
    }
}