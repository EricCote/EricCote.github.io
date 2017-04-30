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


if (-not $Uninstall ) {
$dl=$Destination;


#"http://download.microsoft.com/download/4/4/F/44F2C687-BD92-4331-9D4F-882A5AB0D301/SQLServer2016-SSEI-Dev.exe"
#& ($dl + "SQLServer2016-SSEI-Dev.exe")  -?


$sourceSqlDev = "https://download.microsoft.com/download/E/1/2/E12B3655-D817-49BA-B934-CEB9DAC0BAF3/SQLServer2016-x64-ENU-Dev.iso";
$SqlDev= ($dl + "SQLServer2016SP1-FullSlipstream-x64-ENU-DEV.iso")

if (-Not (Test-Path $SqlDev)) {
   Download-File $sourceSqlDev $SqlDev
}


$drv=((Mount-DiskImage $SqlDev -PassThru  | Get-Volume).DriveLetter + ':\')


if ($true)
{

$user = $(whoami)

& ($drv + 'setup.exe') /qs `
                       /Action=install `
                       /IAcceptSqlServerLicenseTerms `
                       /IACCEPTROPENLICENSETERMS `
                       /Features=sql,PolyBase,AdvancedAnalytics,AS,RS,DQC,IS,MDS,SQL_SHARED_MR,tools `
                       /UpdateEnabled=1 `
                       /UpdateSource=MU `
                       /InstanceName=MSSQLSERVER `
                       /SqlSvcAccount="NT SERVICE\MSSQLSERVER" `
                       /SqlSysAdminAccounts="$user" `
                       /AgtSvcAccount="NT SERVICE\SQLSERVERAGENT" `
                       /SqlSvcInstantFileInit="True" | Out-Null

}


#--------------------------------------------------------


$sourcessms="http://go.microsoft.com/fwlink/?LinkID=824938"
$ssms= ($dl + "SSMS-setup-enu.exe")

if (-Not (Test-Path $ssms)) {
   Download-File $sourcessms $ssms
}

& ($ssms) /install /passive | Out-Null


#--------------------------------------------------------


$sourceSsdt="https://go.microsoft.com/fwlink/?LinkID=824659&clcid=0x409"
$ssdt= ($dl + "SSDTSetup.exe")

if (-Not (Test-Path $ssdt)) {
   Download-File $sourceSsdt $ssdt
}

& ($ssdt) INSTALLALL=1 /passive /promptrestart | Out-Null

}

if ($Uninstall)
{


& "$env:programFiles\Microsoft SQL Server\130\Setup Bootstrap\SQLServer2016\setup.exe" /qs `
                       /Action=uninstall `
                       /IAcceptSqlServerLicenseTerms `
                       /Features=SQL,AS,RS,IS,DQC,MDS,SQL_SHARED_MR,Tools `
                       /InstanceName=MSSQLSERVER | Out-Null

$ssms= "$env:Temp\SSMS-setup-enu.exe"
& $ssms /uninstall /passive | Out-Null

$ssdt= "$env:Temp\SSDTSetup.exe"
& $ssdt /uninstall /passive | Out-Null



uninstall-program "*Data tools for*" 

uninstall-program "*Data tools*" 
uninstall-program "*ssdt*"

uninstall-program "Microsoft SQL Server Management Studio*" -list


uninstall-program "Microsoft Visual Studio Tools for Applications 2015 Language Support"  
uninstall-program "Microsoft Visual Studio Tools for Applications 2015"  


uninstall-program "Microsoft Visual Studio 2015 Shell (Integrated)"
uninstall-program "Microsoft Visual Studio 2015 Shell (Isolated)" 

uninstall-program "*help viewer 2.2*"
uninstall-program "*help viewer 1.1*"



uninstall-program "*sql server*" 
uninstall-program "*sql server*"  #64 bit
uninstall-program "Microsoft Visual C++*Redistributable*"
uninstall-program "Microsoft Visual C++*Redistributable*" 


rd "C:\Program Files\Microsoft SQL Server" -recurse -force
rd "C:\Program Files (x86)\Microsoft SQL Server" -recurse -force
rd "C:\Program Files (x86)\Microsoft Visual Studio 14.0" -recurse -force

 }

#Start-Process  "msiexec"  -argumentlist "/passive /i ""$SqlLocalDb"" IACCEPTSQLLOCALDBLICENSETERMS=YES" -Wait 
#Start-Process  "msiexec"  -argumentlist "/passive /i ""$odbc"" IACCEPTMSODBCSQLLICENSETERMS=YES" -Wait 
#Start-Process  "msiexec"  -argumentlist "/passive /i ""$CmdLineUtil"" IACCEPTMSSQLCMDLNUTILSLICENSETERMS=YES" -Wait 


