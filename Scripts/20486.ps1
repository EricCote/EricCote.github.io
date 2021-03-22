iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco feature enable -n allowGlobalConfirmation
choco feature enable -n exitOnRebootDetected

choco install googlechrome
choco install nodejs-lts

choco install vscode.install
choco install git

#####################Office 365

$filename = (join-path  $env:Temp config.xml)

$xml = '<Configuration ID="9da73586-1220-41fb-b51d-a4af1c225f04">
  <Add OfficeClientEdition="64" Channel="Current">
    <Product ID="O365BusinessRetail">
      <Language ID="MatchOS" />
      <Language ID="en-us" />
      <Language ID="fr-fr" />
      <ExcludeApp ID="Access" />
      <ExcludeApp ID="Groove" />
      <ExcludeApp ID="Lync" />
      <ExcludeApp ID="OneDrive" />
      <ExcludeApp ID="Outlook" />
      <ExcludeApp ID="Publisher" />
      <ExcludeApp ID="Teams" />
    </Product>
    <Product ID="VisioPro2019Retail" >
      <Language ID="MatchOS" />
      <Language ID="en-us" />
      <Language ID="fr-fr" />
      <ExcludeApp ID="Access" />
      <ExcludeApp ID="Groove" />
      <ExcludeApp ID="Lync" />
      <ExcludeApp ID="OneDrive" />
      <ExcludeApp ID="Outlook" />
      <ExcludeApp ID="Publisher" />
      <ExcludeApp ID="Teams" />
    </Product>
  </Add>
  <Updates Enabled="TRUE" />
  <RemoveMSI />
  <Display Level="None" AcceptEULA="TRUE" />
</Configuration>'


set-content -path $filename -value $xml
choco install office365business --params="/configpath:$filename"

########################Office365 end


choco install sql-server-express
choco install sql-server-management-studio

choco install visualstudio2019community 
choco install visualstudio2019-workload-netweb --package-parameters "--add Microsoft.VisualStudio.Component.ClassDesigner"
choco install visualstudio2019-workload-node 

choco install powershell-core --install-arguments='"ADD_FILE_CONTEXT_MENU_RUNPOWERSHELL=1 ADD_EXPLORER_CONTEXT_MENU_OPENPOWERSHELL=1"'
choco install microsoft-windows-terminal

iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/EricCote/DevTestLabs/master/Artifacts/windows-sql-samples/Install-Samples.ps1'))



