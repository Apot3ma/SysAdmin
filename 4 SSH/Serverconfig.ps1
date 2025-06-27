. "$PSScriptRoot\lib.ps1"

do{
    Write-Output "Bienvenido al menu de configuracion del servidor ssh"
    Write-Output "1. instalacion de ssh"
    Write-Output "2. estado del servidor"
    Write-Output "3. reiniciar el servidor"
    Write-Output "4. ver ip"
    Write-Output "5. crear usuario"
    Write-Output "6. ver usuarios"
    Write-Output "7. eliminar usuario"
    Write-Output "8. salir"
    $opcion = Read-Host "Seleccione una opcion"
    switch ($opcion) {
        1 {
            # Instalar el servidor SSH
            instalar-ssh
        }
        2 {
            # Verificar el estado del servidor SSH
            ver-estado-ssh
        }
        3 {
            # Reiniciar el servidor SSH
            reiniciar-ssh
        }
        4 {
            # Ver la dirección IP
            ver_ip
        }
        5 {
            # Crear un nuevo usuario
            $username = Read-Host "Ingrese el nombre de usuario"
            $password = Read-Host "Ingrese la contraseña" -AsSecureString
            #asi se llama a la funcion y se le pasan los argumentos
            # Convertir la contraseña a un SecureString
            crear_usuario -username $username -password $password
        }
        6 {
            # Ver los usuarios locales
            ver_usuarios
        }
        7 {
            # Eliminar un usuario
            $username = Read-Host "Ingrese el nombre de usuario a eliminar"
            eliminar_usuario -username $username
        }
        8 {
            # Salir del script
            salir
        }
    }

    $op = Read-Host "Desea continuar (s/n)?"
}while($op -eq 's' -or $op -eq 'S')


