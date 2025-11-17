#!/bin/bash

# Script para crear carpetas con estructura 3-*/Imagenes

echo "Creando estructura de carpetas..."

for i in {3..16}; do
    carpeta="3-${i}/Imagenes"
    echo "Creando: $carpeta"
    mkdir -p "$carpeta"
done

echo "Estructura creada exitosamente"
