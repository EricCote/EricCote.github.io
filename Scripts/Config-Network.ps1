 Set-VMSwitch -name "external network" `
   -NetAdapterInterfaceDescription "vmxnet3 Ethernet Adapter" `
   -AllowManagementOS $true

$d=get-date

$ip3 = (Get-NetIPAddress -AddressFamily IPv4 -PrefixOrigin Dhcp).IPAddress.Split(".")[-2];
$ip4 = (Get-NetIPAddress -AddressFamily IPv4 -PrefixOrigin Dhcp).IPAddress.Split(".")[-1];

$hex1 = '{0:x2}' -f $d.Day;
$hex2 = '{0:x2}' -f $d.Hour;
$hex3 = '{0:x2}' -f $d.Minute;
$hex4 = '{0:x2}' -f $d.Second;
$hex5 = '{0:x2}' -f ($d.Millisecond % 256);
$hex6 = '{0:x2}' -f ($ip4 -as [int]);
　
$macAddress =$hex1+$hex2+$hex3+$hex4+$hex5+$hex6;
　
Get-VMNetworkAdapter -vmName "win" | `
 where SwitchName -EQ "external Network" | `
 Set-VMNetworkAdapter   -StaticMacAddress $macAddress
 
 
 
 