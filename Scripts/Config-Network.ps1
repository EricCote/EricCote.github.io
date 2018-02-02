  Set-VMSwitch -name "external network" `
   -NetAdapterInterfaceDescription "vmxnet3 Ethernet Adapter" `
   -AllowManagementOS $true

$d=get-date

$ip3 = (Get-NetIPAddress -AddressFamily IPv4 -PrefixOrigin Dhcp).IPAddress.Split(".")[-2];
$ip4 = (Get-NetIPAddress -AddressFamily IPv4 -PrefixOrigin Dhcp).IPAddress.Split(".")[-1];

$hex1 = '{0:x2}' -f '00';
$hex2 = '{0:x2}' -f $d.Minute;
$hex3 = '{0:x2}' -f $d.Second;
$hex4 = '{0:x2}' -f ($d.Millisecond % 256);
$hex5 = '{0:x2}' -f ($ip4 -as [int]);

$macAddressStart =$hex1+$hex2+$hex3+$hex4+$hex5+'00';
$macAddressEnd =$hex1+$hex2+$hex3+$hex4+$hex5+'ff';

Set-VMHost -MacAddressMinimum $macAddressStart   -MacAddressMaximum $macAddressEnd

Restore-VMSnapshot -Name "Config Reseau 172.16.0.1-255.255.0.0" -VMName "MS-Gate" -Confirm:$false

#Get-VMNetworkAdapter -vmName "MS-GATE" | `
# where SwitchName -EQ "External Network" | `
# Set-VMNetworkAdapter   -StaticMacAddress $macAddress
 
 
 
 
 
