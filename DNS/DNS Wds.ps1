#Instala el dns
Install-WindowsFeature -Name DNS -IncludeManagementTools

$IpDns = Read-Host "Ingrese la ip para la zona"

$NombreDns = Read-Host "Ingrese el nombre para la zona"

#Genera el archivo dns
Add-DnsServerPrimaryZone -Name "$NombreDns" -ZoneFile "$NombreDns.dns"

#Genera la zona 

Add-DnsServerResourceRecordA -Name "servidor" -ZoneName "$NombreDns" -IPv4Address "IpDns"

#resoluciones para el servidor dns

Set-DnsServerForwarder -IPAddress "8.8.8.8", "8.8.4.4"

Get-DnsServerZone -Name "$NombreDns"

Get-DnsServerResourceRecord -ZoneName "$NombreDns"

#comando para importar manualmente en la sesion de powershell
# Import-Module DnsServer

#"Dato basura"ip de la maquina 192.168.100.133


#generamos la zona A el @ y el cname con el www para reprobados.com

Add-DnsServerResourceRecordA -ZoneName "$NombreDns" -Name "@" -IPv4Address "IpDns"

Get-DnsServerResourceRecord -ZoneName "$NombreDns" -RRType "A"

Add-DnsServerResourceRecordCName -ZoneName "$NombreDns" -Name "www" -HostNameAlias "$NombreDns"