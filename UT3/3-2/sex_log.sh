#!/bin/bash
#
# Script para ver que IPs han accedido a webs de sexo en un log, ordenado y sin repetir IPs

PATRON_BUSQUEDA="sex|porn|desnud|naked"

ARCHIVO_LOG="$1"

if [ ! -f "$ARCHIVO_LOG" ]; then
    echo "Error: el archivo '$ARCHIVO_LOG' no existe"
    exit 1
fi

if [ ! -r "$ARCHIVO_LOG" ]; then
    echo "Error: el archivo '$ARCHIVO_LOG' no tiene permisos de lectura"
    exit 1
fi

if [ ! -s "$ARCHIVO_LOG" ]; then
  echo "Error: El archivo '$ARCHIVO_LOG' está vacío"
  exit 1
fi


# Busqueda en el archivo .log
grep -iE "$PATRON_BUSQUEDA" "$ARCHIVO_LOG" | awk '{print $3}' | sort | uniq
