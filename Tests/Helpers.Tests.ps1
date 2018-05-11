<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2018 v5.5.150
	 Created on:   	5/8/2018 11:36 AM
	 Created by:   	Ben Claussen
	 Organization: 	NEOnet
	 Filename:     	Helpers.Tests.ps1
	===========================================================================
	.DESCRIPTION
		Helper functions Pester tests
#>

Import-Module Pester
Remove-Module NetboxPS -Force -ErrorAction SilentlyContinue

$ModulePath = "$PSScriptRoot\..\dist\NetboxPS.psd1"

if (Test-Path $ModulePath) {
    Import-Module $ModulePath -ErrorAction Stop
}

Describe "Helpers tests" -Tag 'Core', 'Helpers' -Fixture {
    It "Should throw because we are not connected" {
        {
            Check-NetboxIsConnected
        } | Should -Throw
    }
    
    Mock -CommandName 'CheckNetboxIsConnected' -MockWith {
        return $true
    } -ModuleName 'NetboxPS'
    
    Context "Building URI tests" {
        InModuleScope -ModuleName 'NetboxPS' -ScriptBlock {
            It "Should give a basic URI object" {
                BuildNewURI -HostName 'netbox.domain.com' | Should -BeOfType [System.UriBuilder]
            }
            
            It "Should generate a URI using only a supplied hostname" {
                $URIBuilder = BuildNewURI -Hostname "netbox.domain.com"
                $URIBuilder.Host | Should -BeExactly 'netbox.domain.com'
                $URIBuilder.Path | Should -BeExactly 'api//'
                $URIBuilder.Scheme | Should -Be 'https'
                $URIBuilder.Port | Should -Be 443
                $URIBuilder.URI.AbsoluteUri | Should -Be 'https://netbox.domain.com/api//'
            }
            
            It "Should generate a URI using a hostname and segments" {
                $URIBuilder = BuildNewURI -Hostname "netbox.domain.com" -Segments 'seg1', 'seg2'
                $URIBuilder.Host | Should -BeExactly 'netbox.domain.com'
                $URIBuilder.Path | Should -BeExactly 'api/seg1/seg2/'
                $URIBuilder.URI.AbsoluteUri | Should -BeExactly 'https://netbox.domain.com/api/seg1/seg2/'
            }
            
            It "Should generate a URI using insecure HTTP and default to port 80" {
                $URIBuilder = BuildNewURI -Hostname "netbox.domain.com" -Segments 'seg1', 'seg2' -HTTPS $false -WarningAction 'SilentlyContinue'
                $URIBuilder.Scheme | Should -Be 'http'
                $URIBuilder.Port | Should -Be 80
                $URIBuilder.URI.AbsoluteURI | Should -Be 'http://netbox.domain.com/api/seg1/seg2/'
            }
            
            It "Should generate a URI using HTTPS on port 1234" {
                $URIBuilder = BuildNewURI -Hostname "netbox.domain.com" -Segments 'seg1', 'seg2' -Port 1234
                $URIBuilder.Scheme | Should -Be 'https'
                $URIBuilder.Port | Should -Be 1234
                $URIBuilder.URI.AbsoluteURI | Should -BeExactly 'https://netbox.domain.com:1234/api/seg1/seg2/'
            }
            
            It "Should generate a URI using HTTP on port 4321" {
                $URIBuilder = BuildNewURI -Hostname "netbox.domain.com" -Segments 'seg1', 'seg2' -HTTPS $false -Port 4321 -WarningAction 'SilentlyContinue'
                $URIBuilder.Scheme | Should -Be 'http'
                $URIBuilder.Port | Should -Be 4321
                $URIBuilder.URI.AbsoluteURI | Should -BeExactly 'http://netbox.domain.com:4321/api/seg1/seg2/'
            }
            
            It "Should generate a URI with parameters" {
                $URIParameters = @{
                    'param1' = 'paramval1'
                    'param2' = 'paramval2'
                }
                
                $URIBuilder = BuildNewURI -Hostname "netbox.domain.com" -Segments 'seg1', 'seg2' -Parameters $URIParameters
                $URIBuilder.Query | Should -BeExactly '?param1=paramval1&param2=paramval2'
                $URIBuilder.URI.AbsoluteURI | Should -BeExactly 'https://netbox.domain.com/api/seg1/seg2/?param1=paramval1&param2=paramval2'
            }
        }
    }
    
    Context "Invoking request tests" {
        InModuleScope -ModuleName 'NetboxPS' -ScriptBlock {
            Mock -CommandName 'Invoke-RestMethod' -Verifiable -MockWith {
                # Return an object of the items we would normally pass to Invoke-RestMethod
                return [pscustomobject]@{
                    'Method' = $Method
                    'Uri' = $Uri
                    'Headers' = $Headers
                    'Timeout' = $Timeout
                    'ContentType' = $ContentType
                    'Body' = $Body
                    'results' = 'Only results'
                }
            }
            
            Mock -CommandName 'Get-NetboxCredentials' -Verifiable -ModuleName 'NetboxPS' -MockWith {
                return [PSCredential]::new('notapplicable', (ConvertTo-SecureString -String "faketoken" -AsPlainText -Force))
            }
            
            It "Should return direct results instead of the raw request" {
                $URIBuilder = BuildNewURI -Hostname "netbox.domain.com" -Segments 'seg1', 'seg2'
                
                $Result = InvokeNetboxRequest -URI $URIBuilder
                
                Assert-VerifiableMock
                
                $Result | Should -BeOfType [string]
                $Result | Should -BeExactly "Only results"
            }
            
            It "Should generate a basic request" {
                $URIBuilder = BuildNewURI -Hostname "netbox.domain.com" -Segments 'seg1', 'seg2'
                
                $Result = InvokeNetboxRequest -URI $URIBuilder -Raw
                
                Assert-VerifiableMock

                $Result.Method | Should -Be 'GET'
                $Result.Uri | Should -Be $URIBuilder.Uri.AbsoluteUri
                $Result.Headers | Should -BeOfType [System.Collections.HashTable]
                $Result.Headers.Authorization | Should -Be "Token faketoken"
                $Result.Timeout | Should -Be 5
                $Result.ContentType | Should -Be 'application/json'
                $Result.Body | Should -Be $null # We did not supply a body
            }
            
            It "Should generate a POST request with body" {
                $URIBuilder = BuildNewURI -Hostname "netbox.domain.com" -Segments 'seg1', 'seg2'
                
                $Result = InvokeNetboxRequest -URI $URIBuilder -Method POST -Body @{'bodyparam1' = 'val1'} -Raw
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'POST'
                $Result.Body | Should -Be '{"bodyparam1":"val1"}'
            }
            
            It "Should generate a POST request with an extra header" {
                $Headers = @{
                    'Connection' = 'keep-alive'
                }
                
                $Body = @{
                    'bodyparam1' = 'val1'
                }
                
                $URIBuilder = BuildNewURI -Hostname "netbox.domain.com" -Segments 'seg1', 'seg2'
                
                $Result = InvokeNetboxRequest -URI $URIBuilder -Method POST -Body $Body -Headers $Headers -Raw
                
                Assert-VerifiableMock
                
                $Result.Method | Should -Be 'POST'
                $Result.Body | Should -Be '{"bodyparam1":"val1"}'
                $Result.Headers.Authorization | Should -Be "Token faketoken"
                $Result.Headers.Connection | Should -Be "keep-alive"
            }
            
            It "Should throw because of an invalid method" {
                {
                    $URI = BuildNewURI -Hostname "netbox.domain.com" -Segments 'seg1', 'seg2'
                    InvokeNetboxRequest -URI $URI -Method 'Fake'
                } | Should -Throw
            }
            
            It "Should throw because of an out-of-range timeout" {
                {
                    $URI = BuildNewURI -Hostname "netbox.domain.com" -Segments 'seg1', 'seg2'
                    InvokeNetboxRequest -URI $URI -Timeout 61
                } | Should -Throw
            }
        }
    }
}






