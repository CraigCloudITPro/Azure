$foldername = 'C:\Azure Audit' 
% {Write-Host ""}
Write-Host "Performing Route Table Audit, please be patient..." -Verbose -ForegroundColor Green
% {Write-Host ""}
$rtfilename = "$foldername\RouteTableAudit.csv"
$allResources = @()

    $routetable = Get-AzRouteTable | Get-AzRouteTable -Name $routetable.Name

    foreach($routetables in $routetable) { 

    $routesobject = ConvertFrom-Json -InputObject $routetable.RoutesText

    foreach($routesobjects in $routesobject) {
  
        $customPsObject = New-Object psobject 
        $tags = $resource.Tags.Keys + $resource.Tags.Values -join ':'
 
        $customPsObject | Add-Member -MemberType NoteProperty -Name "Name" -Value $routetable.Name
        $customPsObject | Add-Member -MemberType NoteProperty -Name "ResourceGroupName" -Value $routetable.ResourceGroupName
        $customPsObject | Add-Member -MemberType NoteProperty -Name "Location" -Value $routetable.Location
        $customPsObject | Add-Member -MemberType NoteProperty -Name "RouteName" -Value $routesobject.Name
        $customPsObject | Add-Member -MemberType NoteProperty -Name "AddressPrefix" -Value $routesobject.AddressPrefix
        $customPsObject | Add-Member -MemberType NoteProperty -Name "NextHopIpAddress" -Value $routesobject.NextHopIpAddress
        $customPsObject | Add-Member -MemberType NoteProperty -Name "NextHopType" -Value $routesobject.NextHopType

        $allResources += $customPsObject

        }
  } 

$allResources | Export-Csv $rtfilename -NoTypeInformation -Verbose
