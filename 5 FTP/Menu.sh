#!/bin/bash

source "/home/gael/Desktop/Scripts/Funciones.sh"

# Llamar primero a FTP al iniciar el programa
FTP

while true; do
    echo "Configuracion de los usuarios"
    echo "1) Crear Usuario FTP"
    echo "2) Eliminar Usuario FTP"
    echo "3) Cambiar grupo de usuario FTP"
    echo "4) Salir"
    read -p "Seleccione una de las opciones: " opcion

    case "$opcion" in
        1) 
            read -p "Ingrese un nombre para el usuario: " nombreUsuario
            Crear-UsuarioFTP "$nombreUsuario"
            ;;
        2) 
            read -p "Ingrese el nombre del usuario que desea eliminar: " nombreUsuario
            Eliminar-UsuarioFTP "$nombreUsuario"
            ;;
        3) 
            read -p "Ingrese el nombre del usuario que desea cambiar de grupo: " nombreUsuario
            Cambiar-GrupoFTP "$nombreUsuario"
            ;;
        4) exit 0 ;;
        *) echo "Opción no válida." ;;
    esac
done
