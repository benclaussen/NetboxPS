function Get-NetboxExtrasChoices {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "", Justification = "These are literally 'choices' in Netbox")]
	param ()
    
    $uriSegments = [System.Collections.ArrayList]::new(@('extras', '_choices'))
    
    $uri = BuildNewURI -Segments $uriSegments
    
    InvokeNetboxRequest -URI $uri
}
