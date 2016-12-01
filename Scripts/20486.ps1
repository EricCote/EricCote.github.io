
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

    "downloading projets..."
    $fileSource = "http://download.microsoft.com/download/1/2/2/12272195-AAFC-4A9E-B06C-AE99ACD5E472/20486B-ENU-Allfiles.exe"
    $fileDest= ($dl + "20486B-ENU-Allfiles.exe")

    $wc = new-object System.Net.WebClient ;
    $wc.DownloadFile($fileSource, $fileDest) ;
    $wc.Dispose();  

    "Dezipping projects..."
    & $fileDest /s -dc:\20486b | out-null
}
    
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

"Delete Packages.config"
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
	

"remove pages from web.config"
Replace-Text Web.config "<pages(.|\r|\n)+?System.Web.Mvc(.|\r|\n)+?<\/pages>"  ''

"update mvc version to 5.2.3.0"
Replace-Text Web.config "System.Web.Mvc, Version=4.0.0.0" "System.Web.Mvc, Version=5.2.3.0"

"update razor version to 3.0.0.0"
Replace-Text Web.config "System.Web.WebPages.Razor, Version=2.0.0.0" "System.Web.WebPages.Razor, Version=3.0.0.0"

"remove packages.config"
Replace-Text *.csproj '<Content Include="packages.config" \/>' ''

"remove <HintPath>"
Replace-Text *.csproj '<HintPath>.+</HintPath>' ''

$packages = @"
<?xml version="1.0" encoding="utf-8"?>
<packages>
  <package id="EntityFramework" version="6.1.3" targetFramework="net461" />
  <package id="Microsoft.AspNet.Mvc" version="5.2.3" targetFramework="net461" />
  <package id="Microsoft.AspNet.Razor" version="3.2.3" targetFramework="net461" />
  <package id="Microsoft.AspNet.Web.Optimization" version="1.1.3" targetFramework="net461" />
  <package id="Microsoft.AspNet.WebPages" version="3.2.3" targetFramework="net461" />
  <package id="Microsoft.CodeDom.Providers.DotNetCompilerPlatform" version="1.0.2" targetFramework="net461" />
  <package id="Microsoft.jQuery.Unobtrusive.Validation" version="3.2.3" targetFramework="net461" />
  <package id="Microsoft.Net.Compilers" version="1.3.2" targetFramework="net461" developmentDependency="true" />
  <package id="Microsoft.AspNet.WebApi" version="5.2.3" targetFramework="net461" />
  <package id="Microsoft.AspNet.WebApi.Client" version="5.2.3" targetFramework="net461" />
  <package id="Microsoft.AspNet.WebApi.Core" version="5.2.3" targetFramework="net461" />
  <package id="Microsoft.AspNet.WebApi.WebHost" version="5.2.3" targetFramework="net461" /> 
  <package id="Microsoft.Web.Infrastructure" version="1.0.0.0" targetFramework="net461" />
  <package id="Newtonsoft.Json" version="6.0.4" targetFramework="net461" />
  <package id="WebGrease" version="1.5.2" targetFramework="net461" />
  <package id="Antlr" version="3.4.1.9004" targetFramework="net461" />
</packages>
"@

######################################
Get-ChildItem packages.config  -recurse   | Set-Content  -value $packages       



Get-Childitem web.config -recurse |  Where {$_.Directory.name -eq 'Views' }




Install-PackageProvider -Name NuGet

Install-Package *NuGet*

Get-PackageSource

get-packageProvider


Get-Package *Nuget*
#Replace-Text *.csproj "System.Web.Mvc, Version=3.0.0.0" `
#                      "System.Web.Mvc, Version=4.0.0.0"


#Replace-Text web.config  "System.Web.Mvc, Version=3.0.0.0"  `
#                         "System.Web.Mvc, Version=4.0.0.0"

#Replace-Text web.config  "System.Web.Helpers, Version=1.0.0.0"  `
#                         "System.Web.Helpers, Version=2.0.0.0"

#Replace-Text web.config  "System.Web.WebPages, Version=1.0.0.0"  `
#                         "System.Web.WebPages, Version=2.0.0.0"



"replace text elements"

Replace-Text *.css  "column-count: 3;"  `
                    @"
-webkit-column-count: 3;
                    column-count: 3;                        
"@

Replace-Text *.css  "column-gap: 5rem;"  `
                    @"
-webkit-column-gap: 5rem;
                    column-gap: 5rem;                        
"@

Replace-Text *.css  "display: flexbox;"        "display: flex;";
Replace-Text *.css  "display: box;"            "display: flex;";
Replace-Text *.css  "display: -webkit-flexbox" "display: -webkit-flex";
Replace-Text *.css  "box-flex:"                "flex:";
#Replace-Text *.css  "display: -webkit-box;"    "";

Replace-Text *.css  "-ms-box: 0;"                "";
Replace-Text *.css  "-webkit-flex: 0;"           "";
Replace-Text *.css  "flex: 0;"                   "";

Replace-Text *.css  "-webkit-flex-pack: center"  "-webkit-justify-content: center";
Replace-Text *.css  "flex-pack: center;"         "justify-content: center;";
Replace-Text *.css  "box-align: center;"         "align-items: center;";

Replace-Text *.css "linear-gradient\(top" `
                   "linear-gradient(to bottom";
                    

Replace-Text *.manifest "htmwell.png"     "sponsor1.png";
Replace-Text *.manifest "medior-inc.png"  "sponsor2.png";
Replace-Text *.manifest "ncode.png"       "sponsor3.png";
Replace-Text *.manifest "optimjs.png"     "sponsor4.png";
Replace-Text *.manifest "squarefont.png"  "sponsor5.png";
 
       




       $e = "CN=Ken =Myer"


 $e.Substring($e.LastIndexOf('\') + 1)

