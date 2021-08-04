<#

.SYNOPSIS

    Helper Module

.NOTES

    File Name        : Helper.psm1
    Author           : Craig Fretwell
    Company          : CraigCloudITPro 
    Version          : 1.0
    Date             : 29-November-2019
    Updated          : 29-November-2019
    Requires         : PowerShell 5.1 or later
    Operating System : Windows 10
    Module           : Helper.psm1
    RunAs            : Administrator {Set-ExecutionPolicy Un-Restricted}

#>

Write-Host "PowerShell Module Loading...." -ForegroundColor Green

Function Create-AZResourceGroup {

    [CmdletBinding()]
    param (
        [string]$ResourceGroupName,
        [string]$location 
    )

    % {Write-Host ""}
    Write-Host "Creating "$ResourceGroupName" Resource Group..." -ForegroundColor Yellow; 
    % {Write-Host ""}
    New-AzResourceGroup -Name $ResourceGroupName -Location $location -Force
   
}

Function Get-VMPIP {

    [CmdletBinding()]
    param (
        [string]$ResourceGroupName,
        [string]$VMName, 
        [string]$localuseradmin,
        [string]$localadminpassword
    )

    $azurevmpublicip = Get-AzPublicIpAddress -ResourceGroupName $ResourceGroupName -Name $VMName-publicip01
    % {Write-Host ""}
    Write-Host "The Jump Box Public IP Address is..." -ForegroundColor Green; 
    % {Write-Host ""}
    % {Write-Host ""}
    % {Write-Host ""}
    $azurevmpublicip.IpAddress 
    % {Write-Host ""}
    % {Write-Host ""}
    % {Write-Host ""}
    Write-Host "Launching RDP with secure credentials..." -ForegroundColor Green; 
    % {Write-Host ""}
    cmdkey /add: $azurevmpublicip.IpAddress /user: $localuseradmin /pass: $localadminpassword
    mstsc /v: $azurevmpublicip.IpAddress

}


Function Get-PublicIP {

    $yourpublicip = Invoke-RestMethod http://ipinfo.io/json | Select -exp ip
% {Write-Host ""}
Write-Host "Your Public Ip Address is...$yourpublicip" -ForegroundColor Green; 
% {Write-Host ""}
}

Export-ModuleMember Function Create-AZResourceGroup -ErrorAction Ignore -WarningAction Ignore 
Export-ModuleMember Function Get-PublicIP -ErrorAction Ignore -WarningAction Ignore
Export-ModuleMember Function Upload-AuditLog -ErrorAction Ignore -WarningAction Ignore
Export-ModuleMember Function Get-VMPIP -ErrorAction Ignore -WarningAction Ignore