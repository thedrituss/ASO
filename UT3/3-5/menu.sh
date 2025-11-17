#!/bin/bash
#
# Menú básico
#

echo "===================="
echo "========Menu========"
echo "===================="
echo ""

echo " · Selecciona una opción"
echo " - 1) Comprobar si /etc/hosts se puede escribir"
echo " - 2) Comprimir en .tar ./etc"
echo " - 3) Averiguar espacio ocupado por los subdirectorios de /"
echo " - 4) SALIR"
echo ""
read op
echo ""


case $op in
  1)

    if [ ! -w "/etc/hosts" ]; then
      echo -e "/etc/hosts no se puede escribir"
    fi


    if [ -w "/etc/hosts" ]; then
      echo -e "/etc/hosts SI se puede escribir"
    fi

    ;;
  
  2)
    tar -cf etc.tar .etc/
    
    ;;
  
  3)
    du -h --max-depth=1 / 2>/dev/null | sort -hr

    ;;

  4)
    exit 1

    ;;

esac
