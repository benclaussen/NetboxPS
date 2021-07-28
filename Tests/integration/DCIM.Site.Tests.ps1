#
# Copyright 2021, Alexis La Goutte <alexis dot lagoutte at gmail dot com>
#
# SPDX-License-Identifier: Apache-2.0
#
. ../common.ps1

BeforeAll {
    Connect-NetboxAPI @invokeParams
}

Describe "Get (DCIM) Site" {

    BeforeAll {
        New-NetboxDCIMSite -name $pester_site1
    }

    It "Get Site Does not throw an error" {
        {
            Get-NetboxDCIMSite
        } | Should -Not -Throw
    }

    It "Get ALL Site" {
        $site = Get-NetboxDCIMSite
        $site.count | Should -Not -Be $NULL
    }

    It "Get Site ($pester_site1)" {
        $site = Get-NetboxDCIMSite | Where-Object { $_.name -eq $pester_site1 }
        $site.id | Should -Not -BeNullOrEmpty
        $site.name | Should -Be $pester_site1
        $site.status.value | Should -Be "active"
    }

    It "Search Site by name ($pester_site1)" {
        $site = Get-NetboxDCIMSite -name $pester_site1
        @($site).count | Should -Be 1
        $site.id | Should -Not -BeNullOrEmpty
        $site.name | Should -Be $pester_site1
    }

    AfterAll {
        Get-NetboxDCIMSite -name $pester_site1 | Remove-NetboxDCIMSite -confirm:$false
    }
}

Describe "New (DCIM) Site" {

    It "New Site with no option" {
        New-NetboxDCIMSite -name $pester_site1
        $site = Get-NetboxDCIMSite -name $pester_site1
        $site.id | Should -Not -BeNullOrEmpty
        $site.name | Should -Be $pester_site1
        $site.slug | Should -Be $pester_site1
    }

    It "New Site with different slug" {
        New-NetboxDCIMSite -name $pester_site1 -slug pester_slug
        $site = Get-NetboxDCIMSite -name $pester_site1
        $site.id | Should -Not -BeNullOrEmpty
        $site.name | Should -Be $pester_site1
        $site.slug | Should -Be "pester_slug"
    }

    AfterEach {
        Get-NetboxDCIMSite -name $pester_site1 | Remove-NetboxDCIMSite -confirm:$false
    }
}

Describe "Remove Site" {

    BeforeEach {
        New-NetboxDCIMSite -name $pester_site1
    }

    It "Remove Site" {
        $site = Get-NetboxDCIMSite -name $pester_site1
        Remove-NetboxDCIMSite -id $site.id -confirm:$false
        $site = Get-NetboxDCIMSite -name $pester_site1
        $site | Should -BeNullOrEmpty
        @($site).count | Should -Be 0
    }

}