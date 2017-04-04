$tempFolder= ${env:Temp};

$BuildVersion=[Environment]::OSVersion.Version.Build
$OsVersion=[Environment]::OSVersion.Version.Major 
$isServer= (Gwmi  Win32_OperatingSystem).productType -gt 1


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
    $filename = Join-Path  $tempFolder  "lang.cab"
  
    $wc = new-object System.Net.WebClient ;
    $wc.DownloadFile($LanguagePackSource,  $filename);
    $wc.Dispose();      

    if ((Get-WindowsPackage -Online -PackagePath ($filename)).PackageState -eq "NotPresent")
    {
      Add-WindowsPackage -Online -PackagePath ($filename)
    }
}



$lang="fr-CA";

tzutil /s "Eastern Standard Time"

function Add-OptionalFeature ($Name)
{
  if((Get-WindowsCapability -online -Name $Name).State -eq "NotPresent")
  {
    Add-WindowsCapability -online -Name $Name
  }
}

if ($OsVersion -eq 10)
{      
  Add-OptionalFeature -Name "Language.Basic~~~fr-CA~0.0.1.0"
  Add-OptionalFeature -Name "Language.Basic~~~fr-FR~0.0.1.0"
  Add-OptionalFeature -Name "Language.Handwriting~~~fr-FR~0.0.1.0"
  Add-OptionalFeature -Name "Language.OCR~~~fr-CA~0.0.1.0"
  Add-OptionalFeature -Name "Language.Speech~~~fr-CA~0.0.1.0"
  Add-OptionalFeature -Name "Language.Speech~~~en-CA~0.0.1.0"
  Add-OptionalFeature -Name "Language.TextToSpeech~~~fr-CA~0.0.1.0"
  Add-OptionalFeature -Name "Language.TextToSpeech~~~EN-CA~0.0.1.0"

}



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


$confPath= Join-Path $tempFolder  "lang.xml"
sc $confPath $xml 
$arg = "/c control.exe intl.cpl,, /f:`"$confPath`""
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

#Get-WinUILanguageOverride
Set-WinUILanguageOverride $lang

#Order the list accordingly 
$frFirst = "hex(7):66,00,72,00,2d,00,43,00,41,00,00,00,65,00,6e,00,2d,00,55,00,53,00,00,00"
$enFirst = "hex(7):65,00,6e,00,2d,00,55,00,53,00,00,00,66,00,72,00,2d,00,43,00,41,00,00,00"

$langlist=$(if ($lang -eq "fr-CA") {$frFirst} else {$enFirst})

#create a .ini registry string
$regini = @"
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Control Panel\International]
"Locale"="00000C0C"
"LocaleName"="fr-CA"
"s1159"=""
"s2359"=""
"sCountry"="Canada"
"sCurrency"="$"
"sDate"="-"
"sDecimal"=","
"sGrouping"="3;0"
"sLanguage"="FRC"
"sList"=";"
"sLongDate"="d MMMM yyyy"
"sMonDecimalSep"=","
"sMonGrouping"="3;0"
"sMonThousandSep"=" "
"sNativeDigits"="0123456789"
"sNegativeSign"="-"
"sPositiveSign"=""
"sShortDate"="yyyy-MM-dd"
"sThousand"=" "
"sTime"=":"
"sTimeFormat"="HH:mm:ss"
"sShortTime"="HH:mm"
"sYearMonth"="MMMM, yyyy"
"iCalendarType"="1"
"iCountry"="1"
"iCurrDigits"="2"
"iCurrency"="3"
"iDate"="2"
"iDigits"="2"
"NumShape"="1"
"iFirstDayOfWeek"="6"
"iFirstWeekOfYear"="0"
"iLZero"="1"
"iMeasure"="0"
"iNegCurr"="15"
"iNegNumber"="1"
"iPaperSize"="1"
"iTime"="1"
"iTimePrefix"="0"
"iTLZero"="1"

[HKEY_CURRENT_USER\Control Panel\International\User Profile]
"Languages"=$langlist
"ShowAutoCorrection"=dword:00000001
"ShowTextPrediction"=dword:00000001
"ShowCasing"=dword:00000001
"ShowShiftLock"=dword:00000001
"InputMethodOverride"="0c0c:00001009"
"WindowsOverride"="$lang"

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

[HKEY_CURRENT_USER\Control Panel\Desktop]
"PreferredUILanguages"=$langlist
"PreferredUILanguagesPending"=$langlist

[HKEY_CURRENT_USER\Control Panel\Desktop\MuiCached]
"MachinePreferredUILanguages"=$langlist

[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\MUI\Settings]
"PreferredUILanguages"=$langlist

"@

#-----------------------------------------

function  ModifyRegistry($Regini, $profileName)
{
    $profileName= "HKEY_USERS\" + $profileName
    #modify ini to affect system user
    $regSys = $regini.Replace("HKEY_CURRENT_USER",$profileName)

    #save it in a temp file and import it using reg.exe
    $confPath= Join-Path $tempFolder "lang.reg"
    sc $confPath $regSys 
    $params = "/c reg.exe IMPORT `"$confPath`" /reg:64 2> null:"
    &cmd $params
}

ModifyRegistry  -Regini $regini -profilename ".DEFAULT"
ModifyRegistry  -Regini $regini -profilename "S-1-5-19"
ModifyRegistry  -Regini $regini -profilename "S-1-5-20"

&reg load hku\def "C:\users\default user\NTUSER.DAT"
ModifyRegistry  -Regini $regini -profilename "def"
&reg unload hku\def


