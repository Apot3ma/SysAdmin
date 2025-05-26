function instalar-ssh {
    # Verificar si OpenSSH ya está instalado
    $sshInstalled = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*' | Select-Object -ExpandProperty State

    if ($sshInstalled -eq 'NotPresent') {
        # Instalar OpenSSH
        Add-WindowsCapability -Online -Name OpenSSH.Server~~~~
        # Iniciar el servicio SSH
    }
}

function ver-estado-ssh {
    # Verificar el estado del servicio SSH
    $sshService = Get-Service -Name sshd
    if ($sshService.Status -eq 'Running') {
        Write-Host "El servicio SSH está en ejecución."
    } else {
        Write-Host "El servicio SSH no está en ejecución."
    }
}

function reiniciar-ssh {
    # Reiniciar el servicio SSH
    Restart-Service sshd
    Write-Host "Servicio SSH reiniciado."
}

function ver_ip {
    # Obtener todas las direcciones IPv4 activas
    $ips = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike '169.*' -and $_.IPAddress -ne '127.0.0.1' }
    if ($ips) {
        foreach ($ip in $ips) {
            Write-Host "Interfaz: $($ip.InterfaceAlias) - IP: $($ip.IPAddress)"
        }
    } else {
        Write-Host "No se encontró ninguna dirección IP válida."
    }
}

function crear_usuario {
    param (
        [string]$username,
        [system.Security.SecureString]$password
    )

    # Crear un nuevo usuario
    $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
    New-LocalUser -Name $username -Password $securePassword -FullName $username -Description "Usuario SSH"
    Write-Host "Usuario $username creado."
}

function ver_usuarios {
    # Verificar los usuarios locales
    $usuarios = Get-LocalUser
    Write-Host "Usuarios locales:"
    foreach ($usuario in $usuarios) {
        Write-Host $usuario.Name
    }
}

function eliminar_usuario {
    param (
        [string]$username
    )

    # Eliminar un usuario
    Remove-LocalUser -Name $username
    Write-Host "Usuario $username eliminado."
}

function salir {
    # Salir del script
    Write-Host "Saliendo..."
    exit
}