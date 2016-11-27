
[CmdletBinding()]
Param
    ( 
    [string]$Destination = $(Join-Path  $env:USERPROFILE "downloads\"),
    [switch] $Uninstall = $false 
    )



function Download-File
{
    Param([parameter(Position=1)]
      $Source, 
      [parameter(Position=2)]
      $Destination
    )

    $wc = new-object System.Net.WebClient
    $wc.DownloadFile($Source,$Destination)
    $wc.Dispose()
}

$dl=$Destination;

$sourceOracle = "http://download.oracle.com/otn/nt/oracle11g/xe/OracleXE112_Win64.zip"
$sourceOracle = "http://downloads.nuronerp.com/Installation/SERVER%20INSTALLATION/OracleXE112_Win64.zip";
$sourceOracleDev="http://download.oracle.com/otn/java/sqldeveloper/sqldeveloper-4.1.5.21.78-x64.zip"
$sourceOracleExamples="http://download.oracle.com/otn/nt/oracle11g/112010/win64_11gR2_examples.zip"

$oracleZip= ($dl + "OracleXE112_Win64.zip")
$oracleDevZip = ($dl + "sqldeveloper-4.1.5.21.78-x64.zip" )
$oracleExemplesZip=($dl +"win64_11gR2_examples.zip")


if (-not $Uninstall ) {


if (-Not (Test-Path $oracleZip)) {
   Download-File $sourceOracle $oracleZip
}

if (-Not (Test-Path $oracleDevZip)) {
   Download-File $sourceOracleDev $oracleDevZip
}

#if (-Not (Test-Path $oracleExemplesZip)) {
#   Download-File $sourceOracleExamples $oracleExemplesZip
#}



Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($oracleZip, $dl )
[System.IO.Compression.ZipFile]::ExtractToDirectory($oracleDevZip, "c:\oraclexe\" )
#[System.IO.Compression.ZipFile]::ExtractToDirectory($oracleExemplesZip, "c:\oraclexe\" )
                                                
 & ($dl + "DISK1\setup.exe")  /s /f1"$dl\disk1\response\OracleXE-Install.iss" /f2"$dl\setup.log" | out-null

# & ("C:\oraclexe\examples\setup.exe") /?
}
else
{
 & ($dl + "DISK1\setup.exe")  /s /f1"$dl\disk1\response\OracleXE-remove.iss" /f2"$dl\setup.log" | out-null
 "uninstalled"
 

 rd "c:\oraclexe\" -Recurse
}

