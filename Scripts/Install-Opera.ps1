[CmdletBinding()]
Param
    ( 
    [string] $Destination = $(Join-Path  $env:USERPROFILE "downloads\"),
    [switch] $Uninstall = $false 
    )

$dl=$Destination;

if (-not $Uninstall)
{

$operaLink = "http://dl.opera.com/download/get/?id=40225&autoupdate=1&ni=1&stream=stable&utm_source=(direct)_via_opera_com&utm_campaign=(direct)_via_opera_com&utm_medium=doc&niuid=83e71787-9541-4660-ada2-5833a366d8bb"

$wc = new-object System.Net.WebClient ;
$wc.DownloadFile($operaLink, $dl + "Opera_setup.exe");
$wc.Dispose();  
"Downloaded Opera"

& ($dl + "Opera_setup.exe") /install /runimmediately  /language=en-US /launchopera=0 /setdefaultbrowser=0 /startmenushortcut=1 /desktopshortcut=0 /quicklaunchshortcut=0 /pintotaskbar=0 /allusers=1 | Out-Null

$prefs=@'
{
    "browser": { 
        "check_default_browser": false 
    }, 
    "startpage": {
        "should_prompt_for_default_browser": false
    },
    "themes": {
       "selected_id": "bundled/feathers"
    }
}
'@


#Set-Content "C:\Program Files (x86)\Opera\41.0.2353.46\master_preferences" $prefs
#Set-Content "C:\Program Files (x86)\Opera\41.0.2353.46\preferences" $prefs
#Set-Content (Join-Path Env:APPDATA  "\Opera Software\Opera Stable\preferences") $prefs
#md "c:\users\default\appData\roaming\Opera Software\Opera Stable\" -ErrorAction Ignore
#Set-Content "c:\users\default\appData\roaming\Opera Software\Opera Stable\preferences" $prefs

}

else { # uninstall

    & "c:\Program Files (x86)\Opera\launcher.exe" /silent /uninstall | Out-Null
    rd  (Join-Path  $env:APPDATA "\..\local\Opera Software") -Recurse -Force
    rd  (Join-Path  $env:APPDATA "\Opera Software") -Recurse -Force -ErrorAction Ignore
    #rd "c:\users\default\appData\roaming\Opera Software" -Recurse -Force
    Start-Sleep -Seconds 3
    rd "c:\Program Files (x86)\Opera" -Recurse -Force

}

 