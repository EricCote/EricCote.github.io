


$dl=$env:USERPROFILE + "\downloads\"

$BuildVersion=[Environment]::OSVersion.Version.Build
$OsVersion=[Environment]::OSVersion.Version.Major 
$isServer= (Gwmi  Win32_OperatingSystem).productType -gt 1


function Disable-IEESC
{
    $AdminKey = “HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}”
    $UserKey = “HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}”
    Set-ItemProperty -Path $AdminKey -Name “IsInstalled” -Value 0
    Set-ItemProperty -Path $UserKey -Name “IsInstalled” -Value 0

    Rundll32 iesetup.dll, IEHardenLMSettings
    Rundll32 iesetup.dll, IEHardenUser
    Rundll32 iesetup.dll, IEHardenAdmin
    Rundll32 iesetup.dll, IEHardenMachineNow

    start-sleep 3

    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Internet Explorer\Main" -Name "First Home Page" -Value "https://www.google.ca/"
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Internet Explorer\Main" -Name "Start Page" -Value "https://www.google.ca/"
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Internet Explorer\Main" -Name "Default_Page_URL" -Value "https://www.google.ca/"
}


function Install-MediaFeatures
{
#detect windows version for client
    if (-NOT $isserver)
    {
        $HasMedia='disabled'
        $HasMedia=(Get-WindowsOptionalFeature -online -FeatureName MediaPlayback).State


        #detect if windows media playback is not installed
        if ($HasMedia -ne 'Enabled' -and $OsVersion -eq 10 )
        {
            #creators edition (1703)  
            #anniversary edition  (1607)
            $url="https://download.microsoft.com/download/1/3/F/13F19BF0-17CF-4D0F-938C-41D0489C3FE6/KB3133719-x64.msu.msu"

            
            if ($BuildVersion -lt 14393) #november 2015 update (1511)
            {
               $url="https://download.microsoft.com/download/B/E/3/BE302763-5BFD-4209-9C98-02DF5B2DB452/KB3099229_x64.msu"
            }
           
            if ($BuildVersion -lt 10586) #original (1507)
            {
               $url="http://download.microsoft.com/download/7/F/2/7F2E00A7-F071-41CA-A35B-00DC536D4227/Windows10-KB3010081-x64.msu"
            }
            
            "Downloading Media Pack...."
            #Download Media feature pack
    
            $wc = new-object System.Net.WebClient ;
            $wc.DownloadFile($url, $dl + "Win-Media-Pack.msu");
            $wc.Dispose();    



            "Installing Media Pack..."
            #install Media feature pack
            $wusaArgs =  '"' + $dl + 'Win-Media-Pack.msu" /quiet /norestart'
            Start-Process wusa.exe -ArgumentList $wusaArgs -Wait
        }

    }
    else #is windows server
    {
        Install-WindowsFeature Desktop-Experience
        Set-Service audiosrv -startuptype automatic

    }
}

Install-MediaFeatures