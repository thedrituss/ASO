#!/bin/bash
# Nombre: recup_20_21.sh
# Descripción: Menú modular para administración de sistemas (Red, Prioridad, Servicios, Usuarios)

# --- FUNCIONES AUXILIARES ---

function check_root() {
    # Comprueba si el script se ejecuta como root
    if [[ $EUID -ne 0 ]]; then
       echo "Error: Este script debe ejecutarse como root."
       exit 1
    fi
}

function pause() {
    read -p "Pulsa Enter para continuar..."
}

# --- FUNCIONES DEL MENÚ ---

function configure_network() {
    # Opción [N]etwork
    echo "--- Configuración de Red ---"
    systemctl stop NetworkManager
    systemctl disable NetworkManager
    echo "NetworkManager detenido y deshabilitado."

    read -p "Nuevo Hostname: " nuevo_host
    read -p "IP v4 (ej. 192.168.1.50/24): " ip_addr
    read -p "Gateway: " gateway
    read -p "DNS: " dns

    hostnamectl set-hostname "$nuevo_host"
    # Intenta configurar eth0 o enp0s3 según disponibilidad
    ip addr flush dev eth0 2>/dev/null || ip addr flush dev enp0s3
    ip addr add "$ip_addr" dev eth0 2>/dev/null || ip addr add "$ip_addr" dev enp0s3
    ip route add default via "$gateway"
    echo "nameserver $dns" > /etc/resolv.conf

    echo "Red configurada."
}

function set_priority() {
    # Opción [P]rioridad
    echo "Subiendo prioridad de procesos del usuario 'alumno'..."
    pgrep -u alumno | xargs -r renice -n -20
    echo "Prioridad actualizada."
}

function show_services() {
    # Opción [S]ervicios
    echo "--- Servicios Activos y Puertos ---"
    ss -tulpn | awk 'NR>1 {print $0}'
    echo "Nota: Si un servicio activo no aparece aquí, no tiene puertos abiertos."
}

# --- SUBMENÚ USUARIOS ---

function user_process_info() {
    # Submenú opción 1: Procesos
    read -p "Nombre del usuario: " target_user
    if id "$target_user" &>/dev/null; then
        echo "Top 5 procesos por CPU para $target_user:"
        ps -u "$target_user" -o comm,%cpu --sort=-%cpu | head -n 6
    else
        echo "El usuario no existe."
    fi
}

function schedule_clean() {
    # Submenú opción 2: Programar limpieza
    read -p "Usuario para programar borrado: " clean_user
    # Lógica: Ejecutar días 1-7 de enero y verificar si es domingo (día 7 de la semana)
    local comando="test \$(date +\%u) -eq 7 && find / -user $clean_user -type f -delete"

    echo "30 23 1-7 1 * root $comando" >> /etc/crontab
    echo "Tarea programada en /etc/crontab."
}

function users_submenu() {
    # Gestión del submenú
    while true; do
        clear
        echo "    SUBMENÚ USUARIOS"
        echo "    ================"
        echo "    1. Procesos"
        echo "    2. Programar limpieza"
        echo "    3. Volver"
        read -p "    Elige una opción: " subopcion

        case $subopcion in
            1) user_process_info ; pause ;;
            2) schedule_clean ; pause ;;
            3) break ;;
            *) echo "Opción incorrecta." ; sleep 1 ;;
        esac
    done
}

# --- BLOQUE PRINCIPAL ---

check_root

while true; do
    clear
    echo "============================="
    echo "      MENÚ DE OPERADOR"
    echo "============================="
    echo "[N]etwork"
    echo "[P]rioridad"
    echo "[S]ervicios"
    echo "[U]suarios"
    echo "[Q]uit"
    echo "============================="
    read -p "Elige una opción: " opcion

    opcion=$(echo "$opcion" | tr '[:lower:]' '[:upper:]')

    case $opcion in
        N) configure_network ; pause ;;
        P) set_priority ; pause ;;
        S) show_services ; pause ;;
        U) users_submenu ;;
        Q) echo "Saliendo..." ; exit 0 ;;
        *) echo "Opción no válida." ; sleep 1 ;;
    esac
done
