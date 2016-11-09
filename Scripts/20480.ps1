
$dl=$(Join-Path  $env:USERPROFILE "downloads\");

$mvcSource = "https://download.microsoft.com/download/3/4/A/34A8A203-BD4B-44A2-AF8B-CA2CFCB311CC/AspNetMVC3Setup.exe"



function Replace-Text($filetype, $FindText, $ReplaceText)
{
Get-ChildItem $filetype -recurse -file  | 
  ForEach-Object {  (Get-Content $_) -replace
                      $FindText,
                      $ReplaceText | 
                      Set-Content -path $_ 
                 }
}

if (-not (test-path "C:\Program Files (x86)\Microsoft ASP.NET\ASP.NET MVC 3" ))
{
    "Download MVC 3"
    $wc = new-object System.Net.WebClient ;
    $wc.DownloadFile($mvcSource, $dl + "mvc3setup.exe") ;
    $wc.Dispose();  

    "install mvc 3"
    & ($dl + "mvc3setup.exe") /passive /promtrestart | out-null


}

if (-not (test-path "C:\20480b" ))
{

    "downloading projets..."
    $fileSource = "http://download.microsoft.com/download/6/9/3/693DED73-7477-43F3-A21F-E2D20BA93E27/20480B-ENU-Allfiles.exe"
    $fileDest= ($dl + "20480B-ENU-Allfiles.exe")

    $wc = new-object System.Net.WebClient ;
    $wc.DownloadFile($fileSource, $fileDest) ;
    $wc.Dispose();  

    "Dezipping projects..."
    & $fileDest /s -dc:\20480b | out-null 
}
    
    cd c:\20480b -ErrorAction Stop

    
    "Modifying projet to read-write"
Get-ChildItem *   -recurse | Where-Object {$_.Attributes -ne "Directory"}  |
    ForEach-Object {  
                    $_.IsReadOnly=$false 
                   }


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
 
       