#!/bin/bash
# Nombre: recup_22_23.sh
# Descripción: Herramientas y Submenú Varios

# --- FUNCIONES ---

function schedule_stop_apache() {
    # Domingos de febrero a las 22:30
    echo "Programando apagado apache2..."
    local line="30 22 * 2 0 systemctl stop apache2"
    # Intenta añadir al cron de root o al sistema
    if [ -d "/var/spool/cron/crontabs" ]; then
        echo "$line" >> /var/spool/cron/crontabs/root 2>/dev/null
    else
        echo "$line" >> /etc/crontab
    fi
    echo "Programado correctamente."
}

function list_top_mem_processes() {
    echo "Top 5 procesos por memoria:"
    ps -eo pid,comm,rss --sort=-rss | head -n 6
}

function show_hardware() {
    echo "--- HARDWARE ---"
    echo "CPUs lógicas: $(nproc)"
    echo "Discos y particiones:"
    lsblk | grep "disk\|part" | wc -l
    echo "Memoria Total y Tipo:"
    if [ -x "$(command -v dmidecode)" ]; then
        dmidecode -t memory | grep -E "Size:|Type:" | grep -v "No Module"
    else
        echo "dmidecode no disponible. Info básica:"
        free -h | grep Mem
    fi
}

# --- FUNCIONES SUBMENÚ VARIOS ---

function create_user_auto() {
    # Crear usuario, grupo staff, pass fija
    read -p "Nombre nuevo usuario: " new_u
    if id "$new_u" &>/dev/null; then
        echo "Error: El usuario ya existe."
    else
        useradd -m -G staff "$new_u"
        echo "$new_u:S3cur3&&" | chpasswd
        echo "Usuario creado correctamente."
    fi
}

function consult_user_info() {
    # UID, accesos, grupos, prioridad
    read -p "UID a consultar: " q_uid
    local q_user=$(awk -F: -v uid="$q_uid" '$3 == uid {print $1}' /etc/passwd)

    if [ -z "$q_user" ]; then
        echo "Error: UID no encontrado."
    else
        echo "Usuario: $q_user"
        echo "Accesos: $(last "$q_user" | wc -l)"
        echo "Grupos: $(id -Gn "$q_user")"
        echo "Subiendo prioridad al máximo..."
        pgrep -u "$q_user" | xargs -r renice -n -20
    fi
}

function submenu_varios() {
    while true; do
        clear
        echo "VARIOS"
        echo "1. CREAR"
        echo "2. CONSULTAR"
        echo "3. VOLVER"
        read -p "Opción: " sub_op

        case $sub_op in
            1) create_user_auto ; read -p "Enter..." ;;
            2) consult_user_info ; read -p "Enter..." ;;
            3) break ;;
            *) echo "Opción inválida." ; sleep 1 ;;
        esac
    done
}

# --- MENÚ PRINCIPAL ---

while true; do
    clear
    echo "HERRAMIENTAS"
    echo "***********************"
    echo "[T]ERMINAR"
    echo "[L]ISTAR"
    echo "[H]ARDWARE"
    echo "[V]ARIOS"
    echo "[S]ALIR"
    read -p "Elige una opción: " op

    op=$(echo "$op" | tr '[:lower:]' '[:upper:]')

    case $op in
        T) schedule_stop_apache ; read -p "Enter..." ;;
        L) list_top_mem_processes ; read -p "Enter..." ;;
        H) show_hardware ; read -p "Enter..." ;;
        V) submenu_varios ;;
        S) exit 0 ;;
        *) echo "Opción no válida." ; sleep 1 ;;
    esac
done
