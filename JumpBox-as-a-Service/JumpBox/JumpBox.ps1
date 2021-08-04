<#

.SYNOPSIS

    This script will deploy an on Demand single Virtual Machine & Network Security Group to be used as a JumpBox.
    It will pass your Public IP Address as an Allowed rule into the NSG on 3389.
    For Security purposes credentials are randomly generated so the purpose is to use this VM for 1 time only.
    Once you've completed your tasks within the JumpBox go back to the PowerShell console and enter "yes" twice, 
    this will remove what you've just deployed from the portal.

    *PLEASE NOTE* You will need to have an existing Virtual Network and Subnet available.
    
    
.DESCRIPTION

<<<<The following resources will be deployed:>>>>

    Virtual Machine (with Public IP Address)
    Network Security Group (with your Public IP in the Allow Rule)

.NOTES

    File Name        : JumpBox.ps1
    Author           : Craig Fretwell
    Company          : CraigCloudITPro
    Version          : 1.0
    Date             : 28-November-2019
    Updated          : 28-November-2019
    Requires         : PowerShell 5.1 or later
    Operating System : Windows 10
    Module           : Helper.psm1, Az Version 2.5.0
    RunAs            : Administrator {Set-ExecutionPolicy Un-Restricted}

.EXAMPLE

PS: .\JumpBox.ps1

#>

[CmdletBinding()]

Param

( 

    [Parameter(Mandatory=$true,
    HelpMessage="Name of Virtual Machine")]
    [string]$VMName,

    [Parameter(Mandatory=$false,
    HelpMessage="Geographical Location")]
    [string]$location = "West Europe"             ,

    [Parameter(Mandatory=$true,
    HelpMessage="New Resource Group Name which you're deploying into")]
    [string]$ResourceGroupName = "RG-TestJump" ,

    [Parameter(Mandatory=$false,
    HelpMessage="Virtual Network Resource Group Name")]
    [string]$VnetResourceGroupName = "RG-Vnet"       ,

    [Parameter(Mandatory=$false,
    HelpMessage="Existing Virtual Network Name")]
    [string]$VnetName = "HubVnet"        ,

    [Parameter(Mandatory=$false,
    HelpMessage="Existing Subnet Name for Jump Box Virtual Machine")]
    [string]$VMSubnetName = "jump-Tier-Subnet"     ,                 
    
    [Parameter(Mandatory=$false,
    HelpMessage="Local Admin Username for Jumpbox Virtual Machine")]
    [string]$localuseradmin = "azureadmin"     ,

    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [string]$VMSize = "Standard_D4s_v3"                            

)

$ErrorActionPreference = 'silentlycontinue'
$filepath = "$Env:UserProfile\Downloads\JumpBox-as-a-Service\Jumpbox"
Set-Location $filepath
Set-ExecutionPolicy Unrestricted -Force -ErrorAction SilentlyContinue

#Import-Module .\Helper.psm1

if (Get-Module -ListAvailable -Name .\Helper.psm1) {

    Write-Host "CraigCloudITPro Module exists...Importing Module" -ForegroundColor Green; Import-Module .\Helper.psm1 -ErrorAction SilentlyContinue 
} 
else {
    Write-Host "CraigCloudITPro Module does not exist....Please Import Module before running Script...Exiting PowerShell"; 
}

Function Login {
    $needLogin = $true
    Try {
    $content = Get-AzContext
    if ($content) {
    $needLogin = ([string]::IsNullOrEmpty($content.Account))
    } 
    } 
    Catch {
    if ($_ -like "*Login-AzAccount to login*") {
    $needLogin = $true
    } 
    else {
    throw
    }
    }
   
    if ($needLogin) {
    Login-AzAccount
    }
   }

Login

Function AzSubscription {
    Function Select-Subscription {
        Clear-Host
        $ErrorActionPreference = 'SilentlyContinue'
        $Menu = 0
        $Subs = @(Get-AzSubscription | select Name, ID, TenantId)
    
        Write-Host "Please select the subscription you want to use" -ForegroundColor Green;
        % {Write-Host ""}
        $Subs | % {Write-Host "[$($Menu)]" -ForegroundColor Cyan -NoNewline ; Write-host ". $($_.Name)"; $Menu++; }
        % {Write-Host ""}
        % {Write-Host "[S]" -ForegroundColor Yellow -NoNewline ; Write-host ". To switch Azure Account."}
        % {Write-Host ""}
        % {Write-Host "[Q]" -ForegroundColor Red -NoNewline ; Write-host ". To quit."}
        % {Write-Host ""}
        $selection = Read-Host "Please select the Subscription Number - Valid numbers are 0 - $($Subs.count -1), S to switch Azure Account or Q to quit"
        If ($selection -eq 'S') { 
            Get-AzContext | ForEach-Object {Clear-AzContext -Scope CurrentUser -Force}
            Select-Subscription
        }
        If ($selection -eq 'Q') { 
            Clear-Host
    
        }
        If ($Subs.item($selection) -ne $null)
        { Return @{name = $subs[$selection].Name; ID = $subs[$selection].ID} 
        }
    
    }
    
    $Sub = Select-Subscription
    Select-AzSubscription -SubscriptionName $Sub.Name -ErrorAction Stop
    % {Write-Host ""}
    Write-Host "You're currently logged into Subscription" -ForegroundColor Yellow; 
    % {Write-Host ""}
    Write-Host $sub.Name -ForegroundColor Green; 
    
}

AzSubscription
Clear-Host

% {Write-Host " Running.....

   ____           _          ____ _                 _   ___ _____   ____             
  / ___|_ __ __ _(_) __ _   / ___| | ___  _   _  __| | |_ _|_   _| |  _ \ _ __ ___   
 | |   |  __/ _  | |/ _  | | |   | |/ _ \| | | |/ _  |  | |  | |   | |_) |  __/ _ \  
 | |___| | | (_| | | (_| | | |___| | (_) | |_| | (_| |  | |  | |   |  __/| | | (_) | 
  \____|_|  \__,_|_|\__, |  \____|_|\___/ \__,_|\__,_| |___| |_|   |_|   |_|  \___/  
                    |___/                                                            

" -ForegroundColor Green}

Start-Sleep -Seconds 1

################# Hardcoded Values ####################################

$yourpublicip = Invoke-RestMethod http://ipinfo.io/json | Select -exp ip
% {Write-Host ""}
Write-Host "Your Public Ip Address is...$yourpublicip" -ForegroundColor Green; 
% {Write-Host ""}

################# Generating Secure Credentials Credentials ########################################

$localadminpassword = New-Object -TypeName PSObject
$localadminpassword | Add-Member -MemberType ScriptProperty -Name "Password" -Value { ("!@#$%^&*0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz".tochararray() | sort {Get-Random})[0..8] -join '' }

################# Create Azure Resource Group ####################################

Create-AZResourceGroup -ResourceGroupName $ResourceGroupName -Location $location 

################# Virtual Machine Template Parameters ###############################
  
$vmparams =@{ 

        LocalAdminUsername = "$localuseradmin"
        LocalAdminPassword = "$localadminpassword"
        NetworkResourceGroup = "$VnetResourceGroupName"
        NetworkName = "$VnetName"
        SubnetName = "$VMSubnetName"
        VMName = "$VMName"
        VMSize = "$VMSize"
}

################# VM Network Security Group Template Parameters #################

$vmnsgparams =@{ 

        location = "$location"
        VMName = "$VMName"
        yourpublicip = "$yourpublicip"
 }

################# Virtual Machine Function Deployment ###############################

Function DeployVirtualMachine {
 
    $today = Get-Date -Format "dd-mm-yyyy"
    $suffix = Get-Random -Maximum 100
    $deployName = "$ResourceGroupName" + "$today" + "_$suffix"
    $templateFileLoc = "$filepath\azuredeploy_jumpbox_vm.json" 
    
    New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -Name $deployName -TemplateUri $templateFileLoc -TemplateParameterObject $vmparams -Verbose -ErrorAction Stop
}

################# Network Security Group Function Deployment ###############################

Function DeployVMNSG {

    $today = Get-Date -Format "dd-mm-yyyy"
    $suffix = Get-Random -Maximum 100
    $deployName = "$ResourceGroupName" + "$today" + "_$suffix"
    $templateFileLoc = "$filepath\azuredeploy_jumpbox_nsg.json" 
    
    New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -Name $deployName -TemplateUri $templateFileLoc -TemplateParameterObject $VMnsgparams -Verbose -ErrorAction Stop
    
    $nic = Get-AzNetworkInterface -ResourceGroupName $resourcegroupname -Name $VMName-nic01 -Verbose
    $nsg = Get-AzNetworkSecurityGroup -ResourceGroupName $ResourceGroupName -Name $VMName-nsg01 -Verbose
    $nic.NetworkSecurityGroup = $nsg
    $nic | Set-AzNetworkInterface -Verbose
}

################# Running Main Functions of Script ###############################

Start-Sleep -Seconds 5
DeployVirtualMachine
Start-Sleep -Seconds 5
DeployVMNSG 
Start-Sleep -Seconds 5

################# Launch RDP and log into JumpBox VM  ###############################

Get-VMPIP -ResourceGroupName $ResourceGroupName -VMName $VMName -localuseradmin $localuseradmin -localadminpassword $localadminpassword -Verbose
 
################################## Clearing Credentials #######################################

% {Write-Host ""}
Write-Host "Clearing credentials from memory..." -ForegroundColor Yellow; 
% {Write-Host ""}

$localuseradmin = $null
$localadminpassword = $null

% {Write-Host ""}
Write-Host "JumpBox Deployment Complete..." -ForegroundColor Green; 
% {Write-Host ""}

############################ Waiting for User Prompt to finish with Jump Box #########################

% {Write-Host " 


 ____           _   _  ___ _____         _                   _   _     _                 _           _                 _ 
|  _ \  ___    | \ | |/ _ \_   _|    ___| | ___  ___  ___   | |_| |__ (_)___   __      _(_)_ __   __| | _____      __ | |
| | | |/ _ \   |  \| | | | || |     / __| |/ _ \/ __|/ _ \  | __| '_ \| / __|  \ \ /\ / / | '_ \ / _  |/ _ \ \ /\ / / | |
| |_| | (_) |  | |\  | |_| || |    | (__| | (_) \__ \  __/  | |_| | | | \__ \   \ V  V /| | | | | (_| | (_) \ V  V /  |_|
|____/ \___/   |_| \_|\___/ |_|     \___|_|\___/|___/\___|   \__|_| |_|_|___/    \_/\_/ |_|_| |_|\__,_|\___/ \_/\_/   (_)
                                                                                                                                                                                                                                                                      
                           
                        
  " -ForegroundColor Red}
Function Remove-ResourceGroup {

Write-Host "Are you fininshed with the Jump Box??" -ForegroundColor Yellow 
% {Write-Host ""}
% {Write-Host ""}    
    $Readhost = Read-Host "yes / no  " 
do {
    $response = Read-Host -Prompt $Readhost
    if ($response -eq 'no' ) {Write-Host "Are you finished with the Jump Box??" -ForegroundColor Yellow  }
} until ($response -eq 'yes') 

% {Write-Host ""}
% {Write-Host ""}
Write-host "Removing Jumpbox Resource Group $ResourceGroupName... This can take a few minutes" -ForegroundColor Red;
% {Write-Host ""}
% {Write-Host ""}

Invoke-Command -ScriptBlock { Remove-AzResourceGroup -ResourceGroupName $ResourceGroupName -Verbose}

}

Remove-ResourceGroup
Write-Host "All resources cleaned up..." -ForegroundColor Green;