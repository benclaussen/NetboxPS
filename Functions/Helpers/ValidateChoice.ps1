<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/26/2020 14:23
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	ValidateChoice.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function ValidateChoice {
    [CmdletBinding()]
    [OutputType([uint16], [string], [bool])]
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
                $val = $script:NetboxConfig.Choices.$MajorObject.$ChoiceName.Where({
                        $_.Label -eq $ProvidedValue
                    }).Value
            }
            
            return $val
        }
        
        default {
            # Convert the ProvidedValue to the integer value
            try {
                $intVal = [uint16]"$ProvidedValue"
            } catch {
                # It must not be a number, get the value from the label
                $intVal = [uint16]$script:NetboxConfig.Choices.$MajorObject.$ChoiceName.Where({
                        $_.Label -eq $ProvidedValue
                    }).Value
            }
            
            return $intVal
        }
    }
}