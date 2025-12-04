#!/bin/bash

# ==============================================================================
# Nombre: menu_admin.sh
# Descripción: Script de administración de sistemas con menú interactivo.
# Autor: Gemini (Asistente IA)
# Requisitos: Debe ejecutarse como root (sudo) para las opciones 5 y 7.
# ==============================================================================

# Comprobamos si el usuario es root, necesario para ciertas operaciones (opciones 5 y 7)
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta este script como root (sudo ./script.sh)"
  exit 1
fi

# ------------------------------------------------------------------------------
# FUNCIONES DEL MENÚ
# ------------------------------------------------------------------------------

# 1. Comprobar puerto TCP
# Utiliza 'ss' (socket statistics) o 'netstat' para ver puertos en escucha.
function comprobar_puerto() {
    echo "--- Comprobar Puerto TCP ---"
    read -p "Introduce el número de puerto TCP: " puerto

    # -t: tcp, -u: udp (no usado aqui pero comun), -l: listening, -n: numerico
    # Grep busca el puerto especifico precedido de ':' y seguido de espacio o final de linea
    if ss -tln | grep -qE ":$puerto\b"; then
        echo "Resultado: El puerto $puerto está ABIERTO (Listen)."
    else
        echo "Resultado: El puerto $puerto está CERRADO o no está en escucha."
    fi
    read -p "Presiona Enter para continuar..."
}

# 2. Procesos prioritarios
# Muestra los procesos ordenados por prioridad (Nice).
# Menor valor de Nice = Mayor prioridad.
function procesos_prioritarios() {
    echo "--- Top 10 Procesos (Mayor a Menor Prioridad) ---"
    echo "PID: ID Proceso | NI: Nivel de Prioridad (Menor es más prioritario) | CMD: Comando"
    echo "-----------------------------------------------------------------------------------"

    # ps -e: todos los procesos, -o: formato personalizado
    # --sort=ni: Ordena ascendente por nice (-20 es max prioridad, 19 es min)
    # head -n 11: Muestra la cabecera + 10 procesos
    ps -eo pid,ni,comm --sort=ni | head -n 11

    read -p "Presiona Enter para continuar..."
}

# 3. Usuarios sin login
# Busca en /etc/passwd usuarios cuya shell sea nologin o false
function usuarios_sin_login() {
    echo "--- Usuarios sin acceso a Login ---"

    # awk separa por ':' ($7 es la shell, $1 es el usuario)
    # Buscamos patrones como 'nologin' o 'false'
    awk -F: '$7 ~ /(nologin|false)/ { print $1 }' /etc/passwd

    read -p "Presiona Enter para continuar..."
}

# 4. Comprobar Swap
# Calcula si el uso de swap supera el 50%
function comprobar_swap() {
    echo "--- Comprobación de Memoria Swap ---"

    # Extraemos total y usado usando free y awk
    total_swap=$(free | grep "Swap:" | awk '{print $2}')
    used_swap=$(free | grep "Swap:" | awk '{print $3}')

    # Evitar división por cero si no hay swap configurada
    if [ "$total_swap" -eq 0 ]; then
        echo "No hay memoria Swap configurada en este sistema."
    else
        # Calculamos porcentaje (aritmetica entera de bash)
        porcentaje=$(( (used_swap * 100) / total_swap ))

        echo "Uso actual de Swap: $porcentaje%"

        if [ "$porcentaje" -gt 50 ]; then
            echo "ALERTA: El sistema está usando más del 50% de la Swap."
        else
            echo "El uso de Swap es normal (bajo el 50%)."
        fi
    fi
    read -p "Presiona Enter para continuar..."
}

# 5. Quitar servicios
# Lee de /root/servicios.txt, para el servicio y lo deshabilita
function quitar_servicios() {
    echo "--- Parar y Deshabilitar Servicios ---"
    fichero="/root/servicios.txt"

    if [ ! -f "$fichero" ]; then
        echo "Error: No existe el fichero $fichero"
        echo "Por favor créalo primero con un nombre de servicio por línea."
    else
        # Leemos línea por línea
        while IFS= read -r servicio; do
            # Ignorar líneas vacías
            if [ -z "$servicio" ]; then continue; fi

            echo "Procesando servicio: $servicio..."
            systemctl stop "$servicio" 2>/dev/null
            systemctl disable "$servicio" 2>/dev/null

            if [ $? -eq 0 ]; then
                echo " -> $servicio detenido y deshabilitado."
            else
                echo " -> Error gestionando $servicio (¿Quizás no existe?)."
            fi
        done < "$fichero"
    fi
    read -p "Presiona Enter para continuar..."
}

# 6. Está usuario conectado
# Comprueba si un usuario específico tiene una sesión activa
function usuario_conectado() {
    echo "--- Comprobar si usuario está conectado ---"
    read -p "Introduce el nombre de usuario: " usuario

    # 'who' lista los usuarios conectados. Grep busca el nombre exacto al inicio de linea.
    if who | grep -q "^$usuario "; then
        echo "SÍ: El usuario $usuario está conectado al sistema."
    else
        echo "NO: El usuario $usuario NO está conectado actualmente."
    fi
    read -p "Presiona Enter para continuar..."
}

# 7. Listado ficheros/carpetas home
# Recorre los homes y cuenta ficheros y carpetas
function estadisticas_home() {
    echo "--- Estadísticas de Ficheros y Carpetas en /home ---"
    echo "Fecha/Hora: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "----------------------------------------------------"

    # Iteramos sobre los directorios dentro de /home
    for home_dir in /home/*; do
        if [ -d "$home_dir" ]; then
            usuario=$(basename "$home_dir")

            # Contamos ficheros (-type f) y carpetas (-type d)
            # 2>/dev/null oculta errores de permisos si los hubiera
            num_ficheros=$(find "$home_dir" -type f 2>/dev/null | wc -l)
            num_carpetas=$(find "$home_dir" -type d 2>/dev/null | wc -l)

            echo "Usuario: $usuario | Ficheros: $num_ficheros | Carpetas: $num_carpetas"
        fi
    done
    read -p "Presiona Enter para continuar..."
}

# ------------------------------------------------------------------------------
# BUCLE PRINCIPAL (MENÚ)
# ------------------------------------------------------------------------------

while true; do
    clear
    echo "========================================"
    echo "          MENÚ ADMINISTRADOR            "
    echo "========================================"
    echo "1. Comprueba puerto TCP"
    echo "2. Procesos prioritarios"
    echo "3. Usuarios sin login"
    echo "4. Swap"
    echo "5. Quitar servicios (desde /root/servicios.txt)"
    echo "6. Está usuario conectado"
    echo "7. Comprobar ficheros y carpetas usuarios"
    echo "0. Salir"
    echo "========================================"
    read -p "Seleccione una opción: " opcion

    case $opcion in
        1) comprobar_puerto ;;
        2) procesos_prioritarios ;;
        3) usuarios_sin_login ;;
        4) comprobar_swap ;;
        5) quitar_servicios ;;
        6) usuario_conectado ;;
        7) estadisticas_home ;;
        0)
            echo "Saliendo del sistema... ¡Hasta pronto!"
            exit 0
            ;;
        *)
            echo "Opción incorrecta. Intente de nuevo."
            sleep 1
            ;;
    esac
done
