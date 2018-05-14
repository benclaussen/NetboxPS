# Build a list of common paramters so we can omit them to build URI parameters
$script:CommonParameterNames = New-Object System.Collections.ArrayList
[void]$script:CommonParameterNames.AddRange(@([System.Management.Automation.PSCmdlet]::CommonParameters))
[void]$script:CommonParameterNames.AddRange(@([System.Management.Automation.PSCmdlet]::OptionalCommonParameters))
[void]$script:CommonParameterNames.Add('Raw')

SetupNetboxConfigVariable

#if (-not ([System.Management.Automation.PSTypeName]'NetboxVirtualMachineStatus').Type) {
#    Add-Type -TypeDefinition @"
#public enum NetboxVirtualMachineStatus
#{
#    Offline = 0,
#    Active = 1,
#    Staged = 3
#}
#"@
#}


Export-ModuleMember -Function *
#Export-ModuleMember -Function *-*