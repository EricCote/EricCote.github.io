 

[CmdletBinding()]
Param
    (
    [string] $ScriptPath = "C:\code\EricCote.github.io\scripts\install-oracle.ps1", 
    [string] $Destination = $(Join-Path  $env:USERPROFILE "downloads\"),
    [switch] $Uninstall = $false 
    )
 

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


#    "downloading extras..."
#    $fileSource = "http://7-zip.org/a/7z1604-extra.7z"
#    $fileDest= ($dl + "7z1604-extra.7z")

#    $wc = new-object System.Net.WebClient ;
#    $wc.DownloadFile($fileSource, $fileDest) ;
#    $wc.Dispose();  




   
$fileSource = "https://github.com/EricCote/AfiSetup/raw/master/7z/7zS2con.sfx"
$fileDest= ($dl + "7zS2con.sfx")

if (-not (test-path $fileDest)) {
    "Downloading sfx" 
    $wc = new-object System.Net.WebClient ;
    $wc.DownloadFile($fileSource, $fileDest) ;
    $wc.Dispose();  
}

   # Originally,I used the sfx from extras. I don't anymore. 
   # "unzipping extras"
   # & "C:\Program Files\7-Zip\7z.exe" l $fileDest

if (-not (Test-Path $ScriptPath)){
    "script path not there"
    return "script Path not here!"

}

 
$scriptName = (dir $ScriptPath)[0].Name
$scriptBase = (dir $ScriptPath)[0].BaseName

 $cmd= @"
      @%SystemRoot%\sysnative\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy bypass -f "%~dp0$scriptName"
"@
   
 Set-Content ($dl + "install.cmd") $cmd;

 & "C:\Program Files\7-Zip\7z.exe" a  ($dl + "out.7z")  ($ScriptPath) ($dl + 'install.cmd')  -mx 
 & cmd /c copy /b  ($dl + "7zS2con.sfx") + ($dl + "out.7z")  ($dl + $ScriptBase + ".exe")  




    function Get-BasicAuthCreds {
        param([string]$Username,[string]$Password)
        $AuthString = "{0}:{1}" -f $Username,$Password
        $AuthBytes  = [System.Text.Encoding]::Ascii.GetBytes($AuthString)
        return [Convert]::ToBase64String($AuthBytes)

    }

    $cred=  (Get-Credential -Message 'Enter Github password' -UserName 'eric@coteexpert.com');
    $BasicCreds = Get-BasicAuthCreds -Username "eric@coteexpert.com" -Password $cred.GetNetworkCredential().password
   
    $result = Invoke-RestMethod -Method Post `
     -Uri "https://uploads.github.com/repos/EricCote/EricCote.github.io/releases/4838718/assets?name=$ScriptBase.exe" `
     -Credential  $cred `
     -Headers @{"Authorization"="Basic $BasicCreds"} `
     -InFile ($dl + $ScriptBase + ".exe") `
     -ContentType "application/octet-stream" 




 