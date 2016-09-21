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


#$sourceSql = "https://download.microsoft.com/download/B/F/2/BF2EDBB8-004D-47F3-AA2B-FEA897591599/SQLServer2016-SSEI-Expr.exe"
#$LocalSqlDownloader= ($dl + "SQLServer2016-SSEI-Expr.exe")

#& ($LocalSqlDownloader) /ConfigurationFile=C:\code\Configuration.ini  /IAcceptSqlServerLicenseTerms /MediaPath=C:\SqlServer2016Setup  /ENU | Out-Null

#$configurationIni= @"
#; Microsoft SQL Server Configuration file  
#[OPTIONS]  
#ACTION="Install"  
#FEATURES=SQL
#INSTANCENAME=SqlExpress  
#"@


#-------------------------------

$dl=$Destination
                     
$sourceSqlLocalDb="https://download.microsoft.com/download/9/0/7/907AD35F-9F9C-43A5-9789-52470555DB90/ENU/SqlLocalDB.msi";
$sourceSqlLocalDb="https://download.microsoft.com/download/E/1/2/E12B3655-D817-49BA-B934-CEB9DAC0BAF3/SqlLocalDB.msi";
$SqlLocalDb= ($dl + "SqlLocalDB.msi")


$sourceOdbc = "https://download.microsoft.com/download/D/5/E/D5EEF288-A277-45C8-855B-8E2CB7E25B96/13.1.811.168/amd64/msodbcsql.msi"
$odbc = ($dl + "msodbcsql.msi")

$sourceCmdLineUtil = "https://download.microsoft.com/download/C/8/8/C88C2E51-8D23-4301-9F4B-64C8E2F163C5/Command%20Line%20Utilities%20MSI%20files/amd64/MsSqlCmdLnUtils.msi"
$CmdLineUtil = ($dl + "MsSqlCmdLnUtils.msi")

Download-File $sourceOdbc $odbc
Download-File $sourceSqlLocalDb $SqlLocalDb
Download-File $sourceCmdLineUtil $CmdLineUtil

Start-Process  "msiexec"  -argumentlist "/passive /i ""$SqlLocalDb"" IACCEPTSQLLOCALDBLICENSETERMS=YES" -Wait 
Start-Process  "msiexec"  -argumentlist "/passive /i ""$odbc"" IACCEPTMSODBCSQLLICENSETERMS=YES" -Wait 
Start-Process  "msiexec"  -argumentlist "/passive /i ""$CmdLineUtil"" IACCEPTMSSQLCMDLNUTILSLICENSETERMS=YES" -Wait 


del $SqlLocalDb
del $odbc
del $CmdLineUtil


if ($Uninstall)
{
    
#& MsiExec.exe /x{33C3E60D-6E22-445C-9B44-E9EEA5C47A01} /passive
#& MsiExec.exe /x{F89605E4-B8A7-46ED-84E7-6AB7F2CFD9BC} /passive
#& MsiExec.exe /x{9097BF1A-13A0-4A4A-A1F8-473E2A669863} /passive
#& MsiExec.exe /I{9097BF1A-13A0-4A4A-A1F8-473E2A669863} /passive 
Uninstall-Program "Microsoft SQL Server 2016 LocalDB "
Uninstall-Program "Microsoft Command Line Utilities 13 for SQL Server" 
Uninstall-Program "Microsoft ODBC Driver 13 for SQL Server"
}

function Uninstall-Program
{
    Param([parameter(Position=1)]
        $Name,
        [switch] $List
    )

    $programs = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | `
    Select-Object DisplayName, UninstallString | `
    ? DisplayName -like $name ;
     

    if ($programs -eq $null) {
        $programs = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | `
        Select-Object DisplayName, UninstallString | `
        ? DisplayName -like $name; 
    }

    if ($programs -eq $null) {
        return "No programs found with the name: " + $name;
    }

    if ($list) {
        return $programs;
    }
    else {
     
        $programs | `
        % -Process {  $unstr=$_.UninstallString.Replace("\Package Cache\","\Package_Cache\" ).Replace("  "," ") ;
                $items = ($unstr.split(" ",2));
                $items[0]= $items[0].Replace("\Package_Cache\","\Package Cache\" ).Replace("`"", "") ;
                $items[1]= $items[1].Replace("/I","/x"); 
                & ($items[0]) $items[1] /passive| Out-Null;
        }

    }
 }




#$SourceOdbc13dot0 = "https://download.microsoft.com/download/1/E/7/1E7B1181-3974-4B29-9A47-CC857B271AA2/English/X64/msodbcsql.msi"
#$sourceCmdLineUtil13dot0 = "https://download.microsoft.com/download/C/8/E/C8ECE442-C29C-4EE4-BD73-872C03D9EB84/ENG_1033/x64/SqlCmdLnUtils.msi"

#"https://download.microsoft.com/download/E/1/2/E12B3655-D817-49BA-B934-CEB9DAC0BAF3/SQLEXPR_x64_ENU.exe" 
#"https://download.microsoft.com/download/E/1/2/E12B3655-D817-49BA-B934-CEB9DAC0BAF3/SQLEXPRADV_x64_ENU.exe"
#"https://download.microsoft.com/download/E/1/2/E12B3655-D817-49BA-B934-CEB9DAC0BAF3/SqlLocalDB.msi"


