

#https://c2rsetup.officeapps.live.com/c2r/download.aspx?productReleaseID=O365ProPlusRetail&platform=X86&language=en-us&version=O16GA&source=O16OLSO365
#https://c2rsetup.officeapps.live.com/c2r/download.aspx?TaxRegion=IR&version=O16GA&language=fr-FR&Source=O16HUP&platform=x86&ProductreleaseID=ProPlusRetail
#https://c2rsetup.officeapps.live.com/c2r/download.aspx?language=en-US&Source=O16HUP&ProductreleaseID=ProPlusRetail&platform=x86&act=1&TaxRegion=SG&version=O16GA&token=PYMX3-N8CKJ-222J7-RFTKY-HT9X7


 $dl= (Join-Path  $env:USERPROFILE "downloads\")


    $fileSource = "https://c2rsetup.officeapps.live.com/c2r/download.aspx?productReleaseID=O365ProPlusRetail&platform=X86&language=en-us&version=O16GA&source=O16OLSO365"
    $fileDest= ($dl + "office.exe")

    $wc = new-object System.Net.WebClient ;
    $wc.DownloadFile($fileSource, $fileDest) ;
    $wc.Dispose();  

    "install 7zip..."
    & $fileDest | out-null 