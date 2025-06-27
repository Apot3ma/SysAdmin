#!/bin/bash
source "$(dirname "$0")/Lib.sh"


echo "Bienvenido al menu de configuracion del servidor ssh"
echo "1. instalacion de ssh"
echo "2. estado del servidor"
echo "3. reiniciar el servidor"
echo "4. ver ip"
echo "5. crear usuario"
echo "6. ver usuarios"
echo "7. eliminar usuario"
echo "8. salir"
read -p "ingrese la opcion deseada: " opcion

case $opcion in
    1)
        echo "instalando ssh"
        instalar_ssh
        ;;
    2)
        echo "verificando el estado del servidor ssh"
        estado_ssh
        ;;
    3)
        echo "reiniciando el servidor ssh"
        reiniciar_ssh
        ;;
    4)
        echo "verificando la ip del servidor ssh"
        ver_ip
        ;;
    5)
        echo "creando usuario"
        crear_usuario
        ;;
    6)
        echo "verificando los usuarios"
        ver_usuarios
        ;;
    7)
        echo "eliminando usuario"
        eliminar_usuario
        ;;
    8)
        echo "saliendo del menu de configuracion del servidor ssh"
        exit 0
        ;;
    *)
        echo "opcion no valida"
        ;;
esac
echo "¿Desea realizar otra accion? (s/n)"
read respuesta
if [ "$respuesta" == "s" ]; then
    ./ssh/Serverconfig.sh
else
    echo "saliendo del menu de configuracion del servidor ssh"
    exit 0
fi