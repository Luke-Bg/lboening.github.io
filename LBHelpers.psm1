Function Add-TypeSysWebExt {
    Add-Type -AssemblyName System.Web.Extension
}

Function Add-ConsoleApp{

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

Function Get-Links {
    $wc = New-object System.Net.Webclient
    $url = "https://gsa.github.io/data/dotgov-domains/2014-12-01-full.csv"
    $resp = $wc.DownloadString($url)
    return $resp
}

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
} Catch [System.Net.WebException] 
{
   $prop = @{'KeyToRec'=$keytorec;'Error'= $true; 'Uri'=$uri; ErrorDetail=$_.Exception.Message; 'DateTimeUTC'= (Get-date -format O);}
   New-Object -TypeName PsObject -property $prop
}
Catch [Exception]{
   $prop = @{'KeyToRec'=$keytorec;'Error'= $true; 'Uri'=$uri; ErrorDetail=$_.Exception.Message; 'DateTimeUTC'= (Get-date -format O);}
   New-Object -TypeName PsObject -property $prop
}  
}
<#
.Synopsis
   Get-WebHeaders
.DESCRIPTION
   Gets header, returns object
.EXAMPLE
   Get-Webheaders -uri 'http://boening.us'
.EXAMPLE
  $getlinks = Get-Links | convertfrom-csv

   Write-Host "Count of returned rows: "$out.Length

  remove-item C:\alldata\Getwc.json -ErrorAction SilentlyContinue
  $count = 0
  $countstart = read-host(('Enter start count between 0 and '+$out.length))
  $countend = read-host(('Enter end count greater than '+$countstart+' and less than '+$out.length))
  $counttotal = $countend - $countstart
  foreach ($link in $getlinks[$countstart..$countend]) {
      Write-Progress -Activity 'Processing' -Status ('{0} {1} of {2}'-f ('Testing link', $count, $counttotal)) -CurrentOperation $link.'Domain Name' -PercentComplete ( $count/$counttotal*100)
      Get-WebHeaders -uri ('http://'+$link.'Domain Name'+'/') -keytorec ('LinkWWW'+$count) | ConvertTo-Json -depth 3 -compress | out-file 'c:\alldata\getwc.json' -Encoding ascii -Append
      Get-WebHeaders -uri ('http://www.'+$link.'Domain Name'+'/') -keytorec ('Link'+$count) | ConvertTo-Json -depth 3 -compress | out-file 'c:\alldata\getwc.json' -Encoding ascii -Append 
      $count ++;
  }
.EXAMPLE
   
   Import into MongoDB
   C:\Program Files\MongoDB 2.6 Standard\bin>mongoimport -d test -c getwc c:\alldata\getwc.json
   C:\Program Files\MongoDB 2.6 Standard\bin>mongo
   > use test
   > db.getwc.findOne()
{
        "_id" : ObjectId("54fc6ca54b026d61d1d20aac"),
        "Error" : false,
        "Uri" : "http://ABINGDON-VA.GOV/",
        "KeyToRec" : "LinkWWW0",
        "DateTimeUTC" : "2015-03-08T10:34:01.9483404-05:00",
        "StatusCode" : 200,
        "Headers" : {
                "Vary" : "Accept-Encoding",
                "Connection" : "close",
                "Content-Length" : "27345",
                "Content-Type" : "text/html",
                "Date" : "Sun, 08 Mar 2015 15:30:12 GMT",
                "ETag" : "\"840058-6ad1-5109eb428c040\"",
                "Last-Modified" : "Fri, 06 Mar 2015 13:31:37 GMT",
                "Server" : "Apache/2.2.14 (Ubuntu)"
        }
}
   
.INPUTS
   [string] uri 
   [string] keytorec (optional key added to output)
.OUTPUTS
   [psobject]
.NOTES
   See details as web site noted.
.NOTES
   New-ModuleManifest -NestedModules ".\Lbhelpers.psm1" -Author "Luke Boening" -CompanyName "Luke Boening" -Copyright "None" -Description "Testing module creation" -ModuleVersion "0.0.3" -path "C:\Code\scripts\LBHelpers.psd1" -RootModule ".\LbHelpers.psm1"  -PowerShellVersion 3.0 -Confirm
#>
}




#New-ModuleManifest -NestedModules ".\Lbhelpers.psm1" -Author "Luke Boening" -CompanyName "Luke Boening" -Copyright "None" -Description "Testing module creation" -ModuleVersion "0.0.2" -path "C:\USERS\LUKE_2\Documents\WindowsPowershell\Modules\LBHelpers\LBHelpers.psd1" -RootModule ".\LbHelpers.psm1" -confirm

