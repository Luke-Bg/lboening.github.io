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
	 Example output:
		blah
.EXAMPLE
   Get-Webheaders -uri 'http://ABINGDON-VA.GOV/'
.EXAMPLE
   Get-WebHeaders -uri 'http://ABINGDON-VA.GOV/' -KeyToRec 'Abingdon-va' | FL
.EXAMPLE
   # Examples
   $links = Get-Links -url "https://gsa.github.io/data/dotgov-domains/2014-12-01-full.csv" | Convertfrom-csv
   $links.'Domain Name'[0..5] | % {'http://'+$_.'Domain Name'} | get-webheaders | convertto-json -depth 2 -compress | out-file c:\alldata\responses.json -encoding ascii
.PARAMETER  Uri
   Enter the URI to the resource
.PARAMETER KeyToRec
   Enter an optional key to the record
   Type: string
   Used for JSON output
   Validation: none
.INPUTS
   [string] URI. Validated as HTTP.
   [string] KeyToRec (optional key added to output)
.OUTPUTS
   [psobject] with keys and values
.LINK
   http://lboening.github.io/LBHelpers.psm1
   https://msdn.microsoft.com/en-us/library/hh847834.aspx   
.NOTES
   # Lifecycle

   
   # Test
   # Copy-item .\Lbhelpers.ps1 -destination .\Tests
   # CD .\Tests
   # Invoke-Pester

   # New-ModuleManifest -NestedModules ".\Lbhelpers.psm1" -Author "Luke Boening" -CompanyName "Luke Boening" -Copyright "None" -Description "Testing module creation" -ModuleVersion "0.1.1" -path "C:\Code\scripts\LBHelpers.psd1" -RootModule ".\LbHelpers.psm1"  -PowerShellVersion 3.0 -Confirm
   # Test-ModuleManifext -Path c:\code\scripts\LBHelpers.psd1
   
   # Deploy
   # copy-item .\LBHelpers.ps* ..\lboening.github.io\LBHelpers.ps*
   # Git commit
   # Git push

   # Installation
   # Install PSGet: (new-object Net.WebClient).DownloadString("http://psget.net/GetPsGet.ps1") | iex
   # Install-module -ModuleURL http://lboening.github.io/LBHelpers.psm1 -force
   # Import-Module LBHelpers
   # get-command -listimported | ? {$_.ModuleName -like 'LB*'}
#>
Function Get-WebHeaders{
[cmdletbinding()]
[Outputtype([psobject])]
param(
[parameter(Mandatory=$true,ValueFromPipeLine=$true)]
[ValidatePattern('http*')]
[string]$uri,
[parameter(Mandatory=$false,ValueFromPipeLine=$true)]
[string]$keytorec
)
Process {
   try {
    if (!($keytorec)) { $keytorec = (Get-random -SetSeed 1000 -maximum 1000000 -minimum 1) }
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

