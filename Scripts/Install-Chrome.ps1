([bool] $Uninstall = $false)

$dl =  Join-Path  $env:USERPROFILE "downloads\"
$env:APPDATA


$master_prefs = @'
{ 
 "browser": {
   "default_browser_infobar_last_declined":"66666666666666",
   "should_reset_check_default_browser": false,
   "default_browser_setting_enabled": false
             },
 "first_run_tabs": ["about:newtab"],
 "homepage" : "http://www.afiexpertise.com", 
 "homepage_is_newtabpage" : false, 
 "sync_promo" : {"show_on_first_run_allowed": false,  "user_skipped": true}, 
 "distribution" : { 
   "create_all_shortcuts" : false, 
   "make_chrome_default" : false, 
   "make_chrome_default_for_user": false, 
   "suppress_first_run_default_browser_prompt": true,
   "suppress_first_run_bubble": true, 
   "do_not_create_desktop_shortcut":true,
   "do_not_create_quick_launch_shortcut":true,
   "do_not_create_taskbar_shortcut":true,
   "do_not_create_any_shortcuts" : true,
   "welcome_page_on_os_upgrade_enabled": false,
   "msi":true,
   "system_level":true,
   "verbose_logging":true,
   "allow_downgrade":false
 }
}
'@

Set-Content (Join-Path $dl "master_preferences.json") $master_prefs



$wc = New-Object System.Net.WebClient;
$chromelink = "http://dl.google.com/edgedl/chrome/install/GoogleChromeStandaloneEnterprise64.msi" ; 
$wc.DownloadFile($chromelink, $dl + "GoogleChrome_setup64.msi");
$wc.Dispose(); 

& msiexec /i ($dl + "GoogleChrome_setup64.msi")   /passive | Out-Null;

copy (Join-Path $dl "master_preferences.json") "c:\program files (x86)\Google\Chrome\Application\master_preferences";

del "C:\Users\Public\Desktop\*chrome*.lnk"

if ($Uninstall) {
  & MsiExec.exe /X  ($dl + "GoogleChrome_setup64.msi")  /passive | Out-Null
  
  Start-Sleep -Seconds 3

#  rd (Join-Path  $env:APPDATA "\google")  -recurse -force
#  rd "c:\program files\Google"              -recurse -force
  rd (Join-Path  $env:APPDATA "\..\local\google")  -recurse -force
  rd "c:\program files (x86)\Google"        -recurse -force

}


#"msi_product_id":"16C1182D-6E13-3989-A4BC-360B106D5C4E","allow_downgrade":false
# // "skip_first_run_ui" : true, 
#   // "show_welcome_page": false, 