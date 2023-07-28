
function New-NetboxCircuit {
    [CmdletBinding(ConfirmImpact = 'Low',
        SupportsShouldProcess = $true)]
    [OutputType([pscustomobject])]
    param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string]$CID,

        [Parameter(Mandatory = $true)]
        [uint64]$Provider,

        [Parameter(Mandatory = $true)]
        [uint64]$Type,

        #[ValidateSet('Active', 'Planned', 'Provisioning', 'Offline', 'Deprovisioning', 'Decommissioned ')]
        [uint16]$Status = 'Active',

        [string]$Description,

        [uint64]$Tenant,

        [string]$Termination_A,

        [datetime]$Install_Date,

        [string]$Termination_Z,

        [ValidateRange(0, 2147483647)]
        [uint64]$Commit_Rate,

        [string]$Comments,

        [hashtable]$Custom_Fields,

        [switch]$Force,

        [switch]$Raw
    )

    process {
        $Segments = [System.Collections.ArrayList]::new(@('circuits', 'circuits'))
        $Method = 'POST'

        $URIComponents = BuildURIComponents -URISegments $Segments -ParametersDictionary $PSBoundParameters

        $URI = BuildNewURI -Segments $URIComponents.Segments

        if ($Force -or $PSCmdlet.ShouldProcess($CID, 'Create new circuit')) {
            InvokeNetboxRequest -URI $URI -Method $Method -Body $URIComponents.Parameters -Raw:$Raw
        }
    }
}