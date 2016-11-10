 
 
$dl=$(Join-Path  $env:USERPROFILE "downloads\");

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



    "Downloading sfx"
   
    $fileSource = "https://github.com/EricCote/AfiSetup/raw/master/7z/7zS2con.sfx"
    $fileDest= ($dl + "7zS2con.sfx")

    if (-not (test-path $fileDest)) { 
    $wc = new-object System.Net.WebClient ;
    $wc.DownloadFile($fileSource, $fileDest) ;
    $wc.Dispose();  
    }
   # "unzipping extras"
   # & "C:\Program Files\7-Zip\7z.exe" l $fileDest


    $psFileName="20480.ps1"

    $cmd= @"
      @%SystemRoot%\sysnative\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy bypass -f "%~dp0$psFileName"
"@
   
 Set-Content ($dl + "install.cmd") $cmd

 & "C:\Program Files\7-Zip\7z.exe" a  ($dl + "out.7z")  ($dl + '20480.ps1') ($dl + 'install.cmd')  -mx 
 & cmd /c copy /b  ($dl + "7zS2con.sfx") + ($dl + "out.7z")  ($dl + "setup.exe")  
