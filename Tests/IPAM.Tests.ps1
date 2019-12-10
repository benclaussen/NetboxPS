<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2018 v5.5.150
	 Created on:   	5/10/2018 3:41 PM
	 Created by:   	Ben Claussen
	 Organization: 	NEOnet
	 Filename:     	IPAM.Tests.ps1
	===========================================================================
	.DESCRIPTION
		IPAM Pester tests
#>

Import-Module Pester
Remove-Module NetboxPS -Force -ErrorAction SilentlyContinue

$ModulePath = "$PSScriptRoot\..\dist\NetboxPS.psd1"

if (Test-Path $ModulePath) {
    Import-Module $ModulePath -ErrorAction Stop
}


Describe -Name "IPAM tests" -Tag 'Ipam' -Fixture {
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
        $script:NetboxConfig.Choices.IPAM = (Get-Content "$PSScriptRoot\IPAMChoices.json" -ErrorAction Stop | ConvertFrom-Json)

        Context -Name "Get-NetboxIPAMAggregate" -Fixture {
            It "Should request the default number of aggregates" {
                $Result = Get-NetboxIPAMAggregate
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/ipam/aggregates/'
                $Result.Headers.Keys.Count | Should -BeExactly 1
                $Result.Headers.Authorization | Should -Be "Token faketoken"
            }
            
            It "Should request with limit and offset" {
                $Result = Get-NetboxIPAMAggregate -Limit 10 -Offset 12
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/ipam/aggregates/?offset=12&limit=10'
                $Result.Headers.Keys.Count | Should -BeExactly 1
                $Result.Headers.Authorization | Should -Be "Token faketoken"
            }
            
            It "Should request with a query" {
                $Result = Get-NetboxIPAMAggregate -Query '10.10.0.0'
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/ipam/aggregates/?q=10.10.0.0'
                $Result.Headers.Keys.Count | Should -BeExactly 1
                $Result.Headers.Authorization | Should -Be "Token faketoken"
            }
            
            It "Should request with an escaped query" {
                $Result = Get-NetboxIPAMAggregate -Query 'my aggregate'
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/ipam/aggregates/?q=my+aggregate'
                $Result.Headers.Keys.Count | Should -BeExactly 1
                $Result.Headers.Authorization | Should -Be "Token faketoken"
            }
            
            It "Should request with a single ID" {
                $Result = Get-NetboxIPAMAggregate -Id 10
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/ipam/aggregates/10/'
                $Result.Headers.Keys.Count | Should -BeExactly 1
                $Result.Headers.Authorization | Should -Be "Token faketoken"
            }
            
            It "Should request with multiple IDs" {
                $Result = Get-NetboxIPAMAggregate -Id 10, 12, 15
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/ipam/aggregates/?id__in=10,12,15'
                $Result.Headers.Keys.Count | Should -BeExactly 1
                $Result.Headers.Authorization | Should -Be "Token faketoken"
            }
        }
        
        Context -Name "Get-NetboxIPAMAddress" -Fixture {
            It "Should request the default number of addresses" {
                $Result = Get-NetboxIPAMAddress
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/ipam/ip-addresses/'
                $Result.Headers.Keys.Count | Should -BeExactly 1
                $Result.Headers.Authorization | Should -Be "Token faketoken"
            }
            
            It "Should request with limit and offset" {
                $Result = Get-NetboxIPAMAddress -Limit 10 -Offset 12
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/ipam/ip-addresses/?offset=12&limit=10'
                $Result.Headers.Keys.Count | Should -BeExactly 1
                $Result.Headers.Authorization | Should -Be "Token faketoken"
            }
            
            It "Should request with a query" {
                $Result = Get-NetboxIPAMAddress -Query '10.10.10.10'
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/ipam/ip-addresses/?q=10.10.10.10'
                $Result.Headers.Keys.Count | Should -BeExactly 1
                $Result.Headers.Authorization | Should -Be "Token faketoken"
            }
            
            It "Should request with an escaped query" {
                $Result = Get-NetboxIPAMAddress -Query 'my ip address'
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/ipam/ip-addresses/?q=my+ip+address'
                $Result.Headers.Keys.Count | Should -BeExactly 1
                $Result.Headers.Authorization | Should -Be "Token faketoken"
            }
            
            It "Should request with a single ID" {
                $Result = Get-NetboxIPAMAddress -Id 10
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/ipam/ip-addresses/10/'
                $Result.Headers.Keys.Count | Should -BeExactly 1
                $Result.Headers.Authorization | Should -Be "Token faketoken"
            }
            
            It "Should request with multiple IDs" {
                $Result = Get-NetboxIPAMAddress -Id 10, 12, 15
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/ipam/ip-addresses/?id__in=10,12,15'
                $Result.Headers.Keys.Count | Should -BeExactly 1
                $Result.Headers.Authorization | Should -Be "Token faketoken"
            }
            
            It "Should request with a family number" {
                $Result = Get-NetboxIPAMAddress -Family 4
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/ipam/ip-addresses/?family=4'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
            
            It "Should request with a family name" {
                $Result = Get-NetboxIPAMAddress -Family 'IPv4'
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/ipam/ip-addresses/?family=4'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
        }
        
        Context -Name "Get-NetboxIPAMAvailableIP" -Fixture {
            It "Should request the default number of available IPs" {
                $Result = Get-NetboxIPAMAvailableIP -Prefix_Id 10
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/ipam/prefixes/10/available-ips/'
                $Result.Headers.Keys.Count | Should -BeExactly 1
                $Result.Headers.Authorization | Should -Be "Token faketoken"
            }
            
            It "Should request 10 available IPs" {
                $Result = Get-NetboxIPAMAvailableIP -Prefix_Id 1504 -NumberOfIPs 10
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/ipam/prefixes/1504/available-ips/?limit=10'
                $Result.Headers.Keys.Count | Should -BeExactly 1
                $Result.Headers.Authorization | Should -Be "Token faketoken"
            }
        }
        
        Context -Name "Get-NetboxIPAMPrefix" -Fixture {
            It "Should request the default number of prefixes" {
                $Result = Get-NetboxIPAMPrefix
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/ipam/prefixes/'
                $Result.Headers.Keys.Count | Should -BeExactly 1
                $Result.Headers.Authorization | Should -Be "Token faketoken"
            }
            
            It "Should request with limit and offset" {
                $Result = Get-NetboxIPAMPrefix -Limit 10 -Offset 12
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/ipam/prefixes/?offset=12&limit=10'
                $Result.Headers.Keys.Count | Should -BeExactly 1
                $Result.Headers.Authorization | Should -Be "Token faketoken"
            }
            
            It "Should request with a query" {
                $Result = Get-NetboxIPAMPrefix -Query '10.10.10.10'
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/ipam/prefixes/?q=10.10.10.10'
                $Result.Headers.Keys.Count | Should -BeExactly 1
                $Result.Headers.Authorization | Should -Be "Token faketoken"
            }
            
            It "Should request with an escaped query" {
                $Result = Get-NetboxIPAMPrefix -Query 'my ip address'
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/ipam/prefixes/?q=my+ip+address'
                $Result.Headers.Keys.Count | Should -BeExactly 1
                $Result.Headers.Authorization | Should -Be "Token faketoken"
            }
            
            It "Should request with a single ID" {
                $Result = Get-NetboxIPAMPrefix -Id 10
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/ipam/prefixes/10/'
                $Result.Headers.Keys.Count | Should -BeExactly 1
                $Result.Headers.Authorization | Should -Be "Token faketoken"
            }
            
            It "Should request with multiple IDs" {
                $Result = Get-NetboxIPAMPrefix -Id 10, 12, 15
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/ipam/prefixes/?id__in=10,12,15'
                $Result.Headers.Keys.Count | Should -BeExactly 1
                $Result.Headers.Authorization | Should -Be "Token faketoken"
            }
            
            It "Should request with VLAN vID" {
                $Result = Get-NetboxIPAMPrefix -VLAN_VID 10
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/ipam/prefixes/?vlan_vid=10'
                $Result.Headers.Keys.Count | Should -BeExactly 1
                $Result.Headers.Authorization | Should -Be "Token faketoken"
            }
            
            It "Should request with family of 4" {
                $Result = Get-NetboxIPAMPrefix -Family 4
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/ipam/prefixes/?family=4'
                $Result.Headers.Keys.Count | Should -BeExactly 1
                $Result.Headers.Authorization | Should -Be "Token faketoken"
            }
            
            It "Should throw because the mask length is too large" {
                {
                    Get-NetboxIPAMPrefix -Mask_length 128
                } | Should -Throw
            }
            
            It "Should throw because the mask length is too small" {
                {
                    Get-NetboxIPAMPrefix -Mask_length -1
                } | Should -Throw
            }
            
            It "Should not throw because the mask length is just right" {
                {
                    Get-NetboxIPAMPrefix -Mask_length 24
                } | Should -Not -Throw
            }
            
            It "Should request with mask length 24" {
                $Result = Get-NetboxIPAMPrefix -Mask_length 24
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/ipam/prefixes/?mask_length=24'
                $Result.Headers.Keys.Count | Should -BeExactly 1
                $Result.Headers.Authorization | Should -Be "Token faketoken"
            }
        }
        
        Context -Name "New-NetboxIPAMPrefix" -Fixture {
            It "Should create a basic prefix" {
                $Result = New-NetboxIPAMPrefix -Prefix "10.0.0.0/24"
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'POST'
                $Result.URI | Should -Be 'https://netbox.domain.com/api/ipam/prefixes/'
                $Result.Headers.Keys.Count | Should -BeExactly 1
                $Result.Body | Should -Be '{"prefix":"10.0.0.0/24","status":1}'
            }
            
            It "Should create a prefix with a status and role names" {
                $Result = New-NetboxIPAMPrefix -Prefix "10.0.0.0/24" -Status 'Active' -Role 'Active'
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'POST'
                $Result.URI | Should -Be 'https://netbox.domain.com/api/ipam/prefixes/'
                $Result.Headers.Keys.Count | Should -BeExactly 1
                $Result.Body | Should -Be '{"prefix":"10.0.0.0/24","status":1,"role":"Active"}'
            }
            
            It "Should create a prefix with a status, role name, and tenant ID" {
                $Result = New-NetboxIPAMPrefix -Prefix "10.0.0.0/24" -Status 'Active' -Role 'Active' -Tenant 15
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'POST'
                $Result.URI | Should -Be 'https://netbox.domain.com/api/ipam/prefixes/'
                $Result.Headers.Keys.Count | Should -BeExactly 1
                $Result.Body | Should -Be '{"prefix":"10.0.0.0/24","status":1,"tenant":15,"role":"Active"}'
            }
        }
        
        Context -Name "New-NetboxIPAMAddress" -Fixture {
            It "Should create a basic IP address" {
                $Result = New-NetboxIPAMAddress -Address '10.0.0.1/24'
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'POST'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/ipam/ip-addresses/'
                $Result.Headers.Keys.Count | Should -BeExactly 1
                $Result.Body | Should -Be '{"status":1,"address":"10.0.0.1/24"}'
            }
            
            It "Should create an IP with a status and role names" {
                $Result = New-NetboxIPAMAddress -Address '10.0.0.1/24' -Status 'Reserved' -Role 'Anycast'
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'POST'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/ipam/ip-addresses/'
                $Result.Headers.Keys.Count | Should -BeExactly 1
                $Result.Body | Should -Be '{"status":2,"address":"10.0.0.1/24","role":30}'
            }
            
            It "Should create an IP with a status and role values" {
                $Result = New-NetboxIPAMAddress -Address '10.0.1.1/24' -Status '1' -Role '10'
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'POST'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/ipam/ip-addresses/'
                $Result.Headers.Keys.Count | Should -BeExactly 1
                $Result.Body | Should -Be '{"status":1,"address":"10.0.1.1/24","role":10}'
            }
        }
        
        Context -Name "Remove-NetboxIPAMAddress" -Fixture {
            Mock -CommandName "Get-NetboxIPAMAddress" -ModuleName NetboxPS -MockWith {
                return @{
                    'address' = "10.1.1.1/$Id"
                    'id' = $id
                }
            }
            
            It "Should remove a single IP" {
                $Result = Remove-NetboxIPAMAddress -Id 4109 -Force
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName "Get-NetboxIPAMAddress" -Times 1 -Scope 'It' -Exactly
                
                $Result.Method | Should -Be 'DELETE'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/ipam/ip-addresses/4109/'
                $Result.Headers.Keys.Count | Should -BeExactly 1
                $Result.Body | Should -Be $null
            }
            
            It "Should remove a single IP from the pipeline" {
                $Result = [pscustomobject]@{
                    'id' = 4110
                } | Remove-NetboxIPAMAddress -Force
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName "Get-NetboxIPAMAddress" -Times 1 -Scope 'It' -Exactly
                
                $Result.Method | Should -Be 'DELETE'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/ipam/ip-addresses/4110/'
                $Result.Headers.Keys.Count | Should -BeExactly 1
                $Result.Body | Should -Be $null
            }
            
            It "Should remove multiple IPs" {                
                $Result = Remove-NetboxIPAMAddress -Id 4109, 4110 -Force
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName "Get-NetboxIPAMAddress" -Times 2 -Scope 'It' -Exactly
                
                $Result.Method | Should -Be 'DELETE', 'DELETE'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/ipam/ip-addresses/4109/', 'https://netbox.domain.com/api/ipam/ip-addresses/4110/'
                $Result.Headers.Keys.Count | Should -BeExactly 2
            }
            
            It "Should remove multiple IPs from the pipeline" {
                $Result = @(
                    [pscustomobject]@{
                        'id' = 4109
                    },
                    [pscustomobject]@{
                        'id' = 4110
                    }
                ) | Remove-NetboxIPAMAddress -Force
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName "Get-NetboxIPAMAddress" -Times 2 -Scope 'It' -Exactly
                
                $Result.Method | Should -Be 'DELETE', 'DELETE'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/ipam/ip-addresses/4109/', 'https://netbox.domain.com/api/ipam/ip-addresses/4110/'
                $Result.Headers.Keys.Count | Should -BeExactly 2
            }
        }
        
        Context -Name "Set-NetboxIPAMAddress" -Fixture {
            Mock -CommandName "Get-NetboxIPAMAddress" -ModuleName NetboxPS -MockWith {
                return @{
                    'address' = '10.1.1.1/24'
                    'id' = $id
                }
            }
            
            It "Should set an IP with a new status" {
                $Result = Set-NetboxIPAMAddress -Id 4109 -Status 2 -Force
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName "Get-NetboxIPAMAddress" -Times 1 -Scope "It" -Exactly
                
                $Result.Method | Should -Be 'PATCH'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/ipam/ip-addresses/4109/'
                $Result.Headers.Keys.Count | Should -BeExactly 1
                $Result.Body | Should -Be '{"status":2}'
            }
            
            It "Should set an IP from the pipeline" {
                $Result = [pscustomobject]@{
                    'Id' = 4501
                } | Set-NetboxIPAMAddress -VRF 10 -Tenant 14 -Description 'Test description' -Force
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName "Get-NetboxIPAMAddress" -Times 1 -Scope "It" -Exactly
                
                $Result.Method | Should -Be 'PATCH'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/ipam/ip-addresses/4501/'
                $Result.Headers.Keys.Count | Should -BeExactly 1
                $Result.Body | Should -Be '{"vrf":10,"description":"Test description","tenant":14}'
            }
            
            It "Should set mulitple IPs to a new status" {
                $Result = Set-NetboxIPAMAddress -Id 4109, 4555 -Status 2 -Force
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName "Get-NetboxIPAMAddress" -Times 2 -Scope "It" -Exactly
                
                $Result.Method | Should -Be 'PATCH', 'PATCH'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/ipam/ip-addresses/4109/', 'https://netbox.domain.com/api/ipam/ip-addresses/4555/'
                $Result.Headers.Keys.Count | Should -BeExactly 2
                $Result.Body | Should -Be '{"status":2}', '{"status":2}'
            }
            
            It "Should set an IP with VRF, Tenant, and Description" {
                $Result = Set-NetboxIPAMAddress -Id 4110 -VRF 10 -Tenant 14 -Description 'Test description' -Force
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName "Get-NetboxIPAMAddress" -Times 1 -Scope "It" -Exactly
                
                $Result.Method | Should -Be 'PATCH'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/ipam/ip-addresses/4110/'
                $Result.Headers.Keys.Count | Should -BeExactly 1
                $Result.Body | Should -Be '{"vrf":10,"description":"Test description","tenant":14}'
            }
            
            It "Should set multiple IPs from the pipeline" {
                $Result = @(
                    [pscustomobject]@{
                        'Id' = 4501
                    },
                    [pscustomobject]@{
                        'Id' = 4611
                    }
                ) | Set-NetboxIPAMAddress -Status 2 -Force
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName "Get-NetboxIPAMAddress" -Times 2 -Scope "It" -Exactly
                
                $Result.Method | Should -Be 'PATCH', 'PATCH'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/ipam/ip-addresses/4501/', 'https://netbox.domain.com/api/ipam/ip-addresses/4611/'
                $Result.Headers.Keys.Count | Should -BeExactly 2
                $Result.Body | Should -Be '{"status":2}', '{"status":2}'
            }
        }
    }
}










