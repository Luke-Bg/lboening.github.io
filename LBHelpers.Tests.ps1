$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "LBHelper" {
    Context "Testing help" {
    It "Get-help opens successfully" {
        (Get-Help Get-WebHeaders) | Should Be $true
    }

    It "Get-help with full opens" {
        (Get-Help Get-WebHeaders -full).examples | Should be $true
    }

    It "Get-Help with full switch matches 'sends head request' " {
        (get-help get-webheaders -full).details.description.text | should match "Get-WebHeaders sends head request to URI"
    }
    }

    Context "Opens valid URL" {
    it "Opens uri" {
        (Get-WebHeaders -uri 'http://lboening.github.io') | should be $true
        }
    it "Opens invalid url http://lboening1.github.io returns 404 error" {
        (Get-WebHeaders -uri 'http://lboening1.github.io').ErrorDetail | should be "The remote server returned an error: (404) Not Found."
    }
    }

}
