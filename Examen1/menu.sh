#!/bin/bash
#
# Función 1: Mostrar CPU y RAM
function cpuram() {
    clear
    # Extrae el nombre del modelo de CPU del archivo /proc/cpuinfo
    # grep filtra la línea, head -1 se queda con la primera (por si hay varios cores)
    echo Processor $(cat /proc/cpuinfo | grep "model name" | head -1)

    # Extrae la memoria total. 'awk' imprime la segunda columna ($2) que es el número.
    echo Memoria: $(cat /proc/meminfo | grep -i memtotal | awk '{print $2}') KB

    # Pausa para que el usuario pueda leer
    echo Pulsa Enter para continuar
    read nada
}

# Función 2: Espacio en disco de los directorios raíz
function espacioraiz() {
    clear
    # Bucle 'for': Ejecuta el comando 'ls /' para listar carpetas en la raíz
    # NOTA: En el PDF ponía 'Is/' (error de escaneo), lo correcto es 'ls /'
    for directorio in $(ls /)
    do
        # 'test -d' comprueba si es un directorio.
        # && significa "si es directorio, entonces ejecuta du -sh"
        # 2>/dev/null oculta errores de permisos (stderr)
        test -d /$directorio && du -sh /$directorio 2>/dev/null
    done
    echo Pulsa Enter para continuar
    read nada
}

# Función 3: Cambiar prioridad de procesos (renice)
function prioridad() {
    clear
    # renice cambia la prioridad. -n -5 aumenta la prioridad (valores negativos son más prioritarios)
    # -u alumno aplica esto a todos los procesos del usuario 'alumno'
    renice -n -5 -u alumno
    echo Pulsa Enter para continuar
    read nada
}

# Función 4: Verificar e instalar Nginx
function nginxinstalado() {
    clear
    # dpkg -l lista paquetes instalados. grep busca 'nginx'.
    # &>/dev/null silencia la salida (solo nos importa si lo encuentra o no)
    dpkg -l | grep nginx &>/dev/null

    # $? guarda el resultado del último comando (0 = éxito/encontrado, otro = fallo)
    case $? in
        0) echo El servidor nginx esta instalado ;;
        *) echo Nginx no esta instalado, lo instalamos; apt-get -y install nginx ;;
    esac
    echo Pulsa Enter para continuar
    read nada
}

# Función 5: Verificar si Nginx corre
function nginxactivo() {
    clear
    # netstat busca conexiones de red. -tlnp (tcp, listening, numeric, process name)
    netstat -tlnp | grep nginx &>/dev/null
    case $? in
        0) echo El servidor nginx esta activo ;;
        *) echo Nginx no está activo, lo arrancamos; service nginx start;;
    esac
    echo Pulsa Enter para continuar
    read nada
}

# Función 6: Programar tarea con 'at'
function workers() {
    # Crea un script temporal con sed para cambiar la config de 4 workers a 10
    echo "sed -i 's/worker_processes 4/worker_processes 10/g' /etc/nginx/nginx.conf" > /tmp/atjobs.txt
    # Añade el reinicio del servicio al script temporal
    echo "service nginx restart" >> /tmp/atjobs.txt

    # Programa la tarea con 'at'.
    # El formato de tiempo 12050230 es MMDDhhmm (Dic 05, 02:30)
    at -t 12050230 -f /tmp/atjobs.txt

    # Muestra la cola de trabajos programados
    atq
    echo Pulsa Enter para continuar
    read nada
}

# Función 7: Monitor de procesos en tiempo real
function procesos() {
    clear
    # Bucle infinito interno para refrescar la pantalla cada 3 segundos
    while true
    do
        clear
        echo Procesos nginx
        echo ============
        # Muestra procesos del usuario www-data (nginx), ordenados por RAM (rss)
        ps -U "www-data" -o uid,pid,cmd,rss --sort -rss

        echo Procesos de alumno que mas memoria consumen
        echo ===
        # Muestra top 6 procesos de 'alumno' ordenados por memoria
        ps -U alumno -o uid,pid,cmd,rss --sort=-rss | head -6

        sleep 3 # Espera 3 segundos antes de volver a ejecutar
    done
    # Nota: Este bucle no tiene salida fácil (ctrl+c para salir)
}
while true
do
    clear
    # Imprime el menú estético
    echo "==="
    echo "1) Muestra marca y modelo del microprocesador y tamaño de memoria RAM"
    echo "2) Muestra ocupación de todos los directorios de /"
    echo "3) Subir ligeramente la prioridad a todos los procesos del usuario alumno"
    echo "4) Comprobar si está instalado el servidor web nginx y si no instalarlo"
    echo "5) Comprobar si el servidor web nginx está arrancando y respondiendo"
    echo "6) Programar la reconfiguración del servidor nginx"
    echo "7) Mostrar monitor de procesos (Nginx y Alumno)"
    echo "8) Salir"
    echo "======"

    echo "Introduce una opción:"
    read opcion

    # Selector de opciones (Switch)
    case $opcion in
        1) cpuram;;          # Llama a la función cpuram
        2) espacioraiz;;     # Llama a espacioraiz
        3) prioridad;;       # Llama a prioridad
        4) nginxinstalado;;  # Llama a nginxinstalado
        5) nginxactivo;;     # Llama a nginxactivo
        6) workers;;         # Llama a workers
        7) procesos;;        # Llama a procesos
        8) echo "Finalizando programa"; break;; # 'break' rompe el while y sale
        *) echo "Opción no válida"; read nada;; # Opción por defecto (error)
    esac
done
