#---------------------------------------------------------------------------------- HTTP 

validar_puerto() {
    local puerto="$1"
    local reserved_ports=(21 22 23 25 53 110 119 123 135 137 138 139 143 161 162 389 443 445 465 587 636 993 995 1433 1521 1723 3306 3389 5900 8443 27017 5432)

    # Verificar si es un número y está en el rango permitido
    if ! [[ "$puerto" =~ ^[0-9]+$ ]] || ((puerto < 1 || puerto > 65535)); then
        echo "Error: El puerto debe ser un número entre 1 y 65535."
        return 1
    fi

    # Verificar si está en la lista de puertos reservados
    for p in "${reserved_ports[@]}"; do
        if [[ "$puerto" -eq "$p" ]]; then
            echo "Error: El puerto $puerto está reservado y no se puede usar."
            return 1
        fi
    done

    # Verificar si el puerto está en uso
    if sudo lsof -i :"$puerto" &>/dev/null; then
        echo "Error: El puerto $puerto ya está en uso. Por favor, elija otro."
        return 1
    fi

    return 0
}

versiones_tomcat() {
    local url_lts="https://tomcat.apache.org/download-10.cgi"
    local url_des="https://tomcat.apache.org/download-11.cgi"

    # Obtener el HTML de las páginas de descarga
    local html_lts=$(curl -s "$url_lts")
    local html_des=$(curl -s "$url_des")

    # Extraer versión de Tomcat 10 (LTS)
    local version_lts=$(echo "$html_lts" | grep -oP 'apache-tomcat-\K[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)

    # Extraer versión de Tomcat 11 (Desarrollo)
    local version_des=$(echo "$html_des" | grep -oP 'apache-tomcat-\K[0-9]+\.[0-9]+\.[0-9]+' | head -n 1)

    # Validar que se hayan obtenido las versiones
    if [[ -z "$version_lts" || -z "$version_des" ]]; then
        echo "Error: No se pudo obtener la versión de Tomcat. Revisa la página de Apache."
        return 1
    fi

    echo "Seleccione la versión de Tomcat:"
    echo "1.- Tomcat 10 (LTS) - Versión: $version_lts"
    echo "2.- Tomcat 11 (Desarrollo) - Versión: $version_des"
    echo "3.- Volver"

    read -p "Seleccione una opción (1-3): " opcion
    case "$opcion" in
        1) tomcat "10" "$version_lts" ;;
        2) tomcat "11" "$version_des" ;;
        3) return ;;
        *) echo "Opción no válida, por favor elija una opción válida..." ;;
    esac
}

tomcat() {
    local tomcatV="$1"
    local version="$2"
    local reserved_ports=(21 22 23 25 53 110 119 123 135 137 138 139 143 161 162 389 443 445 465 587 636 993 995 1433 1521 1723 3306 3389 5900 8443 27017 5432)
    local puerto

    while true; do
        read -p "Ingrese el puerto en el que desea configurar Tomcat: " puerto

        # Validar que el puerto sea un número entero
        if ! [[ "$puerto" =~ ^[0-9]+$ ]]; then
            echo "Error: El puerto debe ser un número entero."
            continue
        fi

        # Validar que esté en el rango válido (1-65535)
        if (( puerto < 1 || puerto > 65535 )); then
            echo "Error: El puerto debe estar entre 1 y 65535."
            continue
        fi

        # Validar que el puerto no esté en la lista de puertos reservados
        if [[ " ${reserved_ports[@]} " =~ " $puerto " ]]; then
            echo "Error: El puerto $puerto está reservado para otro servicio. Elija otro."
            continue
        fi

        # Verificar si el puerto está en uso
        if sudo lsof -i :$puerto &>/dev/null; then
            echo "Error: El puerto $puerto ya está en uso. Por favor, elija otro."
            continue
        fi

        # Si pasa todas las validaciones, salir del bucle
        break
    done

    echo "Tomcat ${tomcatV} versión ${version} está siendo instalado en el puerto ${puerto}..."

    # Verificar si Java está instalado
    if ! command -v java &>/dev/null; then
        echo "Java no está instalado, instalando OpenJDK 17..."
        sudo apt-get update -y &>/dev/null
        sudo apt-get install -y openjdk-17-jdk &>/dev/null
    fi

    # Definir carpeta específica para la versión
    local dir_tomcat="/opt/tomcat${tomcatV}"
    
    # Seleccionar método de descarga
    echo "Seleccione el método de descarga de Tomcat:"
    echo "1) Desde la web oficial"
    echo "2) Desde el servidor FTP"
    read -p "Ingrese el número de la opción deseada: " opcion_descarga

    if [[ "$opcion_descarga" == "1" ]]; then
        # Descargar desde la web oficial
        echo "Descargando Tomcat desde la web oficial..."
        e_descarga="https://dlcdn.apache.org/tomcat/tomcat-${tomcatV}/v${version}/bin/apache-tomcat-${version}.tar.gz"
        wget "$e_descarga" -O "/tmp/apache-tomcat-${version}.tar.gz" &>/dev/null || {
            echo "Error: No se pudo descargar Tomcat desde la web oficial."
            return 1
        }
    elif [[ "$opcion_descarga" == "2" ]]; then
        # Descargar desde el servidor FTP
        echo "Descargando Tomcat desde el servidor FTP..."
        ruta_ftp="/Servidores/Tomcat/${tomcatV}/apache-tomcat-${version}.tar.gz"
        lftp -u hola,1234 192.168.0.20 -e "
            set ssl:verify-certificate no;
            get -c ${ruta_ftp} -o /tmp/apache-tomcat-${version}.tar.gz;
            bye;
        " || {
            echo "Error: No se pudo descargar Tomcat desde el servidor FTP."
            return 1
        }
    else
        echo "Opción no válida. Saliendo..."
        return 1
    fi

    # Extraer Tomcat
    echo "Extrayendo Tomcat..."
    sudo mkdir -p "$dir_tomcat"
    sudo tar -xzf "/tmp/apache-tomcat-${version}.tar.gz" -C "$dir_tomcat" --strip-components=1 &>/dev/null
    rm "/tmp/apache-tomcat-${version}.tar.gz"

    # Configurar los puertos en server.xml
    echo "Configurando Tomcat en el puerto ${puerto}..."
    sudo sed -i "s/port=\"8080\"/port=\"${puerto}\"/" "$dir_tomcat/conf/server.xml"
    sudo sed -i "s/port=\"8005\"/port=\"$((puerto + 1))\"/" "$dir_tomcat/conf/server.xml"  # Puerto de shutdown
    sudo sed -i "s/port=\"8009\"/port=\"$((puerto + 2))\"/" "$dir_tomcat/conf/server.xml"  # Puerto AJP

    # Crear servicio systemd para cada instancia
    local service_name="tomcat${tomcatV}"
    cat <<EOF | sudo tee /etc/systemd/system/${service_name}.service > /dev/null
[Unit]
Description=Apache Tomcat ${tomcatV} Web Application Server
After=network.target

[Service]
Type=forking
Environment="JAVA_HOME=$(readlink -f /usr/bin/java | sed 's|/bin/java||')"
Environment="CATALINA_PID=${dir_tomcat}/temp/tomcat.pid"
Environment="CATALINA_HOME=${dir_tomcat}"
Environment="CATALINA_BASE=${dir_tomcat}"
Environment="JAVA_OPTS=-Djava.security.egd=file:/dev/./urandom"
ExecStart=${dir_tomcat}/bin/catalina.sh start
ExecStop=${dir_tomcat}/bin/catalina.sh stop
User=root
Group=root

[Install]
WantedBy=multi-user.target
EOF

    # Iniciar y habilitar Tomcat
    sudo systemctl daemon-reload
    sudo systemctl enable ${service_name}
    sudo systemctl start ${service_name}
    sudo systemctl restart ${service_name}

    echo "Tomcat ${tomcatV} versión ${version} ha sido instalado y configurado en el puerto ${puerto}."
}

# Función para obtener la versión Mainline de Nginx
obtener_version_nginx_mainline() {
    curl -s https://nginx.org/en/download.html | grep -oP 'nginx-\K[0-9]+\.[0-9]+\.[0-9]+' | sort -V | tail -n1
}

# Función para obtener la versión Stable de Nginx
obtener_version_nginx_stable() {
    ng_page=$(curl -s https://nginx.org/en/download.html)
    version_lts=$(echo "$ng_page" | grep -oP '(?<=Stable version</h4>).*?nginx-\K\d+\.\d+\.\d+' | head -1)
    echo "$version_lts"
}

# Función para seleccionar e instalar NGINX
seleccionar_e_instalar_nginx() {
    echo "Seleccione la versión de Nginx a instalar:"
    echo "1) Mainline (Última versión en desarrollo)"
    echo "2) Stable (Última versión estable)"
    read -rp "Ingrese el número de la opción deseada: " opcion_version

    if [[ "$opcion_version" == "1" ]]; then
        version_nginx=$(obtener_version_nginx_mainline)
        tipo_version="Mainline"
        ruta_instalacion="/usr/local/nginx-mainline"
    elif [[ "$opcion_version" == "2" ]]; then
        version_nginx=$(obtener_version_nginx_stable)
        tipo_version="Stable"
        ruta_instalacion="/usr/local/nginx-stable"
    else
        echo "Opción no válida. Saliendo..."
        return 1
    fi

    while true; do
        read -rp "Ingrese el puerto en el que desea ejecutar Nginx: " puerto
        if validar_puerto "$puerto"; then
            break
        fi
    done

    instalar_nginx "$version_nginx" "$tipo_version" "$puerto" "$ruta_instalacion"
}

instalar_nginx() {
    local version="$1"
    local tipo="$2"
    local puerto="$3"
    local ruta="$4"
    local nombre_archivo_nginx="nginx-${version}.tar.gz"
    local enlace_web="https://nginx.org/download/${nombre_archivo_nginx}"
    local enlace_ftp="/Servidores/Nginx/${tipo}/${nombre_archivo_nginx}"

    echo "Seleccione el método de descarga de NGINX:"
    echo "1) Desde la web oficial"
    echo "2) Desde el servidor FTP"
    read -rp "Ingrese el número de la opción deseada: " opcion_descarga

    if [[ "$opcion_descarga" == "1" ]]; then
        # Descargar desde la web oficial
        echo "Descargando NGINX versión $version ($tipo) desde la web oficial..."
        wget "$enlace_web" -O "/tmp/${nombre_archivo_nginx}" || {
            echo "Error: No se pudo descargar NGINX desde la web oficial."
            return 1
        }
    elif [[ "$opcion_descarga" == "2" ]]; then
        # Descargar desde el servidor FTP
        echo "Descargando NGINX versión $version ($tipo) desde el servidor FTP..."
        lftp -u hola,1234 192.168.0.20 -e "
            set ssl:verify-certificate no;
            get -c ${enlace_ftp} -o /tmp/${nombre_archivo_nginx};
            bye;
        " || {
            echo "Error: No se pudo descargar NGINX desde el servidor FTP."
            return 1
        }
    else
        echo "Opción no válida. Saliendo..."
        return 1
    fi

    echo "Extrayendo archivos..."
    sudo mkdir -p "$ruta"
    sudo tar -xzf "/tmp/${nombre_archivo_nginx}" -C "$ruta" --strip-components=1 || {
        echo "Error: No se pudo extraer NGINX."
        return 1
    }

    cd "$ruta" || {
        echo "Error: No se pudo acceder al directorio de NGINX."
        return 1
    }

    echo "Instalando dependencias necesarias..."
    sudo apt-get update -y
    sudo apt-get install -y build-essential libpcre3 libpcre3-dev zlib1g zlib1g-dev libssl-dev

    echo "Configurando y compilando NGINX..."
    sudo ./configure --prefix="$ruta" --with-http_ssl_module --with-pcre
    sudo make -j$(nproc)
    sudo make install

    echo "Configurando NGINX en el puerto ${puerto}..."
    sudo sed -i "s/listen[[:space:]]*80;/listen ${puerto};/g" "$ruta/conf/nginx.conf"

    echo "Creando directorios de logs si no existen..."
    sudo mkdir -p "$ruta/logs"
    sudo touch "$ruta/logs/error.log" "$ruta/logs/nginx.pid"
    sudo chmod 777 "$ruta/logs/error.log" "$ruta/logs/nginx.pid"

    echo "Creando servicio systemd para NGINX (${tipo})..."
    local servicio_nombre="nginx-${tipo,,}.service"
    sudo bash -c "cat > /etc/systemd/system/${servicio_nombre}" <<EOF
[Unit]
Description=NGINX $tipo
After=network.target

[Service]
Type=forking
PIDFile=$ruta/logs/nginx.pid
ExecStartPre=$ruta/sbin/nginx -t
ExecStart=$ruta/sbin/nginx
ExecReload=/bin/kill -s HUP \$MAINPID
ExecStop=/bin/kill -s TERM \$MAINPID

[Install]
WantedBy=multi-user.target
EOF

    echo "Habilitando y arrancando NGINX ($tipo)..."
    sudo systemctl daemon-reload
    sudo systemctl enable "$servicio_nombre"
    sudo systemctl start "$servicio_nombre"
    sudo systemctl restart "$servicio_nombre"

    echo "NGINX versión $version ($tipo) ha sido instalado y configurado en el puerto ${puerto}."
}
# Función para seleccionar la versión de Apache
seleccionar_e_instalar_apache() {
    while true; do
        echo "Seleccione la versión de Apache a instalar:"
        echo "1) LTS"
        echo "2) Desarrollo"
        read -rp "Ingrese el número de la opción deseada: " opcion_version

        if [[ "$opcion_version" == "1" ]]; then
            version_apache="2.4.63"
            break
        elif [[ "$opcion_version" == "2" ]]; then
            echo "EASTER EGG: Esta no existe profe, haga paro :D"
        else
            echo "Opción no válida. Intente de nuevo."
        fi
    done

    while true; do
        read -rp "Ingrese el puerto en el que desea configurar Apache: " puerto
        if validar_puerto "$puerto"; then
            break
        fi
    done

    instalar_apache "$version_apache" "$puerto"
}

instalar_apache() {
    local version="$1"
    local puerto="$2"

    echo "Instalando Apache HTTP Server ${version} en el puerto ${puerto}..."

    # Instalar dependencias necesarias
    sudo apt update -y &>/dev/null
    sudo apt install -y build-essential libpcre3 libpcre3-dev zlib1g-dev libapr1-dev libaprutil1-dev &>/dev/null

    # Seleccionar método de descarga
    echo "Seleccione el método de descarga de Apache:"
    echo "1) Desde la web oficial"
    echo "2) Desde el servidor FTP"
    read -p "Ingrese el número de la opción deseada: " opcion_descarga

    if [[ "$opcion_descarga" == "1" ]]; then
        # Descargar desde la web oficial
        echo "Descargando Apache desde la web oficial..."
        url="https://dlcdn.apache.org/httpd/httpd-${version}.tar.gz"
        wget "$url" -O "/tmp/httpd-${version}.tar.gz" &>/dev/null || {
            echo "Error: No se pudo descargar Apache desde la web oficial."
            return 1
        }
    elif [[ "$opcion_descarga" == "2" ]]; then
        # Descargar desde el servidor FTP
        echo "Descargando Apache desde el servidor FTP..."
        ruta_ftp="/Servidores/Apache/${version}/httpd-${version}.tar.gz"
        lftp -u hola,1234 192.168.0.20 -e "
            set ssl:verify-certificate no;
            get -c ${ruta_ftp} -o /tmp/httpd-${version}.tar.gz;
            bye;
        " || {
            echo "Error: No se pudo descargar Apache desde el servidor FTP."
            return 1
        }
    else
        echo "Opción no válida. Saliendo..."
        return 1
    fi

    # Extraer y compilar Apache
    echo "Extrayendo y compilando Apache..."
    tar -xzf "/tmp/httpd-${version}.tar.gz" &>/dev/null
    cd "httpd-${version}" || return 1

    ./configure --prefix=/usr/local/apache2 --enable-so --enable-mods-shared=all &>/dev/null
    make -j$(nproc) &>/dev/null
    sudo make install &>/dev/null

    cd .. && rm -rf "httpd-${version}" "/tmp/httpd-${version}.tar.gz"

    # Verificar que la instalación se completó
    if [ ! -f "/usr/local/apache2/conf/httpd.conf" ]; then
        echo "Error: No se encontró el archivo de configuración /usr/local/apache2/conf/httpd.conf"
        return 1
    fi

    # Configurar el puerto
    if grep -q "^Listen " /usr/local/apache2/conf/httpd.conf; then
        sudo sed -i "s/^Listen [0-9]\+/Listen ${puerto}/" /usr/local/apache2/conf/httpd.conf
    else
        echo "Listen ${puerto}" | sudo tee -a /usr/local/apache2/conf/httpd.conf > /dev/null
    fi

    # Crear servicio systemd para Apache
    cat <<EOF | sudo tee /etc/systemd/system/apache.service &>/dev/null
[Unit]
Description=Apache HTTP Server
After=network.target

[Service]
Type=forking
ExecStart=/usr/local/apache2/bin/apachectl start
ExecStop=/usr/local/apache2/bin/apachectl stop
Restart=always
User=root
Group=root

[Install]
WantedBy=multi-user.target
EOF

    # Iniciar y habilitar Apache
    sudo systemctl daemon-reload &>/dev/null
    sudo systemctl enable apache &>/dev/null
    sudo systemctl start apache &>/dev/null
    sudo systemctl restart apache &>/dev/null

    echo "Apache HTTP Server ${version} ha sido instalado y configurado en el puerto ${puerto}."
}