Function Add-ConsoleApp{
[cmdletbinding()]
param(
[Parameter(Mandatory=$false,ValueFromPipelineByPropertyName=$true,Position=0)]
[string]$assembly
)
process{
$assembly = @"
using System;

public class MyProgram
{
    public static void Main(string[] args) {
        Console.WriteLine("Hello World");
    }
}
"@
Add-Type -OutputType ConsoleApplication -OutputAssembly HelloWorld.exe $assembly
}
}

Function Get-Links {
[cmdletbinding()]
param(
[Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true,Position=0)]
[string]$url="https://gsa.github.io/data/dotgov-domains/2014-12-01-full.csv"
)
process{
 $wc = New-object System.Net.Webclient
 $resp = $wc.DownloadString($url)
 return $resp
}
}


<#
.Synopsis
   Get-WebHeaders sends head request to URI and returns a Powershell custom object
.DESCRIPTION
   Gets header, returns object with following properties
     KeyToRec: Optional key, used for JSON
     Uri: Uri that was called
     Headers: The header response
     StatusCode: Statuscode returned
     DateTimeUTC: The datetime the command was run
     You can use these commands for further processing
.EXAMPLE
   Get-Webheaders -uri 'http://ABINGDON-VA.GOV/'
.EXAMPLE
   Get-WebHeaders -uri 'http://ABINGDON-VA.GOV/' -KeyToRec 'Abingdon-va' | FL
.INPUTS
   [string] uri. Validated as HTTP.
   [string] keytorec (optional key added to output)
.OUTPUTS
   [psobject] with keys and values
.NOTES
   Installation: install-module -ModuleUrl http://lboening.github.io/LBHelpers.psm1 -Force
   See details as web site noted.
.NOTES
   ## Actions on creating file
   New-ModuleManifest -NestedModules ".\Lbhelpers.psm1" -Author "Luke Boening" -CompanyName "Luke Boening" -Copyright "None" -Description "Testing module creation" -ModuleVersion "0.0.3" -path "C:\Code\scripts\LBHelpers.psd1" -RootModule ".\LbHelpers.psm1"  -PowerShellVersion 3.0 -Confirm
   Test-ModuleManifext -Path c:\code\scripts\LBHelpers.psd1
.NOTES
   Pester testing
   TBD
.NOTES
   ## Installation using PSGet
   ## Install PSGet: (new-object Net.WebClient).DownloadString("http://psget.net/GetPsGet.ps1") | iex
   Install-module -ModuleURL http://lboening.github.io/LBHelpers.psm1 -force
   get-command -listimported | ? {$_.ModuleName -like 'LB*'}
#>
Function Get-WebHeaders{
[cmdletbinding()]
[Outputtype([psobject])]
param(
[parameter(Mandatory=$true,ValueFromPipeLine=$true)]
[ValidatePattern('http*')]
[string]$uri,
[parameter(Mandatory=$false,ValueFromPipeLine=$true)]
[string]$keytorec='Url'
)
Process {
   try {
    $resp = Invoke-WebRequest -uri $uri -method head -UseBasicParsing -DisableKeepAlive -TimeoutSec 4 -UserAgent "Powershell 4.0" -MaximumRedirection 2 
    $prop = @{'KeyToRec'=$keytorec;'Uri'=$uri; 'Headers'=$resp.headers; 'StatusCode'=$resp.StatusCode; 'Error'=$false; 'DateTimeUTC'= (Get-date -format O);}
    New-Object -TypeName PSObject -Property $prop
    } Catch [System.Net.WebException]{
      $prop = @{'KeyToRec'=$keytorec;'Error'= $true; 'Uri'=$uri; ErrorDetail=$_.Exception.Message; 'DateTimeUTC'= (Get-date -format O);}
      New-Object -TypeName PsObject -property $prop
    } Catch [Exception]{
      $prop = @{'KeyToRec'=$keytorec;'Error'= $true; 'Uri'=$uri; ErrorDetail=$_.Exception.Message; 'DateTimeUTC'= (Get-date -format O);}
      New-Object -TypeName PsObject -property $prop
    }  
    }
}

## New-ModuleManifest -NestedModules ".\Lbhelpers.psm1" -Author "Luke Boening" -CompanyName "Luke Boening" -Copyright "None" -Description "Testing module creation" -ModuleVersion "0.2.0" -path "C:\USERS\LUKE_2\Documents\WindowsPowershell\Modules\LBHelpers\LBHelpers.psd1" -RootModule ".\LbHelpers.psm1" -confirm

