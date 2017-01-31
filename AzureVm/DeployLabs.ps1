Install-Module AzureRM
Import-Module azurerm

$PSVersionTable.PSVersion

Get-Module -ListAvailable Azure*
Set-ExecutionPolicy -ExecutionPolicy bypass -Scope Process

Install-AzureRM
 Import-AzureRM
 update-azurerm

Import-Module AzureRM


# To log in to Azure Resource Manager
Login-AzureRmAccount

# You can also use a specific Tenant if you would like a faster log in experience
# Login-AzureRmAccount -TenantId xxxx

# To view all subscriptions for your account
Get-AzureRmSubscription

# To select a default subscription for your current session.
# This is useful when you have multiple subscriptions.
Get-AzureRmSubscription -SubscriptionName "Msdn2 sub" | Select-AzureRmSubscription

# View your current Azure PowerShell session context
# This session state is only applicable to the current session and will not affect other sessions
Get-AzureRmContext

Get-AzureRmStorageAccount | Get-AzureStorageContainer | Get-AzureStorageBlob


$PlainPassword = "afi12345678!"
$SecurePassword = $PlainPassword | ConvertTo-SecureString -AsPlainText -Force


$CreateLabTemplate = "https://raw.githubusercontent.com/Azure/azure-devtestlab/master/ARMTemplates/101-dtl-create-lab/azuredeploy.json"
$createVMTemplate="https://raw.githubusercontent.com/Azure/azure-devtestlab/master/ARMTemplates/101-dtl-create-vm-username-pwd-galleryimage/azuredeploy.json"
$createFormulaTemplate="https://raw.githubusercontent.com/Azure/azure-devtestlab/master/ARMTemplates/201-dtl-create-formula/azuredeploy.json"

$createLab= "C:\code\EricCote.github.io\AzureVm\template.json"
$createFormula="C:\code\EricCote.github.io\AzureVm\FormulaTemplate.json"
$deployVm="C:\code\EricCote.github.io\AzureVm\DeployVm.json"

New-AzureRmResourceGroup -Name "monCoursWebApi2" -Location "Canada East"

New-AzureRmResourceGroupDeployment -name "CoursWebApi12345" `
                                   -ResourceGroupName "monCoursWebApi2" `
                                   -TemplateFile $CreateLabTemplate `
                                   -newLabName "CoursApi"

New-AzureRmResourceGroupDeployment -name "CoursWebApi99" `                                   -ResourceGroupName "monCoursWebApi2" `
                                   -TemplateUri $createVMTemplate `
                                   -newVMName "coursWeb01" `
                                   -existingLabName "CoursApi" `
                                   -offer "Windows" `
                                   -publisher "MicrosoftVisualStudio" `
                                   -sku "Windows-10-N-x64" `
                                   -osType "Windows" `
                                   -version "50.2.2" `
                                   -newVMSize "Standard_DS2_V2" `
                                   -userName "afi" `
                                   -password $SecurePassword

New-AzureRmResourceGroupDeployment -name "CoursWebApi99" `                                   -ResourceGroupName "monCoursWebApi" `
                                   -TemplateFile $createFormula `
                                   -formulaName "win10Formula" `
                                   -existingLabName "CoursApi"
                                  
New-AzureRmResourceGroupDeployment -name "CoursWebApi97" `                                   -ResourceGroupName "monCoursWebApi2" `
                                   -TemplateFile $deployVm `
                                   -newVMName "CoursApi" `
                                   -labName "CoursApi" `
                                   -numberOfInstances 3


 $labProperties = (Get-AzureRmResource -ResourceName CoursApi -ResourceType "microsoft.devtestlab/labs" -ResourceGroupName CoursWebApi).Properties
    $labStorageAccountName = $labProperties['defaultStorageAccount']











    $lab = Get-AzureRmResource -ResourceId ('subscriptions/293da491-699f-4085-a089-ac26c94b68d2/resourceGroups/monCoursWebApi2/providers/Microsoft.DevTestLab/labs/coursapi')

# Get the VMs from that lab.
$labVMs = Get-AzureRmResource | Where-Object { 
          $_.ResourceType -eq 'microsoft.devtestlab/labs/virtualmachines' -and
          $_.ResourceName -like "$($lab.ResourceName)/*"}

# Delete the VMs.
foreach($labVM in $labVMs)
{
    Remove-AzureRmResource -ResourceId $labVM.ResourceId -Force
}


Remove-AzureRmResourceGroup -Name "CoursWebApi" -force