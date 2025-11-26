#!/bin/bash
# Nombre: practico_23_24.sh
# Descripción: Herramientas varias (Discos, Usuarios, Backups, Hashes...)

# --- FUNCIONES ---

function pause() { read -p "Pulsa Enter para continuar..." ; }

function show_disk_info() {
    echo "Información de discos (GPT/MBR, Particiones):"
    lsblk -o NAME,SIZE,PTTYPE,TYPE
}

function list_users_groups() {
    # Usuarios reales (no sistema)
    echo "Listado de usuarios y sus grupos:"
    awk -F: '$3 >= 1000 && $3 < 65534 {print $1}' /etc/passwd | while read u; do
        echo -n "Usuario: $u -> Grupos: "
        id -Gn "$u"
    done
}

function schedule_backup() {
    # Viernes a las 18:00
    echo "Programando backup /tmp/usuario.tar..."
    local job="0 18 * * 5 tar -cf /tmp/backup_${USER}.tar $HOME"
    (crontab -l 2>/dev/null; echo "$job") | crontab -
    echo "Añadido al crontab."
}

function check_var_hashes() {
    echo "Hashes MD5 ficheros modificados últimos 10 días en /var..."
    find /var -type f -mtime -10 -exec md5sum {} + 2>/dev/null | more
}

function top_ram_processes() {
    # Top 10 procesos
    echo "Top 10 procesos por memoria física:"
    ps -eo uid,comm,rss --sort=-rss | head -n 11
}

function check_net_errors() {
    echo "Errores en interfaces de red:"
    ip -s link
}

function show_user_history() {
    read -p "Usuario para ver historial: " huser
    if id "$huser" &>/dev/null; then
        local hist_file="/home/$huser/.bash_history"
        if [ -f "$hist_file" ]; then
            echo "Últimos 5 comandos de $huser:"
            tail -n 5 "$hist_file"
        else
            echo "No se encuentra el historial o faltan permisos."
        fi
    else
        echo "Usuario no existe."
    fi
}

function create_witness_file() {
    local hora=$(date +%H%M)
    echo "Creando testigo-$hora.txt en homes..."
    for home_dir in /home/*; do
        if [ -d "$home_dir" ]; then
            touch "$home_dir/testigo-$hora.txt"
            echo "Creado en $home_dir"
        fi
    done
}

# --- MENU ---

while true; do
    clear
    echo "MENU ADMIN 23-24"
    echo "1. Discos"
    echo "2. Usuarios/grupos"
    echo "3. Programar backup"
    echo "4. Sacar hash"
    echo "5. Uso RAM"
    echo "6. Errores interfaces"
    echo "7. Historial"
    echo "8. Crear fichero testigo"
    echo "0. Salir"
    read -p "Opción: " op

    case $op in
        1) show_disk_info ; pause ;;
        2) list_users_groups ; pause ;;
        3) schedule_backup ; pause ;;
        4) check_var_hashes ; pause ;;
        5) top_ram_processes ; pause ;;
        6) check_net_errors ; pause ;;
        7) show_user_history ; pause ;;
        8) create_witness_file ; pause ;;
        0) echo "Adiós!" ; exit 0 ;;
        *) echo "Opción no válida." ; sleep 1 ;;
    esac
done
