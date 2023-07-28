
function Set-NetboxIPAMAddress {
    [CmdletBinding(ConfirmImpact = 'Medium',
        SupportsShouldProcess = $true)]
    param
    (
        [Parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
        [int[]]$Id,

        [string]$Address,

        [string]$Status,

        [int]$Tenant,

        [int]$VRF,

        [object]$Role,

        [int]$NAT_Inside,

        [hashtable]$Custom_Fields,

        [ValidateSet('dcim.interface', 'virtualization.vminterface', IgnoreCase = $true)]
        [string]$Assigned_Object_Type,

        [uint64]$Assigned_Object_Id,

        [string]$Description,

        [string]$Dns_name,

        [switch]$Force
    )

    begin {
        #        Write-Verbose "Validating enum properties"
        #        $Segments = [System.Collections.ArrayList]::new(@('ipam', 'ip-addresses', 0))
        $Method = 'PATCH'
        #
        #        # Value validation
        #        $ModelDefinition = GetModelDefinitionFromURIPath -Segments $Segments -Method $Method
        #        $EnumProperties = GetModelEnumProperties -ModelDefinition $ModelDefinition
        #
        #        foreach ($Property in $EnumProperties.Keys) {
        #            if ($PSBoundParameters.ContainsKey($Property)) {
        #                Write-Verbose "Validating property [$Property] with value [$($PSBoundParameters.$Property)]"
        #                $PSBoundParameters.$Property = ValidateValue -ModelDefinition $ModelDefinition -Property $Property -ProvidedValue $PSBoundParameters.$Property
        #            } else {
        #                Write-Verbose "User did not provide a value for [$Property]"
        #            }
        #        }
        #
        #        Write-Verbose "Finished enum validation"
    }

    process {
        foreach ($IPId in $Id) {
            if ($PSBoundParameters.ContainsKey('Assigned_Object_Type') -or $PSBoundParameters.ContainsKey('Assigned_Object_Id')) {
                if ((-not [string]::IsNullOrWhiteSpace($Assigned_Object_Id)) -and [string]::IsNullOrWhiteSpace($Assigned_Object_Type)) {
                    throw "Assigned_Object_Type is required when specifying Assigned_Object_Id"
                }
                elseif ((-not [string]::IsNullOrWhiteSpace($Assigned_Object_Type)) -and [string]::IsNullOrWhiteSpace($Assigned_Object_Id)) {
                    throw "Assigned_Object_Id is required when specifying Assigned_Object_Type"
                }
            }

            $Segments = [System.Collections.ArrayList]::new(@('ipam', 'ip-addresses', $IPId))

            Write-Verbose "Obtaining IP from ID $IPId"
            $CurrentIP = Get-NetboxIPAMAddress -Id $IPId -ErrorAction Stop

            if ($Force -or $PSCmdlet.ShouldProcess($CurrentIP.Address, 'Set')) {
                $URIComponents = BuildURIComponents -URISegments $Segments.Clone() -ParametersDictionary $PSBoundParameters -SkipParameterByName 'Id', 'Force'

                $URI = BuildNewURI -Segments $URIComponents.Segments

                InvokeNetboxRequest -URI $URI -Body $URIComponents.Parameters -Method $Method
            }
        }
    }
}