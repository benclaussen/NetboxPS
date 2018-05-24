<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2018 v5.5.152
	 Created on:   	5/24/2018 10:50 AM
	 Created by:   	Ben Claussen
	 Organization: 	NEOnet
	 Filename:     	DCIM.Interfaces.Tests.ps1
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>

Import-Module Pester
Remove-Module NetboxPS -Force -ErrorAction SilentlyContinue

$ModulePath = "$PSScriptRoot\..\dist\NetboxPS.psd1"

if (Test-Path $ModulePath) {
    Import-Module $ModulePath -ErrorAction Stop
}

Describe -Name "DCIM Interfaces Tests" -Tag 'DCIM', 'Interfaces' -Fixture {
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
        
        Context -Name "Get-NetboxDCIMInterface" -Fixture {
            It "Should request the default number of interfaces" {
                $Result = Get-NetboxDCIMInterface
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1 -Scope 'It' -Exactly
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/dcim/interfaces/'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
            
            It "Should request with a limit and offset" {
                $Result = Get-NetboxDCIMInterface -Limit 10 -Offset 100
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1 -Scope 'It' -Exactly
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/dcim/interfaces/?offset=100&limit=10'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
            
            It "Should request with enabled" {
                $Result = Get-NetboxDCIMInterface -Enabled $true
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1 -Scope 'It' -Exactly
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -BeExactly 'https://netbox.domain.com/api/dcim/interfaces/?enabled=True'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
            
            It "Should request with a form factor name" {
                $Result = Get-NetboxDCIMInterface -Form_Factor '10GBASE-T (10GE)'
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1 -Scope 'It' -Exactly
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/dcim/interfaces/?form_factor=1150'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
            
            It "Should throw for an invalid form factor" {
                {
                    Get-NetboxDCIMInterface -Form_Factor 'Fake'
                } | Should -Throw
            }
            
            It "Should request devices that are mgmt only" {
                $Result = Get-NetboxDCIMInterface -MGMT_Only $True
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1 -Scope 'It' -Exactly
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -BeExactly 'https://netbox.domain.com/api/dcim/interfaces/?mgmt_only=True'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
            
            It "Should request an interface from the pipeline" {
                $Result = [pscustomobject]@{
                    'Id' = 1234
                } | Get-NetboxDCIMInterface
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1 -Scope 'It' -Exactly
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/dcim/interfaces/1234/'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
        }
        
        Mock -CommandName "Get-NetboxDCIMInterface" -ModuleName "NetboxPS" -MockWith {
            return [pscustomobject]@{
                'Id' = $Id
            }
        }
        
        Context -Name "Add-NetboxDCIMInterface" -Fixture {
            It "Should add a basic interface to a device" {
                $Result = Add-NetboxDCIMInterface -Device 111 -Name "TestInterface"
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1 -Exactly -Scope 'It'
                
                $Result.Method | Should -Be 'POST'
                $Result.Uri | Should -BeExactly 'https://netbox.domain.com/api/dcim/interfaces/'
                $Result.Headers.Keys.Count | Should -BeExactly 1
                $Result.Body | Should -Be '{"name":"TestInterface","device":111}'
            }
            
            It "Should add an interface to a device with lots of properties" {
                $paramAddNetboxDCIMInterface = @{
                    Device = 123
                    Name = "TestInterface"
                    Form_Factor = '10GBASE-T (10GE)'
                    MTU = 9000
                    MGMT_Only = $true
                    Description = 'Test Description'
                    Mode = 'Access'
                }
                
                $Result = Add-NetboxDCIMInterface @paramAddNetboxDCIMInterface
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1 -Exactly -Scope 'It'
                
                $Result.Method | Should -Be 'POST'
                $Result.Uri | Should -BeExactly 'https://netbox.domain.com/api/dcim/interfaces/'
                $Result.Headers.Keys.Count | Should -BeExactly 1
                $Result.Body | Should -Be '{"mtu":9000,"mgmt_only":true,"description":"Test Description","mode":100,"name":"TestInterface","device":123,"form_factor":1150}'
            }
            
            It "Should add an interface with multiple tagged VLANs" {
                $Result = Add-NetboxDCIMInterface -Device 444 -Name "TestInterface" -Mode 'Tagged' -Tagged_VLANs 1, 2, 3, 4
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1 -Exactly -Scope 'It'
                
                $Result.Method | Should -Be 'POST'
                $Result.Uri | Should -BeExactly 'https://netbox.domain.com/api/dcim/interfaces/'
                $Result.Headers.Keys.Count | Should -BeExactly 1
                $Result.Body | Should -Be '{"mode":200,"name":"TestInterface","device":444,"tagged_vlans":[1,2,3,4]}'
            }
            
            It "Should throw for invalid mode" {
                {
                    Add-NetboxDCIMInterface -Device 321 -Name "Test123" -Mode 'Fake'
                } | Should -Throw
            }
            
            It "Should throw for out of range VLAN" {
                {
                    Add-NetboxDCIMInterface -Device 321 -Name "Test123" -Untagged_VLAN 4100
                } | Should -Throw
            }
        }
        
        Context -Name "Set-NetboxDCIMInterface" -Fixture {
            It "Should set an interface to a new name" {
                $Result = Set-NetboxDCIMInterface -Id 123 -Name "TestInterface"
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName 'Get-NetboxDCIMInterface' -Times 1 -Exactly -Scope 'It'
                Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1 -Exactly -Scope 'It'
                
                $Result.Method | Should -Be 'PATCH'
                $Result.Uri | Should -BeExactly 'https://netbox.domain.com/api/dcim/interfaces/123/'
                $Result.Headers.Keys.Count | Should -BeExactly 1
                $Result.Body | Should -Be '{"name":"TestInterface"}'
            }
            
            It "Should set multiple interfaces to a new name" {
                $Result = Set-NetboxDCIMInterface -Id 456, 789 -Name "TestInterface"
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName 'Get-NetboxDCIMInterface' -Times 2 -Exactly -Scope 'It'
                Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 2 -Exactly -Scope 'It'
                
                $Result.Method | Should -Be 'PATCH', 'PATCH'
                $Result.Uri | Should -BeExactly 'https://netbox.domain.com/api/dcim/interfaces/456/', 'https://netbox.domain.com/api/dcim/interfaces/789/'
                $Result.Headers.Keys.Count | Should -BeExactly 2
                $Result.Body | Should -Be '{"name":"TestInterface"}', '{"name":"TestInterface"}'
            }
            
            It "Should set multiple interfaces to a new name from the pipeline" {
                $Result = @(
                    [pscustomobject]@{
                        'Id' = 1234
                    },
                    [pscustomobject]@{
                        'Id' = 4231
                    }
                ) | Set-NetboxDCIMInterface -Name "TestInterface"
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName 'Get-NetboxDCIMInterface' -Times 2 -Exactly -Scope 'It'
                Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 2 -Exactly -Scope 'It'
                
                $Result.Method | Should -Be 'PATCH', 'PATCH'
                $Result.Uri | Should -BeExactly 'https://netbox.domain.com/api/dcim/interfaces/1234/', 'https://netbox.domain.com/api/dcim/interfaces/4231/'
                $Result.Headers.Keys.Count | Should -BeExactly 2
                $Result.Body | Should -Be '{"name":"TestInterface"}', '{"name":"TestInterface"}'
            }
            
            It "Should throw for invalid form factor" {
                {
                    Set-NetboxDCIMInterface -Id 1234 -Form_Factor 'fake'
                } | Should -Throw
            }
        }
        
        Context -Name "Remove-NetboxDCIMInterface" -Fixture {
            It "Should remove an interface" {
                $Result = Remove-NetboxDCIMInterface -Id 10 -Force
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName 'Get-NetboxDCIMInterface' -Times 1 -Exactly -Scope 'It'
                
                $Result.Method | Should -Be 'DELETE'
                $Result.URI | Should -Be 'https://netbox.domain.com/api/dcim/interfaces/10/'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
            
            It "Should remove multiple interfaces" {
                $Result = Remove-NetboxDCIMInterface -Id 10, 12 -Force
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName 'Get-NetboxDCIMInterface' -Times 2 -Exactly -Scope 'It'
                
                $Result.Method | Should -Be 'DELETE', 'DELETE'
                $Result.URI | Should -Be 'https://netbox.domain.com/api/dcim/interfaces/10/', 'https://netbox.domain.com/api/dcim/interfaces/12/'
                $Result.Headers.Keys.Count | Should -BeExactly 2
            }
            
            It "Should remove an interface from the pipeline" {
                $Result = Get-NetboxDCIMInterface -Id 20 | Remove-NetboxDCIMInterface -Force
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName 'Get-NetboxDCIMInterface' -Times 2 -Exactly -Scope 'It'
                
                $Result.Method | Should -Be 'DELETE'
                $Result.URI | Should -Be 'https://netbox.domain.com/api/dcim/interfaces/20/'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
            
            It "Should remove mulitple interfaces from the pipeline" {
                $Result = @(
                    [pscustomobject]@{
                        'Id' = 30
                    },
                    [pscustomobject]@{
                        'Id' = 40
                    }
                ) | Remove-NetboxDCIMInterface -Force
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName 'Get-NetboxDCIMInterface' -Times 2 -Exactly -Scope 'It'
                
                $Result.Method | Should -Be 'DELETE', 'DELETE'
                $Result.URI | Should -Be 'https://netbox.domain.com/api/dcim/interfaces/30/', 'https://netbox.domain.com/api/dcim/interfaces/40/'
                $Result.Headers.Keys.Count | Should -BeExactly 2
            }
        }
        
        Context -Name "Get-NetboxDCIMInterfaceConnection" -Fixture {
            It "Should request the default number of interface connections" {
                $Result = Get-NetboxDCIMInterfaceConnection
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1 -Scope 'It' -Exactly
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/dcim/interface-connections/'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
            
            It "Should request with a limit and offset" {
                $Result = Get-NetboxDCIMInterfaceConnection -Limit 10 -Offset 100
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1 -Scope 'It' -Exactly
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/dcim/interface-connections/?offset=100&limit=10'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
            
            It "Should request connected interfaces" {
                $Result = Get-NetboxDCIMInterfaceConnection -Connection_Status 'Connected'
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1 -Scope 'It' -Exactly
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -BeExactly 'https://netbox.domain.com/api/dcim/interface-connections/?connection_status=True'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
            
            It "Should throw for an invalid connection status" {
                {
                    Get-NetboxDCIMInterfaceConnection -Connection_Status 'Fake'
                } | Should -Throw
            }
        }
    }
}

















