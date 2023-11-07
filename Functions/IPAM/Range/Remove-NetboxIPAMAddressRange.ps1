
function Remove-NetboxIPAMAddressRange {
    <#
    .SYNOPSIS
        Remove an IP address range from Netbox

    .DESCRIPTION
        Removes/deletes an IP address range from Netbox by ID

    .PARAMETER Id
        Database ID of the IP address range object.

    .PARAMETER Force
        Do not confirm.

    .EXAMPLE
        PS C:\> Remove-NetboxIPAMAddressRange -Id 1234

    .NOTES
        Additional information about the function.
#>
    
    [CmdletBinding(ConfirmImpact = 'High',
                   SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true,
                   ValueFromPipelineByPropertyName = $true)]
        [uint64[]]$Id,
        
        [switch]$Force
    )
    
    process {
        foreach ($Range_Id in $Id) {
            $CurrentRange = Get-NetboxIPAMAddressRange -Id $Range_Id -ErrorAction Stop
            
            $Segments = [System.Collections.ArrayList]::new(@('ipam', 'ip-ranges', $Range_Id))
            
            if ($Force -or $pscmdlet.ShouldProcess($CurrentRange.start_address, "Delete")) {
                $URI = BuildNewURI -Segments $Segments
                
                InvokeNetboxRequest -URI $URI -Method DELETE
            }
        }
    }
}