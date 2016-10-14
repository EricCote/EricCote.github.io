
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

#Download-File "http://download.microsoft.com/download/1/2/d/12d1feae-15a0-4d32-8643-4f38915eb07c/vs_enterprise.exe"   ($dl +  "vs_enterprise.exe");

Download-File "http://download.microsoft.com/download/e/4/c/e4c393a9-8fff-441b-ad3a-3f4040317a1f/vs_community.exe" ($dl +  "vs_community.exe");

& ($dl +  "vs_community.exe") /passive | Out-Null


if ($false)
{
#& ($drv + 'setup.exe') /qs `
#                       /Action=uninstall `
#                       /IAcceptSqlServerLicenseTerms `
#                       /Features=SQL,AS,RS,IS,DQC,MDS,SQL_SHARED_MR,Tools `
#                       /InstanceName=MSSQLSERVER | Out-Null

#$ssms= ($dl + "SSMS-setup-enu.exe")
#& ($ssms) /uninstall /passive | Out-Null

#$ssdt= ($dl + "SSDTSetup.exe")
#& ($ssdt) /uninstall /passive | Out-Null


uninstall-program "IIS Express Application Compatibility Database for x86"         
uninstall-program "IIS Express Application Compatibility Database for x64"         
uninstall-program "IIS 10.0 Express"                                               
uninstall-program "Microsoft Web Deploy 3.6"                                       

uninstall-program "Microsoft SQL Server 2016 T-SQL ScriptDom*"                      
uninstall-program "Microsoft System CLR Types for SQL Server 2016*"                 
uninstall-program "Microsoft SQL Server 2016 Management Objects  (x64)"   

uninstall-program "Microsoft SQL Server 2014 Transact-SQL ScriptDom*"               
uninstall-program "Microsoft System CLR Types for SQL Server 2014*"                
uninstall-program "Microsoft SQL Server 2014 Management Objects  (x64)"            

uninstall-program "Active Directory Authentication Library for SQL Server"         

uninstall-program "Microsoft SQL Server 2012 Command Line Utilities*"               
uninstall-program "Microsoft SQL Server 2012 Native Client*"                        
 
uninstall-program "Microsoft SQL Server Compact 4.0 SP1 x64 ENU"                   
      
uninstall-program "Microsoft Visual Studio 2015 Update 3 IntelliTrace (x64)"    
uninstall-program "Microsoft Visual Studio 2015 Update 3 Diagnostic Tools - amd64"


uninstall-program "Microsoft Visual C++ 2015 x64 Debug Runtime - 14.0.24215"

 

#################################

uninstall-program "Microsoft Help Viewer 2.2"                                                   

uninstall-program "Update for  (KB2504637)"         

uninstall-program "Microsoft SQL Server Data Tools - enu (14.0.60519.0)"                     
                                                
uninstall-program "Prerequisites for SSDT*"
             
uninstall-program "Microsoft SQL Server 2016 T-SQL Language Service*" 
uninstall-program "Microsoft System CLR Types for SQL Server 2016"                           
uninstall-program "Microsoft SQL Server 2016 Management Objects*"                             
uninstall-program "Microsoft System CLR Types for SQL Server 2014"  
uninstall-program "Microsoft SQL Server 2014 Management Objects*"                             
uninstall-program "Microsoft SQL Server 2014 T-SQL Language Service*"                         


#uninstall-program "Active Directory Authentication Library for SQL Server (x86)*"                
       

uninstall-program "Microsoft Visual Studio 2015 Windows Diagnostic Tools"                    


uninstall-program "Microsoft .NET Framework 4 Multi-Targeting Pack"                          
uninstall-program "Microsoft .NET Framework 4.5 Multi-Targeting Pack"                
uninstall-program "Microsoft .NET Framework 4.5.1 Multi-Targeting Pack"  ##
uninstall-program "Microsoft .NET Framework 4.5.1 Multi-Targeting Pack (ENU)" ## 
uninstall-program "Microsoft .NET Framework 4.5.2 Multi-Targeting Pack" ##                     
uninstall-program "Microsoft .NET Framework 4.6 Targeting Pack"                              
                       
uninstall-program "Microsoft .NET Framework 4.6.1 Targeting Pack"                            
uninstall-program "Microsoft .NET Framework 4.6.1 Targeting Pack (ENU)"                      

uninstall-program "Microsoft .NET Framework 4.6.1 SDK"  ##                                     
uninstall-program "Microsoft .NET Framework 4.6.1 Developer Pack" 
              
uninstall-program "Microsoft .NET Core 5.0 SDK"   ##
                          
uninstall-program "Microsoft Portable Library Multi-Targeting Pack"  ##    
uninstall-program "Microsoft Portable Library Multi-Targeting Pack Language Pack - enu" ##
                           
uninstall-program "Visual C++ IDE Debugger Package" 
uninstall-program "Visual C++ IDE Base Package"   
uninstall-program "Visual C++ IDE Core Package"                                                  

uninstall-program "Roslyn Language Services - x86"                                           
                                
uninstall-program "Microsoft Visual Studio 2015 Update 3 Diagnostic Tools - x86" 
uninstall-program "Microsoft Visual Studio 2015 Update 3.1 Team Explorer Language Pack - ENU"            
uninstall-program "Team Explorer for Microsoft Visual Studio 2015 Update 3.1"                
          
uninstall-program "Microsoft Expression Blend SDK for .NET 4" 
uninstall-program "Windows Phone SDK 8.0 Assemblies for Visual Studio 2015"  ##                                          
uninstall-program "Blend for Visual Studio SDK for .NET 4.5"  ##                       
uninstall-program "Microsoft Silverlight"          
       
uninstall-program "TypeScript Tools for Microsoft Visual Studio 2015" 
uninstall-program "Microsoft Visual Studio 2015 Update 3 IntelliTrace Front End"  
uninstall-program "Microsoft Visual Studio 2015 Update 3 IntelliTrace (x86)"                           
            
uninstall-program "Microsoft Visual Studio 2015 XAML Application Timeline"                   
uninstall-program "Microsoft Visual Studio 2015 XAML Visual Diagnostics"    
#uninstall-program "Microsoft Visual Studio 2015 XAML Designer"       

uninstall-program "Microsoft Visual Studio 2015 Shell (Minimum) Interop Assemblies"   
                 
uninstall-program "Microsoft Visual C++ 2012 Redistributable (x86) - 11.0.60610" 
uninstall-program "Microsoft Visual C++ 2012 Redistributable (x64) - 11.0.60610"    
 
uninstall-program "Microsoft Visual C++ 2013 Redistributable (x64) - 12.0.21005"   
uninstall-program "Microsoft Visual C++ 2013 Redistributable (x86) - 12.0.21005"  

uninstall-program "Microsoft Visual C++ 2015 Redistributable (x86) - 14.0.24215" 
uninstall-program "Microsoft Visual C++ 2015 Redistributable (x64) - 14.0.24215"

uninstall-program "Microsoft Visual C++ 2015 x86 Debug Runtime - 14.0.24215"                   
            

$g="/x{D9CAC4A5-7F4C-3792-90F1-C93F4FDB4120}"

& msiexec.exe $g /passive| Out-Null


& fsutil reparsepoint delete "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\team explorer"

rd "C:\Program Files (x86)\Microsoft Visual Studio 14.0" -Recurse -Force 

 }
