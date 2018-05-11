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
    
    Mock -CommandName 'Get-NetboxCredentials' -Verifiable -ModuleName 'NetboxPS' -MockWith {
        return [PSCredential]::new('notapplicable', (ConvertTo-SecureString -String "faketoken" -AsPlainText -Force))
    }
    
    Mock -CommandName 'Get-NetboxHostname' -Verifiable -ModuleName 'NetboxPS' -MockWith {
        return 'netbox.domain.com'
    }
    
    InModuleScope -ModuleName 'NetboxPS' -ScriptBlock {
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
            
            #region TODO: Figure out how to mock/test Verification appropriately...
            <#
            It "Should request with a family number" {
                Mock -CommandName 'Get-NetboxIPAMChoices' -ModuleName 'NetboxPS' -MockWith {
                    return @"
{"aggregate:family":[{"label":"IPv4","value":4},{"label":"IPv6","value":6}],"prefix:family":[{"label":"IPv4","value":4},{"label":"IPv6","value":6}],"prefix:status":[{"label":"Container","value":0},{"label":"Active","value":1},{"label":"Reserved","value":2},{"label":"Deprecated","value":3}],"ip-address:family":[{"label":"IPv4","value":4},{"label":"IPv6","value":6}],"ip-address:status":[{"label":"Active","value":1},{"label":"Reserved","value":2},{"label":"Deprecated","value":3},{"label":"DHCP","value":5}],"ip-address:role":[{"label":"Loopback","value":10},{"label":"Secondary","value":20},{"label":"Anycast","value":30},{"label":"VIP","value":40},{"label":"VRRP","value":41},{"label":"HSRP","value":42},{"label":"GLBP","value":43},{"label":"CARP","value":44}],"vlan:status":[{"label":"Active","value":1},{"label":"Reserved","value":2},{"label":"Deprecated","value":3}],"service:protocol":[{"label":"TCP","value":6},{"label":"UDP","value":17}]}
"@ | ConvertFrom-Json
                }
                
                Mock -CommandName 'Connect-NetboxAPI' -ModuleName 'NetboxPS' -MockWith {
                    $script:NetboxConfig.Connected = $true
                    $script:NetboxConfig.Choices.IPAM = Get-NetboxIPAMChoices
                }
                Connect-NetboxAPI
                $Result = Get-NetboxIPAMAddress -Role 4
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName "Get-NetboxIPAMChoices"
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/ipam/ip-addresses/?role=4'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
            #>
            #endregion
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
        
        Context -Name "Get-NetboxIPAMPrefix" {
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
            
            <#
            It "Should request with family of 4" {
                Mock -CommandName "VerifyIPAMChoices" -ModuleName 'NetboxPS' -MockWith {
                    return 4
                } -Verifiable
                $Result = Get-NetboxIPAMPrefix -Family 4
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/ipam/prefixes/?family=4'
                $Result.Headers.Keys.Count | Should -BeExactly 1
                $Result.Headers.Authorization | Should -Be "Token faketoken"
            }
            #>
            
            It "Should request with mask length 24" {
                $Result = Get-NetboxIPAMPrefix -Mask_length 24
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/ipam/prefixes/?mask_length=24'
                $Result.Headers.Keys.Count | Should -BeExactly 1
                $Result.Headers.Authorization | Should -Be "Token faketoken"
            }
            
            It "Should throw because the mask length is too large" {
                {
                    Get-NetboxIPAMPrefix -Mask_length 128
                } | Should -Throw
            }
        }
    }
}










