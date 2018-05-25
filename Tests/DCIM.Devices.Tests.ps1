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

Describe -Name "DCIM Devices Tests" -Tag 'DCIM', 'Devices' -Fixture {
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
            
            It "Should request a device by ID from the pipeline" {
                $Result = [pscustomobject]@{
                    'id' = 10
                } | Get-NetboxDCIMDevice
                
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
            
            It "Should request a device role by Id" {
                $Result = Get-NetboxDCIMDeviceRole -Id 10
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName "Invoke-RestMethod" -Times 1 -Scope 'It' -Exactly
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/dcim/device-roles/10/'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
            
            It "Should request multiple roles by Id" {
                $Result = Get-NetboxDCIMDeviceRole -Id 10, 12
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName "Invoke-RestMethod" -Times 2 -Scope 'It' -Exactly
                
                $Result.Method | Should -Be 'GET', 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/dcim/device-roles/10/', 'https://netbox.domain.com/api/dcim/device-roles/12/'
                $Result.Headers.Keys.Count | Should -BeExactly 2
            }
            
            It "Should request single role by Id and color" {
                $Result = Get-NetboxDCIMDeviceRole -Id 10 -Color '0fab12'
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName "Invoke-RestMethod" -Times 1 -Scope 'It' -Exactly
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/dcim/device-roles/10/?color=0fab12'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
            
            It "Should request multiple roles by Id and color" {
                $Result = Get-NetboxDCIMDeviceRole -Id 10, 12 -Color '0fab12'
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName "Invoke-RestMethod" -Times 2 -Scope 'It' -Exactly
                
                $Result.Method | Should -Be 'GET', 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/dcim/device-roles/10/?color=0fab12', 'https://netbox.domain.com/api/dcim/device-roles/12/?color=0fab12'
                $Result.Headers.Keys.Count | Should -BeExactly 2
            }
            
            It "Should request with a limit and offset" {
                $Result = Get-NetboxDCIMDeviceRole -Limit 10 -Offset 100
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName "Invoke-RestMethod" -Times 1 -Scope 'It' -Exactly
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/dcim/device-roles/?offset=100&limit=10'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
            
            It "Should request with a slug" {
                $Result = Get-NetboxDCIMDeviceRole -Slug 'testdevice'
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName "Invoke-RestMethod" -Times 1 -Scope 'It' -Exactly
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/dcim/device-roles/?slug=testdevice'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
            
            It "Should request with a name" {
                $Result = Get-NetboxDCIMDeviceRole -Name 'TestRole'
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName "Invoke-RestMethod" -Times 1 -Scope 'It' -Exactly
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/dcim/device-roles/?name=TestRole'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
            
            It "Should request those that are VM role" {
                $Result = Get-NetboxDCIMDeviceRole -VM_Role $true
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName "Invoke-RestMethod" -Times 1 -Scope 'It' -Exactly
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/dcim/device-roles/?vm_role=True'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
        }
        
        Context -Name "New-NetboxDCIMDevice" -Fixture {
            It "Should create a new device" {
                $Result = New-NetboxDCIMDevice -Name "newdevice" -Device_Role 4 -Device_Type 10 -Site 1 -Face 0
                
                Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1 -Exactly -Scope 'It'
                
                $Result.Method | Should -Be 'POST'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/dcim/devices/'
                $Result.Headers.Keys.Count | Should -BeExactly 1
                $Result.Body | Should -Be '{"site":1,"face":0,"name":"newdevice","status":1,"device_type":10,"device_role":4}'
            }
            
            It "Should throw because of an invalid status" {
                {
                    New-NetboxDCIMDevice -Name "newdevice" -Device_Role 4 -Device_Type 10 -Site 1 -Status 5555
                } | Should -Throw
            }
        }
        
        
        Mock -CommandName "Get-NetboxDCIMDevice" -ModuleName NetboxPS -MockWith {
            return [pscustomobject]@{
                'Id' = $Id
                'Name' = $Name
            }
        }
        
        Context -Name "Set-NetboxDCIMDevice" -Fixture {
            It "Should set a device to a new name" {
                $Result = Set-NetboxDCIMDevice -Id 1234 -Name 'newtestname' -Force
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName 'Get-NetboxDCIMDevice' -Times 1 -Exactly -Scope 'It'
                
                $Result.Method | Should -Be 'PATCH'
                $Result.URI | Should -Be 'https://netbox.domain.com/api/dcim/devices/1234/'
                $Result.Headers.Keys.Count | Should -BeExactly 1
                $Result.Body | Should -Be '{"name":"newtestname"}'
            }
            
            It "Should set a device with new properties" {
                $Result = Set-NetboxDCIMDevice -Id 1234 -Name 'newtestname' -Cluster 10 -Platform 20 -Site 15 -Force
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName 'Get-NetboxDCIMDevice' -Times 1 -Exactly -Scope 'It'
                
                $Result.Method | Should -Be 'PATCH'
                $Result.URI | Should -Be 'https://netbox.domain.com/api/dcim/devices/1234/'
                $Result.Headers.Keys.Count | Should -BeExactly 1
                $Result.Body | Should -Be '{"cluster":10,"platform":20,"name":"newtestname","site":15}'
            }
            
            It "Should set multiple devices with new properties" {
                $Result = Set-NetboxDCIMDevice -Id 1234, 3214 -Cluster 10 -Platform 20 -Site 15 -Force
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName 'Get-NetboxDCIMDevice' -Times 2 -Exactly -Scope 'It'
                
                $Result.Method | Should -Be 'PATCH', 'PATCH'
                $Result.URI | Should -Be 'https://netbox.domain.com/api/dcim/devices/1234/', 'https://netbox.domain.com/api/dcim/devices/3214/'
                $Result.Headers.Keys.Count | Should -BeExactly 2
                $Result.Body | Should -Be '{"cluster":10,"platform":20,"site":15}', '{"cluster":10,"platform":20,"site":15}'
            }
            
            It "Should set multiple devices with new properties from the pipeline" {
                $Result = @(
                    [pscustomobject]@{
                        'id' = 4432
                    },
                    [pscustomobject]@{
                        'id' = 3241
                    }
                ) | Set-NetboxDCIMDevice -Cluster 10 -Platform 20 -Site 15 -Force
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName 'Get-NetboxDCIMDevice' -Times 2 -Exactly -Scope 'It'
                
                $Result.Method | Should -Be 'PATCH', 'PATCH'
                $Result.URI | Should -Be 'https://netbox.domain.com/api/dcim/devices/4432/', 'https://netbox.domain.com/api/dcim/devices/3241/'
                $Result.Headers.Keys.Count | Should -BeExactly 2
                $Result.Body | Should -Be '{"cluster":10,"platform":20,"site":15}', '{"cluster":10,"platform":20,"site":15}'
            }
        }
        
        Context -Name "Remove-NetboxDCIMDevice" -Fixture {
            It "Should remove a device" {
                $Result = Remove-NetboxDCIMDevice -Id 10 -Force
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName 'Get-NetboxDCIMDevice' -Times 1 -Exactly -Scope 'It'
                
                $Result.Method | Should -Be 'DELETE'
                $Result.URI | Should -Be 'https://netbox.domain.com/api/dcim/devices/10/'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
            
            It "Should remove multiple devices" {
                $Result = Remove-NetboxDCIMDevice -Id 10, 12 -Force
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName 'Get-NetboxDCIMDevice' -Times 2 -Exactly -Scope 'It'
                
                $Result.Method | Should -Be 'DELETE', 'DELETE'
                $Result.URI | Should -Be 'https://netbox.domain.com/api/dcim/devices/10/', 'https://netbox.domain.com/api/dcim/devices/12/'
                $Result.Headers.Keys.Count | Should -BeExactly 2
            }
            
            It "Should remove a device from the pipeline" {
                $Result = Get-NetboxDCIMDevice -Id 20 | Remove-NetboxDCIMDevice -Force
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName 'Get-NetboxDCIMDevice' -Times 2 -Exactly -Scope 'It'
                
                $Result.Method | Should -Be 'DELETE'
                $Result.URI | Should -Be 'https://netbox.domain.com/api/dcim/devices/20/'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
            
            It "Should remove mulitple devices from the pipeline" {
                $Result = @(
                    [pscustomobject]@{
                        'Id' = 30
                    },
                    [pscustomobject]@{
                        'Id' = 40
                    }
                ) | Remove-NetboxDCIMDevice -Force
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName 'Get-NetboxDCIMDevice' -Times 2 -Exactly -Scope 'It'
                
                $Result.Method | Should -Be 'DELETE', 'DELETE'
                $Result.URI | Should -Be 'https://netbox.domain.com/api/dcim/devices/30/', 'https://netbox.domain.com/api/dcim/devices/40/'
                $Result.Headers.Keys.Count | Should -BeExactly 2
            }
        }
    }
}































