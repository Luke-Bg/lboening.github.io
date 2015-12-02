$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"

Describe "LBHelper functions" {
    
    Context "The module or script contains desired functions" {

    $functions = @('Get-Version','Clear-AllLogFiles','Get-ServiceHash','Test-RestSharp','New-CommentSnippet','Add-ConsoleApp','Get-Links', 'Get-WebHeaders', 'Get-Stats')

    Foreach ($func in $functions| sort) {
        it "Function exists $($func)" {
         
            (Test-path function:\$func) | should be true

        }
    }
    }
   
    Context "Testing help in Get-WebHeaders function" {
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
    it "Opens valid uri http://lboening.github.io and Get-WebHeaders gets the headers" {
        (Get-WebHeaders -uri 'http://lboening.github.io') | should be $true
        }
    it "Opens invalid uri http://lboening1.github.io which returns 404 error" {
        (Get-WebHeaders -uri 'http://lboening1.github.io').ErrorDetail | should be "The remote server returned an error: (404) Not Found."
    }
    }
    
    Context "Testing help in Get-ServiceHash function" {

    
    It "Get-help with full opens" {
        (Get-Help Get-ServiceHash -full).examples | Should be $true
    }


    }

    Context "Testing return object is hashtable in Get-ServiceHash function" {
        
        Mock Get-ServiceHash { return @{ComputerName='Luke';} }
    
    It "Get-ServiceHash returns hash table" {
        (get-servicehash | % { $_.GetType().FullName}) | Should be "System.Collections.Hashtable"
    }

    It "Assert verifiable mocks for Get-ServiceHash" {
        Assert-VerifiableMocks
    }


    It "Assert mockCalled once for Get-ServiceHash" {
        Assert-MockCalled Get-ServiceHash -Times 1
    }
    }
}
