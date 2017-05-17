 

[CmdletBinding()]
Param
    (
    [string] $ScriptPath = "C:\code2\EricCote.github.io\scripts", 
    [string] $Destination = $(Join-Path  $env:USERPROFILE "downloads\"),
    [switch] $Uninstall = $false 
    )
 

function Get-BasicAuthCreds {
        param([string]$Username,[string]$Password)
        $AuthString = "{0}:{1}" -f $Username,$Password
        $AuthBytes  = [System.Text.Encoding]::Ascii.GetBytes($AuthString)
        return [Convert]::ToBase64String($AuthBytes)
}


$dl=$Destination

if(-not (test-path "C:\Program Files\7-Zip")) {

    "downloading 7zip..."
    $fileSource = "http://7-zip.org/a/7z1604-x64.exe"
    $fileDest= ($dl + "7zip1604.exe")

    $wc = new-object System.Net.WebClient ;
    $wc.DownloadFile($fileSource, $fileDest) ;
    $wc.Dispose();  

    "install 7zip..."
    & $fileDest /S /D="c:\program files\7-Zip" | out-null 

}

   # Originally,I used the sfx from extras. I don't anymore. 
   # "unzipping extras"
#    "downloading extras..."
#    $fileSource = "http://7-zip.org/a/7z1604-extra.7z"
#    $fileDest= ($dl + "7z1604-extra.7z")

#    $wc = new-object System.Net.WebClient ;
#    $wc.DownloadFile($fileSource, $fileDest) ;
#    $wc.Dispose();  
# & "C:\Program Files\7-Zip\7z.exe" l $fileDest
   
$fileSource = "https://github.com/EricCote/AfiSetup/raw/master/7z/7zS2con.sfx"
$fileDest= ($dl + "7zS2con.sfx")

if (-not (test-path $fileDest)) {
    "Downloading sfx" 
    $wc = new-object System.Net.WebClient ;
    $wc.DownloadFile($fileSource, $fileDest) ;
    $wc.Dispose();  
}



if (-not (Test-Path $ScriptPath)){
    "script path not there"
    return "script Path not here!"

}

$cred=  (Get-Credential -Message 'Enter Github password' -UserName 'eric@coteexpert.com');
$BasicCreds = Get-BasicAuthCreds -Username "eric@coteexpert.com" -Password $cred.GetNetworkCredential().password
   
$scripts = dir ($ScriptPath + "\*.ps1")

foreach ($script in $scripts)
{ 
    $scriptName = $script.Name
    $scriptBase = $script.BaseName

    $cmd= @"
      @%SystemRoot%\sysnative\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy bypass -f "%~dp0$scriptName"
"@

     Set-Content ($dl + "install.cmd") $cmd;
    

     & "C:\Program Files\7-Zip\7z.exe" a  ($dl + "out.7z")  ($Script.FullName) ($dl + 'install.cmd')  -mx -bso0
     & cmd /c copy /b  ($dl + "7zS2con.sfx") + ($dl + "out.7z")  ($dl + $ScriptBase + ".exe")  | Out-Null

     del  ($dl + "out.7z")
    

     #https://api.github.com/repos/EricCote/EricCote.github.io/releases

     $result = Invoke-RestMethod -Method Post `
     -Uri "https://uploads.github.com/repos/EricCote/EricCote.github.io/releases/4838718/assets?name=$ScriptBase.exe" `
     -Credential  $cred `
     -Headers @{"Authorization"="Basic $BasicCreds"} `
     -InFile ($dl + $ScriptBase + ".exe") `
     -ContentType "application/octet-stream" 
}




  





 