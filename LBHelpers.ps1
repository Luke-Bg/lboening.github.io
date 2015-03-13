## Script Name: LBHelpers.ps1
## Purpose: Helper functions
## Record Content Author: luke_2
## Revision: 0.1
## Create date: 03/12/2015 19:40:51
## Last update: 03/12/2015 19:40:51

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
[Parameter(Mandatory=$false,ValueFromPipeLine=$true, ValueFromPipelineByPropertyName=$true,Position=0)]
[string]$url="https://gsa.github.io/data/dotgov-domains/2014-12-01-full.csv",
[switch]$version
)
begin { if($version) { "Get-Links version {0}" -f ("0.1.1") } }
process{
 $wc = New-object System.Net.Webclient
 $wc.DownloadString($url)
}
}


<#
.Synopsis
   Get-WebHeaders sends head request to URI and returns a Powershell custom object. Revision 0.1.3 2015-03-12
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
   # Lifecycle
   # CD .\Tests
   # Edit .\LBHelpers.ps1
   # Invoke-Pester
   # Copy-item .\LBHelpers.ps1 ..\.\lboening.github.io

   # Create manifest
   # New-ModuleManifest -NestedModules ".\Lbhelpers.psm1" -Author "Luke Boening" -CompanyName "Luke Boening" -Copyright "None" -Description "Testing module creation" -ModuleVersion "0.1.1" -path "C:\Code\scripts\LBHelpers.psd1" -RootModule ".\LbHelpers.psm1"  -PowerShellVersion 3.0 -Confirm
   # Test-ModuleManifest -Path c:\code\scripts\LBHelpers.psd1
   
   # Deploy
   # copy-item .\LBHelpers.ps* ..\lboening.github.io
   # Git commit
   # Git push

   # Edit web page and deploy
   # Update README.MD
   # Update INDEX.HTML
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
[switch]$version,
[parameter(Mandatory=$false,ValueFromPipeLine=$true)]
[ValidatePattern('http*')]
[string]$uri="http://ABINGDON-VA.GOV/",
[parameter(Mandatory=$false,ValueFromPipeLine=$true)]
[string]$keytorec
)
begin { if ($version) { "Get-Webheaders version: {0}" -f ("0.1.4") } }
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

# invoke-pester

$hv = @"
## Script Name:
## Purpose: 
## Record Content Author: $($env:USERNAME)
## Revision: 0.1
## Create date: $(get-date)
## Last update: $(get-date)
"@
new-IseSnippet -Title "Set Comment Header" -Description "Set comment header" -text "$hv" -CaretOffset 15 -Author "Luke Boening" -Force