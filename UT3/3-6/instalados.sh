#!/bin/bash
#
# Script que muestra si están instalados una lista de paquetes como parámetros
#

verificar_paquete() {
  local paquete="$1"

  if pacman -Qi "$paquete" &>/dev/null; then
    return 0
  else
    return 1
  fi
}


main() {
  local paquetes=("$@")
  local instalados=()
  local no_instalados=()

  echo "Verificando paquetes instalados en Arch"
  echo "======================================="

  for paquete in "${paquetes[@]}"; do
    printf "%-20s->" "$paquete"
    if verificar_paquete "$paquete"; then
      echo " Instalado."
      instalados+=("$paquete")
    else
      echo " No instalado."
      no_instalados+=("$paquete")
    fi
  done

  echo ""

  local total_instalados=${#instalados[@]}
  local total_no_instalados=${#no_instalados[@]}
  local total_paquetes=$#

  if [ $total_instalados -eq $total_paquetes ]; then
    echo "Están todos los paquetes instalados."
    exit 0
  
  elif [ $total_instalados -eq 0 ]; then
    echo "No hay ningún paquete instalado."
    exit 2

  else 
    echo ""
    if [ $total_instalados -gt 0 ]; then
      echo "Están instalados: $(printf '%s,' "${instalados[@]}" | sed 's/, $//')"
    fi
    if [ $total_no_instalados -gt 0 ]; then
      echo "NO están instalados: $(printf '%s,' "${no_instalados[@]}" | sed 's/, $//')"
    fi

    exit 1
  fi
}

if [ $# -eq 0 ]; then
  echo "Error: Debes proporcionar al menos un paquete"
  exit 1
fi


main "$@"
