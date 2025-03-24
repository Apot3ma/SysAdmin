#!/bin/bash

regex='^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
nombreDominio=''
ipDominio=''

#sudo apt update -y
#sudo apt upgrade -y
#sudo apt autoremove -y
#sudo apt  install bind9 bind9-utils -y
#echo "instalarciones realizadas"
#sudo ufw allow bind9
#echo "Regla del ufw sobre el bind9 ejecutada"

read -p "ingrese la ip del dominio: " ipDominio

while [[ ! $ipDominio =~ $regex ]]; do
	read -p "Dato invalido, ingrese uno valido: " ipDominio
done

read -p "Ingrese el nombre del dns" nombreDominio

sudo cat ./ConfiMin.sh > /etc/bind/named.conf.options

sudo sed -i 's/OPTIONS="-u bind"/OPTIONS="-u bind -4"/g' /etc/default/named

sudo systemctl restart bind9


#agregar zonas
zona=$(echo "$ipDominio" | awk -F'.' '{OFS="."; $NF=""; print substr($0, 1, length($0)-1)}')
zonaInv=$(echo "$ipDominio" | awk -F'.' '{OFS="."; $NF=""; print substr($0, 1, length($0)-1)}' | awk -F'.' '{OFS="."; print $3"."$2"."$1}')

cat > /etc/bind/named.conf.local << EOF
	zone "${nombreDominio}" IN {
		type master;
		file "/etc/bind/zonas/db.${nombreDominio}";
	};


	zone "${zonaInv}.in-addr.arpa" {
		type master;
		file "/etc/bind/zonas/db.${zona}";
	};
EOF

#Crear carpeta de zonas
sudo mkdir -p /etc/bind/zonas

#Zona
cat << EOF > "/etc/bind/zonas/db.${nombreDominio}"
\$TTL    1D

@       IN      SOA     ns1.${nombreDominio}. admin.${nombreDominio}. (

     $(date +%Y%m%d)00  ; Serial

        12h             ; Refresh

        15m             ; Retry

        3w              ; Expire

        2h  )           ; Negative Cache TTL



;       Registros NS



        IN      NS      ns1.${nombreDominio}.

@       IN      A       ${ipDominio}

ns1     IN      A       ${ipDominio}

www     IN      A       ${ipDominio}
EOF

#Zona Inversa
cat << EOF > "/etc/bind/zonas/db.${zona}"
\$TTL    1d ;

@       IN      SOA     ns1.${nombreDominio}. admin.${nombreDominio}. (

                     $(date +%Y%m%d)01  ; Serial

                        12h             ; Refresh

                        15m             ; Retry

                        3w              ; Expire

                        2h      )       ; Negative Cache TTL

;

@      IN      NS      ns1.${nombreDominio}.

1       IN      PTR     www.${nombreDominio}.
EOF

sudo named-checkzone networld.cu /etc/bind/zonas/db.networld.cu
sudo named-checkzone db.20.10.10.in-addr.arpa /etc/bind/zonas/db.10.10.20

read -p "Si el indicador es OK en ambos, presione enter, si no ctrl+C para cancelar"

sudo systemctl restart bind9
systemctl status bind9


