#---------------------------------------------------------------------------------------- HTTP

function Get-ValidPort {
    $reservedPorts = @(21, 22, 23, 25, 53, 110, 119, 123, 135, 137, 138, 139, 143, 161, 162, 389, 443, 445, 465, 587, 636, 993, 995, 1433, 1521, 1723, 3306, 3389, 5900)

    do {
        $port = Read-Host "Ingrese el puerto"

        # Validar que el puerto sea un número
        if ($port -match "^\d+$") {
            $port = [int]$port

            if ($port -eq 0 -or $port -gt 65535) {
                Write-Host "El puerto debe ser un número entre 1 y 65535. Intente con otro."
                continue
            }

            # Verificar si está en la lista de reservados
            if ($reservedPorts -contains $port) {
                Write-Host "El puerto $port está reservado para otro servicio. Intente con otro."
                continue
            }

            # Verificar si el puerto está en uso
            $inUse = Test-NetConnection -Port $port -ComputerName "localhost" | Select-Object -ExpandProperty TcpTestSucceeded
            
            if (-not $inUse) {
                return $port
            } else {
                Write-Host "El puerto $port ya está en uso. Intente con otro."
            }
        } else {
            Write-Host "Puerto inválido."
        }
    } while ($true)
}


# Función para obtener la versión de Tomcat elegida por el usuario
function Get-TomcatVersion {
    do {
        Write-Host "Seleccione la versión de Tomcat a instalar:"
        Write-Host "1 - LTS"
        Write-Host "2 - Desarrollo"
        $selection = Read-Host "Ingrese su opción (1 o 2)"
        
        if ($selection -eq "1") {
            return "10.1.39"
        } elseif ($selection -eq "2") {
            return "11.0.5"
        } else {
            Write-Host "Opción inválida. Intente de nuevo."
        }
    } while ($true)
}


# Función para instalar Tomcat
function Install-Tomcat {
    param (
        [string]$tomcatVersion,
        [int]$port
    )
    
    # Definir la URL de descarga según la versión seleccionada
    if ($tomcatVersion -like "10.*") {
        $downloadUrl = "https://dlcdn.apache.org/tomcat/tomcat-10/v$tomcatVersion/bin/apache-tomcat-$tomcatVersion-windows-x64.zip"
    } elseif ($tomcatVersion -like "11.*") {
        $downloadUrl = "https://dlcdn.apache.org/tomcat/tomcat-11/v$tomcatVersion/bin/apache-tomcat-$tomcatVersion-windows-x64.zip"
    } else {
        Write-Host "Error: Versión de Tomcat no válida."
        return
    }
    
    # Definir rutas de instalación y archivos
    $installPath = "C:\Tomcat\apache-tomcat-$tomcatVersion"
    $zipFile = "C:\Temp\apache-tomcat-$tomcatVersion.zip"
    $serviceName = "Tomcat$($tomcatVersion.Split('.')[0])"  # Tomcat10 o Tomcat11

    # Verificar si el servicio ya existe
    if (Get-Service -Name $serviceName -ErrorAction SilentlyContinue) {
        Write-Host "El servicio $serviceName ya existe. Volviendo al menú..."
        return
    }
    
    # Crear carpeta temporal si no existe
    if (!(Test-Path "C:\Temp")) { 
        New-Item -Path "C:\Temp" -ItemType Directory | Out-Null 
    }
    
    # Descargar Tomcat
    Write-Host "Descargando Tomcat $tomcatVersion desde $downloadUrl..."
    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipFile
    
    if (!(Test-Path $zipFile)) {
        Write-Host "Error: No se pudo descargar el archivo ZIP."
        return
    }
    
    # Extraer archivos
    Write-Host "Extrayendo archivos..."
    Expand-Archive -Path $zipFile -DestinationPath "C:\Tomcat" -Force
    
    # Verificar que server.xml exista
    if (!(Test-Path "$installPath\conf\server.xml")) {
        Write-Host "Error: El archivo server.xml no se encontró en la ruta esperada."
        return
    }
    
    # Configurar el puerto en server.xml
    $serverXmlPath = "$installPath\conf\server.xml"
    (Get-Content $serverXmlPath) -replace 'port="8080"', "port=`"$port`"" | Set-Content $serverXmlPath
    
    # Instalar el servicio usando service.bat
    Write-Host "Instalando el servicio $serviceName..."
    cd "$installPath\bin"
    .\service.bat install $serviceName
    
    # Verificar que el servicio se haya creado correctamente
    if (!(Get-Service -Name $serviceName -ErrorAction SilentlyContinue)) {
        Write-Host "Error: No se pudo crear el servicio $serviceName."
        return
    }
    
    # Iniciar el servicio
    Write-Host "Iniciando servicio $serviceName..."
    Start-Service -Name $serviceName
    Write-Host "Tomcat $tomcatVersion ha sido instalado y configurado en el puerto $port."
}


function Install-Nginx {
    param (
        [string]$nginxDescargas = "https://nginx.org/en/download.html"
    )

    # Obtener la página de descargas de Nginx
    $paginaNginx = (Invoke-WebRequest -Uri $nginxDescargas -UseBasicParsing).Content

    # Expresión regular para encontrar versiones de Nginx
    $versionRegex = 'nginx-(\d+\.\d+\.\d+)\.zip'

    # Encontrar todas las versiones en la página
    $versiones = [regex]::Matches($paginaNginx, $versionRegex) | ForEach-Object { $_.Groups[1].Value }

    # Asignar versiones LTS y de desarrollo
    $versionLTSNginx = $versiones[6]  
    $versionDevNginx = $versiones[0]  

    # Menú de selección de versión
    echo "Instalador de Nginx"
    echo "1. Versión LTS $versionLTSNginx"
    echo "2. Versión de desarrollo $versionDevNginx"
    echo "3. Salir"
    $opcNginx = Read-Host "Selecciona una versión"

    switch ($opcNginx) {
        "1" {
            $port = Get-ValidPort
            Install-NginxVersion -version $versionLTSNginx -port $port
        }
        "2" {
            $port = Get-ValidPort
            Install-NginxVersion -version $versionDevNginx -port $port
        }
        "3" {
           return
        }
        default {
            echo "Seleccione una opción válida..."
        }
    }
}

function Install-NginxVersion {
    param (
        [string]$version,
        [int]$port
    )

    try {
        # Detener cualquier instancia de Nginx en ejecución
        Stop-Process -Name nginx -ErrorAction SilentlyContinue

        # Crear carpeta C:\nginx si no existe
        if (-not (Test-Path "C:\nginx")) {
            New-Item -ItemType Directory -Path "C:\nginx"
        }

        # Descargar la versión seleccionada de Nginx
        echo "Instalando versión $version"
        $downloadUrl = "https://nginx.org/download/nginx-$version.zip"
        $zipFile = "C:\nginx\nginx-$version.zip"
            if ($downloadMethod -eq "1") {
        # Descargar desde la web oficial
        if ($tomcatVersion -like "10.*") {
            $downloadUrl = "https://dlcdn.apache.org/tomcat/tomcat-10/v$tomcatVersion/bin/apache-tomcat-$tomcatVersion-windows-x64.zip"
        } elseif ($tomcatVersion -like "11.*") {
            $downloadUrl = "https://dlcdn.apache.org/tomcat/tomcat-11/v$tomcatVersion/bin/apache-tomcat-$tomcatVersion-windows-x64.zip"
        } else {
            Write-Host "Error: Versión de Tomcat no válida."
            return
        }

        Write-Host "Descargando Tomcat $tomcatVersion desde la web oficial..."
        Invoke-WebRequest -Uri $downloadUrl -OutFile $zipFile
    } elseif ($downloadMethod -eq "2") {
        # Descargar desde el servidor FTP
        Write-Host "Hola profe"
    } else {
        Write-Host "Opción no válida. Saliendo..."
        return
    }

        # Extraer el archivo ZIP
        Expand-Archive -Path $zipFile -DestinationPath "C:\nginx" -Force

        # Cambiar al directorio de Nginx
        $nginxDir = "C:\nginx\nginx-$version"
        cd $nginxDir

        # Configurar el puerto en nginx.conf
        $nginxConfigPath = "$nginxDir\conf\nginx.conf"
        (Get-Content $nginxConfigPath) -replace "listen\s+[0-9]{1,5}", "listen       $port" | Set-Content $nginxConfigPath

        # Verificar el cambio en nginx.conf
        Select-String -Path $nginxConfigPath -Pattern "listen\s+[0-9]{1,5}"

        # Iniciar Nginx
        Start-Process "$nginxDir\nginx.exe"

        # Verificar que Nginx esté en ejecución
        Get-Process | Where-Object { $_.ProcessName -like "*nginx*" }

        echo "Se instaló la versión $version de Nginx en C:\nginx y está corriendo en el puerto $port"
    }
    catch {
        echo "Error: $($Error[0].ToString())"
    }
}

function Install-IIS {
    # Verificar si IIS está instalado
    $iisFeature = Get-WindowsFeature -Name Web-Server
    if ($iisFeature.Installed -eq $false) {
        Write-Host "IIS no está instalado. Instalando..."
        Install-WindowsFeature -Name Web-Server -IncludeManagementTools -NoProgress
    } else {
        Write-Host "IIS ya está instalado."
    }

    # Obtener un puerto válido
    $port = Get-ValidPort

    # Validar que el puerto sea válido antes de continuar
    if ($port -lt 1 -or $port -gt 65535) {
        Write-Host "Error: El puerto $port no es válido. Debe estar entre 1 y 65535."
        return
    }

    # Iniciar el servicio IIS si no está corriendo
    if ((Get-Service -Name W3SVC).Status -ne "Running") {
        Write-Host "Iniciando el servicio IIS..."
        Start-Service -Name W3SVC
    }

    # Importar módulo de administración web
    Import-Module WebAdministration

    # Verificar si el sitio predeterminado existe
    $defaultSite = Get-WebSite -Name "Default Web Site" -ErrorAction SilentlyContinue
    if ($defaultSite) {
        Write-Host "El sitio 'Default Web Site' ya existe. Configurando..."
        Stop-WebSite -Name "Default Web Site"

        # Verificar si hay un binding en el puerto 80 antes de eliminarlo
        $binding80 = Get-WebBinding -Name "Default Web Site" | Where-Object { $_.bindingInformation -eq "*:80:" }
        if ($binding80) {
            Remove-WebBinding -Name "Default Web Site" -BindingInformation "*:80:"
        }

        # Verificar si el binding en el nuevo puerto ya existe antes de agregarlo
        $existingBinding = Get-WebBinding -Name "Default Web Site" | Where-Object { $_.bindingInformation -match "\*:$($port):" }
        if (-not $existingBinding) {
            New-WebBinding -Name "Default Web Site" -Protocol http -Port $port
        } else {
            Write-Host "El sitio ya tiene un binding en el puerto $port."
        }

        Start-WebSite -Name "Default Web Site"
    } else {
        Write-Host "No se encontró 'Default Web Site'. Creándolo..."
        New-WebSite -Name "Default Web Site" -Port $port -PhysicalPath "C:\inetpub\wwwroot"
    }

    # Verificar si el puerto está escuchando
    Write-Host "Verificando si el puerto $port está escuchando..."
    try {
        $portListening = Test-NetConnection -ComputerName localhost -Port $port -ErrorAction Stop
        if ($portListening.TcpTestSucceeded) {
            Write-Host "IIS está corriendo correctamente en http://localhost:$port"
        } else {
            Write-Host "Error: El puerto $port no está escuchando. Revisa la configuración de IIS."
        }
    } catch {
        Write-Host "Error: No se pudo verificar el puerto $port. Asegúrate de que sea un puerto válido."
    }
}