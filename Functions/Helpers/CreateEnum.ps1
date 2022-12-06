
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
{`n$(foreach ($value in $values) {
            "`t$($value.label) = $($value.value),`n"
        })
}
"@
    if (-not ([System.Management.Automation.PSTypeName]"$EnumName").Type) {
        #Write-Host $definition -ForegroundColor Green
        Add-Type -TypeDefinition $definition -PassThru:$PassThru
    } else {
        Write-Warning "EnumType $EnumName already exists."
    }
}