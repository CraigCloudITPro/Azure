# Azure Audit 

![](https://user-images.githubusercontent.com/8083855/47106128-dbb6a280-d256-11e8-9fda-d37b8e5580c7.png) 


This repository contains a selection of PowerShell scripts for developers and administrators to audit specific resources in Microsoft Azure.

## Pre Reqs

### PowerShell Gallery

Run the following command in an elevated PowerShell session to install the rollup module for Azure PowerShell cmdlets:

```powershell
Install-Module -Name Az
```

This module runs on Windows PowerShell with [.NET Framework 4.7.2][DotNetFramework] or greater, or [PowerShell Core][PowerShellCore]. The `Az` module replaces `AzureRM`. You should not install `Az` side-by-side with `AzureRM`.

If you have an earlier version of the Azure PowerShell modules installed from the PowerShell Gallery and would like to update to the latest version, run the following commands in an elevated PowerShell session:

```powershell
Update-Module -Name Az
```

`Update-Module` installs the new version side-by-side with previous versions. It does not uninstall the previous versions.

--------

### Contribute Code

As a baseline, if you would like to become an active contributor to this project, please follow the instructions provided in https://opensource.microsoft.com/resources Contribution Guidelines

## Learn more visit my personal blog

[Craig Cloud IT Pro Blog](https://craigclouditpro.wordpress.com/)
