#!/bin/bash
# Bienvenido al menu de configuracion del cliente ssh
# echo "1. instalacion de ssh"
function instalar_ssh {
    sudo apt update -y
    sudo apt upgrade -y
    sudo apt install openssh-server -y
}
# echo "2. estado del servidor"
function estado_ssh {
    systemctl status ssh
}
# echo "3. reiniciar el servidor"
function reiniciar_ssh {
    systemctl restart ssh
}
# echo "4. ver ip"
function ver_ip {
    ip addr show
}
# echo "5. crear usuario"
function crear_usuario {
    read -p "ingrese el nombre del usuario: " usuario
    sudo adduser $usuario
}
# echo "6. ver usuarios"
function ver_usuarios {
    cut -d: -f1 /etc/passwd
}
# echo "7. eliminar usuario"
function eliminar_usuario {
    read -p "ingrese el nombre del usuario: " usuario
    sudo deluser $usuario
}
# echo "8. salir"
function salir {
    exit 0
}