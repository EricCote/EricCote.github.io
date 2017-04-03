
$dl= ${env:Temp};

$BuildVersion=[Environment]::OSVersion.Version.Build
$OsVersion=[Environment]::OSVersion.Version.Major 
$isServer= (Gwmi  Win32_OperatingSystem).productType -gt 1

tzutil /s "Eastern Standard Time"

$LanguagePackSource=""

if (-NOT $isserver -and $OsVersion -eq 10 )  #Windows 10 
{        
  if ($BuildVersion -le 15063) #1703 Creator's update
  {
    $LanguagePackSource = "http://download.windowsupdate.com/c/msdownload/update/software/updt/2017/03/lp_8cbb51723015e2557115f1471d696451abae68e1.cab"
  }
  if ($BuildVersion -le 14393) #1607 anniversary update
  { 
    $LanguagePackSource = "http://download.windowsupdate.com/c/msdownload/update/software/updt/2016/07/lp_a63abaa1136ce9bd7a50ae1eaf54f1a58500c1a7.cab"
  }         
  if ($BuildVersion -le 10586) #1511  November update
  {
    $LanguagePackSource = "http://download.windowsupdate.com/d/msdownload/update/software/updt/2015/11/lp_7f834b68030b2e216d529c565305ea0ee8bb2489.cab"
  }
  if ($BuildVersion -le 10240) #RTM version
  {
    $LanguagePackSource = "http://download.windowsupdate.com/d/msdownload/update/software/updt/2015/07/lp_8f6e1d4cb3972edef76030b917020b7ee6cf6582.cab"
  }
}
       
if ($isServer)  #Windows Server
{   
  if ($OsVersion -eq 10) #Windows Server 2016
  {
    $LanguagePackSource = "http://download.windowsupdate.com/c/msdownload/update/software/updt/2016/09/lp_84495308108c7684657c4be5f032341565f47410.cab";
  }
  if ($OsVersion -eq 8)  #Windows Server 2012R2
  {
    $LanguagePackSource = "http://download.windowsupdate.com/c/msdownload/update/software/updt/2014/11/windows8.1-kb3012997-x64-fr-fr-server_f5e444a46e0b557f67a0df7fa28330f594e50ea7.cab";
  }   
} 
    
if (-NOT $isServer -and $OsVersion -eq 8)  #Windows 8.1
{
  $LanguagePackSource = "http://download.windowsupdate.com/c/msdownload/update/software/updt/2014/11/windows8.1-kb3012997-x64-fr-fr-client_134770b2c1e1abaab223d584d0de5f3b4d683697.cab"
}       


if ($LanguagePackSource -ne $null)  
{      
    $filename = Join-Path  $dl  "lang.cab"
  
    $wc = new-object System.Net.WebClient ;
    $wc.DownloadFile($LanguagePackSource,  $filename);
    $wc.Dispose();      

    if ((Get-WindowsPackage -Online -PackagePath ($filename)).PackageState -eq "NotPresent")
    {
      Add-WindowsPackage -Online -PackagePath ($filename)
    }
}


if ($OsVersion -eq 10)
{      
  #Get-WindowsCapability -online
  #add-WindowsCapability -online -name Language.Basic~~~fr-FR~0.0.1.0
  if((Get-WindowsCapability -online -Name Language.Basic~~~fr-CA~0.0.1.0).State -eq "NotPresent")
  {
    add-WindowsCapability -online -name Language.Basic~~~fr-CA~0.0.1.0
    add-WindowsCapability -online -name Language.OCR~~~fr-CA~0.0.1.0
    add-WindowsCapability -online -name Language.Speech~~~fr-CA~0.0.1.0
    setadd-WindowsCapability -online -name Language.TextToSpeech~~~fr-CA~0.0.1.0
  }
  
}


$lang="fr-CA"

$xml = @"
<gs:GlobalizationServices xmlns:gs="urn:longhornGlobalizationUnattend">

  <!--User List-->

  <gs:UserList>
    <gs:User UserID="Current" CopySettingsToDefaultUserAcct="true" CopySettingsToSystemAcct="true" />
  </gs:UserList>

  <!--User Locale - This changes formats to French Canada -->
  <gs:UserLocale>
    <gs:Locale Name="$lang" SetAsCurrent="true"/>
  </gs:UserLocale>

  <gs:MUILanguagePreferences> 
    <gs:MUILanguage Value="$lang" /> 
  </gs:MUILanguagePreferences> 

  <gs:InputPreferences>

    <!--Add English US-->
    <gs:InputLanguageID Action="add" ID="0409:00000409"/>
    <!--Add canada Francais-->
    <gs:InputLanguageID Action="add" ID="0c0c:00001009" Default="true" />
    <!--Remove Canadian MultiLingual Standard -->
    <gs:InputLanguageID Action="remove" ID="0c0c:00011009"/>
    <gs:InputLanguageID Action="remove" ID="1009:00011009"/>
    <!--Remove french legacy-->
    <gs:InputLanguageID Action="remove" ID="0c0c:00000c0c"/>  
    <!-- remove us Canada -->
    <gs:InputLanguageID Action="remove" ID="1009:00000409"/>
    <!-- Remove azerty france  -->
    <gs:InputLanguageID Action="remove" ID="040c:0000040c"/>
  </gs:InputPreferences>

  <!--location - Change location on Location tab to Canada: 39 US:244-->
  <gs:LocationPreferences>
    <gs:GeoID Value="39"/>
  </gs:LocationPreferences>

</gs:GlobalizationServices>
"@


$confPath= Join-Path $dl  "lang.xml"
sc $confPath $xml 
$arg = "/c control.exe intl.cpl,, /f:""$confPath"""
&cmd $arg | out-null 

"waiting 10 seconds..."
start-sleep 10
"resume"


#modify language list for current user
$languages = New-WinUserLanguageList $lang
$languages.Add("en-US")
$languages.Add("fr-CA")
Set-WinUserLanguageList $languages -force

#modify keyboards for French-Canada (remove multilingual)
$languages = Get-WinUserLanguageList
$fr=$languages | Where {$_.LanguageTag -eq "fr-CA"}[0];
$fr.InputMethodTips.clear();
$fr.InputMethodTips.add("0c0c:00001009");
Set-WinUserLanguageList $languages -force

Set-WinUILanguageOverride $lang

#Order the list accordingly 
$frFirst = "`"Languages`"=hex(7):66,00,72,00,2d,00,43,00,41,00,00,00,65,00,6e,00,2d,00,55,00,53,00,00,00"
$enFirst = "`"Languages`"=hex(7):65,00,6e,00,2d,00,55,00,53,00,00,00,66,00,72,00,2d,00,43,00,41,00,00,00"

$langlist=$(if ($lang -eq "fr-CA") {$frFirst} else {$enFirst})

#create a .ini registry string
$regini = @"
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Control Panel\International\User Profile]
$langlist
"ShowAutoCorrection"=dword:00000001
"ShowTextPrediction"=dword:00000001
"ShowCasing"=dword:00000001
"ShowShiftLock"=dword:00000001
"InputMethodOverride"="0c0c:00001009"

[-HKEY_CURRENT_USER\Control Panel\International\User Profile\en-US]

[HKEY_CURRENT_USER\Control Panel\International\User Profile\en-US]
"CachedLanguageName"="@Winlangdb.dll,-1121"
"0409:00000409"=dword:00000001

[-HKEY_CURRENT_USER\Control Panel\International\User Profile\fr-CA]

[HKEY_CURRENT_USER\Control Panel\International\User Profile\fr-CA]
"CachedLanguageName"="@Winlangdb.dll,-1160"
"0C0C:00001009"=dword:00000001

[-HKEY_CURRENT_USER\Control Panel\International\User Profile\fr-FR]

[-HKEY_CURRENT_USER\Control Panel\International\User Profile\en-CA]

[-HKEY_CURRENT_USER\Control Panel\International\User Profile System Backup]

"@

#-----------------------------------------
#modify ini to affect system user
$regSys = $regini.Replace("HKEY_CURRENT_USER","HKEY_USERS\.DEFAULT")

#save it in a temp file and import it using reg.exe
$confPath= Join-Path $dl  "lang.reg"
sc $confPath $regSys 
$params = "/c reg.exe IMPORT `"$confPath`" /reg:64 2> null:"
&cmd $params

#-------------------------------------------
#modify ini to affect default user
$regDef = $regini.Replace("HKEY_CURRENT_USER","HKEY_USERS\def")
#load default user hive
&reg load hku\def "C:\users\default user\NTUSER.DAT"

#save it in a temp file and import it using reg.exe
sc $confPath $regDef 
$params = "/c reg.exe IMPORT `"$confPath`" /reg:64 2> null:"
&cmd $params

#unload default user hive
&reg unload hku\def


