
$dl=$(Join-Path  $env:USERPROFILE "downloads\");


function find-Text($filetype, $FindText)
{
  Get-ChildItem $filetype -recurse -file | % { ((Get-Content $_ -raw) -match $FindText)  }            
}

function Replace-Text($filetype, $FindText, $ReplaceText)
{
  Get-ChildItem $filetype -recurse -file  | 
     ForEach-Object { (Get-Content $_ -raw) -replace
                      $FindText,
                      $ReplaceText | 
                      Set-Content -path $_  
                    };          
}

function Run-Sql
{
    param 
    (
        [parameter(position=1,mandatory=$true)] $sqlString
    )   

    #list of paths where we can search for sqlcmd 
    $paths = @("C:\Program Files\Microsoft SQL Server\110\Tools\Binn\sqlcmd.exe",
               "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\110\Tools\Binn\SQLCMD.EXE",
               "C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\130\Tools\Binn\SQLCMD.EXE");

    #return the First path where sqlcmd is found
    $sqlcmd = $paths.Where({test-Path $_ })[0];

    $svr="(localDb)\MsSqlLocalDb";

    return & $sqlcmd -S $svr -E -Q $SqlString ;
}


if (-not (test-path "C:\20486b" ))
{   
    $fileSource = "http://download.microsoft.com/download/1/2/2/12272195-AAFC-4A9E-B06C-AE99ACD5E472/20486B-ENU-Allfiles.exe"
    $fileDest= ($dl + "20486B-ENU-Allfiles.exe")

    if (-not (test-path $fileDest)) {
        "downloading projets..."
        $wc = new-object System.Net.WebClient ;
        $wc.DownloadFile($fileSource, $fileDest) ;
        $wc.Dispose();  
    }
    "Dezipping projects..."
    & $fileDest /s -dc:\20486b | out-null
}



if (-not (test-path "C:\nuget" ))
{   
    $fileSource = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
    $fileDest= ($dl + "nuget.exe")

    if (-not (test-path $fileDest)) {
        "downloading Nuget..."
        $wc = new-object System.Net.WebClient ;
        $wc.DownloadFile($fileSource, $fileDest) ;
        $wc.Dispose();  
    }

}
cd c:\20486b -ErrorAction Stop




cd c:\20486b -ErrorAction Stop

    
"Modifying projet to read-write"
Get-ChildItem *   -recurse | Where-Object {$_.Attributes -ne "Directory"}  |
    ForEach-Object {  
                $_.IsReadOnly=$false 
                }


"Delete .nuget folders"
Get-ChildItem .nuget   -recurse | rd -recurse

"Delete obj folders"
get-childitem obj -directory -Recurse | rd -Recurse

"Delete packages folders"
Get-ChildItem Packages   -recurse | rd -recurse

"Delete bin folders"
Get-ChildItem bin   -recurse | rd -recurse

#"Delete Packages.config"
#Get-ChildItem packages.config  -recurse| del 


"Updating databases to latest SQL Server"
Get-ChildItem *.mdf -recurse |
    % {  $dbName = $_.Name;
         Run-Sql "CREATE DATABASE [$dbName]
            ON (FILENAME = '$_')   
            FOR ATTACH ;
	  
            DROP DATABASE [$dbName];"   } ; 

"Updating Connection strings to the latest SQL"
Replace-Text web.config "\(localdb\)\\v11.0;" "(localdb)\MsSqlLocalDb;"

"update LocalDb entity framework factory"
Replace-Text web.config  '<parameter value="v11.0" />' '<parameter value="mssqllocaldb" />'


"update webpages"
Replace-Text web.config '<add key="webpages:Version" value="2.0.0.0" />' `
                        '<add key="webpages:Version" value="3.0.0.0" />'

"update mvc binding redirect"                                
Replace-Text web.config  '<bindingRedirect oldVersion="0.0.0.0-4.0.0.0" newVersion="4.0.0.0" />'  `
                         '<bindingRedirect oldVersion="0.0.0.0-5.2.3.0" newVersion="5.2.3.0" />'




"update Target Framework (web config)"
Replace-Text web.config 'targetFramework="4.5"' 'targetFramework="4.6.1"' 

"update Target Framework (project)"
Replace-Text *.csproj '<TargetFrameworkVersion>v4.5</TargetFrameworkVersion>' '<TargetFrameworkVersion>v4.6.1</TargetFrameworkVersion>'
 
"remove mvc4 project type"
Replace-Text *.csproj '<ProjectTypeGuids>{E3E379DF-F4C6-4180-9B81-6769533ABE47};'  '<ProjectTypeGuids>'

"remove imports from project"
Replace-Text *.csproj '<Import Project="\$\(SolutionDir\)\\\.nuget\\nuget\.targets" \/>' ''

"Remove Nuget from solution"
Replace-Text  *.sln 'Project\("{2150E333-8FDC-42A3-9474-1A3956D46DE8}"\)(.|\r|\n)+?EndProject\r'  ''
	

#"remove pages from web.config"
#Replace-Text Web.config "<pages(.|\r|\n)+?System.Web.Mvc(.|\r|\n)+?<\/pages>"  ''

"update mvc version to 5.2.3.0"
Replace-Text Web.config "System.Web.Mvc, Version=4.0.0.0" "System.Web.Mvc, Version=5.2.3.0"

"update razor version to 3.0.0.0"
Replace-Text Web.config "System.Web.WebPages.Razor, Version=2.0.0.0" "System.Web.WebPages.Razor, Version=3.0.0.0"

#"remove packages.config"
#Replace-Text *.csproj '<Content Include="packages.config" \/>' ''


$packages = @"
<?xml version="1.0" encoding="utf-8"?>
<packages>
  <package id="EntityFramework" version="6.1.3" targetFramework="net461" />
  <package id="Microsoft.AspNet.Mvc" version="5.2.3" targetFramework="net461" />
  <package id="Microsoft.AspNet.Razor" version="3.2.3" targetFramework="net461" />
  <package id="Microsoft.AspNet.Web.Optimization" version="1.1.3" targetFramework="net461" />
  <package id="Microsoft.AspNet.WebPages" version="3.2.3" targetFramework="net461" />
  <package id="Microsoft.CodeDom.Providers.DotNetCompilerPlatform" version="1.0.2" targetFramework="net461" />
  <package id="Microsoft.Net.Compilers" version="1.3.2" targetFramework="net461" developmentDependency="true" />
  <package id="Microsoft.AspNet.WebApi" version="5.2.3" targetFramework="net461" />
  <package id="Microsoft.AspNet.WebApi.Client" version="5.2.3" targetFramework="net461" />
  <package id="Microsoft.AspNet.WebApi.Core" version="5.2.3" targetFramework="net461" />
  <package id="Microsoft.AspNet.WebApi.WebHost" version="5.2.3" targetFramework="net461" /> 
  <package id="Microsoft.Web.Infrastructure" version="1.0.0.0" targetFramework="net461" />
  <package id="Newtonsoft.Json" version="9.0.1" targetFramework="net461" />
  <package id="WebGrease" version="1.6.0" targetFramework="net461" />
  <package id="Antlr" version="3.5.0.2" targetFramework="net461" />
</packages>
"@

Get-ChildItem packages.config  -recurse   | Set-Content  -value $packages       






[xml]$xml=get-content "C:\20486b\Democode\Mod01\PhotoSharingSample\PhotoSharingSample\PhotoSharingSample.csproj";


$elem = $xml.Project.ItemGroup.Reference | where Include -like 'Antlr3.Runtime*'
$elem.Include = "Antlr3.Runtime, Version=3.5.0.2, Culture=neutral, PublicKeyToken=eb42632606e9261f, processorArchitecture=MSIL"
$elem.InnerXml ="<HintPath>..\packages\Antlr.3.5.0.2\lib\Antlr3.Runtime.dll</HintPath><Private>True</Private>"

$elem = $xml.Project.ItemGroup.Reference | where Include -like 'WebGrease*'
$elem.Include = "WebGrease, Version=1.6.5135.21930, Culture=neutral, PublicKeyToken=31bf3856ad364e35, processorArchitecture=MSIL"
$elem.InnerXml ="<HintPath>..\packages\WebGrease.1.6.0\lib\WebGrease.dll</HintPath><Private>True</Private>"
 

$elem =  $xml.Project.ItemGroup.Reference | where Include -like 'System.Web.Optimization*'
$elem.Include = "System.Web.Optimization, Version=1.1.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35, processorArchitecture=MSIL"
$elem.InnerXml ="<HintPath>..\packages\Microsoft.AspNet.Web.Optimization.1.1.3\lib\net40\System.Web.Optimization.dll</HintPath><Private>True</Private>"

$elem=  $xml.Project.ItemGroup.Reference | where Include -Match 'EntityFramework([^\.]|($))'
$elem.Include = "EntityFramework, Version=6.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089, processorArchitecture=MSIL"
$elem.InnerXml ="<HintPath>..\packages\Newtonsoft.Json.9.0.1\lib\net45\Newtonsoft.Json.dll</HintPath>"

$elem =  $xml.Project.ItemGroup.Reference.Remove(($xml.Project.ItemGroup.Reference | where Include -like 'Microsoft.WebSockets'))


$elem =  $xml.Project.ItemGroup.Reference | where Include -Match 'System.Net.Http([^\.]|($))'
$elem.InnerXml=""

$elem =  $xml.Project.ItemGroup.Reference | where Include -like 'System.Net.Http.WebRequest'
$elem.InnerXml=""

$elem = $xml.Project.ItemGroup.Reference | where Include -like 'Microsoft.Web.Infrastructure*'
$elem.Include = "Microsoft.Web.Infrastructure, Version=1.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35, processorArchitecture=MSIL"
$elem.InnerXml =" <HintPath>..\packages\Microsoft.Web.Infrastructure.1.0.0.0\lib\net40\Microsoft.Web.Infrastructure.dll</HintPath><Private>True</Private>"


$elem = $xml.Project.ItemGroup.Reference | where Include -like 'Newtonsoft.Json*'
$elem.Include = "Newtonsoft.Json, Version=9.0.0.0, Culture=neutral, PublicKeyToken=30ad4fe6b2a6aeed, processorArchitecture=MSIL"
$elem.InnerXml ="<HintPath>..\packages\Newtonsoft.Json.6.0.4\lib\net45\Newtonsoft.Json.dll</HintPath><Private>True</Private>"


$elem = $xml.Project.ItemGroup.Reference | where Include -like 'System.Web.Helpers*'
$elem.Include = "System.Web.Helpers, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35, processorArchitecture=MSIL"
$elem.InnerXml ="<HintPath>..\packages\Microsoft.AspNet.WebPages.3.2.3\lib\net45\System.Web.Helpers.dll</HintPath><Private>True</Private>"
#----
$elem = $xml.Project.ItemGroup.Reference | where Include -like 'System.Web.Razor*'
$elem.Include = "System.Web.Razor, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35, processorArchitecture=MSIL"
$elem.InnerXml =" <HintPath>..\packages\Microsoft.AspNet.Razor.3.2.3\lib\net45\System.Web.Razor.dll</HintPath><Private>True</Private>"


$elem = $xml.Project.ItemGroup.Reference | where Include -Match 'System.Web.WebPages([^\.]|($))'
$elem.Include = "System.Web.WebPages, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35, processorArchitecture=MSIL"
$elem.InnerXml =" <HintPath>..\packages\Microsoft.AspNet.WebPages.3.2.3\lib\net45\System.Web.WebPages.dll</HintPath><Private>True</Private>"

$elem = $xml.Project.ItemGroup.Reference | where Include -like 'System.Web.WebPages.Razor*'
$elem.Include = "System.Web.WebPages.Razor, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35, processorArchitecture=MSIL"
$elem.InnerXml ="<HintPath>..\packages\Microsoft.AspNet.WebPages.3.2.3\lib\net45\System.Web.WebPages.Razor.dll</HintPath><Private>True</Private>"

$elem = $xml.Project.ItemGroup.Reference | where Include -like 'System.Web.WebPages.Deployment*'
$elem.Include = "System.Web.WebPages.Deployment, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35, processorArchitecture=MSIL"
$elem.InnerXml ="<HintPath>..\packages\Microsoft.AspNet.WebPages.3.2.3\lib\net45\System.Web.WebPages.Deployment.dll</HintPath><Private>True</Private>"


$elem = $xml.Project.ItemGroup.Reference | where Include -like 'System.Web.Mvc*'
$elem.Include = "System.Web.Mvc, Version=5.2.3.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35, processorArchitecture=MSIL"
$elem.InnerXml =" <HintPath>..\packages\Microsoft.AspNet.Mvc.5.2.3\lib\net45\System.Web.Mvc.dll</HintPath><Private>True</Private>"

$elem = $xml.Project.ItemGroup.Reference | where Include -like 'System.Web.Http.WebHost*'
$elem.Include = "System.Web.Http.WebHost, Version=5.2.3.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35, processorArchitecture=MSIL"
$elem.InnerXml ="<HintPath>..\packages\Microsoft.AspNet.WebApi.WebHost.5.2.3\lib\net45\System.Web.Http.WebHost.dll</HintPath><Private>True</Private>"


$elem = $xml.Project.ItemGroup.Reference | where Include -like 'System.Net.Http.Formatting*'
$elem.Include = "System.Net.Http.Formatting, Version=5.2.3.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35, processorArchitecture=MSIL"
$elem.InnerXml ="<HintPath>..\packages\Microsoft.AspNet.WebApi.Client.5.2.3\lib\net45\System.Net.Http.Formatting.dll</HintPath><Private>True</Private>"


$elem = $xml.Project.ItemGroup.Reference | where Include -Match 'System.Web.Http([^\.]|($))' 
$elem.Include = "System.Web.Http, Version=5.2.3.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35, processorArchitecture=MSIL"
$elem.InnerXml ="<HintPath>..\packages\Microsoft.AspNet.WebApi.Core.5.2.3\lib\net45\System.Web.Http.dll</HintPath><Private>True</Private>"

#$elem = $xml.Project.ItemGroup.Reference | where Include -like 'Microsoft.CodeDom.Providers.DotNetCompilerPlatform*'
#$elem.Include = "Microsoft.CodeDom.Providers.DotNetCompilerPlatform, Version=1.0.2.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35, processorArchitecture=MSIL"
#$elem.InnerXml ="<HintPath>..\packages\Microsoft.CodeDom.Providers.DotNetCompilerPlatform.1.0.2\lib\net45\Microsoft.CodeDom.Providers.DotNetCompilerPlatform.dll</HintPath><Private>True</Private>"


#$elem = $xml.Project.ItemGroup.Reference | where Include -like 'EntityFramework.SqlServer*'
#$elem.Include = "EntityFramework.SqlServer, Version=6.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089, processorArchitecture=MSIL"
#$elem.InnerXml ="  <HintPath>..\packages\EntityFramework.6.1.3\lib\net45\EntityFramework.SqlServer.dll</HintPath><Private>True</Private>"

#$elem.GetType()
    
set-content "C:\20486b\Democode\Mod01\PhotoSharingSample\PhotoSharingSample\PhotoSharingSample.csproj" -Value $xml.InnerXml




######################################
$comment = 
@"
Get-ChildItem packages.config  -recurse   | Set-Content  -value $packages       

Get-Childitem web.config -recurse |  Where {$_.Directory.name -eq 'Views' }

Install-PackageProvider -Name NuGet

Install-Package *NuGet*

Get-PackageSource

get-packageProvider


Get-Package *Nuget*
"@