<#
.SYNOPSIS
  Get-Version
.DESCRIPTION
  Use to get version from this program. Version is hardcoded.
.EXAMPLE
  Get-Version
.OUTPUTTYPE
[STRING]
 # 
#>
function Get-Version () {
[cmdletbinding()]
param()
process{
   return "0.1.10"
}
}

<#
.SYNOPSIS
Clears all log files
.DESCRIPTION
Run and clear all log files
.EXAMPLE
Clear-AllLogFiles
 # 
#>
Function Clear-AllLogFiles {
[cmdletbinding()]
param()
process {
  try {
    wevtutil el | foreach-object {wevtutil cl "$_"}
    return $true
  } 
  Catch [Exception] 
  {
   $prop = @{'Module'=$MyInvocation.MyCommand.ModuleName; 'Error'= $true;  ErrorDetail=$_.Exception.Message; 'DateTimeUTC'= (Get-date -format O);}
   New-Object -TypeName PsObject -property $prop
  }
}
}


<#
.SYNOPSIS
  Get-RestSharp uses PSGET to install
.DESCRIPTION
  Use to download RestSharp
.EXAMPLE
  Get-RestSharp
 # 
#>
function Get-RestSharp {
[cmdletbinding()]
param()
process{
    install-module -NuGetPackageId RestSharp
}
}

<#
.SYNOPSIS
  Test-RestSharp import RestSharp and connects to default site
.DESCRIPTION
  Use to test RestSharp
.EXAMPLE
  Test-RestSharp
 # 
#>
function Test-RestSharp {
[cmdletbinding()]
param()
process {
   Import-Module RestSharp
   Add-Type -AssemblyName RestSharp
   $client = new-object RestSharp.RestClient
   $client.BaseUrl = new-Object System.uri("http://data.consumerfinance.gov/api/views.json")
   $request = new-Object RestSharp.RestRequest
   $client.Execute($request)
}
}

<#
.SYNOPSIS
  New-CommentSnippet
.DESCRIPTION
  Use to add new comment snippet
.EXAMPLE
  New-CommentSnippet
 # 
#>
Function New-CommentSnippet{
[cmdletbinding()]
param()
process{
$hv = @"
## Script Name: $($MyInvocation.mycommand.modulename)
## Purpose: Various Modules
## Record Content Author: $($env:USERNAME)
## Revision: $(Get-version)
## Create date: $(get-date)
## Last update: $(get-date)
"@
new-IseSnippet -Title "Set Comment Header" -Description "Set comment header" -text "$hv" -CaretOffset 15 -Author "Luke Boening" -Force
}
}

<#
.SYNOPSIS
  Add-ConsoleApp
.DESCRIPTION
  Use to generate HELLOWORLD.EXE
.EXAMPLE
  Add-ConsoleApp
 # 
#>
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

<#
.SYNOPSIS
  Get-Links
.DESCRIPTION
  Use to Get-Links.
.EXAMPLE
  Get-Links
.EXAMPLE
  $resp = Get-Links -url "http://urlwith.csv.values.com/file.csv"
.OUTPUTTYPE
[PSCUSTOMOBJECT]
 # 
#>
Function Get-Links {
[cmdletbinding()]
param(
[Parameter(Mandatory=$false,ValueFromPipeLine=$true, ValueFromPipelineByPropertyName=$true,Position=0)]
[string]$url="https://gsa.github.io/data/dotgov-domains/2014-12-01-full.csv",
[switch]$version
)
begin { if($version) { "Get-Links version {0}" -f (Get-Build) } }
process{
 $wc = New-object System.Net.Webclient
 $wc.DownloadString($url)
}
}


<#
.Synopsis
   Get-WebHeaders sends head request to URI and returns a Powershell custom object.
.DESCRIPTION
   Gets header, returns object with following properties
     KeyToRec: Optional key, used for JSON
     Uri: Uri that was called
     Headers: The header response
     StatusCode: Statuscode returned
     DateTimeUTC: The datetime the command was run
     You can use these commands for further processing
	 Example output:
       Error       : False
       Uri         : http://ABINGDON-VA.GOV/
       KeyToRec    : 151558
       DateTimeUTC : 2015-03-12T19:42:47.3972921-05:00
       StatusCode  : 200
       Headers     : {[Vary, Accept-Encoding], [Connection, close], [Content-Length, 26937], [Content-Type, text/html]...}
		
.EXAMPLE
   Get-Webheaders -uri 'http://ABINGDON-VA.GOV/'
.EXAMPLE
   Get-WebHeaders -uri 'http://ABINGDON-VA.GOV/' -KeyToRec 'Abingdon-va' | FL
.EXAMPLE
   # Examples
   $links = Get-Links -url "https://gsa.github.io/data/dotgov-domains/2014-12-01-full.csv" | Convertfrom-csv
   $links.'Domain Name'[0..5] | % {'http://'+$_.'Domain Name'} | get-webheaders | convertto-json -depth 2 -compress | out-file c:\alldata\responses.json -encoding ascii
.EXAMPLE
   # Output 
   Get-Webheaders -uri 'http://ABINGDON-VA.GOV/'
        Error       : False
        Uri         : http://ABINGDON-VA.GOV/
        KeyToRec    : 151558
        DateTimeUTC : 2015-03-12T19:42:47.3972921-05:00
        StatusCode  : 200
        Headers     : {[Vary, Accept-Encoding], [Connection, close], [Content-Length, 26937], [Content-Type, text/html]...}
.PARAMETER  Uri
   Enter the URI to the resource
   Type: string
   Purpose: invokes the uri
   Validation: checks for http or https
   Example(s): http://github.io, http://VA.GOV
.PARAMETER KeyToRec
   Enter an optional key to the record
   Type: string
   Purpose: Used for JSON output
   Default: random number 
   Validation: none
   Examples(s): KEY1234, WEBHEAD01OF20, 151558
.PARAMETER Demo
   Enter switch for demo mode
.INPUTS
   [string] URI. Validated as HTTP.
   [string] KeyToRec (optional key added to output)
.OUTPUTS
   [PSCUSTOMOBJECT] with keys and values representing the headers from the web response
.LINK
   http://lboening.github.io/LBHelpers.psm1
   https://msdn.microsoft.com/en-us/library/hh847834.aspx   
.NOTES
 ---------
 Lifecycle
 ---------
   # Set-location c:\code\scripts\Tests
   # Edit .\LBHelpers.ps1
   # Edit .\LBHelpers.Tests.ps1
   # Run LbHelpers.Tests.Ps1 (just hit F5)
   # PS C:\code\Scripts\tests> copy-item -path .\LBHelpers.ps1 -Destination .\LBHelpers.psm1
   # Ps c:\code\Scripts\tests> Invoke-Pester
   # Copy-item .\LBHelpers.ps* ..\..\lboening.github.io

 Create manifest
 -----------
   # New-ModuleManifest -NestedModules ".\Lbhelpers.psm1" -Author "Luke Boening" -CompanyName "Luke Boening" -Copyright "None" -Description "Testing module creation" -ModuleVersion "0.1.10" -path "C:\Code\scripts\tests\LBHelpers.psd1" -RootModule ".\LbHelpers.psm1"  -PowerShellVersion 3.0 -Confirm
   # Test-ModuleManifest -Path c:\code\scripts\Tests\LBHelpers.psd1
   # PS C:\code\Scripts\tests> copy-item .\LBHelpers.ps* -Destination ..\..\lboening.github.io

 Deploy
 ------
   # PS C:\code\Scripts\tests> copy-item .\LBHelpers.ps* -Destination ..\..\lboening.github.io
   # Edit README.MD
   # Edit INDEX.HTML
   # Git commit
   # Git push

 Installation
 ------------
   # Install PSGet: (new-object Net.WebClient).DownloadString("http://psget.net/GetPsGet.ps1") | iex
   # Install-module -ModuleURL http://lboening.github.io/LBHelpers.psm1 -force
   # Import-Module LBHelpers
   # get-command -listimported | ? {$_.ModuleName -like 'LB*'}
#>
Function Get-WebHeaders{
[cmdletbinding()]
[Outputtype([psobject])]
param(
[switch]$version,
[parameter(Mandatory=$false,ValueFromPipeLine=$true)]
[ValidatePattern('http*')]
[string]$uri="http://ABINGDON-VA.GOV/",
[parameter(Mandatory=$false,ValueFromPipeLine=$true)]
[string]$keytorec
)
begin { if ($version) { "Get-Webheaders version: {0}" -f (get-build) } }
Process {
   try {
     if (!($keytorec)) { $keytorec = (Get-random -SetSeed 1000 -maximum 1000000 -minimum 1) }
       $resp = Invoke-WebRequest -uri $uri -method head -UseBasicParsing -DisableKeepAlive -TimeoutSec 4 -UserAgent "Powershell 4.0" -MaximumRedirection 2 
       $prop = @{'KeyToRec'=$keytorec;'Uri'=$uri; 'Headers'=$resp.headers; 'StatusCode'=$resp.StatusCode; 'Error'=$false; 'DateTimeUTC'= (Get-date -format O);}
       New-Object -TypeName PSObject -Property $prop
    } 
   catch [Exception]
    {
       $prop = @{'KeyToRec'=$keytorec;'Error'= $true; 'Uri'=$uri; ErrorDetail=$_.Exception.Message; 'DateTimeUTC'= (Get-date -format O);}
       New-Object -TypeName PsObject -property $prop
    }  
    }
}


function get-stats {
Get-WinEvent -FilterHashtable @{LogName="Application";StartTime=((get-date).AddDays(-1));} | group-object -property id, ProviderName -NoElement | sort-object -property count, id | select-object -property count, values | % {"{0,5} | {1,5}  | {2,-30}" -f ($_.count, $_.values[0], $_.Values[1])} 
}
