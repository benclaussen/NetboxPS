<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2020 v5.7.181
	 Created on:   	2020-11-04 14:23
	 Created by:   	Claussen
	 Organization: 	NEOnet
	 Filename:     	Get-ModelDefinition.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>



function Get-ModelDefinition {
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    param
    (
        [Parameter(ParameterSetName = 'ByName',
                   Mandatory = $true)]
        [string]$ModelName,
        
        [Parameter(ParameterSetName = 'ByPath',
                   Mandatory = $true)]
        [string]$URIPath,
        
        [Parameter(ParameterSetName = 'ByPath')]
        [string]$Method = "post"
    )
    
    switch ($PsCmdlet.ParameterSetName) {
        'ByName' {
            $script:NetboxConfig.APIDefinition.definitions.$ModelName
            break
        }
        
        'ByPath' {
            switch ($Method) {
                "get" {
                    
                    break
                }
                
                "post" {
                    if (-not $URIPath.StartsWith('/')) {
                        $URIPath = "/$URIPath"
                    }
                    
                    if (-not $URIPath.EndsWith('/')) {
                        $URIPath = "$URIPath/"
                    }
                    
                    $ModelName = $script:NetboxConfig.APIDefinition.paths.$URIPath.post.parameters.schema.'$ref'.split('/')[-1]
                    $script:NetboxConfig.APIDefinition.definitions.$ModelName
                    break
                }
            }
            
            break
        }
    }
    
}
