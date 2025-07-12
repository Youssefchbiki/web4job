#!/bin/bash

# ────────────────
# Projet : CERTIF CYBER - Scan Web Complet
# Auteur : Youssef Chbiki
# Description : Script pour scanner un site Web vulnérable avec Nikto, WhatWeb, Dirb
# Bonus : Installe automatiquement les outils requis
# ────────────────

# Couleurs pour affichage
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

# Vérifier si root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}[!] Veuillez exécuter ce script en tant que root.${RESET}"
  exit 1
fi

# Vérifier dépendances
install_tools() {
  echo -e "${YELLOW}Installation des outils requis...${RESET}"
  apt update
  apt install -y nikto whatweb dirb gobuster wireshark
  echo -e "${GREEN}Installation terminée.${RESET}"
}

# Vérifier si dossier results existe
mkdir -p results

# Variables
TARGET=""
WORDLIST="/usr/share/wordlists/dirb/common.txt"

# Afficher usage
usage() {
  echo "Usage: $0 -u <URL> [-i]"
  echo "  -u <URL>     URL cible (ex: http://192.168.1.10)"
  echo "  -i           Installer les dépendances"
  exit 1
}

# Parse options
while getopts ":u:i" opt; do
  case ${opt} in
    u )
      TARGET=$OPTARG
      ;;
    i )
      install_tools
      exit 0
      ;;
    \? )
      usage
      ;;
  esac
done

if [ -z "$TARGET" ]; then
  usage
fi

# ────────────────
# 1) Nikto Scan
# ────────────────
echo -e "${GREEN}[+] Lancement du scan Nikto...${RESET}"
nikto -h "$TARGET" -output results/nikto.txt

# ────────────────
# 2) WhatWeb Scan
# ────────────────
echo -e "${GREEN}[+] Lancement du fingerprint WhatWeb...${RESET}"
whatweb "$TARGET" > results/whatweb.txt

# ────────────────
# 3) Dirb Scan
# ────────────────
echo -e "${GREEN}[+] Lancement de Dirb...${RESET}"
dirb "$TARGET" "$WORDLIST" -o results/dirb.txt

# ────────────────
# BONUS : Afficher astuce pour Wireshark
# ────────────────
echo -e "${YELLOW}[!] BONUS : Pense à lancer Wireshark pour capturer le trafic pendant le scan.${RESET}"

# ────────────────
# Résumé
# ────────────────
echo -e "${GREEN}[+] Scan terminé. Résultats enregistrés dans le dossier ./results${RESET}"
