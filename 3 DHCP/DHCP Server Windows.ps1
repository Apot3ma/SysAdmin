Install-WindowsFeature -Name DHCP -IncludeManagementTools


Get-NetAdapter

$IpDhcp = Read-Host "ingrese su la ip estatica para el DHCP"
$Nombre = Read-Host "Ingrese el nombre del servidor"
$IpMin = Read-Host "Ingese la ip minima del rango"
$IpMax = Read-Host "Ingrese la ip maxima del rango"
$Mascara = Read-Host "Ingrese la mascara"


New-NetIPAddress -InterfaceAlias "Ethernet0" -IPAddress $IpDhcp -PrefixLength "24"

Add-DhcpServerv4Scope -Name "$Nombre" -StartRange $IpMin -EndRange $IpMax -SubnetMask $Mascara