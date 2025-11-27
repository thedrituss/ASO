#!/bin/bash
#
# Script que muestra un menú tipo utilizando funciones
# Administracion de Sistemas Informaticos en Red
#
# Funciones
#
pausa()
{
read nada
"Pulsa INTRO para continuar....."
}

terminar()
{
# programando parar servicios domingos de enero 23:30
echo "systemctl list-units --type=service --state=exited|grep service|"
for i in `cat /tmp/servicios.txt`; do systemctl stop $i; done
# mantando procesos gnome
kill -9 `pgrep gnome`
# cambiando prioridad a procesos que no son de root
renice -n 19 `ps -ef|grep -v root|awk '{print $2}'`



}

listar()
{
echo TAMAÑO    PAQUETE
echo ==========================
dpkg-query -W --showformat='${Installed-Size}\t${Package}\n' | sort -nr |more
pausa
}

hardware()
{
echo MEMORIA
echo ========
cat /proc/meminfo|grep -i memtotal
echo MICROPROCESADOR
echo ===============
cat /proc/cpuinfo |grep -i "model name"|uniq
echo NUMERO VCPUS
echo ========================
cat /proc/cpuinfo |grep -i "model name"|wc -l
echo FILESYSTEMS
echo =================
df -h |grep -v loop
echo EL DISCO ES
echo =================
DISCO=`cat /sys/block/sda/queue/rotational`
case $DISCO in
1) echo Magnético HD ;;
*) echo SSD ;;
esac
pausa
}

varios()
{
SUBMENU=0
while true
do
 clear
 echo VARIOS
 echo ---------------
 echo '1. CREAR'
 echo '2. CONSULTAR'
 echo '3. VOLVER'
 echo " "
 echo 'Introduce una opción:'
 read SUBMENU
 case $SUBMENU in
 1) echo Dime usuario; read USUARIO; cat /etc/passwd|grep $USUARIO || useradd $USUARIO; echo 'Usuario creado'; pausa  ;;
 2) echo Dime usuario
    read USUARIO
    cat /etc/passwd|grep $USUARIO
    if [ $? -eq 0 ]
    then
     echo GRUPOS DEL USUARIO
     echo =================
     id $USUARIO
     echo ESPACIO OCUPADO
     echo ================
     du -sh /home/$USUARIO
     echo FICHEROS MAYORES DE 10M de $USUARIO
     echo ===================================
     find /home/$USUARIO -type f -size 10M
    fi
   pausa
   ;;
 3) return ;;
 esac
done

}

# Programa principal
ENTRADA=0
while true
do
   clear
   echo 'Introduce una opción:'
   echo '====================='
   echo '[t]erminar '
   echo '[l]istar '
   echo '[h]hardware '
   echo '[v]arios'
   echo '[s]alir'
   read ENTRADA
   case $ENTRADA in
   t) terminar ;;
   l) listar; pausa ;;
   h) hardware ;;
   v) varios;pausa ;;
   s) clear; echo 'Fin del programa'; read nada; break ;;
   *) echo 'Error! Opción no válida' ;;
   esac
done
