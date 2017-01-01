#Set-ExecutionPolicy -scope process  bypass -force


$dl=$env:USERPROFILE + "\downloads\"

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

function List-Programs
{  Param([parameter(Position=1)]
        $Name)
  
  if($name -eq $null) { $name="*"}
   
  $programs = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | `
    Select-Object DisplayName, UninstallString | `
    ? DisplayName -like $name ;
  $programs2 = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | `
        Select-Object DisplayName, UninstallString | `
        ? DisplayName -like $name; 

  return $programs+$programs2
   
        
}

function Uninstall-Program
{
    Param([parameter(Position=1)]
        $Name,
        [switch] $List,
        [switch] $SkipDependencies
    )

    $programs = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | `
    Select-Object DisplayName, UninstallString | `
    ? DisplayName -like $name ;
     

    if ($programs -eq $null) {
        $programs = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | `
        Select-Object DisplayName, UninstallString | `
        ? DisplayName -like $name; 
    }
    
    $skip= if($SkipDependencies) {"IGNOREDEPENDENCIES=ALL"} else {""};

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
                & ($items[0]) $items[1] /passive $skip| Out-Null;
        }

    }
 }

$WebSource = "http://download.microsoft.com/download/1/2/d/12d1feae-15a0-4d32-8643-4f38915eb07c/vs_enterprise.exe";
$destination = ($dl +  "vs_enterprise.exe");

$WebSource = "http://download.microsoft.com/download/c/0/4/c04e3eff-c8e5-486c-af04-b85abb693cc7/vs_professional.exe"
$destination = ($dl +  "vs_professional.exe")

$WebSource = "http://download.microsoft.com/download/e/4/c/e4c393a9-8fff-441b-ad3a-3f4040317a1f/vs_community.exe";
$destination = ($dl +  "vs_community.exe");

Download-File $WebSource $destination;

& $destination  /passive | Out-Null

& "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installershell.exe" /help  | Out-Null


if ($false)
{
& $destination /Uninstall /passive  | Out-Null
& $destination /Uninstall /Force /passive  | Out-Null

        
uninstall-program "Microsoft SQL Server Data Tools - enu (14.0.60519.0)"                     
uninstall-program "Prerequisites for SSDT*"

uninstall-program "Microsoft SQL Server 2016 T-SQL ScriptDom*" 
uninstall-program "Microsoft SQL Server 2016 T-SQL Language Service*"
uninstall-program "Microsoft System CLR Types for SQL Server 2016" 
uninstall-program "Microsoft System CLR Types for SQL Server 2016*" 
                
uninstall-program "Microsoft SQL Server 2016 Management Objects  (x64)"   
uninstall-program "Microsoft SQL Server 2016 Management Objects*"

uninstall-program "Active Directory Authentication Library for SQL Server" 
uninstall-program "Active Directory Authentication Library for SQL Server (x86)*"   
                        
uninstall-program "Microsoft SQL Server 2012 Native Client*"                         

uninstall-program "Microsoft SQL Server 2016 LocalDB*"                  
uninstall-program "Microsoft SQL Server Compact 4.0 SP1 x64 ENU" 

uninstall-program "Microsoft .NET Framework 4.6.1 Developer Pack"  
uninstall-program "TypeScript Tools for Microsoft Visual Studio 2015" 

uninstall-program "Microsoft Visual C++ 2012 Redistributable (x86) - 11.0.60610" 
uninstall-program "Microsoft Visual C++ 2012 Redistributable (x64) - 11.0.60610"    
uninstall-program "Microsoft Visual C++ 2013 Redistributable (x64) - 12.0.21005"   
uninstall-program "Microsoft Visual C++ 2013 Redistributable (x86) - 12.0.21005"
uninstall-program "Microsoft Visual C++ 2015 Redistributable (x86) - 14.0.24215" 
uninstall-program "Microsoft Visual C++ 2015 Redistributable (x64) - 14.0.24215"



& fsutil reparsepoint delete "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\team explorer"
rd "C:\Program Files (x86)\Microsoft Visual Studio 14.0" -Recurse -Force 
rd "C:\Program Files (x86)\Microsoft SQL Server Compact Edition" -Recurse -Force
rd "C:\Program Files (x86)\Microsoft.net" -Recurse -Force

rd "C:\ProgramData\Microsoft\VisualStudio" -Recurse -Force
rd "C:\ProgramData\Microsoft\VisualStudioSecondaryInstaller" -recurse -force
rd "C:\ProgramData\Microsoft\Blend" -recurse -force

rd "HKLM:\SOFTWARE\Microsoft\VisualStudio" -recurse -force
rd "HKLM:\SOFTWARE\WOW6432Node\Microsoft\VisualStudio" -Recurse -force
rd "HKLM:\SOFTWARE\WOW6432Node\Microsoft\VSD3DProviders" -Recurse -force
rd "HKLM:\SOFTWARE\WOW6432Node\Microsoft\VsGraphics" -Recurse -force
rd "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Blend" -Recurse -force

rd "HKCU:\SOFTWARE\Microsoft\VsHub" -Recurse -force
rd "HKCU:\SOFTWARE\Microsoft\VSCommon" -Recurse -force
rd "HKCU:\SOFTWARE\Microsoft\VisualStudio" -Recurse -force
rd "HKCU:\SOFTWARE\Microsoft\Blend" -Recurse -force

rd ($env:USERPROFILE + "\documents\Visual Studio 2015") -Recurse -Force
}
