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
{  Param(
    [parameter(Position=1)] $Name
    )
  
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
        % -Process {  
                $unstr = $_.UninstallString.Replace("  "," ");
                $separatorPos = if ($unstr.LastIndexOf('"') -ge 0) {$unstr.LastIndexOf('"') + 1 } else {$unstr.IndexOf(" ")};
                $items= "", ""
                $items[0] = $unstr.Substring(0,$separatorPos);
                if ($separatorPos + 1 -lt $unstr.Length) {
                $items[1] = $unstr.Substring($separatorPos + 1); };
                $items[1] = $items[1].TrimStart(" ");
                $items[0]= $items[0].Replace("`"", "") ;
                $items[1]= $items[1].Replace("/I","/x"); 
                & ($items[0]) $items[1] /passive $skip| Out-Null;
        };

    }
 }

 
#https://docs.microsoft.com/en-us/visualstudio/install/use-command-line-parameters-to-install-visual-studio


$WebSource = "https://download.microsoft.com/download/D/1/F/D1F328D6-A080-4017-B125-138BA7344727/vs_Enterprise.exe";
$destination = ($dl +  "vs_enterprise.exe");


Download-File $WebSource $destination;

#& $destination install `
#               --productid Microsoft.VisualStudio.Product.Enterprise `
#               --add Microsoft.VisualStudio.Workload.NetWeb `
#               --add Microsoft.VisualStudio.Workload.NetCoreTools.Preview `
#               --add Microsoft.VisualStudio.Component.SQL.CMDUtils `
#               --add Microsoft.Component.NetFX.Core.Runtime `
#               --add Microsoft.Net.ComponentGroup.4.6.2.DeveloperTools `
#               --passive | Out-Null


& $destination  `
               --productid Microsoft.VisualStudio.Product.Enterprise `
               --all `
               --passive | Out-Null


& "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe" modify `
               --channelid VisualStudio.15.Release `
               --productid Microsoft.VisualStudio.Product.Enterprise `
               --add Microsoft.VisualStudio.Component.Azure.ServiceFabric.Tools `
               --add Microsoft.Net.ComponentGroup.4.6.2.DeveloperTools `
               --add Microsoft.VisualStudio.Component.SQL.CMDUtils `
               --add Microsoft.Component.NetFX.Core.Runtime `
               --add Component.GitHub.VisualStudio `
               --add Microsoft.VisualStudio.Component.Git `
               --add Microsoft.VisualStudio.Component.EntityFramework `
               --passive | Out-Null


#               /install `
#               --channelid VisualStudio.15.Release

if ($false)
{
& "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe" /uninstall  | Out-Null
#& $destination /Uninstall /passive  | Out-Null
#& $destination /Uninstall /Force /passive  | Out-Null

uninstall-program "Windows Software Development Kit - Windows 10.0.14393.33"
uninstall-program "Microsoft Visual Studio Code"
uninstall-program "Microsoft Identity Extensions"
uninstall-program "Workflow Manager Client 1.0" 
uninstall-program "Windows SDK AddOn"
uninstall-program "Microsoft .NET Framework 4.6.2 SDK"
uninstall-program "Microsoft .NET Framework 4.6.2 Targeting Pack"  #(inverse???)
uninstall-program "Microsoft Visual Studio 2017 Tools for Unity"
uninstall-program "Git version 2.10.2"

uninstall-program "Microsoft .NET Core 1.0.1 - SDK Preview 4 (x64)"
uninstall-program "Microsoft Visual C++ 2017 RC Redistributable (x64) - 14.10.24728"
uninstall-program "Microsoft Visual C++ 2017 RC Redistributable (x86) - 14.10.24728"

uninstall-program "Microsoft Visual C++ 2013 Redistributable (x64) - 12.0.21005"
uninstall-program "Microsoft Visual C++ 2013 Redistributable (x86) - 12.0.21005"
        



       
#uninstall-program "Microsoft SQL Server Data Tools - enu (14.0.60519.0)"                     
#uninstall-program "Prerequisites for SSDT*"

#uninstall-program "Microsoft SQL Server 2016 T-SQL ScriptDom*" 
#uninstall-program "Microsoft SQL Server 2016 T-SQL Language Service*"
#uninstall-program "Microsoft System CLR Types for SQL Server 2016" 
#uninstall-program "Microsoft System CLR Types for SQL Server 2016*" 
                
#uninstall-program "Microsoft SQL Server 2016 Management Objects  (x64)"   
#uninstall-program "Microsoft SQL Server 2016 Management Objects*"

#uninstall-program "Active Directory Authentication Library for SQL Server" 
#uninstall-program "Active Directory Authentication Library for SQL Server (x86)*"   
                        
#uninstall-program "Microsoft SQL Server 2012 Native Client*"                         

#uninstall-program "Microsoft SQL Server 2016 LocalDB*"                  
#uninstall-program "Microsoft SQL Server Compact 4.0 SP1 x64 ENU" 

#uninstall-program "Microsoft .NET Framework 4.6.1 Developer Pack"  
#uninstall-program "TypeScript Tools for Microsoft Visual Studio 2015" 

#uninstall-program "Microsoft Visual C++ 2012 Redistributable (x86) - 11.0.60610" 
#uninstall-program "Microsoft Visual C++ 2012 Redistributable (x64) - 11.0.60610"    
#uninstall-program "Microsoft Visual C++ 2013 Redistributable (x64) - 12.0.21005"   
#uninstall-program "Microsoft Visual C++ 2013 Redistributable (x86) - 12.0.21005"
#uninstall-program "Microsoft Visual C++ 2015 Redistributable (x86) - 14.0.24215" 
#uninstall-program "Microsoft Visual C++ 2015 Redistributable (x64) - 14.0.24215"


$Acl = Get-Acl "C:\Program Files (x86)\Microsoft.NET\RedistList\AssemblyList_4_client.xml"
$Ar = New-Object  system.security.accesscontrol.filesystemaccessrule("BUILTIN\users","FullControl","Allow")
$Acl.AddAccessRule($Ar)
Set-Acl "C:\Program Files (x86)\Microsoft.NET\RedistList\AssemblyList_4_client.xml" $Acl
Set-Acl "C:\Program Files (x86)\Microsoft.NET\RedistList\AssemblyList_4_extended.xml" $Acl




#& fsutil reparsepoint delete "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\team explorer"
rd "C:\Program Files (x86)\Microsoft Visual Studio" -Recurse -Force
rd "C:\Program Files (x86)\Common Files\Microsoft Shared\VS7Debug" -Recurse -Force
#rd "C:\Program Files (x86)\Microsoft SQL Server Compact Edition" -Recurse -Force

rd "C:\Program Files (x86)\Microsoft.net" -Recurse -Force

rd "C:\ProgramData\Microsoft\VisualStudio" -Recurse -Force
rd "C:\Program Files (x86)\Reference Assemblies" -Recurse -Force
rd "C:\Program Files (x86)\Windows Kits" -Recurse -Force
#rd "C:\ProgramData\Microsoft\VisualStudioSecondaryInstaller" -recurse -force
#rd "C:\ProgramData\Microsoft\Blend" -recurse -force
rd ($env:USERPROFILE + "\documents\Visual Studio 2017") -Recurse -Force

rd "HKLM:\SOFTWARE\WOW6432Node\Microsoft\VisualStudio" -Recurse -force
rd "HKLM:\SOFTWARE\WOW6432Node\Microsoft\vscommon" -Recurse -force
dir "HKLM:\SOFTWARE\WOW6432Node\Microsoft\visualstudio_*" -Recurse -force
rd "HKLM:\SOFTWARE\Microsoft\VisualStudio" -recurse -force
#rd "HKLM:\SOFTWARE\WOW6432Node\Microsoft\VSD3DProviders" -Recurse -force
#rd "HKLM:\SOFTWARE\WOW6432Node\Microsoft\VsGraphics" -Recurse -force
#rd "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Blend" -Recurse -force

rd "HKCU:\SOFTWARE\Microsoft\VisualStudio" -Recurse -force
rd "HKCU:\SOFTWARE\Microsoft\VsHub" -Recurse -force
rd "HKCU:\SOFTWARE\Microsoft\VSCommon" -Recurse -force
#rd "HKCU:\SOFTWARE\Microsoft\Blend" -Recurse -force


}
