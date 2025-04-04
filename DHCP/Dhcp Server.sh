#!/bin/bash

sudo apt update -y
sudo apt upgrade -y

sudo apt-get install isc-dhcp-server 

sudo sed -i 's/INTERFACESv4=""/INTERFACESv4="ens33"/g' /etc/default/isc-dhcp-server

#cambiar el archivo /etc/netplan/*yaml addresses y dhcp a false
read -p "Ingrese la ip: " Ip

cat << EOF > "/etc/netplan/50-cloud-init.yaml"
network:
  version: 2
  ethernets:
    ens33:
      addresses: [$Ip/24]
      dhcp4: false
EOF

sudo netplan apply  

#necesito configurar el archivo /etc/dhcp/dhcp.conf
echo "escoja una opcion"
echo "1) Ingresar datos manuales"
echo "2) Ingresar datos por defecto"
read Opcion

if ["$Opcion" = "1"]; then
	echo "se a seleccionado la opcion1"
	read -p "Ingrese la subred" Subred
	read -p "Ingrese la mascara" Mascara
	read -p "ingrese la opciones del router" OptRot
	read -p "Ingrese la mascara de la subred" SubMas
	read -p "Ingrese el rango minimo" RanMin
	read -p "Ingrese el rango maximo" RanMax
	
	cat << EOF>> "/etc/dhcp/dhcpd.conf"
		subnet $Subred netmask $Mascara {
			option routers $OptRot;
			option subnet-mask $SubMas;
			range $RanMin $RanMax;
		}
	EOF


elif ["$Opcion" = "2"]; then
	echo "se a seleccionado la opcion 2"
	cat << EOF >> "/etc/dhcp/dhcpd.conf"
		subnet 192.168.100.0 netmask 255.255.255.0 {
			option routers 192.168.100.1;
			option subnet-mask 255.255.255.0;
			range 192.168.100.7 192.168.100.35;
		}
	EOF
	
fi

service isc-dhcp-server restart


