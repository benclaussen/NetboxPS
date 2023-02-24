
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingConvertToSecureStringWithPlainText", "")]
param
(
)
Import-Module Pester
Remove-Module NetboxPS -Force -ErrorAction SilentlyContinue

$ModulePath = "$PSScriptRoot\..\dist\NetboxPS.psd1"

if (Test-Path $ModulePath) {
    Import-Module $ModulePath -ErrorAction Stop
}

Describe "Setup tests" -Tag 'Core', 'Setup' -Fixture {
    It "Throws an error for an empty hostname" {
        { Get-NetboxHostname } | Should -Throw
    }

    It "Sets the hostname" {
        Set-NetboxHostName -HostName 'netbox.domain.com' | Should -Be 'netbox.domain.com'
    }

    It "Gets the hostname from the variable" {
        Get-NetboxHostName | Should -Be 'netbox.domain.com'
    }

    It "Throws an error for empty credentials" {
        { Get-NetboxCredential } | Should -Throw
    }

    Context "Plain text credentials" {
        It "Sets the credentials using plain text" {
            Set-NetboxCredential -Token (ConvertTo-SecureString -String "faketoken" -Force -AsPlainText) | Should -BeOfType [pscredential]
        }

        It "Checks the set credentials" {
            Set-NetboxCredential -Token (ConvertTo-SecureString -String "faketoken" -Force -AsPlainText)
            (Get-NetboxCredential).GetNetworkCredential().Password | Should -BeExactly "faketoken"
        }
    }

    Context "Credentials object" {
        $Creds = [PSCredential]::new('notapplicable', (ConvertTo-SecureString -String "faketoken" -AsPlainText -Force))

        It "Sets the credentials using [pscredential]" {
            Set-NetboxCredential -Credential $Creds | Should -BeOfType [pscredential]
        }

        It "Checks the set credentials" {
            (Get-NetboxCredential).GetNetworkCredential().Password | Should -BeExactly 'faketoken'
        }
    }

    <#
    Context "Connecting to the API" {
        Mock Get-NetboxCircuitsChoices {
            return $true
        } -ModuleName NetboxPS -Verifiable

        $Creds = [PSCredential]::new('notapplicable', (ConvertTo-SecureString -String "faketoken" -AsPlainText -Force))

        It "Connects using supplied hostname and obtained credentials" {
            #$null = Set-NetboxCredentials -Credentials $Creds
            Connect-NetboxAPI -Hostname "fake.org" | Should -Be $true
        }

        It "Connects using supplied hostname and credentials" {
            Connect-NetboxAPI -Hostname 'fake.org' -Credentials $Creds | Should -Be $true
        }



        Assert-MockCalled -CommandName Get-NetboxCircuitsChoices -ModuleName NetboxPS
    }
    #>
}








