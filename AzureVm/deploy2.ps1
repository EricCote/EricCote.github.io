#Install-Module AzureRM


#Import-Module azurerm.profile

#
##Get-AzureRmContext

<#
 .SYNOPSIS
    Deploys a template to Azure

 .DESCRIPTION
    Deploys an Azure Resource Manager template

 .PARAMETER subscriptionId
    The subscription id where the template will be deployed.

 .PARAMETER resourceGroupName
    The resource group where the template will be deployed. Can be the name of an existing or a new resource group.

 .PARAMETER resourceGroupLocation
    Optional, a resource group location. If specified, will try to create a new resource group in this location. If not specified, assumes resource group is existing.

 .PARAMETER deploymentName
    The deployment name.

 .PARAMETER templateFilePath
    Optional, path to the template file. Defaults to template.json.

 .PARAMETER parametersFilePath
    Optional, path to the parameters file. Defaults to parameters.json. If file is not found, will prompt for parameter values based on template.
#>



<#
.SYNOPSIS
    Registers RPs
#>
Function RegisterRP {
    Param(
        [string]$ResourceProviderNamespace
    )

    Write-Host "Registering resource provider '$ResourceProviderNamespace'";
    Register-AzureRmResourceProvider -ProviderNamespace $ResourceProviderNamespace ;
}



function aaa {
param(

 [string]$subscriptionId = "bc453d64-14e7-4d7c-a387-c44a77dc5b94",

 [string]$resourceGroupName= "win10vm",

 [string]$resourceGroupLocation = "canadaeast" ,

 [string]
 $templateFilePath = "https://raw.githubusercontent.com/EricCote/EricCote.github.io/master/AzureVm/template.json",

 [string]
 $parametersFilePath = "https://raw.githubusercontent.com/EricCote/EricCote.github.io/master/AzureVm/parameters.json"
)



#******************************************************************************
# Script body
# Execution begins here
#******************************************************************************
$ErrorActionPreference = "Stop"

# sign in
Write-Host "Logging in...";
Login-AzureRmAccount;

# select subscription
Write-Host "Selecting subscription '$subscriptionId'";
Select-AzureRmSubscription -SubscriptionID $subscriptionId;

# Register RPs
$resourceProviders = @("microsoft.compute","microsoft.resources","microsoft.storage","microsoft.network");
if($resourceProviders.length) {
    Write-Host "Registering resource providers"
    foreach($resourceProvider in $resourceProviders) {
        RegisterRP($resourceProvider);
    }
}

#Create or check for existing resource group
$resourceGroup = Get-AzureRmResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
if(!$resourceGroup)
{
    Write-Host "Resource group '$resourceGroupName' does not exist. To create a new resource group, please enter a location.";
    if(!$resourceGroupLocation) {
        $resourceGroupLocation = Read-Host "resourceGroupLocation";
    }
    Write-Host "Creating resource group '$resourceGroupName' in location '$resourceGroupLocation'";
    New-AzureRmResourceGroup -Name $resourceGroupName -Location $resourceGroupLocation
}
else{
    Write-Host "Using existing resource group '$resourceGroupName'";
}

# Start the deployment
Write-Host "Starting deployment...";
 New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -TemplateUri $templateFilePath -TemplateParameterUri $parametersFilePath;


$ip = Get-AzureRmPublicIpAddress -Name "win10a-ip" -ResourceGroupName "win10vm"

$ip.DnsSettings = New-Object -TypeName Microsoft.Azure.Commands.Network.Models.PSPublicIpAddressDnsSettings

$ip.DnsSettings.DomainNameLabel="win10a"

Set-AzureRmPublicIpAddress -PublicIpAddress $ip 




}


