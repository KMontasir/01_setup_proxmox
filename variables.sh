#!/bin/bash

# Variables utilisateurs
declare -A PROXMOX_USERS=( 
    ["user1"]="pveadmin-user1@pve" 
    ["user2"]="pveadmin-user2@pve"
    ["user3"]="pveadmin-user3@pve"
    ["user4"]="pveadmin-user4@pve"
)
PROXMOX_PASSWORD="Azerty/123"
PVE_PASSWORD="Azerty/123"

# Variables fichiers ISO
OPNSENSE_ISO=""
DEBIAN_ISO=""

# Variables Stockage
declare -A STORAGE_CONFIGS=(
    ["local-lvm-vm"]="/dev/sdb"
    ["local-lvm-pve"]="/dev/sdc"
)

# Variables Disque pour les VMs
declare -A DISK_CONFIGS=(
    ["OpnsenseTemplate"]="16G"
    ["WebServerTemplate"]="16G"
)

# Variables réseau
CONFIG_FILE="/etc/network/interfaces"
HOSTS_FILE="/etc/hosts"
BOND_INTERFACES_1="eno1"         # Interfaces physiques 1 pour le bond0 (WAN)
BOND_INTERFACES_2="eno2"         # Interfaces physiques 2 pour le bond0 (WAN)
LAN_INTERFACE="eno3"              # Interface utilisée pour les VLANs 5, 10, 20
ADMIN_INTERFACE="eno4"              # Interface dédiée à vmbr4

WAN_IP="172.16.0.5"
WAN_NETMASK="255.255.255.240"
WAN_GATEWAY="172.16.0.14"
WAN_HOSTNAME="pve-1"
WAN_DOMAIN="sun.com"

LAN_IP="172.16.1.250"
LAN_NETMASK="255.255.255.0"
LAN_HOSTNAME="pve-1"
LAN_DOMAIN="localdomain"
