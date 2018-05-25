<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2018 v5.5.152
	 Created on:   	5/25/2018 1:03 PM
	 Created by:   	Ben Claussen
	 Organization: 	NEOnet
	 Filename:     	DCIM.Platforms.Tests.ps1
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

Describe -Name "DCIM Platforms Tests" -Tag 'DCIM', 'platforms' -Fixture {
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
        Context -Name "Get-NetboxDCIMPlatform" -Fixture {
            It "Should request the default number of platforms" {
                $Result = Get-NetboxDCIMPlatform
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1 -Scope 'It' -Exactly
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/dcim/platforms/'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
            
            It "Should request with a limit and offset" {
                $Result = Get-NetboxDCIMPlatform -Limit 10 -Offset 100
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1 -Scope 'It' -Exactly
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/dcim/platforms/?offset=100&limit=10'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
            
            It "Should request with a platform name" {
                $Result = Get-NetboxDCIMPlatform -Name "Windows Server 2016"
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1 -Scope 'It' -Exactly
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be 'https://netbox.domain.com/api/dcim/platforms/?name=Windows+Server+2016'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
            
            It "Should request a platform by manufacturer" {
                $Result = Get-NetboxDCIMPlatform -Manufacturer 'Cisco'
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1 -Scope 'It' -Exactly
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -BeExactly 'https://netbox.domain.com/api/dcim/platforms/?manufacturer=Cisco'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
            
            It "Should request a platform by ID" {
                $Result = Get-NetboxDCIMPlatform -Id 10
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 1 -Scope 'It' -Exactly
                
                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -BeExactly 'https://netbox.domain.com/api/dcim/platforms/10/'
                $Result.Headers.Keys.Count | Should -BeExactly 1
            }
            
            It "Should request multiple platforms by ID" {
                $Result = Get-NetboxDCIMPlatform -Id 10, 20
                
                Assert-VerifiableMock
                Assert-MockCalled -CommandName 'Invoke-RestMethod' -Times 2 -Scope 'It' -Exactly
                
                $Result.Method | Should -Be 'GET', 'GET'
                $Result.Uri | Should -BeExactly 'https://netbox.domain.com/api/dcim/platforms/10/', 'https://netbox.domain.com/api/dcim/platforms/20/'
                $Result.Headers.Keys.Count | Should -BeExactly 2
            }
        }
    }
}




