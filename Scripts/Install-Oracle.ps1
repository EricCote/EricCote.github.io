
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
$sourceOracle = "https://github.com/EricCote/EricCote.github.io/releases/download/v1.0/OracleXE112_Win64.zip";
$sourceOracleDev="http://download.oracle.com/otn/java/sqldeveloper/sqldeveloper-4.1.5.21.78-x64.zip"
$sourceOracleExamples="http://download.oracle.com/otn/nt/oracle11g/112010/win64_11gR2_examples.zip"
$Sourceodt="https://github.com/EricCote/EricCote.github.io/releases/download/v1.0/ODTforVS2015_121025.exe"


$oracleZip= ($dl + "OracleXE112_Win64.zip")
$oracleOdt=($dl + "ODTforVS2015_121025.exe")
$oracleDevZip = ($dl + "sqldeveloper-4.1.5.21.78-x64.zip" )
$oracleExemplesZip=($dl +"win64_11gR2_examples.zip")


if (-not $Uninstall ) {

    "Downloading...";
    if (-Not (Test-Path $oracleZip)) {
       Download-File $sourceOracle $oracleZip
    }
    "50% downloaded";
    if (-Not (Test-Path $oracleodt)) {
       Download-File $SourceoDT $oracleodt
    }
    "Downloaded";

  



    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($oracleZip, $dl )

    "Installing..."                                            
    & ($dl + "DISK1\setup.exe")  /s /f1"$dl\disk1\response\OracleXE-Install.iss" /f2"$dl\setup.log" | out-null
    "Installed"
    # & ("C:\oraclexe\examples\setup.exe") /?
    "oracle installed"
    
    "ALTER USER HR IDENTIFIED BY afi12345 ACCOUNT UNLOCK;" | & ("C:\oraclexe\app\oracle\product\11.2.0\server\bin\sqlplus.exe")   system/oraclexe

    "activated User hr"

    & $oracleOdt  /v"/qn /V/passive" | Out-Null

$tns = @"
XE =
   (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = XE) 
    )
  )
"@

$tns | Set-Content  ("C:\Program Files (x86)\Oracle Developer Tools for VS2015\network\admin\tnsnames.ora")


}
else
{
 & ($dl + "DISK1\setup.exe")  /s /f1"$dl\disk1\response\OracleXE-remove.iss" /f2"$dl\setup.log" | out-null
 "uninstalled"
 

 rd "c:\oraclexe\" -Recurse
}

