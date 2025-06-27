#!/bin/bash
# Bienvenido al menu de configuracion del cliente ssh
# echo "1. instalacion de ssh"
function instalar_ssh {
    sudo apt update -y
    sudo apt upgrade -y
    sudo apt install openssh-server -y
    sudo ufw allow 22
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
function crear_usuario() {
    read -p "Ingrese el nombre del usuario: " usuario
    
    # Crear usuario con home y shell bash
    sudo adduser --shell /bin/bash --disabled-password --gecos "" "$usuario"
    
    # Pedir la contraseña
    read -s -p "Ingrese la contraseña para $usuario: " contrasena
    echo
    read -s -p "Confirme la contraseña: " contrasena2
    echo
    
    if [ "$contrasena" != "$contrasena2" ]; then
        echo "Las contraseñas no coinciden. Abortando."
        return 1
    fi
    
    # Establecer la contraseña usando chpasswd
    echo "$usuario:$contrasena" | sudo chpasswd
    
    # Asegurarse que la cuenta no esté bloqueada (quitar ! en /etc/shadow)
    sudo sed -i "/^$usuario:/ s/!//" /etc/shadow
    
    # (Opcional) Verificar que el shell sea /bin/bash
    sudo usermod -s /bin/bash "$usuario"
    
    echo "Usuario $usuario creado y contraseña asignada correctamente."
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