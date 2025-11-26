#!/bin/bash
# Nombre: MenuNombreAlumno.sh
# Descripción: Gestión de Nginx y recursos del sistema

# --- FUNCIONES ---

function pause(){
    read -p "Pulsa Enter para continuar..."
}

function show_hardware_info() {
    # Opción 1
    echo "Modelo CPU:"
    grep -m 1 'model name' /proc/cpuinfo
    echo "RAM Total:"
    free -h | grep "Mem:"
}

function calc_disk_usage() {
    # Opción 2
    echo "Calculando espacio ocupado por directorios en / (tardará un poco)..."
    du -sh /* 2>/dev/null
}

function boost_priority() {
    # Opción 3
    echo "Subiendo prioridad a procesos de alumno..."
    pgrep -u alumno | xargs -r renice -n -5
}

function check_install_nginx() {
    # Opción 4
    if dpkg -l | grep -q nginx; then
        echo "Nginx ya está instalado."
    else
        echo "Instalando Nginx..."
        apt-get update && apt-get install -y nginx
    fi
}

function check_start_nginx() {
    # Opción 5
    if systemctl is-active --quiet nginx && ss -tuln | grep -q ":80 "; then
        echo "Nginx está corriendo correctamente en el puerto 80."
    else
        echo "Arrancando Nginx..."
        systemctl start nginx
    fi
}

function schedule_nginx_reconfig() {
    # Opción 6
    echo "Programando tarea con 'at'..."
    # Se escapa el comando sed para que pase correctamente a at
    echo "sed -i 's/worker_processes .*/worker_processes 10/' /etc/nginx/nginx.conf && systemctl reload nginx" | at 02:30 12/05/2016 2>/dev/null
    echo "Tarea enviada a la cola."
}

function monitor_loop() {
    # Opción 7
    echo "Monitorizando... (Pulsa Ctrl+C para parar)"
    local nginx_user=$(ps -eo user,comm | grep nginx | head -n 1 | awk '{print $1}')

    while true; do
        clear
        echo "=== Monitorización (cada 3s) ==="
        echo "--- Procesos Nginx (Usuario: $nginx_user) ---"
        [ -n "$nginx_user" ] && ps -u "$nginx_user"

        echo ""
        echo "--- Top 5 RAM usuario alumno ---"
        # Mostrar uid, pid, cmd, rss
        ps -u alumno -o uid,pid,cmd,rss --sort=-rss | head -n 6
        sleep 3
    done
}

# --- MENU PRINCIPAL ---

while true; do
    clear
    echo "MENU INFO WEB"
    echo "1. Muestra CPU y RAM"
    echo "2. Espacio ocupado por directorios de /"
    echo "3. Subir prioridad procesos usuario 'alumno'"
    echo "4. Comprobar/Instalar Nginx"
    echo "5. Comprobar/Arrancar Nginx (Puerto 80)"
    echo "6. Programar reconfiguración Nginx"
    echo "7. Monitorizar procesos (bucle 3s)"
    echo "8. Salir"
    read -p "Opción: " op

    case $op in
        1) show_hardware_info ; pause ;;
        2) calc_disk_usage ; pause ;;
        3) boost_priority ; pause ;;
        4) check_install_nginx ; pause ;;
        5) check_start_nginx ; pause ;;
        6) schedule_nginx_reconfig ; pause ;;
        7) monitor_loop ;;
        8) exit 0 ;;
        *) echo "Opción inválida" ; sleep 1 ;;
    esac
done
