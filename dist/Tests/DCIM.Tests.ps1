<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2018 v5.5.152
	 Created on:   	5/22/2018 4:48 PM
	 Created by:   	Ben Claussen
	 Organization: 	NEOnet
	 Filename:     	DCIM.Tests.ps1
	===========================================================================
	.DESCRIPTION
		DCIM tests.
#>

Import-Module Pester
Remove-Module NetboxPS -Force -ErrorAction SilentlyContinue

$ModulePath = "$PSScriptRoot\..\dist\NetboxPS.psd1"

if (Test-Path $ModulePath) {
    Import-Module $ModulePath -ErrorAction Stop
}

Describe -Name "DCIM Tests" -Tag 'DCIM' -Fixture {
    Mock -CommandName 'CheckNetboxIsConnected' -Verifiable -ModuleName 'NetboxPS' -MockWith {
        return $true
    }
    
    Mock -CommandName 'Invoke-RestMethod' -Verifiable -ModuleName 'NetboxPS' -MockWith {
        # Return a hashtable of the items we would normally pass to Invoke-RestMethod
        return [ordered]@{
            'Method' = $Method
            'Uri' = $Uri
            'Headers' = $Headers
            'Timeout' = $Timeout
            'ContentType' = $ContentType
            'Body' = $Body
        }
    }
    
    Mock -CommandName 'Get-NetboxCredential' -Verifiable -ModuleName 'NetboxPS' -MockWith {
        return [PSCredential]::new('notapplicable', (ConvertTo-SecureString -String "faketoken" -AsPlainText -Force))
    }
    
    Mock -CommandName 'Get-NetboxHostname' -Verifiable -ModuleName 'NetboxPS' -MockWith {
        return 'netbox.domain.com'
    }
    
    InModuleScope -ModuleName 'NetboxPS' -ScriptBlock {
        $script:NetboxConfig.Choices.DCIM = (Get-Content "$PSScriptRoot\DCIMChoices.json" -ErrorAction Stop | ConvertFrom-Json)
        
        Context -Name "Get-NetboxDCIMDevice" -Fixture {
            It "Should request the default number of devices" {
                $Result = Get-NetboxDCIMDevice
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/dcim/devices/'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
            
            It "Should request with a limit and offset" {
                $Result = Get-NetboxDCIMDevice -Limit 10 -Offset 100
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/dcim/devices/?offset=100&limit=10'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
            
            It "Should request with a query" {
                $Result = Get-NetboxDCIMDevice -Query 'testdevice'
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/dcim/devices/?q=testdevice'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
            
            It "Should request with an escaped query" {
                $Result = Get-NetboxDCIMDevice -Query 'test device'
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/dcim/devices/?q=test+device'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
            
            It "Should request with a name" {
                $Result = Get-NetboxDCIMDevice -Name 'testdevice'
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/dcim/devices/?name=testdevice'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
            
            It "Should request with a single ID" {
                $Result = Get-NetboxDCIMDevice -Id 10
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/dcim/devices/10/'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
            
            It "Should request with multiple IDs" {
                $Result = Get-NetboxDCIMDevice -Id 10, 12, 15
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/dcim/devices/?id__in=10,12,15'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
            
            It "Should request a status" {
                $Result = Get-NetboxDCIMDevice -Status 'Active'
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/dcim/devices/?status=1'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
            
            It "Should throw for an invalid status" {
                {
                    Get-NetboxDCIMDevice -Status 'Fake'
                } | Should -Throw
            }
            
            It "Should request devices that are a PDU" {
                $Result = Get-NetboxDCIMDevice -Is_PDU $True
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -BeExactly 'https://netbox.domain.com/api/dcim/devices/?is_pdu=True'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
        }
        
        Context -Name "Get-NetboxDCIMDeviceType" -Fixture {
            It "Should request the default number of devices types" {
                $Result = Get-NetboxDCIMDeviceType
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/dcim/device-types/'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
            
            It "Should request with a limit and offset" {
                $Result = Get-NetboxDCIMDeviceType -Limit 10 -Offset 100
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/dcim/device-types/?offset=100&limit=10'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
            
            It "Should request with a query" {
                $Result = Get-NetboxDCIMDeviceType -Query 'testdevice'
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/dcim/device-types/?q=testdevice'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
            
            It "Should request with an escaped query" {
                $Result = Get-NetboxDCIMDeviceType -Query 'test device'
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/dcim/device-types/?q=test+device'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
            
            It "Should request with a slug" {
                $Result = Get-NetboxDCIMDeviceType -Slug 'testdevice'
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/dcim/device-types/?slug=testdevice'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
            
            It "Should request with a single ID" {
                $Result = Get-NetboxDCIMDeviceType -Id 10
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/dcim/device-types/10/'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
            
            It "Should request with multiple IDs" {
                $Result = Get-NetboxDCIMDeviceType -Id 10, 12, 15
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/dcim/device-types/?id__in=10,12,15'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
            
            It "Should request a device type that is PDU" {
                $Result = Get-NetboxDCIMDeviceType -Is_PDU $true
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/dcim/device-types/?is_pdu=True'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
        }
        
        Context -Name "Get-NetboxDCIMDeviceRole" -Fixture {
            It "Should request the default number of devices types" {
                $Result = Get-NetboxDCIMDeviceRole
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName "Invoke-RestMethod" -Times 1 -Scope 'It' -Exactly
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/dcim/device-roles/'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
            
            It "Should request with a limit and offset" {
                $Result = Get-NetboxDCIMDeviceRole -Limit 10 -Offset 100
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/dcim/device-roles/?offset=100&limit=10'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
            
            It "Should request with a slug" {
                $Result = Get-NetboxDCIMDeviceRole -Slug 'testdevice'
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/dcim/device-roles/?slug=testdevice'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
            
            It "Should request with a name" {
                $Result = Get-NetboxDCIMDeviceRole -Name 'TestRole'
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/dcim/device-roles/?name=TestRole'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
            
            It "Should request those that are VM role" {
                $Result = Get-NetboxDCIMDeviceRole -VM_Role $true
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/dcim/device-roles/?vm_role=True'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
        }
    }
}































