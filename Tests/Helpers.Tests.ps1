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
    
    InModuleScope -ModuleName 'NetboxPS' -ScriptBlock {
        Context -Name "Building URIBuilder" -Fixture {
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
        
        Context -Name "Building URI components" -Fixture {
            It "Should give a basic hashtable" {
                $URIComponents = BuildURIComponents -URISegments @('segment1', 'segment2') -ParametersDictionary @{'param1' = 1}
                
                $URIComponents | Should -BeOfType [hashtable]
                $URIComponents.Keys.Count | Should -BeExactly 2
                $URIComponents.Keys | Should -Be @("Segments", "Parameters")
                $URIComponents.Segments | Should -Be @("segment1", "segment2")
                $URIComponents.Parameters.Count | Should -BeExactly 1
                $URIComponents.Parameters | Should -BeOfType [hashtable]
                $URIComponents.Parameters['param1'] | Should -Be 1
            }
            
            It "Should add a single ID parameter to the segments" {
                $URIComponents = BuildURIComponents -URISegments @('segment1', 'segment2') -ParametersDictionary @{'id' = 123}
                
                $URIComponents | Should -BeOfType [hashtable]
                $URIComponents.Keys.Count | Should -BeExactly 2
                $URIComponents.Keys | Should -Be @("Segments", "Parameters")
                $URIComponents.Segments | Should -Be @("segment1", "segment2", '123')
                $URIComponents.Parameters.Count | Should -BeExactly 0
                $URIComponents.Parameters | Should -BeOfType [hashtable]
            }
            
            It "Should add multiple IDs to the parameters id__in" {
                $URIComponents = BuildURIComponents -URISegments @('segment1', 'segment2') -ParametersDictionary @{'id' = "123", "456"}
                
                $URIComponents | Should -BeOfType [hashtable]
                $URIComponents.Keys.Count | Should -BeExactly 2
                $URIComponents.Keys | Should -Be @("Segments", "Parameters")
                $URIComponents.Segments | Should -Be @("segment1", "segment2")
                $URIComponents.Parameters.Count | Should -BeExactly 1
                $URIComponents.Parameters | Should -BeOfType [hashtable]
                $URIComponents.Parameters['id__in'] | Should -Be '123,456'
            }
            
            It "Should skip a particular parameter name" {
                $URIComponents = BuildURIComponents -URISegments @('segment1', 'segment2') -ParametersDictionary @{'param1' = 1; 'param2' = 2} -SkipParameterByName 'param2'
                
                $URIComponents | Should -BeOfType [hashtable]
                $URIComponents.Keys.Count | Should -BeExactly 2
                $URIComponents.Keys | Should -Be @("Segments", "Parameters")
                $URIComponents.Segments | Should -Be @("segment1", "segment2")
                $URIComponents.Parameters.Count | Should -BeExactly 1
                $URIComponents.Parameters | Should -BeOfType [hashtable]
                $URIComponents.Parameters['param1'] | Should -Be 1
                $URIComponents.Parameters['param2'] | Should -BeNullOrEmpty
            }
            
            It "Should add a query (q) parameter" {
                $URIComponents = BuildURIComponents -URISegments @('segment1', 'segment2') -ParametersDictionary @{'query' = 'mytestquery'}
                
                $URIComponents | Should -BeOfType [hashtable]
                $URIComponents.Keys.Count | Should -BeExactly 2
                $URIComponents.Keys | Should -Be @("Segments", "Parameters")
                $URIComponents.Segments | Should -Be @("segment1", "segment2")
                $URIComponents.Parameters.Count | Should -BeExactly 1
                $URIComponents.Parameters | Should -BeOfType [hashtable]
                $URIComponents.Parameters['q'] | Should -Be 'mytestquery'
            }
        }
        
        Context -Name "Invoking request tests" -Fixture {
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
            
            Mock -CommandName 'Get-NetboxCredential' -Verifiable -ModuleName 'NetboxPS' -MockWith {
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
                
                $Result = InvokeNetboxRequest -URI $URIBuilder -Method POST -Body @{
                    'bodyparam1' = 'val1'
                } -Raw
                
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
                $Result.Headers.Count | Should -BeExactly 2
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
        
        Context -Name "Validating choices" -Fixture {
            Context -Name "Virtualization choices" -Fixture {
                $MajorObject = 'Virtualization'
                $script:NetboxConfig.Choices.Virtualization = (Get-Content "$PSScriptRoot\VirtualizationChoices.json" -ErrorAction Stop | ConvertFrom-Json)
                
                It "Should return a valid integer for status when provided a name" {
                    $Result = ValidateChoice -MajorObject $MajorObject -ChoiceName 'virtual-machine:status' -ProvidedValue 'Active'
                    
                    $Result | Should -BeOfType [uint16]
                    $Result | Should -BeExactly 1
                }
                
                It "Should return a valid integer for status when provided an integer" {
                    $Result = ValidateChoice -MajorObject $MajorObject -ChoiceName 'virtual-machine:status' -ProvidedValue 0
                    
                    $Result | Should -BeOfType [uint16]
                    $Result | Should -BeExactly 0
                }
                
                It "Should throw because of an invalid choice" {
                    {
                        ValidateChoice -MajorObject $MajorObject -ChoiceName 'virtual-machine:status' -ProvidedValue 'Fake'
                    } | Should -Throw
                }
            }
            
            Context -Name "IPAM choices" -Fixture {
                $MajorObject = 'IPAM'
                $script:NetboxConfig.Choices.IPAM = (Get-Content "$PSScriptRoot\IPAMChoices.json" -ErrorAction Stop | ConvertFrom-Json)
                
                Context -Name "aggregate:family" -Fixture {
                    $ChoiceName = 'aggregate:family'
                    
                    It "Should return a valid integer when provided a name" {
                        $Result = ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue 'IPv4'
                        
                        $Result | Should -BeOfType [uint16]
                        $Result | Should -BeExactly 4
                    }
                    
                    It "Should return a valid integer when provided an integer" {
                        $Result = ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue 4
                        
                        $Result | Should -BeOfType [uint16]
                        $Result | Should -BeExactly 4
                    }
                    
                    It "Should throw because of an invalid choice" {
                        {
                            ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue 0
                        } | Should -Throw
                    }
                }
                
                Context -Name "prefix:family" {
                    $ChoiceName = 'prefix:family'
                    
                    It "Should return a valid integer when provided a name" {
                        $Result = ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue 'IPv4'
                        
                        $Result | Should -BeOfType [uint16]
                        $Result | Should -BeExactly 4
                    }
                    
                    It "Should return a valid integer when provided an integer" {
                        $Result = ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue 4
                        
                        $Result | Should -BeOfType [uint16]
                        $Result | Should -BeExactly 4
                    }
                    
                    It "Should throw because of an invalid choice" {
                        {
                            ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue 0
                        } | Should -Throw
                    }
                }
                
                Context -Name "prefix:status" {
                    $ChoiceName = 'prefix:status'
                    
                    It "Should return a valid integer when provided a name" {
                        $Result = ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue 'Active'
                        
                        $Result | Should -BeOfType [uint16]
                        $Result | Should -BeExactly 1
                    }
                    
                    It "Should return a valid integer when provided an integer" {
                        $Result = ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue 1
                        
                        $Result | Should -BeOfType [uint16]
                        $Result | Should -BeExactly 1
                    }
                    
                    It "Should throw because of an invalid choice" {
                        {
                            ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue 10
                        } | Should -Throw
                    }
                }
                
                Context -Name "ip-address:family" {
                    $ChoiceName = 'ip-address:family'
                    
                    It "Should return a valid integer when provided a name" {
                        $Result = ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue 'IPv4'
                        
                        $Result | Should -BeOfType [uint16]
                        $Result | Should -BeExactly 4
                    }
                    
                    It "Should return a valid integer when provided an integer" {
                        $Result = ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue 4
                        
                        $Result | Should -BeOfType [uint16]
                        $Result | Should -BeExactly 4
                    }
                    
                    It "Should throw because of an invalid choice" {
                        {
                            ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue 10
                        } | Should -Throw
                    }
                }
                
                Context -Name "ip-address:status" {
                    $ChoiceName = 'ip-address:status'
                    
                    It "Should return a valid integer when provided a name" {
                        $Result = ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue 'Active'
                        
                        $Result | Should -BeOfType [uint16]
                        $Result | Should -BeExactly 1
                    }
                    
                    It "Should return a valid integer when provided an integer" {
                        $Result = ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue 1
                        
                        $Result | Should -BeOfType [uint16]
                        $Result | Should -BeExactly 1
                    }
                    
                    It "Should throw because of an invalid choice" {
                        {
                            ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue 10
                        } | Should -Throw
                    }
                }
                
                Context -Name "ip-address:role" {
                    $ChoiceName = 'ip-address:role'
                    
                    It "Should return a valid integer when provided a name" {
                        $Result = ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue 'Anycast'
                        
                        $Result | Should -BeOfType [uint16]
                        $Result | Should -BeExactly 30
                    }
                    
                    It "Should return a valid integer when provided an integer" {
                        $Result = ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue 30
                        
                        $Result | Should -BeOfType [uint16]
                        $Result | Should -BeExactly 30
                    }
                    
                    It "Should throw because of an invalid choice" {
                        {
                            ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue 1
                        } | Should -Throw
                    }
                }
                
                Context -Name "vlan:status" {
                    $ChoiceName = 'vlan:status'
                    
                    It "Should return a valid integer when provided a name" {
                        $Result = ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue 'Active'
                        
                        $Result | Should -BeOfType [uint16]
                        $Result | Should -BeExactly 1
                    }
                    
                    It "Should return a valid integer when provided an integer" {
                        $Result = ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue 1
                        
                        $Result | Should -BeOfType [uint16]
                        $Result | Should -BeExactly 1
                    }
                    
                    It "Should throw because of an invalid choice" {
                        {
                            ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue 0
                        } | Should -Throw
                    }
                }
                
                Context -Name "service:protocol" {
                    $ChoiceName = 'service:protocol'
                    
                    It "Should return a valid integer when provided a name" {
                        $Result = ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue 'TCP'
                        
                        $Result | Should -BeOfType [uint16]
                        $Result | Should -BeExactly 6
                    }
                    
                    It "Should return a valid integer when provided an integer" {
                        $Result = ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue 6
                        
                        $Result | Should -BeOfType [uint16]
                        $Result | Should -BeExactly 6
                    }
                    
                    It "Should throw because of an invalid choice" {
                        {
                            ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue 0
                        } | Should -Throw
                    }
                }
            }
            
            Context -Name "DCIM choices" -Fixture {
                $MajorObject = 'DCIM'
                $script:NetboxConfig.Choices.DCIM = (Get-Content "$PSScriptRoot\DCIMChoices.json" -ErrorAction Stop | ConvertFrom-Json)
                
                Context -Name "device:face" -Fixture {
                    $ChoiceName = 'device:face'
                    
                    It "Should return a valid integer when provided a name" {
                        $Result = ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue 'Front'
                        
                        $Result | Should -BeOfType [uint16]
                        $Result | Should -BeExactly 0
                    }
                    
                    It "Should return a valid integer when provided an integer" {
                        $Result = ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue 1
                        
                        $Result | Should -BeOfType [uint16]
                        $Result | Should -BeExactly 1
                    }
                    
                    It "Should throw because of an invalid choice" {
                        {
                            ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue 'fake'
                        } | Should -Throw
                    }
                }
                
                Context -Name "device:status" -Fixture {
                    $ChoiceName = 'device:status'
                    
                    It "Should return a valid integer when provided a name" {
                        $Result = ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue 'Active'
                        
                        $Result | Should -BeOfType [uint16]
                        $Result | Should -BeExactly 1
                    }
                    
                    It "Should return a valid integer when provided an integer" {
                        $Result = ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue 0
                        
                        $Result | Should -BeOfType [uint16]
                        $Result | Should -BeExactly 0
                    }
                    
                    It "Should throw because of an invalid choice" {
                        {
                            ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue 'fake'
                        } | Should -Throw
                    }
                }
                
                Context -Name "console-port:connection_status" -Fixture {
                    $ChoiceName = 'console-port:connection_status'
                    
                    It "Should return a valid string when provided a name" {
                        $Result = ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue 'Planned'
                        
                        $Result | Should -BeOfType [bool]
                        $Result | Should -Be $false
                    }
                    
                    It "Should return a valid string when provided a string" {
                        $Result = ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue 'false'
                        
                        $Result | Should -BeOfType [bool]
                        $Result | Should -Be $false
                    }
                    
                    It "Should return a valid string when provided a boolean" {
                        $Result = ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue $true
                        
                        $Result | Should -BeOfType [bool]
                        $Result | Should -Be $true
                    }
                    
                    It "Should throw because of an invalid choice" {
                        {
                            ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue 'fake'
                        } | Should -Throw
                    }
                }
                
                Context -Name "interface:form_factor" -Fixture {
                    $ChoiceName = 'interface:form_factor'
                    
                    It "Should return a valid integer when provided a name" {
                        $Result = ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue '10GBASE-CX4 (10GE)'
                        
                        $Result | Should -BeOfType [uint16]
                        $Result | Should -BeExactly 1170
                    }
                    
                    It "Should return a valid integer when provided an integer" {
                        $Result = ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue 1500
                        
                        $Result | Should -BeOfType [uint16]
                        $Result | Should -BeExactly 1500
                    }
                    
                    It "Should throw because of an invalid choice" {
                        {
                            ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue 'fake'
                        } | Should -Throw
                    }
                }
                
                Context -Name "interface-connection:connection_status" -Fixture {
                    $ChoiceName = 'interface-connection:connection_status'
                    
                    It "Should return a valid string when provided a name" {
                        $Result = ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue 'Planned'
                        
                        $Result | Should -BeOfType [bool]
                        $Result | Should -Be $false
                    }
                    
                    It "Should return a valid string when provided a string" {
                        $Result = ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue 'false'
                        
                        $Result | Should -BeOfType [bool]
                        $Result | Should -Be $false
                    }
                    
                    It "Should return a valid string when provided a boolean" {
                        $Result = ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue $true
                        
                        $Result | Should -BeOfType [bool]
                        $Result | Should -Be $true
                    }
                    
                    It "Should throw because of an invalid choice" {
                        {
                            ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue 'fake'
                        } | Should -Throw
                    }
                }
                
                Context -Name "interface-template:form_factor" -Fixture {
                    $ChoiceName = 'interface-template:form_factor'
                    
                    It "Should return a valid integer when provided a name" {
                        $Result = ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue '10GBASE-CX4 (10GE)'
                        
                        $Result | Should -BeOfType [uint16]
                        $Result | Should -BeExactly 1170
                    }
                    
                    It "Should return a valid integer when provided an integer" {
                        $Result = ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue 1500
                        
                        $Result | Should -BeOfType [uint16]
                        $Result | Should -BeExactly 1500
                    }
                    
                    It "Should throw because of an invalid choice" {
                        {
                            ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue 'fake'
                        } | Should -Throw
                    }
                }
                
                Context -Name "power-port:connection_status" -Fixture {
                    $ChoiceName = 'power-port:connection_status'
                    
                    It "Should return a valid string when provided a name" {
                        $Result = ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue 'Planned'
                        
                        $Result | Should -BeOfType [bool]
                        $Result | Should -Be $false
                    }
                    
                    It "Should return a valid string when provided a string" {
                        $Result = ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue 'false'
                        
                        $Result | Should -BeOfType [bool]
                        $Result | Should -Be $false
                    }
                    
                    It "Should return a valid string when provided a boolean" {
                        $Result = ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue $true
                        
                        $Result | Should -BeOfType [bool]
                        $Result | Should -Be $true
                    }
                    
                    It "Should throw because of an invalid choice" {
                        {
                            ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue 'fake'
                        } | Should -Throw
                    }
                }
                
                Context -Name "rack:type" -Fixture {
                    $ChoiceName = 'rack:type'
                    
                    It "Should return a valid integer when provided a name" {
                        $Result = ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue '2-post frame'
                        
                        $Result | Should -BeOfType [uint16]
                        $Result | Should -BeExactly 100
                    }
                    
                    It "Should return a valid integer when provided an integer" {
                        $Result = ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue 300
                        
                        $Result | Should -BeOfType [uint16]
                        $Result | Should -BeExactly 300
                    }
                    
                    It "Should throw because of an invalid choice" {
                        {
                            ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue 'fake'
                        } | Should -Throw
                    }
                }
                
                Context -Name "rack:width" -Fixture {
                    $ChoiceName = 'rack:width'
                    
                    It "Should return a valid integer when provided a name" {
                        $Result = ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue '19 inches'
                        
                        $Result | Should -BeOfType [uint16]
                        $Result | Should -BeExactly 19
                    }
                    
                    It "Should return a valid integer when provided an integer" {
                        $Result = ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue 23
                        
                        $Result | Should -BeOfType [uint16]
                        $Result | Should -BeExactly 23
                    }
                    
                    It "Should throw because of an invalid choice" {
                        {
                            ValidateChoice -MajorObject $MajorObject -ChoiceName $ChoiceName -ProvidedValue 'fake'
                        } | Should -Throw
                    }
                }
            }
        }
    }
}














