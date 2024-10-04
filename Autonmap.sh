#!/bin/bash

# Definición de colores
RED='\033[0;31m'    
GREEN='\033[0;32m'  
YELLOW='\033[0;33m' 
CYAN='\033[0;36m'   
RESET='\033[0m'     

function ctrl_c(){
  echo -e "\n\n${RED}[!] Abortando escaneo...${RESET}\n"
}

trap ctrl_c INT

if [ $(id -u) -ne 0 ]; then
  echo -e "${RED}[!] Por favor, ejecutar el programa como root...${RESET}"
  exit 1
elif [ "$#" -eq 0 ]; then
  echo -e "${YELLOW}[*] Modo de uso: ./Autonmap <IP>${RESET}"
  exit 1
fi

if [[ "$1" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
  IP="$1"
  echo -e "${CYAN} [+] Dirección IP: $1${RESET}"
else
  echo -e "${RED}[!] IP $1 no válida!${RESET}"
  exit 1
fi  

# Escaneando puertos abiertos
nmap -p- --open -sS --min-rate 5000 -n -vvv -Pn $IP -oG nmapA.tmp &>/dev/null
Puertos=$(cat nmapA.tmp | grep -oP '\d{1,5}/open' | tr '/' ' ' | awk 'NF{print $1}' | xargs | tr ' ' ', ')

if [ -n "$Puertos" ]; then
  echo -e "${CYAN} [+] Puertos abiertos: $Puertos.${RESET}\n\n${GREEN}[+] ${RESET}${YELLOW}Aplicando scripts básicos, espere...${RESET}"
else
  echo -e "${RED}[!] No se encontró ningún puerto!${RESET}"
  rm nmapA.tmp
  exit 1
fi
rm nmapA.tmp

# Aplicando scripts basicos a puertos abiertos. 
nmap -p$Puertos -sCV $IP -oN InfoNmap &>/dev/null
sed -i '1,3d' InfoNmap
echo -e "\n${CYAN} [+] Escaneo Avanzado${RESET}\n${RESET}$(cat InfoNmap) \n\n${RED}[!] Consulta al archivo InfoNmap para volver a ver esta información!${RESET}."
echo -e "\n\t[+] Dirección IP: $IP\n\t[+] Puertos escaneados: $Puertos" >> InfoNmap
