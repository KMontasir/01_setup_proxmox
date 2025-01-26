#!/bin/bash

# Variables utilisateurs
declare -A PROXMOX_USERS=( 
    ["user1"]="pveadmin-user1@pve" 
    ["user2"]="pveadmin-user2@pve"
    ["user3"]="pveadmin-user3@pve"
    ["user4"]="pveadmin-user4@pve"
)
PROXMOX_PASSWORD=""
PVE_PASSWORD=""

# Variables fichiers ISO
OPNSENSE_ISO=""
DEBIAN_ISO=""

# Variables Stockage
declare -A STORAGE_CONFIGS=(
    ["local-lvm-template"]="/dev/sdb"
    ["local-lvm-vm"]="/dev/sdc"
)

# Variables Disque pour les VMs
declare -A DISK_CONFIGS=(
    ["OpnsenseTemplate"]="16G"
    ["WebServerTemplate"]="16G"
)

# Variables réseau
CONFIG_FILE="/etc/network/interfaces"
HOSTS_FILE="/etc/hosts"
BOND_INTERFACES="eno1 eno2"         # Interfaces physiques pour le bond0 (WAN)
LAN_INTERFACE="eno3"              # Interface utilisée pour les VLANs 5, 10, 20
ADMIN_INTERFACE="eno4"              # Interface dédiée à vmbr4

WAN_IP="192.168.1.10"
WAN_NETMASK="255.255.255.0"
WAN_GATEWAY="192.168.1.1"
WAN_HOSTNAME="proxmox-wan"
WAN_DOMAIN="localdomain"

LAN_IP="192.168.100.10"
LAN_NETMASK="255.255.255.0"
LAN_HOSTNAME="proxmox-lan"
