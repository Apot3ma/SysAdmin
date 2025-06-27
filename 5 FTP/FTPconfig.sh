#!/bin/bash

function instalar_ftp {
    echo "Actualizando el sistema..."
    sudo apt-get update
    sudo apt-get upgrade -y
    # Instalar y configurar vsftpd

    echo "Instalando servidor FTP..."
    sudo apt-get install vsftpd -y
    sudo systemctl start vsftpd

    sudo groupadd reprobados
    sudo groupadd recursadores

    # Crear los directorios necesarios
    sudo mkdir -p /home/ftp/reprobados
    sudo mkdir -p /home/ftp/recursadores
    sudo mkdir -p /home/ftp/usuarios/publico
    sudo mkdir -p /home/ftp/usuarios
    sudo mkdir -p /home/ftp/anonimo
    sudo mkdir -p /home/ftp/anonimo/publico

    # Asignar permisos y propietarios a los directorios
    sudo chown root:reprobados /home/ftp/reprobados
    sudo chown root:recursadores /home/ftp/recursadores
    sudo chown root:root /home/ftp/publico

    sudo chmod 770 /home/ftp/reprobados
    sudo chmod 770 /home/ftp/recursadores
    sudo chmod 755 /home/ftp/publico

    sudo mount --bind /home/ftp/usuarios/publico /home/ftp/anonimo/publico
    sudo chmod 0555 /home/ftp/anonimo/publico

    sed -i 's/#anonymous_enable=NO/anonymous_enable=YES/' /etc/vsftpd.conf
    sed -i 's/#write_enable=YES/write_enable=YES/' /etc/vsftpd.conf
    sed -i 's/LISTEN=NO/LISTEN=YES/' /etc/vsftpd.conf
    sed -i 's/#chroot_local_user=YES/chroot_local_user=YES/' /etc/vsftpd.conf
    sed -i 's/#chroot_list_enable=YES/chroot_list_enable=YES/' /etc/vsftpd.conf
    sed -i 's/#chroot_list_file=/chroot_list_file=/' /etc/vsftpd.conf

    # Reiniciar el servicio vsftpd
    sudo systemctl restart vsftpd

    echo "Servidor FTP instalado y configurado correctamente."
}

Eliminar-UsuarioFTP() {
    local usuario="$1"
    local rutaUsuario="/home/ftp/usuarios/$usuario"

    # Verificar si el usuario existe en el sistema
    if ! id "$usuario" &>/dev/null; then
        echo "El usuario '$usuario' no existe en el sistema."
        return 1
    fi

    # Terminar procesos activos del usuario
    if pgrep -u "$usuario" &>/dev/null; then
        echo "Matando procesos activos del usuario '$usuario'..."
        sudo pkill -u "$usuario"
    fi

    # Esperar a que los procesos terminen
    sleep 2

    # Dar permisos temporales para desmontar
    echo "Ajustando permisos para desmontar las carpetas..."
    sudo chmod -R 755 "$rutaUsuario"

    # Desmontar carpetas montadas antes de eliminarlas
    for carpeta in "$rutaUsuario/publico" "$rutaUsuario/reprobados" "$rutaUsuario/recursadores"; do
        if mountpoint -q "$carpeta"; then
            echo "Desmontando $carpeta..."
            sudo umount "$carpeta"
        fi
    done

    # Verificar que ya no están montadas antes de proceder
    sleep 1
    for carpeta in "$rutaUsuario/publico" "$rutaUsuario/reprobados" "$rutaUsuario/recursadores"; do
        if mountpoint -q "$carpeta"; then
            echo "Error: No se pudo desmontar $carpeta. Intente nuevamente."
            return 1
        fi
    done

    # Eliminar la carpeta del usuario
    if [[ -d "$rutaUsuario" ]]; then
        echo "Eliminando carpeta del usuario '$rutaUsuario'..."
        sudo rm -rf "$rutaUsuario"
        echo "Se eliminó la carpeta de usuario '$rutaUsuario'."
    fi

    # Eliminar al usuario del sistema correctamente
    echo "Eliminando usuario '$usuario' del sistema..."
    sudo userdel -r "$usuario" 2>/dev/null

    # Verificar si el usuario fue eliminado
    if id "$usuario" &>/dev/null; then
        echo "Error: No se pudo eliminar completamente el usuario '$usuario'."
        return 1
    else
        echo "Usuario '$usuario' eliminado correctamente."
    fi
    sudo systemctl restart vsftpd
}

Crear-UsuarioFTP() {
    local usuario=$1
    local grupo=""

    # Validar nombre de usuario
    if [[ ! "$usuario" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo "El nombre de usuario solo puede contener letras, números, guiones y guiones bajos. Intente de nuevo..."
        return 1
    fi

    if [[ ${#usuario} -lt 4 ]]; then
        echo "El nombre de usuario debe tener al menos 4 caracteres. Intente de nuevo..."
        return 1
    fi

    if [[ "$usuario" =~ ^[0-9] ]]; then
        echo "El nombre de usuario no puede comenzar con un número. Intente de nuevo..."
        return 1
    fi

    if [[ ${#usuario} -gt 20 ]]; then
        echo "El nombre de usuario no puede tener más de 20 caracteres. Intente de nuevo..."
        return 1
    fi

    # Seleccionar grupo
    while true; do
        echo "Seleccione un grupo:"
        echo "1) Reprobados"
        echo "2) Recursadores"
        read -p "Ingrese el número del grupo: " opcion

        case $opcion in
            1) grupo="reprobados"; break ;;
            2) grupo="recursadores"; break ;;
            *) echo "opcion invalida,escoja una dentro del margen" ;;
        esac
    done

    # Verificar si el usuario ya existe en el sistema
    if id "$usuario" &>/dev/null; then
        echo "El usuario '$usuario' ya existe en el sistema."
        return 1
    fi

    # Verificar si la carpeta del usuario aún existe (caso de eliminación incorrecta)
    if [[ -d "/home/ftp/usuarios/$usuario" ]]; then
        echo "El usuario '$usuario' no está en el sistema, pero su carpeta sigue existiendo. Eliminándola..."
        sudo rm -rf "/home/ftp/usuarios/$usuario"
    fi

    # Crear usuario en el sistema
    sudo useradd -m -d /home/ftp/usuarios/$usuario -s /bin/bash -G $grupo $usuario
    sudo passwd $usuario

    # Crear estructura de directorios
    sudo mkdir -p /home/ftp/usuarios/$usuario
    sudo mkdir -p /home/ftp/usuarios/$usuario/publico
    sudo mkdir -p /home/ftp/usuarios/$usuario/$grupo
    sudo mkdir -p /home/ftp/usuarios/$usuario/$usuario

    # Asignar permisos
    sudo chown -R $usuario:$usuario /home/ftp/usuarios/$usuario
    sudo chmod 700 /home/ftp/usuarios/$usuario

    # Montar carpetas compartidas
    sudo mount --bind /home/ftp/$grupo /home/ftp/usuarios/$usuario/$grupo
    sudo chown -R $usuario:$usuario /home/ftp/usuarios/$usuario/$grupo
    sudo chmod 775 /home/ftp/usuarios/$usuario/$grupo

    sudo mount --bind /home/ftp/publico /home/ftp/usuarios/$usuario/publico
    sudo chown -R $usuario:$usuario /home/ftp/usuarios/$usuario/publico
    sudo chmod 777 /home/ftp/usuarios/$usuario/publico

    echo "Usuario '$usuario' creado correctamente en el grupo '$grupo'."
    sudo systemctl restart vsftpd
}