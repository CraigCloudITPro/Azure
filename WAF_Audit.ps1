    $foldername = "C:\Azure Audit"
    % {Write-Host ""}
    Write-Host "Performing Azure WAF Audit..." -Verbose -ForegroundColor Yellow
    % {Write-Host ""}
    $filename = "$foldername\WAFAudit.csv"
    $allResources = @()
        
    $resources = Get-AzApplicationGateway
    foreach ($resource in $resources)
    {
        $customPsObject = New-Object -TypeName PsObject

        $customPsObject | Add-Member -MemberType NoteProperty -Name ApplicationGatewayName -Value $resource.Name -Verbose
        $customPsObject | Add-Member -MemberType NoteProperty -Name Location -Value $resource.Location -Verbose
        $customPsObject | Add-Member -MemberType NoteProperty -Name ResourceGroupName -Value $resource.ResourceGroupName -Verbose
        $customPsObject | Add-Member -MemberType NoteProperty -Name BackendAddressPools -Value $resource.BackendAddressPools.Name
        $customPsObject | Add-Member -MemberType NoteProperty -Name Sku -Value $resource.Sku.Tier
        $customPsObject | Add-Member -MemberType NoteProperty -Name WAFEnabled -Value $resource.WebApplicationFirewallConfiguration
        $customPsObject | Add-Member -MemberType NoteProperty -Name PrivateIPConfig -Value $resource.FrontendIPConfigurations.privateipaddress  
        $customPsObject | Add-Member -MemberType NoteProperty -Name PublicIPConfig -Value $resource.FrontendIPConfigurations.publicipaddresstext   
        $i = 0
        
        foreach ($listener in $resource.HTTPListeners)
        {
            $subnetString = $resource.HTTPListeners[$i].Name
            $subnetString1 = $resource.HTTPListeners[$i].Protocol
            $subnetString2 = $resource.HTTPListeners[$i].HostName
            $customPsObject | Add-Member -MemberType NoteProperty -Name ("HTTPListeners-" + $i) -Value $subnetString
            $customPsObject | Add-Member -MemberType NoteProperty -Name ("HTTPProtocol-" + $i) -Value $subnetString1
            $customPsObject | Add-Member -MemberType NoteProperty -Name ("Hostname-" + $i) -Value $subnetString2
            $i++
        }
       
        $allResources += $customPsObject
    }

    $allResources | Export-Csv $filename -NoTypeInformation -Append -Force
