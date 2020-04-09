<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/26/2020 14:23
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	GetChoiceValidValues.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


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