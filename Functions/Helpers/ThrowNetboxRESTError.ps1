<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.172
	 Created on:   	3/26/2020 14:25
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	ThrowNetboxRESTError.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>


function ThrowNetboxRESTError {
    $uriSegments = [System.Collections.ArrayList]::new(@('fake', 'url'))
    
    $URIParameters = @{
    }
    
    $uri = BuildNewURI -Segments $uriSegments -Parameters $URIParameters
    
    InvokeNetboxRequest -URI $uri -Raw
}